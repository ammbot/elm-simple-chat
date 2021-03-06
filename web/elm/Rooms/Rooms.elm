module Rooms.Rooms exposing (..)

import Dict

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Rooms.Msgs exposing (Msg(..))
import Rooms.Models exposing (Model, Room, isOnline)

import Debug

view : Model -> Html Msg
view model =
  let
      users =
        model.rooms
          |> Dict.remove "lobby"
          |> Dict.remove model.self
      lobbyBadge =
        case Dict.get "lobby" model.rooms of
          Just lobby -> lobby.badge
          Nothing -> 0
      rooms =
        users
          |> Dict.values
          |> List.map (listRooms model.cursor)
      active =
        isActive model.cursor "lobby"
      lobby =
        [ a [ class ("teal item " ++ active), onClick (SetCursor "lobby") ]
            [ text "Lobby"
            , div [ class "ui teal label" ]
                [ text (toString lobbyBadge) ]
            ]
        ]
  in
      div [ class "ui vertical menu" ]
        ( lobby ++ rooms )

listRooms : String -> Room -> Html Msg
listRooms cursor room =
  let
      color = roomColor room
  in
      a [ class ("teal item " ++ (isActive cursor room.name)), onClick (SetCursor room.name) ]
        [ text room.name
        , div [ class ("ui label " ++ color) ]
            [ text (toString room.badge) ]
        ]

roomColor : Room -> String
roomColor room =
  if isOnline room then
    "green"
  else
    "red"

isActive : String -> String -> String
isActive room row =
  if room == row then
    "active"
  else
    ""
