module Router.Types where

import Json.Encode as Json

type alias RouteHandler = String
type alias RouteHandlerM = (RouteHandler, Json.Value)

