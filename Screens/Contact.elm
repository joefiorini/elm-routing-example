module Screens.Contact where

import Json.Decode (at, string)
import Json.Decode as Json
import Json.Encode as Encode
import Json.Encode (object)
import Http
import Signal
import Debug

import Html
import Html (input, textarea, form, text, label, button)
import Html.Attributes (name, id, type')
import Html.Events (on, onClick)
import LocalChannel as LC

type Update = UpdateField String String
            | SubmitForm
            | NoOp

type alias Model =
  { name : String
  , email : String
  , description : String
  }

targetValue : Json.Decoder String
targetValue =
  at [ "target", "value" ] string


sendUpdate : String -> LC.LocalChannel Update -> String -> Signal.Message
sendUpdate fieldName channel value =
  LC.send channel (UpdateField fieldName value)

textField fieldName channel =
  input
    [ name fieldName
    , id fieldName
    , type' "text"
    , on "change" targetValue (sendUpdate fieldName channel)
    ]
    []

textArea : String -> LC.LocalChannel Update -> Html.Html
textArea fieldName channel =
  textarea
    [ name fieldName
    , id fieldName
    , on "change" targetValue (sendUpdate fieldName channel)
    ] []

label' fieldLabel =
  label [] [ text fieldLabel ]

view updateChannel =
  form []
    [ label' "Name"
    , textField "name" updateChannel
    , label' "Email"
    , textField "email" updateChannel
    , label' "Description"
    , textArea "description" updateChannel
    , button
      [ onClick (LC.send updateChannel SubmitForm) ] [ text "Submit" ]
    ]

initialState : Model
initialState =
  { name = ""
  , email = ""
  , description = ""
  }

updateField : String -> String -> Model -> Model
updateField field value contact =
  Debug.log "updateField" <| case field of
    "name" ->
      { contact | name <- value }
    "email" ->
      { contact | email <- value }
    "body" ->
      { contact | email <- value }
    otherwise ->
      contact

modelToJson : Model -> String
modelToJson model =
  Encode.encode 0
    (object
      [ ("name", Encode.string model.name)
      , ("email", Encode.string model.email)
      , ("description", Encode.string model.description)
      ])

-- submitContact : Model -> Signal (Http.Request String)
-- submitContact model =

submit : Model -> Http.Request String
submit contact = (Http.post "/contact" <| modelToJson contact)

submitRequest : Model -> Http.Request String
submitRequest model =
  let url = "https://zapier.com/hooks/catch/okmfri/"
  in
    Http.post url <| modelToJson model
