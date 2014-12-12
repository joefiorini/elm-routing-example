(function() {

    var app = Elm.fullscreen(Elm.Main, {
    });

    var router = new Router();

    document.addEventListener('click', function(e) {
      e.preventDefault();
    });

    app.ports.visitPostIndex.subscribe(function(routeS) {
      var route = JSON.parse(routeS);
      console.log(route);
      window.history.pushState({}, '', route.url);
      router.handleURL("/posts");
    });

    router.map(function(match) {
      match("/posts").to("postIndex");
    });

    var handlers = {};
    handlers.postIndex = {
      setup: function() {
        console.log('postIndex');
      }
    };

    router.getHandler = function(name) {
      return handlers[name];
    };

    window.addEventListener('popstate', function(e) {
      router.handleURL(window.location.href);
    });

})();
