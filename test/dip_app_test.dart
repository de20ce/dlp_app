import 'dart:ffi';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' show TestWidgetsFlutterBinding;
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:ffi/ffi.dart' as Ffi;
import 'package:dip_app/dip_app.dart';

void main() {
  setUpAll(() {
    // Initialize bindings before running the tests
    WidgetsFlutterBinding.ensureInitialized();
    // TestWidgetsFlutterBinding.ensureInitialized();
  });
  late String imagePath;
  late Pointer<Uint8> imageData;
  late Biometrics biometrics;
  late String output;
  late int width;
  late int height;

  setUp(() {
    // For some obfuscated obscure reason, Flutter does not find this path
    // if you have any hint about how to call this correctly and simply in my flutter app
    // feel free to contact me here(Vincent)
    // This might also be critical code not to be shared...
    // Gilles-Christ suggests grabbing the image from the internet!
    imagePath = 'assets/images/alex.png';
    biometrics = Biometrics();
    output = '';
  });

  test('Read image and get dimensions', () async {
    try {
      // final byteData = await rootBundle.load(imagePath);
      String url =
          "https://fastly.picsum.photos/id/9/250/250.jpg?hmac=tqDH5wEWHDN76mBIWEPzg1in6egMl49qZeguSaH9_VI";
      var response = await http.readBytes(Uri(
          scheme: 'https',
          host: 'fastly.picsum.photos',
          path: 'id/9/250/250.jpg',
          queryParameters: {
            'hmac': 'tqDH5wEWHDN76mBIWEPzg1in6egMl49qZeguSaH9_VI'
          }));
      var bytes = response;
      //print(bytes);

      // final bytes = byteData.buffer.asUint8List();
      var blob = Ffi.calloc<Uint8>(bytes.length);
      var blobBytes = blob.asTypedList(bytes.length);
      blobBytes.setAll(0, bytes);
      imageData = blob;

      // Here the use of the Foreign Function getJpegDimensions
      final dimensions = biometrics.getJpegDimensions(imageData);
      width = dimensions[0];
      height = dimensions[1];
      output = 'JPEG Dimensions width: $width height: $height';
    } catch (e) {
      output = 'Failed to read image file: $e';
    }
    //print(output);

    // Verify output
    expect(output, startsWith('JPEG Dimensions width: '));
  });
}
