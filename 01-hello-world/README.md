# 01. Hello World

This sample is a basic introduction on how to setup your project to automatically compile it for the platforms you aim to target.

It contains 2 simple modules :
* `logger` : a very basic module that exposes a `log` method.
* `hello_world`: the main module that is instantiated and where the core logic of the application is done.

For now, this simple logic is simply to create an instance of the `HelloWorld` class with a message and print this message using the logger module.

In the `platform` folder you can find the two entry points for the web and native platforms. The basic lifecycle of the app is to create an instance of the `HelloWorld` class, sleep for 2 seconds and then exit.

## Native
On native, you can see that this instantiation is done in the `main` method of the `platform/native/main.cpp` file, it's very simple and a classical way of doing it.

## Web
On web, it's slightly different. Due to the way Emscripten interacts with the Javascript engine, we need to provide a class that will be instantiated by the generated Javascript glue code. That is the purpose of the `EntryPoint` class. It is registered with Emscripten in the `platform/web/entry_point.hpp` file. As you can see, the constructor is the equivalent of the `main` method on native. The main difference is that the sleep is done in the `post.js` file with a call to `setTimeout(...)`.

The purpose of the `pre.js` and `post.js` is to surround the Javascript glue code generated by Emscripten. This is also where you can define your start and stop logic, similarly to what we have done.