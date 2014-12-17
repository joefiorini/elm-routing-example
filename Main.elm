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

import Router (embedRouter)
import Native.Router
import Router.Renderers ((<~), (<@~), renderTopLevel)
import Router.Helpers (linkTo)
import Router.Types (RouteHandler'(..))

-------- IMPLEMENTATION --------

routes =
  [ ("/", Handler "index")
  , ("/about", Handler "about")
  , ("/colophon", Handler "colophon")
  , ("/posts", NestedHandler "posts"
    [ ("/", Handler "postsIndex")
    , ("/:id", Handler "postsShow")
    ])
  ]

main : Signal.Signal Element
main = Signal.map (Html.toElement 1000 1000) <| embedRouter container routes

container : Signal Html.Html
container =
  renderTopLevel (\outlet ->
    div [class "container"]
      [ header
      , outlet
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
