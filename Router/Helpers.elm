module Router.Helpers where

import Html as Html
import Html (a, text)
import Html.Attributes (href)

linkTo : String -> String -> Html.Html
linkTo title url = a [ href url ] [ text title ]


