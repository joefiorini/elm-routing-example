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
type alias RouteHandler = String
type alias RouteHandlerM = (RouteHandler, Json.Value)

render : Html.Html -> RouteHandler -> Signal Html.Html
render view handler = Signal.map (\h -> if h == "" then text "" else view) (onRoute handler)

findOutlet parent h =
  Debug.log "findOutlet" (if h == "" then (\_ -> text "") else parent)

renderOutlet : (Html.Html -> Html.Html) -> (RouteHandler, List (Signal Html.Html)) -> Signal Html.Html
renderOutlet parent (handler, children) =
  let outletS = Signal.map (findOutlet parent) (onRoute handler) in
    Signal.map2 (\p v -> Debug.log "renderOutlet" p v) outletS <| Signal.mergeMany children

renderTopLevel : (Html.Html -> Html.Html) -> List (Signal Html.Html) -> Signal Html.Html
renderTopLevel parent children =
    Signal.map (\v -> Debug.log "renderOutlet" v) <| Signal.mergeMany children


renderM : (JsonD.Value -> Html.Html) -> RouteHandler -> Signal Html.Html
renderM view handler = Signal.map (\(h,m) -> if h == "" then text "" else view m) (onRouteM handler)

onRoute : RouteHandler -> Signal RouteHandler
onRoute handler = Signal.keepIf ((==) handler) "" routeChangeP

onRouteM : RouteHandler -> Signal RouteHandlerM
onRouteM handler = Signal.keepIf (\(h,_) -> h == handler) ("",Json.null) routeChangePM

linkTo : String -> String -> Html.Html
linkTo title url = a [ href url ] [ text title ]

-------- IMPLEMENTATION --------

type alias Post =
  { id : String
  , title : String
  , body : String
  }

indexRoute = "index"
aboutRoute = "about"
colophonRoute = "colophon"
postsRoute = "posts"
postsIndexRoute = "postsIndex"
postsShowRoute = "postsShow"


view : Signal.Signal Html.Html
view = Signal.map (\v -> div [] [header, v]) body

handleRouteChange : RouteHandler -> RouteHandler -> RouteHandler -> RouteHandler
handleRouteChange listenRoute oldRoute newRoute =
      if | newRoute == listenRoute -> listenRoute
         | otherwise -> oldRoute

port routeChangeP : Signal.Signal RouteHandler
port routeChangePM : Signal.Signal RouteHandlerM

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
  renderTopLevel (\v ->
    div [] [
      v
    ]) [renderIndex, renderPosts, renderAbout, renderColophon]

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
    ) postsShowRoute

postUrl : Post -> String
postUrl p = "/posts/" ++ p.id

postToJson : Post -> Json.Value
postToJson p =
  Json.object
    [ ("id", Json.string p.id)
    , ("title", Json.string p.title)
    , ("body", Json.string p.body)
    ]

linkToHome : String -> Html.Html
linkToHome title =
  linkTo title "/"

linkToPosts : String -> Html.Html
linkToPosts  title =
  linkTo title "/posts"

linkToAbout : String -> Html.Html
linkToAbout title =
  linkTo title "/about"

linkToColophon : String -> Html.Html
linkToColophon title =
  linkTo title "/colophon"

linkToPost : String -> Post -> Html.Html
linkToPost title post =
  linkTo title (postUrl post)
