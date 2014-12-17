module Router.Types where

import Json.Encode as Json

type alias Url = String
type alias HandlerName = String
type alias HandlerNameM = (HandlerName, Json.Value)

type alias Route = (Url, RouteHandler)

type RouteHandler = Handler HandlerName
                   | NestedHandler HandlerName (List Route)

