# 02. Hashing

This sample is a benchmark of the MurmurHash3 hashing algorithm. It compares the performance of this algorithm on native, web (in WASM) and web (in JS).

It contains 3 simple modules :
* `logger` : a very basic module that exposes a `log` method.
* `hasing`: a module that expose a `Hashing` class capable of hashing a `std::vector<uint8_t>`.
* `benchmark`: The main module containing the core logic of the app (similar to the `hello_world` module in the first sample).

For every platforms, it instantiate the `Benchmark` class, runs the hasher multiple times on a random buffer, and logs the average time taken (and its variance) to hash the buffer. For the JS version, it's directly embedded in a web page that you can find in the `html` folder.

## Results

### Google Chrome 90
On 1000 iterations, with a buffer of size 1MiB and compiled in Release mode, here are the results we obtained :

| Platform   | Mean duration | Variance |
|------------|---------------|----------|
| Web (WASM) |       1.198ms |  0.021ms |
| Web (JS)   |       1.737ms |  0.076ms |
| Native     |       0.318ms |  0.007ms |

As we can see, on Chrome, WASM is a bit better than JS and the native code is 3x times faster than the WASM version.

### Firefox 88.0
On 1000 iterations, with a buffer of size 1MiB and compiled in Release mode, here are the results we obtained :

| Platform   | Mean duration | Variance |
|------------|---------------|----------|
| Web (WASM) |       4.137ms |  0.392ms |
| Web (JS)   |       1.977ms |  0.258ms |
| Native     |       0.318ms |  0.007ms |

As we can see, on Firefox, WASM is clearly slower that JS, but JS is slower than on Chrome.

### Safari 13.1.3
On 1000 iterations, with a buffer of size 1MiB and compiled in Release mode, here are the results we obtained :

| Platform   | Mean duration | Variance |
|------------|---------------|----------|
| Web (WASM) |       0.369ms |  0.235ms |
| Web (JS)   |       9.592ms |  0.660ms |
| Native     |       0.318ms |  0.007ms |

Surprisingly, on Safari, WASM is really fast, almost as fast as the native version. However, the JS version is more than 5 times slower than on Chrome.