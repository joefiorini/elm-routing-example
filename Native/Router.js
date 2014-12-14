Elm.Native.Router = {};

console.log("Loading router");
Elm.Native.Router.make = function(elm) {
    elm.Native = elm.Native || {};
    elm.Native.Router = elm.Native.Router || {};
    if (elm.Native.Router.values) return elm.Native.Router.values;

    var elmRouter = Elm.Router.Watchers.make(elm);
    var Utils = Elm.Native.Utils.make(elm);

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

      return elm.Native.Router.values = {
        mkRouter: function(id) {
          console.log("mkRouter");
          return id;
        }
      };
};
