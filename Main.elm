import Html
import Html (div, p, text, ul, a, li, h1, h2)
import Html.Attributes (href)
import Html.Events (onClick)
import List ((::))
import List as List
import Dict as Dict
import Debug as Debug
import Result as Result
import Json.Encode as Json
import Json.Decode ((:=))
import Json.Decode as JsonD
import Graphics.Element (Element)
import Signal as Signal

main : Signal.Signal Element
main = Signal.map (\v -> Html.toElement 1000 1000 v) view

-------- FRAMEWORK -----------

type RouteState = NoState

type alias Url = String

type alias RouteParams = Dict.Dict (String, String)
-- type alias RouteHandler h s =
--   { h | serialize: s -> Route -> RouteParams }
type alias RouteHandler = String
type alias RouteHandlerM = (RouteHandler, Json.Value)

-- routeParams : List (String, String) -> RouteParams
-- routeParams = Dict.fromList

-- routeHandler = { serialize = identity }
-- defaultRouteHandler = routeHandler {} NoState
-- defaultRouteHandlerState s = routeHandler {} s

-- type Route h s = UrlRoute String Url (RouteHandler h s)

-- visitRoute : Signal.Channel (Route,s)
-- visitRoute = Signal.channel (indexRoute,NoState)

-- indexRoute : Route
-- indexRoute = { url = "/" }
indexRoute : RouteHandler
indexRoute = "index"

aboutRoute : RouteHandler
aboutRoute = "about"

colophonRoute : RouteHandler
colophonRoute = "colophon"

postsRoute = "posts"

postsIndexRoute : RouteHandler
postsIndexRoute = "postsIndex"

-- routeToJson : Route -> Json.Value
-- routeToJson route = Json.object [ ("url", Json.string route.url) ]

-------- IMPLEMENTATION --------

type alias Post =
  { id : String
  , title : String
  , body : String
  }

-- serializePost : Post -> RouteParams
-- serializePost p = routeParams ("id", toString p.id)

-- type alias PostsRoute = RouteHandler {} (List Post)

-- postsRoute : PostsRoute
-- postsRoute = routeHandler

-- postsShowRoute : RouteHandler {} Post
-- postsShowRoute =
--   { routeHandler | serialize <- serializePost }

view : Signal.Signal Html.Html
view = Signal.map (\v -> div [] [header, v]) body

-- index = UrlRoute "index" "/" (defaultRouteHandler)

-- postsIndex : Route
-- postsIndex = UrlRoute "postsIndex" "/posts" (routeHandler postsRoute)

-- postsShow : Route
-- postsShow = UrlRoute "postsShow" "/posts/:id" postsShowRoute

-- defaultRoute = index

handleRouteChange : RouteHandler -> RouteHandler -> RouteHandler -> RouteHandler
handleRouteChange listenRoute oldRoute newRoute =
      if | newRoute == listenRoute -> listenRoute
         | otherwise -> oldRoute

-- listenForRoute : RouteHandler -> Signal.Signal RouteHandler
-- listenForRoute r = Signal.map (handleRouteChange r) indexRoute routeChangeP

port routeChangeP : Signal.Signal RouteHandler
port routeChangePM : Signal.Signal RouteHandlerM

port visitRouteP : Signal.Signal RouteHandler
port visitRouteP =
  Signal.subscribe routeChannel

port visitRouteMP : Signal.Signal RouteHandlerM
port visitRouteMP =
  Signal.subscribe routeChannelM

-- port loadPostIndex : Signal.Signal String
-- port loadIndex : Signal.Signal String

header : Html.Html
header =
  div []
  [ ul []
    [ li [] [ linkToHome "Home" ]
    , li [] [ linkToPosts "Posts" ]
    , li [] [ linkToAbout "About" ]
    , li [] [ linkToColophon "Colophon" ]
    ]
  , div []
    [ h1 [] [text "Welcome to this Website!"]
    ]
  ]

body : Signal.Signal Html.Html
body =
  Signal.map (\v ->
    div [] [
      v
    ]) renderRoutes

-- viewForRoute : RouteHandler -> Signal Html.Html
-- viewForRoute handler =
--   if | handler == indexRoute -> Debug.log "renderIndex" renderIndex
--      | handler == postsIndexRoute -> Debug.log "renderPostsIndex" renderPostsIndex
--      | otherwise -> text ""

nullPost =
  { id = 0
  , title = ""
  , body = ""
  }

type alias IdGuy = {id : String}
postDecoder : JsonD.Decoder IdGuy
postDecoder =
  JsonD.object1 IdGuy
    ("id" := JsonD.string)
    -- ("title" := JsonD.string)
    -- ("body" := JsonD.string)

-- viewForRouteM : RouteHandlerM -> Signal Html.Html
-- viewForRouteM (handler,modelS) =
--   if | handler == "postsShow" ->
--     let modelR = JsonD.decodeValue jsonToPost modelS
--         postViewR = Result.map (Debug.log "renderPostsShow" renderPostsShow) modelR in
--     case postViewR of
--       Result.Ok view -> view
--     | otherwise -> text ""

renderRoutes : Signal Html.Html
renderRoutes = Signal.mergeMany [renderIndex, renderPosts, renderAbout, renderColophon]

-- renderRoute : RouteHandler -> Signal.Signal Html.Html
-- renderRoute handler =
--   Signal.map2 (\v (h, m) ->
--     if | v == handler -> viewForRoute handler
--        | h == handler -> viewForRouteM (h, m)
--        | otherwise -> text "")
--     routeChangeP routeChangePM

render : Html.Html -> RouteHandler -> Signal Html.Html
render view handler = Signal.map (\h -> if h == "" then text "" else view) (onRoute handler)

findOutlet parent h =
  Debug.log "findOutlet" (if h == "" then (\_ -> text "") else parent)

renderOutlet : (Html.Html -> Html.Html) -> (RouteHandler, List (Signal Html.Html)) -> Signal Html.Html
renderOutlet parent (handler, children) =
  let outletS = Signal.map (findOutlet parent) (onRoute handler) in
  -- outletS : Signal (Html.Html -> Html.Html)
    Signal.map2 (\p v -> Debug.log "renderOutlet" p v) outletS <| Signal.mergeMany children

renderM : (JsonD.Value -> Html.Html) -> RouteHandler -> Signal Html.Html
renderM view handler = Signal.map (\(h,m) -> if h == "" then text "" else view m) (onRouteM handler)

onRoute : RouteHandler -> Signal RouteHandler
onRoute handler = Signal.keepIf ((==) handler) "" routeChangeP

onRouteM : RouteHandler -> Signal RouteHandlerM
onRouteM handler = Signal.keepIf (\(h,_) -> h == handler) ("",Json.null) routeChangePM

renderPosts : Signal Html.Html
renderPosts =
  renderOutlet postsOutlet (postsRoute, [renderPostsIndex, renderPostsShow])

postsOutlet : Html.Html -> Html.Html
postsOutlet outlet =
  div []
    [ h2 [] [text "Posts"], outlet ]

renderIndex = render (h2 [] [text "This is index!"]) indexRoute

renderAbout =
  render (h2 [] [text "About me", p [] [text "I'm awesome."]]) aboutRoute

renderColophon =
  render (h2 [] [text "Colophon", p [] [text "Made with Elm, Ember and Aliens."]]) colophonRoute

posts : List {title:String,body:String,id:String}
posts =
  [ { title = "Blah Doo Dah"
    , body = "This is such an awesome post"
    , id = "1"
    }
  , { title = "Doo Dah Dee"
    , body = "This one isn't as good."
    , id = "2"
    }
  ]

renderPostsIndex = render (div [] [
    h2 [] (List.map renderPostPreview posts)
  ]) postsIndexRoute

renderPostPreview post =
  div []
  [ linkToPost post.title post
  ]

jsonToPost : JsonD.Value -> Post
jsonToPost value =
  let postR = JsonD.decodeValue postDecoder (Debug.log "value" value) in
    case postR of
      Result.Ok postId ->
        List.foldl (\pp p -> if p.id == postId.id then p else pp)
          (List.head posts)
          (List.tail posts)
      Result.Err s -> Debug.crash s

renderPostsShow = renderM (\postJ ->
  let post = jsonToPost postJ in
    div []
      [ h1 [] [text post.title]
      , p [] [text post.body]
      ]
    ) "postsShow"

postUrl : Post -> String
postUrl p = "/posts/" ++ p.id

postToJson : Post -> Json.Value
postToJson p =
  Json.object
    [ ("id", Json.string p.id)
    , ("title", Json.string p.title)
    , ("body", Json.string p.body)
    ]

visitRoute : RouteHandler -> Signal.Message
visitRoute handler = Signal.send routeChannel handler

routeChannel : Signal.Channel RouteHandler
routeChannel = Signal.channel "noop"

routeChannelM : Signal.Channel RouteHandlerM
routeChannelM = Signal.channel ("noop", Json.null)

visitRouteM : RouteHandlerM -> Signal.Message
visitRouteM handler = Signal.send routeChannelM handler

linkTo : String -> String -> Html.Html
linkTo title url = a [ href url ] [ text title ]

linkToC : String -> String -> Signal.Message -> Html.Html
linkToC title url m =
  a
    [ href url
    , onClick m
    ]
    [ text title ]

postsShowRoute : Post -> RouteHandlerM
postsShowRoute post = ("postsShow", postToJson post)

linkToHome : String -> Html.Html
linkToHome title =
  linkToC title "/" (visitRoute indexRoute)

linkToPosts : String -> Html.Html
linkToPosts  title =
  linkToC title "/posts" (visitRoute postsIndexRoute)

linkToAbout : String -> Html.Html
linkToAbout title =
  linkToC title "/about" (visitRoute aboutRoute)

linkToColophon : String -> Html.Html
linkToColophon title =
  linkToC title "/colophon" (visitRoute colophonRoute)

linkToPost : String -> Post -> Html.Html
linkToPost title post =
  linkToC title (postUrl post) (visitRouteM <| postsShowRoute post)

-- linkToRoute : String -> s -> Route -> Html.Html
-- linkToRoute title state route =
--   a
--     [ href <| serializeRoute state route
--     , onClick (Signal.send visitRoute (route,state))
--     ] [ text title ]
