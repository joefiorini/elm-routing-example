module Router.Types where

import Json.Encode as Json

type alias Url = String
type alias RouteHandler = String
type alias RouteHandlerM = (RouteHandler, Json.Value)

type alias Route = (Url, RouteHandler')

type RouteHandler' = Handler RouteHandler
                   | NestedHandler String (List Route)

