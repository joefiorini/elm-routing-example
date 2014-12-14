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

      if(typeof e.target.href !== "undefined") {
        var url = e.target.href.replace(window.location.origin, "");
        console.log("updateURL", url);
        api.updateURL(url);
      }

    });

    // app.ports.visitRouteP.subscribe(function(handler) {
    //   console.log("visitRouteM", handler);
    //   var route = router.recognizer.generate(handler);
    //   api.updateURL(route);
    // });

    // app.ports.visitRouteMP.subscribe(function(handlerM) {
    //   console.log("visitRouteMP", handlerM[0], handlerM[1]);
    //   var handlerName = handlerM[0],
    //       state = handlerM[1];

    //   var route = router.generate(handlerName, state);

    //   api.updateURL(route);
    // });

    router.map(function(match) {
      match("/").to("index");
      match("/about").to("about");
      match("/colophon").to("colophon");
      match("/posts").to("posts", function(match) {
        match("/").to("postsIndex");
        match("/:id").to("postsShow");
      });
    });

    var handlers = {};

    function defaultHandler(handlerName) {
      console.log("defaultHandler for", handlerName);
      return {
        model: function(s) {
          console.log("model for handler", handlerName, s, typeof s);
          return RSVP.resolve(s);
        },
        serialize: function(s) {
          return {id: s.id};
        },
        setup: function(model) {
          if(model && Object.keys(model).length > 0) {
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
      if(handlers[name] !== undefined) {
        return handlers[name];
      } else {
        return defaultHandler(name);
      }
    };

    api.watchURLChanges(function(url) {
      router.handleURL(window.location.pathname);
    });

    console.log("setting up router");

    api.updateURL("/");
    router.handleURL("/");

    return app;
})();
