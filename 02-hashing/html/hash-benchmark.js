var MurmurHash3 = {
    mul32: function(m, n) {
        var nlo = n & 0xffff;
        var nhi = n - nlo;
        return ((nhi * m | 0) + (nlo * m | 0)) | 0;
    },

    hashBytes: function(data, len) {
        var c1 = 0xcc9e2d51,
            c2 = 0x1b873593;

        var h1 = 0x0;
        var roundedEnd = len & ~0x3;

        for (var i = 0; i < roundedEnd; i += 4) {
            var k1 = (data[i] & 0xff) |
                ((data[i + 1] & 0xff) << 8) |
                ((data[i + 2] & 0xff) << 16) |
                ((data[i + 3] & 0xff) << 24);

            k1 = this.mul32(k1, c1);
            k1 = ((k1 & 0x1ffff) << 15) | (k1 >>> 17);
            k1 = this.mul32(k1, c2);

            h1 ^= k1;
            h1 = ((h1 & 0x7ffff) << 13) | (h1 >>> 19);
            h1 = (h1 * 5 + 0xe6546b64) | 0;
        }

        k1 = 0;

        switch (len % 4) {
            case 3:
                k1 = (data[roundedEnd + 2] & 0xff) << 16;
            case 2:
                k1 |= (data[roundedEnd + 1] & 0xff) << 8;
            case 1:
                k1 |= (data[roundedEnd] & 0xff);
                k1 = this.mul32(k1, c1);
                k1 = ((k1 & 0x1ffff) << 15) | (k1 >>> 17);
                k1 = this.mul32(k1, c2);
                h1 ^= k1;
        }

        h1 ^= len;

        h1 ^= h1 >>> 16;
        h1 = this.mul32(h1, 0x85ebca6b);
        h1 ^= h1 >>> 13;
        h1 = this.mul32(h1, 0xc2b2ae35);
        h1 ^= h1 >>> 16;

        return h1;
    }
};

function computeMean(durations) {
    let acc = 0;
    durations.forEach(d => acc += d);
    return acc / durations.length;
}

function computeVariance(durations) {
    let mean = computeMean(durations);
    let acc = 0;
    durations.forEach(d => acc += (d - mean) * (d - mean));
    return acc / durations.length;
}

const ITERATIONS = 1000;
const BUFFER_SIZE = 1024 * 1024;
let durations = [];

let hash = 0;

for (let i = 0;i < ITERATIONS;i++) {
    let buffer = new ArrayBuffer(BUFFER_SIZE);
    let array = new Uint8Array(buffer);
    for (let j = 0;j < array.length;j++) {
        array[j] = Math.random();
    }

    const start = performance.now();
    hash += MurmurHash3.hashBytes(array, array.length);
    const end = performance.now();
    durations.push(end - start);
}

const meanDuration = computeMean(durations);
const variance = computeVariance(durations);
const meanHash = hash / ITERATIONS;

console.log(`Hash of a ${BUFFER_SIZE} bytes buffer (meanHash = ${meanHash}) done in ${meanDuration} ms on average (+/- ${variance}ms) on ${ITERATIONS} iterations"`);