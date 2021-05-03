    Module().then((module) => {
        console.log("Module loaded");
        helloWorld = new module.HelloWorld;
        window['hello_world'] = helloWorld;
        setTimeout(() => {
            helloWorld.delete()
        }, 2000);
    });
})();