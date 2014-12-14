window.app = (function() {

    var app = Elm.fullscreen(Elm.Main, {
      routeChangeP: ""
      , routeChangePM: ["", {}]
    });

    var router = new Router();
    var api = {
      updateURL: function(url) {
        window.history.pushState({}, '', url);
        router.handleURL(url);
      },
      watchURLChanges: function(cb) {
        window.addEventListener('popstate', function(e) {
          console.log('popped state', window.location.pathname, e);
          cb(window.location.pathname, e);
        });
      }
    };

    app.router = router;

    document.addEventListener('click', function(e) {
      e.preventDefault();
    });

    app.ports.visitRouteP.subscribe(function(handler) {
      var route = router.recognizer.generate(handler);
      api.updateURL(route);
    });

    app.ports.visitRouteMP.subscribe(function(handlerM) {
      var handlerName = handlerM[0],
          state = handlerM[1];

      var route = router.generate(handlerName, state);

      api.updateURL(route);
    });

    router.map(function(match) {
      match("/").to("index");
      match("/posts").to("postsIndex");
      match("/posts/:id").to("postsShow");
    });

    function defaultHandler(handlerName) {
      return {
        model: function(s) {
          return s;
        },
        serialize: function(s) {
          return {id: s.id};
        },
        setup: function(model) {
          if(Object.keys(model).length > 0) {
            console.log("sending routeChangePM: ", handlerName);
            app.ports.routeChangePM.send([handlerName, model]);
          } else {
            console.log("sending routeChangeP: ", handlerName);
            app.ports.routeChangeP.send(handlerName);
          }
        }
      };
    }

    router.getHandler = function(name) {
      return defaultHandler(name);
    };

    api.watchURLChanges(function(url) {
      router.handleURL(window.location.pathname);
    });

    console.log("setting up router");

    api.updateURL("/");
    router.handleURL("/");

    return app;
})();
