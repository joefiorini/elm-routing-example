module Router.Watchers where

import Signal
import Json.Encode as Json

import Router.Types (HandlerName, HandlerNameM)

routeChangeP : Signal.Channel HandlerName
routeChangeP = Signal.channel ""

routeChangePM : Signal.Channel HandlerNameM
routeChangePM = Signal.channel ("", Json.null)

