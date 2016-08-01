module Rooms.Update exposing (..)

import Dict
import Json.Decode as JD

import Rooms.Msgs exposing (Msg(..))
import Rooms.Models exposing (
  Model, Room, State(..),
  decodePresence, decodeRooms, decodeMessage,
  presenceToRoom, addNewMessage, setCursor)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Presence raw ->
      case JD.decodeValue decodePresence raw of
        Ok presence ->
          let
              updatedRooms =
                Dict.update presence.name (\room ->
                  case room of
                    Just room' ->
                      Just { room' | state = presence.state }
                    Nothing ->
                      Just ( presenceToRoom presence )
                ) model.rooms
          in
              ( { model | rooms = updatedRooms }
              , Cmd.none
              )
        Err err ->
          ( model, Cmd.none )

    SetCursor room ->
      let
          updatedModel =
            setCursor room model
      in
          ( updatedModel, Cmd.none )

    SetSelf room ->
      ( { model | self = room }
      , Cmd.none
      )

    Refresh raw ->
      case JD.decodeValue decodeRooms raw of
        Ok r ->
          let
              rooms =
                r
                  |> List.map (\room -> (room.name, room))
                  |> Dict.fromList
          in
              ( { model | rooms = rooms }
              , Cmd.none
              )
        Err err ->
          ( model, Cmd.none )

    NewMessage raw ->
      case JD.decodeValue decodeMessage raw of
        Ok message ->
          let
              updatedModel =
                addNewMessage message model
          in
              ( updatedModel , Cmd.none )

        Err err ->
          ( model, Cmd.none )
