Foreign Function Interface (FFI) as Digital Image Processing SDK 
----------------------------------------------------------------



This client project has been managed by:
> - [Gilles-Christ **Tchiakpe**](https://github.com/FulbertoDev) as the Dart/Flutter tech specialist and adviser.
> - [Vincent **Whannou de Dravo**](https://github.com/de20ce) as the tech lead and the project manager.




## Projet Description

Let's say you have a software project where a part of the application logic needs to be embedded within the application itself, while another part, due to intensive computations, security concerns, and cost considerations, needs to be deployed on a remote server. Another issue you face is the limitation of libraries regarding what you can do on the frontend. Let me explain: suppose you're working, for example, in Dart, and you want to perform image processing, computer vision, or machine learning. For this specific task, you have unlimited resources in Python or R, high-performance resources in C/C++, Rust, or Golang, framework resources in JS, and challenging resources in Dart, PHP, etc. You've already started your application in Dart, and initially, for the server part, you thought of using gRPC or similar technologies. Now, for the embedded part, what can you do?

Yes, this part is no less challenging than the server part (even if you use Python at the server level for coding speed or efficiency/security reasons, consider Rust or something similar). Ever heard of Dart FFI? For your embedded code, the most obvious solution might be to refer to the documentation of Dart's Foreign Function Interface (FFI).

Here, in this repository, we provide a small demo of how you could do it. We assume that you've already converted your high-performance code into a library (in C/C++, Rust, Golang), and you're familiar with declaring function interfaces exported in Dart. The source codes of the foreign languages are not provided. In addition, we need to build these dynamic libraries for each architecture on Android, Linux, macOS, iOS, and Windows, covering the most popular operating systems. So, all those steps are not provided here. You have to do that by yourself!

This demo demonstrates the use of an SDK (free or paid) that you can use as a developer directly in your Flutter application and offer a service to your application's clients. Isn't that great? So let's dive in!


## Running the app
You can run the application in the 'test' directory. If you are in Visual Studio, navigate to 'test/dip_app_test.dart'. You will see just above the main function two buttons, 'Run' and 'Debug'. Press either of them to see the result. For privacy reasons, we do not show in this example how to test on Android. However, for those curious enough, you can take inspiration from what we have provided to discover it for yourself.

In CLI, you can run from the project's root directory:
```
flutter test
```
Since we are dealing with a Flutter package, `dart test` will not work

You should then get something similar to the following output:
```
00:01 +0: Read image and get dimensions                                        
[INFO] Succeeded to load dynamic library.
[INFO] JPEG Dimensions: Width=18761, Height=2048
00:02 +1: All tests passed!
```