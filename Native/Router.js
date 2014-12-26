Elm.Native.Router = {};

console.log("Loading router");
Elm.Native.Router.make = function(elm) {
    elm.Native = elm.Native || {};
    elm.Native.Router = elm.Native.Router || {};
    if (elm.Native.Router.values) return elm.Native.Router.values;

    var elmRouter = Elm.Router.Watchers.make(elm);
    var Utils = Elm.Native.Utils.make(elm);
    var List = Elm.Native.List.make(elm);

  console.log('making router');
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

      router = router;

      document.addEventListener('click', function(e) {
        e.preventDefault();

        if(typeof e.target.href !== "undefined") {
          var url = e.target.href.replace(window.location.origin, "");
          console.log("updateURL", url);
          api.updateURL(url);
        }

      });

      var handlers = {};

      function defaultHandler(handlerName) {
        console.log("defaultHandler for", handlerName);
        return {
          model: function(s, t) {
            return RSVP.resolve(s);
          },
          serialize: function(s) {
            return {id: s.id};
          },
          setup: function(model) {
            if(model && Object.keys(model).length > 0) {
              console.log("sending routeChangePM: ", handlerName, model);
              elm.notify(elmRouter.routeChangePM.id, Utils.Tuple2(handlerName, model));
            } else {
              console.log("sending routeChangeP: ", handlerName);
              elm.notify(elmRouter.routeChangeP.id, handlerName);
            }
          },
          events: {
            error: function(e) {
              console.log("Error occurred in handler ", handlerName);
              console.error(e);
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

      var currentPath = window.location.pathname;
      if (currentPath == "/index.html") {
        api.updateURL("/");
      }

      router.handleURL(currentPath);


      function mapRoute(url, handler, match) {
        console.log("defining route: ", url, handler);
        match(url).to(handler);
      }

      function setupRoutes(routes, match) {
        List.map(function(route) {
          if(route._1.ctor === 'Handler') {
            mapRoute(route._0, route._1._0, match);
          } else if(route._1.ctor == 'NestedHandler') {
            match(route._0).to(route._1._0, function(match2) {
              setupRoutes(route._1._1, match2);
            });
          }
        })(routes);
      }

      function embedRoutes(routes, container) {
        router.map(function(match) {
          setupRoutes(routes, match);
        });
        return container;
      }

      return elm.Native.Router.values = {
        mkRouter: function(id) {
          console.log("mkRouter");
          return id;
        },
        embed: F2(embedRoutes)
      };
};
