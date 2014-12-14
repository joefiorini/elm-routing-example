module Screens.Posts.Index (view) where

import List as List
import Html (h2, div)
import Html.Attributes (class)

import Model (posts, Post)
import Router.Helpers (linkTo)

view =
  div [class "posts-listing"]
      [ h2 [] (List.map renderPostPreview posts)
      ]

renderPostPreview post =
  div [class "post-preview"]
    [ linkTo post.title (postUrl post)
    ]

postUrl : Post -> String
postUrl p = "/posts/" ++ p.id
