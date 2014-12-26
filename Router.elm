module Router where

import Debug
import Signal
import Json.Encode as Json

import Html

import Native.Router

import Router.Types (HandlerName, HandlerNameM, Route)
import Router.Watchers (routeChangeP, routeChangePM)

mkRouter : a -> a
mkRouter = Native.Router.mkRouter

onRoute : HandlerName -> Signal HandlerName
onRoute handler = Signal.keepIf ((==) handler) "" (Signal.subscribe routeChangeP)

onRouteM : HandlerName -> Signal HandlerNameM
onRouteM handler = Signal.keepIf (\(h,_) -> (Debug.log "evaluating " h) == handler) ("",Json.null) (Signal.subscribe routeChangePM)

setup : List Route -> List (Signal Html.Html) -> Signal Html.Html
setup routes handlers =
  let handlers' = Native.Router.embed routes handlers
  in
     Signal.mergeMany handlers'

transitionTo : Signal HandlerName -> Signal HandlerName
transitionTo = Native.Router.transitionTo
