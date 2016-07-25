module Chatbox.Chatbox exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Chatbox.Msgs exposing (Msg(..))
import Chatbox.Models exposing (Model)

view : Model -> Html Msg
view model =
  Html.form [ class "ui form", onSubmit Send ]
    [ div [ class "ui fluid icon input" ]
        [ input [ placeholder "Message..."
                , onInput SetMsg
                , autofocus True
                , value model.body ] []
        , i [ class "send icon" ] []
        ]
    ]
