module Screens.Posts.Show (view) where

import List
import Result

import Debug

import Json.Decode ((:=))
import Json.Decode as JsonD

import Html (div, h1, p, text)
import Html.Attributes (class)

import Model (findPost, Post)

view postJson =
  let post = jsonToPost postJson in
    div [class "post"]
      [ h1 [] [text post.title]
      , p [] [text post.body]
      ]


jsonToPost : JsonD.Value -> Post
jsonToPost value =
  let postR = JsonD.decodeValue postDecoder value in
    case postR of
      Result.Ok postId -> findPost postId.id
      Result.Err s -> Debug.crash s

type alias IdGuy = {id : String}
postDecoder : JsonD.Decoder IdGuy
postDecoder =
  JsonD.object1 IdGuy
    ("id" := JsonD.string)

