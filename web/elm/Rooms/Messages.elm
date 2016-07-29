module Rooms.Messages exposing (..)

import Dict
import List
import Html exposing (..)
import Html.Attributes exposing (..)

import Rooms.Msgs exposing (Msg)
import Rooms.Models exposing (Model, Message)

import Debug

view : Model -> List (Html Msg)
view model =
  let
      room =
        case Dict.get model.cursor model.rooms of
          Just room ->
            List.map (msgElem model.self) room.messages
          Nothing ->
            [ div [] [] ]
  in
      room

msgElem : String -> Message -> Html Msg
msgElem self message =
  if message.from == self then
    div [ class "ui segment right aligned" ]
      [ span [ class "ui small message" ]
          [ text message.body ]
      , span [ class "ui teal left pointing label" ]
          [ text message.from ]
      ]
  else
    div [ class "ui segment left aligned" ]
      [ span [ class "ui teal right pointing label" ]
          [ text message.from ]
      , span [ class "ui small message" ]
          [ text message.body ]
      ]
