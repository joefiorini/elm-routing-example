module Screens.About where

import Html (h2, text, p)
import Html.Attributes (class)

view =
  h2 []
    [ text "About me"
    , p
      [class "about"]
      [text "I'm awesome."]
    ]
