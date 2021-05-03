    Module().then((module) => {
        console.log("Module loaded");
        benchmark = new module.Benchmark;
        benchmark.delete();
    });
})();