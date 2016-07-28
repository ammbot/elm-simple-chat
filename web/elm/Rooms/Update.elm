module Rooms.Update exposing (..)

import Dict
import Json.Decode as JD

import Rooms.Msgs exposing (Msg(..))
import Rooms.Models exposing (Model, Room, decodeRoom, decodeRooms)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Presence raw ->
      case JD.decodeValue decodeRoom raw of
        Ok room ->
          let
              updatedRooms =
                Dict.update room.name (\_ -> Just room) model.rooms
          in
              ( { model | rooms = updatedRooms }
              , Cmd.none
              )
        Err _ ->
          ( model, Cmd.none )

    SetCursor room ->
      ( { model | cursor = room }
      , Cmd.none
      )

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
