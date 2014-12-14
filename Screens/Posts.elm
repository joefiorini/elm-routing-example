module Screens.Posts where

import Html
import Html (div, h2, text)
import Html.Attributes (class)

import Routes

import Screens.Posts.Index as Index
import Screens.Posts.Show as Show

import Router.Renderers ((<~), (<#~))

view outlet =
  div [class "posts-outlet"]
    [ h2 [] [text "Posts"], outlet ]

children = [ Routes.postsIndex <~ Index.view
           , Routes.postsShow  <#~ Show.view
           ]

