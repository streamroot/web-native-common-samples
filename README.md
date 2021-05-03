# Web/Native common samples

This repository contains various samples that could help you in the process of developing a cross-platform application targeting Native and Web platforms (with the use of Emscripten). Each sample has its own readme where you can find information on what it presents/is about.

## Prerequisites

In order to build the various samples in this repository, you will need :

* [Emscripten](https://emscripten.org/docs/getting_started/downloads.html)
* CMake
* A C++ compiler (GCC/Clang/MSVC)

## Compiling samples
Each sample is in its own folder and there is only one CMake file to setup the project.

### Native

**For Linux/MacOS**  
To compile for Linux and MacOS, simply setup the CMake project with `cmake -Bcmake-build/native/linux/(release|debug) -DCMAKE_BUILD_TYPE=(Release|Debug) .`.

Then you can compile a specific target using `cmake --build cmake-build/native/linux/(release|debug) --target <target_name> --parallel` and run it with `./cmake-build/native/linux/(release|debug)/bin/<target_name>`.

For example, if you want to run the `release` version of the `01-hello-world` sample, you will execute :
* `cmake -Bcmake-build/native/linux/release -DCMAKE_BUILD_TYPE=Release .`
* `cmake --build cmake-build/native/linux/release --target 01-hello-world --parallel`
* `./cmake-build/native/linux/release/bin/01-hello-world`

**For Windows**  
To compile for Windows, the procedure is similar but slightly different. First to setup the project use `cmake -A Win32 -Bcmake-build/native/win32 .`. (You can also swap `Win32` for `x64` if you target 64 bits platforms).

Then you can compile a specific target using `cmake --build cmake-build\native\win32 --config (Release|Debug) --target <target_name> --parallel` and run it with `cmake-build\native\win32\bin\(Release|Debug)\<target_name>.exe`.

For example, if you want to run the `release` version of the `01-hello-world` sample, you will execute :
* `cmake -A Win32 -Bcmake-build/native/win32 .`
* `cmake --build cmake-build/native/win32 --config Release --target 01-hello-world --parallel`
* `cmake-build\native\win32\bin\Release\01-hello-world.exe`

### Web
On web, the process is similar but uses a tool called `emcmake`, integrated within the Emscripten toolchain that setup mandatory environment variables. To activate it, run `source ./emsdk_env.sh` in the folder where you installed the Emscripten toolchain.

Then, setup the CMake project with `emcmake cmake -Bcmake-build/web/wasm/(release|debug) -DCMAKE_BUILD_TYPE=(Release|Debug) .`.

Then you can compile a specific target using `cmake --build cmake-build/web/wasm/(release|debug) --target <target_name> --parallel` and run it with `./cmake-build/web/wasm/(release|debug)/bin/<target_name>`.

For example, if you want to run the `release` version of the `01-hello-world` sample, you will execute :
* `emcmake cmake -Bcmake-build/web/wasm/release -DCMAKE_BUILD_TYPE=Release .`
* `cmake --build cmake-build/web/wasm/release --target 01-hello-world --parallel`
* Launch an http server in the root folder (`python3 -m http.server 8000` for example) and navigate to `http://localhost:8000/01-hello-world/html/index_release.html` in a browser.