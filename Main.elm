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
import Graphics.Element (Element)
import Signal as Signal

import Routes

import Screens.Home as Home
import Screens.About as About
import Screens.Posts as Posts
import Screens.Colophon as Colophon

import Router
import Native.Router
import Router.Renderers ((<~), (<@~), renderTopLevel)
import Router.Helpers (linkTo)

-------- IMPLEMENTATION --------

main : Signal.Signal Element
main = Signal.map (Html.toElement 1000 1000) container

container : Signal Html.Html
container =
  renderTopLevel (\v ->
    div [class "container"]
      [ header
      , v
      ])
    [ Routes.indexRoute                   <~ Home.view
    , (Routes.postsRoute, Posts.children) <@~ Posts.view
    , Routes.aboutRoute                   <~ About.view
    , Routes.colophonRoute                <~ Colophon.view
    ]

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
