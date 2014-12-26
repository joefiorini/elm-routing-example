import Html
import Html (div, p, text, ul, a, li, h1, h2)
import Html.Attributes (href, class)
import Html.Events (onClick)
import List ((::))
import List as List
import Dict as Dict
import Result as Result
import Maybe
import Http
import Json.Encode as Json
import Graphics.Element (Element)
import Signal as Signal
import LocalChannel as LC
import Debug

import Routes

import Screens.Home as Home
import Screens.About as About
import Screens.Posts as Posts
import Screens.Colophon as Colophon
import Screens.Contact as Contact

import Router
import Native.Router
import Router.Renderers ((<~), (<@~), renderTopLevel)
import Router.Helpers (linkTo)
import Router.Types (RouteHandler(..))

-------- IMPLEMENTATION --------

routes =
  [ ("/", Handler "index")
  , ("/about", Handler "about")
  , ("/colophon", Handler "colophon")
  , ("/contact", Handler "contact")
  , ("/posts", NestedHandler "posts"
    [ ("/", Handler "postsIndex")
    , ("/:id", Handler "postsShow")
    ])
  ]

type alias AppState =
  { contact : Maybe Contact.Model
  }

type Action = SubmitContact (Http.Request String)
            | None

type Update = ContactUpdate Contact.Update
            | NoOp

type alias Transition =
  { update : Update
  , state : AppState
  , action : Action
  }

transition =
  { update = NoOp
  , state = initialState
  , action = None
  }

main : Signal.Signal Element
main = Signal.map2 container (Router.setup routes handlers) (processActions state)

processActions : Signal Transition -> Signal Transition
processActions transitionSignal =
  let actionSignal = Signal.map (.action) transitionSignal
      requestSignal = Signal.map (\a ->
                        case Debug.log "action" a of
                          SubmitContact r -> r
                          None -> Http.request "" "" "" [])
  in
    Signal.map2
      (\r i -> Debug.log "complete" i)
      (Http.send (requestSignal actionSignal))
      transitionSignal

updates : Signal.Channel Update
updates = Signal.channel NoOp

userInput : Signal.Channel Transition
userInput = Signal.channel transition

submitForm = Contact.SubmitForm

process : Update -> Transition -> Transition
process update {state} =
  let currentContact = Maybe.withDefault Contact.initialState state.contact
  in
    Debug.log "app state" <| case update of
      NoOp -> { transition | state <- state }
      ContactUpdate (Contact.UpdateField field value) ->
        let updateField = Contact.updateField field value
            state' = { state | contact <- Just <| updateField currentContact }
        in
          { transition | state <- state' }
      (ContactUpdate submitForm) ->
        let action = SubmitContact <| Contact.submitRequest currentContact
        in
           { transition | state <- state, action <- action }

initialState =
  { contact = Nothing
  }

state : Signal Transition
state = Signal.foldp process transition (Signal.subscribe updates)

generalizeContactUpdate : Contact.Update -> Update
generalizeContactUpdate update = ContactUpdate update

container : Html.Html -> Transition -> Element
container outlet transition =
  Html.toElement 900 900
    (div [class "container"]
      [ header
      , outlet
      ])

handlers =
  let contactUpdate = LC.create generalizeContactUpdate updates
  in
    [ Routes.indexRoute                   <~ Home.view
    , (Routes.postsRoute, Posts.children) <@~ Posts.view
    , Routes.aboutRoute                   <~ About.view
    , Routes.colophonRoute                <~ Colophon.view
    , Routes.contact                      <~ Contact.view contactUpdate
    ]

header : Html.Html
header =
  Html.node "header" []
  [ ul []
    [ li [] [ linkTo "Home" "/" ]
    , li [] [ linkTo "Posts" "/posts" ]
    , li [] [ linkTo "About" "/about" ]
    , li [] [ linkTo "Contact" "/contact" ]
    , li [] [ linkTo "Colophon" "/colophon" ]
    ]
  , div []
    [ h1 [] [text "Welcome to this Website!"]
    ]
  ]
