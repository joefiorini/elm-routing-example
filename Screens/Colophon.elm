module Screens.Colophon where

import Html (h2, text, p)
import Html.Attributes (class)

view =
  h2 []
    [ text "Colophon",
      p [class "colophon"]
        [text "Made with Elm, Ember and Aliens."]
    ]
