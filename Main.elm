import Html
import Html (div, p, text, ul, a, li, h1)
import Html.Attributes (href)
import Graphics.Element (Element)
import Signal as Signal

main : Element
main = (Html.toElement 1000 1000) view

view : Html.Html
view = div [] [header, body]

header : Html.Html
header =
  div [] [
    ul [] [
      li [] [ a [ href "/posts" ] [text "Posts"] ]
    , li [] [ a [ href "/about" ] [text "About"] ]
    , li [] [ a [ href "/colophon" ] [text "Colophon"] ]
    ] ]

body : Html.Html
body =
  div [] [
    h1 [] [text "This is a website!"]
  ]
