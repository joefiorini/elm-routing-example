import Html
import Html (div, p, text, ul, a, li, h1)
import Html.Attributes (href)
import Html.Events (onClick)
import Json.Encode as Json
import Graphics.Element (Element)
import Signal as Signal

main : Element
main = (Html.toElement 1000 1000) view

type alias Route = { url: String }

routeToJson : Route -> Json.Value
routeToJson route = Json.object [ ("url", Json.string route.url) ]

postsRoute : Route
postsRoute = { url = "/posts" }

view : Html.Html
view = div [] [header, body]

postIndex : Signal.Channel Route
postIndex = Signal.channel postsRoute

port visitPostIndex : Signal.Signal String
port visitPostIndex =
  let encodeRoute : Route -> String
      encodeRoute r = Json.encode 0 <| routeToJson r in
    Signal.map (encodeRoute) (Signal.subscribe postIndex)

header : Html.Html
header =
  div [] [
    ul [] [
      li [] [ linkToRoute "Posts" postsRoute ]
    , li [] [ linkTo "About" "/about" ]
    , li [] [ linkTo "Colophon" "/colophon" ]
    ] ]

body : Html.Html
body =
  div [] [
    h1 [] [text "This is a website!"]
  ]

linkTo : String -> String -> Html.Html
linkTo title url = a [ href url ] [ text title ]

linkToRoute : String -> Route -> Html.Html
linkToRoute title route = a [
    href route.url
  , onClick (Signal.send postIndex route)
  ] [ text title ]
