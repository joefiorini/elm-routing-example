module Router where

import Debug
import Signal
import Json.Encode as Json

import Native.Router

import Router.Types (RouteHandler, RouteHandlerM)
import Router.Watchers (routeChangeP, routeChangePM)

mkRouter : a -> a
mkRouter = Native.Router.mkRouter

onRoute : RouteHandler -> Signal RouteHandler
onRoute handler = Signal.keepIf ((==) handler) "" (Signal.subscribe routeChangeP)

onRouteM : RouteHandler -> Signal RouteHandlerM
onRouteM handler = Signal.keepIf (\(h,_) -> (Debug.log "evaluating " h) == handler) ("",Json.null) (Signal.subscribe routeChangePM)

