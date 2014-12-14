import Html
import Html (div, p, text, ul, a, li, h1, h2)
import Html.Attributes (href, class)
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

-------- FRAMEWORK -----------

type alias RouteHandler = String
type alias RouteHandlerM = (RouteHandler, Json.Value)

render : Html.Html -> RouteHandler -> Signal Html.Html
render view handler = Signal.map (\h -> if h == "" then text "" else view) (onRoute handler)

renderTopLevel : (Html.Html -> Html.Html) -> List (Signal Html.Html) -> Signal Html.Html
renderTopLevel parent children =
    Signal.map (parent) (Signal.mergeMany children)

renderOutlet : (Html.Html -> Html.Html) -> (RouteHandler, List (Signal Html.Html)) -> Signal Html.Html
renderOutlet parent (handler, children) =
  let findOutlet parent h = (if h == "" then (\_ -> text "") else parent)
      outletS = Signal.map (findOutlet parent) (onRoute handler) in
    Signal.map2 (\p v -> Debug.log "renderOutlet" p v) outletS <| Signal.mergeMany children

renderM : (JsonD.Value -> Html.Html) -> RouteHandler -> Signal Html.Html
renderM view handler = Signal.map (\(h,m) -> if h == "" then text "" else view m) (onRouteM handler)

onRoute : RouteHandler -> Signal RouteHandler
onRoute handler = Signal.keepIf ((==) handler) "" routeChangeP

onRouteM : RouteHandler -> Signal RouteHandlerM
onRouteM handler = Signal.keepIf (\(h,_) -> h == handler) ("",Json.null) routeChangePM

linkTo : String -> String -> Html.Html
linkTo title url = a [ href url ] [ text title ]

-------- IMPLEMENTATION --------

main : Signal.Signal Element
main = Signal.map (Html.toElement 1000 1000) container

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

port routeChangeP : Signal.Signal RouteHandler
port routeChangePM : Signal.Signal RouteHandlerM

container : Signal Html.Html
container =
  renderTopLevel (\v ->
    div [class "container"]
      [ header
      , v
      ])
    [renderIndex, renderPosts, renderAbout, renderColophon]

header : Html.Html
header =
  Html.node "header" []
  [ ul []
    [ li [] [ linkTo "Home" "/" ]
    , li [] [ linkTo "Posts" "/posts" ]
    , li [] [ linkTo "About" "/about" ]
    , li [] [ linkTo "Colophon" "/colophon" ]
    ]
  , div []
    [ h1 [] [text "Welcome to this Website!"]
    ]
  ]

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
  div [class "posts-outlet"]
    [ h2 [] [text "Posts"], outlet ]

renderIndex = render (h2 [class "index"] [text "This is index!"]) indexRoute

renderAbout =
  render (h2 [] [text "About me", p [class "about"] [text "I'm awesome."]]) aboutRoute

renderColophon =
  render (h2 [] [text "Colophon", p [class "colophon"] [text "Made with Elm, Ember and Aliens."]]) colophonRoute

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

renderPostsIndex = render (div [class "posts-listing"] [
    h2 [] (List.map renderPostPreview posts)
  ]) postsIndexRoute

renderPostPreview post =
  div [class "post-preview"]
  [ linkTo post.title (postUrl post)
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
    div [class "post"]
      [ h1 [] [text post.title]
      , p [] [text post.body]
      ]
    ) postsShowRoute

postUrl : Post -> String
postUrl p = "/posts/" ++ p.id
