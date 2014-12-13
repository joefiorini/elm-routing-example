(function() {

    var app = Elm.fullscreen(Elm.Main, {
      loadPostIndex: "",
      loadIndex: ""
    });

    var router = new Router();

    document.addEventListener('click', function(e) {
      e.preventDefault();
    });

    app.ports.visitIndex.subscribe(function(routeS) {
      var route = JSON.parse(routeS);
      console.log(route);
      window.history.pushState({}, '', route.url);
      router.handleURL("/");
    });

    app.ports.visitPostIndex.subscribe(function(routeS) {
      var route = JSON.parse(routeS);
      console.log(route);
      window.history.pushState({}, '', route.url);
      router.handleURL("/posts");
    });

    router.map(function(match) {
      match("/").to("index");
      match("/posts").to("postIndex");
    });

    var handlers = {};
    handlers.index = {
      setup: function() {
        console.log("index");
        app.ports.loadIndex.send("string");
      }
    };

    handlers.postIndex = {
      setup: function() {
        console.log('postIndex');
        app.ports.loadPostIndex.send("string");
      }
    };

    router.getHandler = function(name) {
      return handlers[name];
    };

    window.addEventListener('popstate', function(e) {
      router.handleURL(window.location.href);
    });

    console.log("setting up router");

    router.handleURL("/");

})();
