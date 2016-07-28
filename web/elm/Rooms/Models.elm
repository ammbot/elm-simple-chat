module Rooms.Models exposing (..)

import Dict exposing (Dict)
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))

type State
  = Online
  | Offline

type alias Room =
  { name : String
  , state : State
  }

type alias Model =
  { rooms : Dict String Room
  , cursor : String
  , self : String
  }

init : Model
init =
  Model Dict.empty "lobby" ""

toRoom : String -> String -> Room
toRoom name state =
  case state of
    "online" ->
      Room name Online

    _ ->
      Room name Offline

decodeRoom : JD.Decoder Room
decodeRoom =
  JD.object2 toRoom
    ("name" := JD.string)
    ("state" := JD.string)
      

decodeRooms : JD.Decoder (List Room)
decodeRooms =
  JD.at ["rooms"] (JD.list decodeRoom)

isOnline : Room -> Bool
isOnline room =
  room.state == Online
