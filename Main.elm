import Html
import Html (div, p, text, ul, a, li, h1, h2)
import Html.Attributes (href)
import Html.Events (onClick)
import Json.Encode as Json
import Graphics.Element (Element)
import Signal as Signal

main : Signal.Signal Element
main = Signal.map (\v -> Html.toElement 1000 1000 v) view

type alias Route = { url: String }

routeToJson : Route -> Json.Value
routeToJson route = Json.object [ ("url", Json.string route.url) ]

indexRoute : Route
indexRoute = { url = "/" }

postsRoute : Route
postsRoute = { url = "/posts" }

noOp : Route
noOp = { url = "" }

view : Signal.Signal Html.Html
view = Signal.map (\v -> div [] [header, v]) body

index : Signal.Channel Route
index = Signal.channel indexRoute

postIndex : Signal.Channel Route
postIndex = Signal.channel postsRoute

listenForRoute : Route -> Signal.Signal String -> Signal.Signal Route
listenForRoute r s = Signal.map (\d -> if d == r.url then postsRoute else noOp) s

port visitIndex : Signal.Signal String
port visitIndex =
  let encodeRoute : Route -> String
      encodeRoute r = Json.encode 0 <| routeToJson r in
    Signal.map (encodeRoute) (Signal.subscribe index)

port visitPostIndex : Signal.Signal String
port visitPostIndex =
  let encodeRoute : Route -> String
      encodeRoute r = Json.encode 0 <| routeToJson r in
    Signal.map (encodeRoute) (Signal.subscribe postIndex)

port loadPostIndex : Signal.Signal String
port loadIndex : Signal.Signal String

header : Html.Html
header =
  div [] [
    ul [] [
      li [] [ linkToRoute "Home" index indexRoute ]
    , li [] [ linkToRoute "Posts" postIndex postsRoute ]
    , li [] [ linkTo "About" "/about" ]
    , li [] [ linkTo "Colophon" "/colophon" ]
    ] ]

body : Signal.Signal Html.Html
body =
  Signal.map (\v ->
    div [] [
      v
    ]) <| Signal.mergeMany [postsView, containerView]

containerView : Signal.Signal Html.Html
containerView = Signal.map renderContainer (listenForRoute postsRoute loadIndex)

renderContainer s = h1 [] [text "This is a website!"]

postsView : Signal.Signal Html.Html
postsView = Signal.map renderPosts (listenForRoute indexRoute loadPostIndex)

renderPosts s = div [] [
    h2 [] [text "This is posts!"]
  ]

linkTo : String -> String -> Html.Html
linkTo title url = a [ href url ] [ text title ]

linkToRoute : String -> Signal.Channel Route -> Route -> Html.Html
linkToRoute title channel route = a [
    href route.url
  , onClick (Signal.send channel route)
  ] [ text title ]
