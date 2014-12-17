module Router.Renderers where

import Signal

import Html
import Html (text)

import Json.Decode as Json

import Router.Types (HandlerName, HandlerNameM)
import Router (onRoute, onRouteM)

render : Html.Html -> HandlerName -> Signal Html.Html
render view handler = Signal.map (\h -> if h == "" then text "" else view) (onRoute handler)

handler <~ view = render view handler

renderTopLevel : (Html.Html -> Html.Html) -> List (Signal Html.Html) -> Signal Html.Html
renderTopLevel parent children =
    Signal.map (parent) (Signal.mergeMany children)

parent <^~ children = renderTopLevel parent children

renderOutlet : (Html.Html -> Html.Html) -> (HandlerName, List (Signal Html.Html)) -> Signal Html.Html
renderOutlet parent (handler, children) =
  let findOutlet parent h = (if h == "" then (\_ -> text "") else parent)
      outletS = Signal.map (findOutlet parent) (onRoute handler) in
    Signal.map2 identity outletS <| Signal.mergeMany children

children <@~ parent = renderOutlet parent children

renderM : (Json.Value -> Html.Html) -> HandlerName -> Signal Html.Html
renderM view handler = Signal.map (\(h,m) -> if h == "" then text "" else view m) (onRouteM handler)

handler <#~ view = renderM view handler


