module Router.Watchers where

import Signal
import Json.Encode as Json

import Router.Types (RouteHandler, RouteHandlerM)

routeChangeP : Signal.Channel RouteHandler
routeChangeP = Signal.channel ""

routeChangePM : Signal.Channel RouteHandlerM
routeChangePM = Signal.channel ("", Json.null)

