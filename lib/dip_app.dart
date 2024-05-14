import 'dart:ffi' as Ffi;
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart' as ffi;
import 'dart:convert' show utf8;
import 'package:path/path.dart' as p;
//import 'package:logging/logging.dart';

import 'biometrics_app_bindings_generated.dart';
import 'package:dip_app/logger.dart';

const String _libName = 'biometrics_app'; // Adjust the library name accordingly

//final Logger _logger = Logger('MyApp');

late Ffi.DynamicLibrary _dylib;
late BiometricsAppBindings _bindings;

class CountingAllocator implements Ffi.Allocator {
  final Ffi.Allocator _wrappedAllocator;
  int _totalAllocations = 0;
  int _nonFreedAllocations = 0;

  CountingAllocator([Ffi.Allocator? allocator])
      : _wrappedAllocator = allocator ?? ffi.calloc;

  int get totalAllocations => _totalAllocations;

  int get nonFreedAllocations => _nonFreedAllocations;

  @override
  Ffi.Pointer<T> allocate<T extends Ffi.NativeType>(int byteCount,
      {int? alignment}) {
    final result =
        _wrappedAllocator.allocate<T>(byteCount, alignment: alignment);
    _totalAllocations++;
    _nonFreedAllocations++;
    return result;
  }

  @override
  void free(Ffi.Pointer<Ffi.NativeType> pointer) {
    _wrappedAllocator.free(pointer);
    _nonFreedAllocations--;
  }
}

String getAndroidArchitecture() {
  final androidCpuAbi = Platform.environment['ro.product.cpu.abi'];
  if (androidCpuAbi != null) {
    if (androidCpuAbi == 'x86') {
      return 'x86';
    } else if (androidCpuAbi == 'x86_64') {
      return 'x86_64';
    } else if (androidCpuAbi.startsWith('arm64')) {
      return 'arm64-v8a';
    } else if (androidCpuAbi.startsWith('armeabi')) {
      return 'armeabi-v7a';
    }
  }
  throw UnsupportedError('Unsupported Android architecture: $androidCpuAbi');
}

bool _loadLibrary() {
  try {
    _dylib = () {
      late String architecture;

      // Determine the target architecture
      if (Platform.isAndroid) {
        architecture = getAndroidArchitecture();
      } else if (Platform.isLinux) {
        architecture = 'linux';
        // You can further determine 32-bit or 64-bit
      } else if (Platform.isMacOS) {
        // Handle macOS architecture here
        // You can further determine 32-bit or 64-bit
      } else if (Platform.isIOS) {
        // Handle IOS architecture here
        // You can further determine 32-bit or 64-bit
      } else if (Platform.isWindows) {
        // Handle Windows architecture here
        // You can further determine 32-bit or 64-bit
        architecture = 'windows';
        // Add from here...
        //if (Platform.environment.containsKey('FLUTTER_TEST')) {
        //return Ffi.DynamicLibrary.open(p.canonicalize(
        //   p.join(r'build\windows\runner\Debug', '$_libName.dll')));
        //}
        // ...to here.
      } else {
        throw UnsupportedError(
            'Unsupported platform: ${Platform.operatingSystem}');
      }

      // Construct the path to the .so file
      var soPath = 'lib/$architecture/lib$_libName.so';

      // If running in a Flutter test environment, adjust the path
      //if (Platform.environment.containsKey('FLUTTER_TEST')) {
      //soPath = 'build/$architecture/x64/debug/bundle/lib/$_libName.so';
      //}

      // Open the DynamicLibrary
      return Ffi.DynamicLibrary.open(soPath);
    }();

    // Initialize the bindings
    _bindings = BiometricsAppBindings(_dylib);

    Logger.info('Succeeded to load dynamic library.');
    return true;
  } catch (e) {
    Logger.error('Failed to load dynamic library: $e');
    return false;
  }
}

class Biometrics {
  Biometrics() {
    // Load the dynamic library during class initialization
    if (!_loadLibrary()) {
      throw Exception('Failed to load dynamic library.');
    }
    // Initialize your context here if necessary
    // For example:
    ctx = _bindings.initialize();
  }

  late int ctx; // Adjust the context type accordingly

  Ffi.Pointer<Ffi.Uint8> readImageToBinary(String filename) {
    // Convert filename to UTF-8 bytes
    var utf8Bytes = utf8.encode(filename);

    // Create a CountingAllocator instance to track memory allocations
    var countingAllocator = CountingAllocator();

    // Allocate memory for the native UTF-8 representation using the counting allocator
    var nativeUtf8 =
        countingAllocator.allocate<Ffi.Uint8>(utf8Bytes.length + 1);

    // Populate the allocated memory with UTF-8 bytes
    for (var i = 0; i < utf8Bytes.length; ++i) {
      nativeUtf8[i] = utf8Bytes[i];
    }
    nativeUtf8[utf8Bytes.length] = 0; // Null terminator

    Logger.info('image file representation: ${utf8.decode(utf8Bytes)}');

    var imageData =
        _bindings.readImageToBinary(ctx, nativeUtf8.cast<Ffi.Char>());
    ffi.malloc.free(nativeUtf8); // Free allocated memory

    if (imageData.address == 0) {
      Logger.info(
          'Failed to read image file: $filename'); // Log the error message
      throw Exception('Failed to read image file.');
    }
    Logger.info('After logging message'); // Debug print after logging message
    return imageData;
  }

  List<int> getPngDimensions(Ffi.Pointer<Ffi.Uint8> imageData) {
    // Initialize variables to store width and height
    final widthPtr = ffi.calloc<Ffi.Int>();
    final heightPtr = ffi.calloc<Ffi.Int>();
    _bindings.getPngDimensions(
      ctx,
      imageData,
      widthPtr,
      heightPtr,
    );

    // Retrieve width and height from pointers
    int width = widthPtr.value;
    int height = heightPtr.value;

    // Free allocated memory
    ffi.malloc.free(widthPtr);
    ffi.malloc.free(heightPtr);

    return [width, height];
  }

  List<int> getBmpDimensions(Ffi.Pointer<Ffi.Uint8> imageData) {
    // Initialize variables to store width and height
    final widthPtr = ffi.calloc<Ffi.Int32>();
    final heightPtr = ffi.calloc<Ffi.Int32>();
    _bindings.getBmpDimensions(ctx, imageData, widthPtr as Ffi.Pointer<Ffi.Int>,
        heightPtr as Ffi.Pointer<Ffi.Int>);

    int width = widthPtr.value;
    int height = heightPtr.value;

    // Log dimensions after method call
    Logger.info('BMP Dimensions: Width=$width, Height=$height');

    // Free allocated memory
    ffi.malloc.free(widthPtr);
    ffi.malloc.free(heightPtr);

    return [width, height];
  }

  List<int> getJpegDimensions(Ffi.Pointer<Ffi.Uint8> imageData) {
    // Initialize variables to store width and height
    final widthPtr = ffi.calloc<Ffi.Int32>();
    final heightPtr = ffi.calloc<Ffi.Int32>();
    _bindings.getJpegDimensions(ctx, imageData,
        widthPtr as Ffi.Pointer<Ffi.Int>, heightPtr as Ffi.Pointer<Ffi.Int>);

    int width = widthPtr.value;
    int height = heightPtr.value;

    // Log dimensions after method call
    Logger.info('JPEG Dimensions: Width=$width, Height=$height');

    // Free allocated memory
    ffi.malloc.free(widthPtr);
    ffi.malloc.free(heightPtr);

    return [width, height];
  }

  Ffi.Pointer<Ffi.Uint8> readImage(
      Ffi.Pointer<Ffi.Uint8> imageData, int width, int height, int channels) {
    final result = _bindings.readImage(ctx, imageData, width, height, channels);
    Logger.info('Successfully read image.');
    return result;
  }

  Ffi.Pointer<Ffi.Uint8> writeImage(
      Ffi.Pointer<Ffi.Uint8> imageData, int width, int height, int channels) {
    final result =
        _bindings.writeImage(ctx, imageData, width, height, channels);
    Logger.info('Successfully wrote image.');
    return result;
  }
}
