# Client-Side Routing in Elm

An example showing my approach to Ember-inspired client-side routing in Elm. Uses [router.js](http://github.com/tildio/router.js).

## Todo

This library is work in progress. Here is the progress thus far. Is there something I'm missing here? Please feel free to open an issue to discuss it.

- [x] Basic example showing nesting & listening for routes
- [x] Ability to define routes in Elm instead of hardcoding
- [ ] Auto generating links instead of hardcoding URLs
- [ ] Browserify build setup to include vendor code in final output
- [ ] Create & push Elm package

## Modules

### Router

The Router module contains all the framework code for integrating with Ember's router.

#### Router.Renderers

Helper functions to handle subscribing to route channels and rendering a view when its requested route is loaded.

### Routes

This module contains mappings of strong names to route handler strings. This makes for slightly easier refactoring, but also allows us to use a custom `RouteHandler` type (at the moment just an alias for `String`). Each route handler string maps exactly to the name of the handler defined in `Native/Router.js`.

### Screens

The Screens module contains the view code for rendering HTML-based views. This module also sets up routing for nested (swappable) routes.

However, `Screens.Posts` takes a

### Native

The Native module contains raw JavaScript code using an undocumented Elm feature that allows more seamless, but less safe, integration with raw JavaScript than ports. This is where all integration with `router.js` lives.

## How it Works

### Defining Routes

A route is a type alias for the following tuple: `(Url, RouteHandler)`. `Url` is currently a type alias for `String` and it represents a URL you want the router to trigger a signal on, for example `"/"` or `"/about"`. [See router.js][routerjs] for more examples of possible URLs.

The second parameter of the `Route` type is the `RouteHandler`. At the moment this type has two constructors: `Handler` and `NestedHandler`. `Handler` represents a route that doesn't have any nested states underneath it, for example `"/colophon"`. A `NestedHandler` is a route that contains some substates (see "Nesting Views within Views" below). For example:

```elm
[ ("/posts", NestedHandler "posts"
  [  -- Matches /posts and triggers signal with "postsIndex"
    ("/", Handler "postsIndex")

    -- Matches /posts/1, /posts/2, etc and triggers signal with "postsShow" and the given id
  , ("/:id", Handler "postsShow")
  ])
]
```

To define these in your app, you can pass a recursive list of `Route` values, along with your top-level container to the `embedRouter` function. For example, if assuming you have a function `routes` defined as:

```elm
routes =
  [ ("/", Handler "index")
  , ("/about", Handler "about)
  ]
```

You can tell the router about them in your `main` function like:

```elm
main = Signal.map (Html.toElement 1000 1000) <| embedRouter container routes
```

#### Why pass container?

It may seem weird to pass `Html` into the router. We need to do this because of the pure nature of Elm. Defining routes is a side-effect action, but Elm doesn't allow you to call functions that don't compose. If you have trouble remembering, I tend to think of "defining routes" as mapping states of your application to the DOM that is rendered (URLs are just a handy way to return to those states). Therefore, you can think of this as "embedding" the router in your DOM, hence the name `embedRoutes`.

### Mapping Routes to Views

In `Main.elm` the `main` function renders a container view (a view is a function with type of `Html` or `Signal Html`).


The `container` view calls `renderTopLevel`, passing it a function `Html -> Html` and a list of route/view mappings. Route/view mappings are defined using one of the `<~`, `<@~`, or `<#~` operators, all aliases for slightly different renderers.

The `Router.Renderers` module contains a few different render funtions, but they all work in a similar way. Each takes a function that returns `Html` and the route (or routes) to listen for, and then return a `Signal Html` that triggers when the route changes. The anonymous function passed into the renderer gets handed the `Html` for the route that is being rendered.

### Rendering a View Based on URL Changes

Assuming we have route-to-URL mappings defined as follows:

```javascript
router.map(function(match) {
    match("/").to("home");
    match("/about").to("about");
});
```

and we have a `Routes` module defined with

```elm
homeRoute = "home"
aboutRoute = "about"
```

then we can render the page with:

```elm

containerView outlet = div [] [ outlet ]

container =
  renderTopLevel containerView
    [ Routes.homeRoute <~ Home.view
    , Routes.aboutRoute <~ About.view ]

```

Now when the page first loads at the root URL, `Native.Router` will trigger the router's signal with the `homeRoute` handler. That in turn will call `containerView` with the result of calling `Home.view`. That view then gets injected into the point where we put `outlet` ("outlet" comes from Ember's terminology for the point at which you want to inject a view into a route).

### Swapping Between Two Views

How do you switch to "About"? Let's add a header with some navigation:

```elm
topBar =
  header []
  [ ul []
    [ li [] [ linkTo "Home" "/" ]
    , li [] [ linkTo "About" "/about" ]
    ]

conatinerView outlet = div [] [ topBar, outlet ]
```

Clicking on "About" will trigger `Native/Router` to update the URL using the [HTML5 History API](). The router will then load the proper handler and trigger `container` with the resultant `Html` from calling `About.view`. The topBar remains in place, but `About.view` now replaces the previous value of `outlet`.

### Nesting Views within Views

Let's say we want to render a list of posts and link to each one. First, we need to add a URL-to-route mapping to support it:

```javascript
router.map(function(match) {
    match("/").to("home");
    match("/about").to("about");
    match("/posts").to("posts", function(match) {
      match("/").to("postsIndex");
      match("/:id").to("postsShow");
    });
});
```

Here we're telling it that we want to have a "posts" route with children for displaying a listing of posts and a single post. This is what makes the Ember router so powerful. We can actually have multiple routes loaded at once. In this example, "home", "about" and "posts" will all swap with each other (none of these siblings can be loaded at the same time). However, when we load "posts" we can swap between "postsIndex" and "postsShow", while "posts" will stay loaded until we swap it with one of its siblings.

This allows us to do things like:

- design a common view for all the screens within posts, perhaps a submenu
- load resources from an API that are needed for every route within posts
- whatever else you can think of

The challenge with doing this in Elm is that these subviews need to listen on the signal for the nested route in order to swap out appropriately. Therefore, they would return a `Signal Html`. However, an `Html` node can only contain other `Html`s, so this is not possible without some extra signal help.

Let's say we've updated `container` to contain the following:

```elm
containerView outlet = div [] [ outlet ]

container =
  renderTopLevel containerView
    [ Routes.homeRoute <~ Home.view
    , Routes.aboutRoute <~ About.view
    , Routes.postsRoute <~ Posts.view]
```

and we have a `Posts` module with the following view:

```elm
view outlet =
  div [class "posts-outlet"]
    [ h2 [] [text "Posts"], outlet ]
```

This would work insofaras rendering the "posts-outlet" div, but since we can't make `Posts.view` a `Signal Html`, we can't just render the children there like we did with `container`. The difference is that previously we were only listening on a single route, but here we want to trigger a render on the individual route, but also set up listeners on any nested child routes.

The easiest way to do that is to `Signal.map` on the parent's route (the outlet), and then combine that listener with the listener for the children. To keep a somewhat consistent API, instead of handing our renderer a list of routes, we can instead give it a tuple with the parent handler & the list of children. This is what the `renderOutlet` renderer does (aliased to `<@~`).

So assuming we expose the posts children in the `Posts` module:

```elm
view outlet =
  div [class "posts-outlet"]
    [ h2 [] [text "Posts"], outlet ]

children = [ Routes.postsIndex <~ Posts.Index.view
           , Routes.postsShow  <#~ Posts.Show.view
           ]
```

then we can use the `<@~` operator to setup the binding in `container`:


```elm
containerView outlet = div [] [ outlet ]

container =
  renderTopLevel containerView
    [ Routes.homeRoute <~ Home.view
    , Routes.aboutRoute <~ About.view
    , (Routes.postsRoute, Posts.children) <@~ Posts.view]
```

## Live Demo

There is a live demo of this example here:

https://elm-routing-example.5apps.com

## Feedback

I'm looking for feedback on this approach. It's still a work in progress, but I believe that having a good router library will make Elm a first class language for writing client-side apps. I'd like to eventually release this as such, but want to have some more discussion first. Thanks!
