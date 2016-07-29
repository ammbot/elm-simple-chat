module Rooms.Models exposing (..)

import Dict exposing (Dict)
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))

type State
  = Online
  | Offline

type alias Message =
  { id: String
  , from : String
  , to : String
  , body : String
  }

type alias Room =
  { name : String
  , state : State
  , messages: List Message
  , badge : Int
  }

type alias Model =
  { rooms : Dict String Room
  , cursor : String
  , self : String
  }

init : Model
init =
  Model Dict.empty "lobby" ""

toRoom : String -> String -> (List Message) -> Int -> Room
toRoom name state messages badge =
  let
      state' =
        case state of
          "online" ->
            Online
          _ ->
            Offline
  in
      Room name state' messages badge

decodeRoom : JD.Decoder Room
decodeRoom =
  JD.object4 toRoom
    (JD.at ["room", "name"] JD.string)
    (JD.at ["room", "state"] JD.string)
    (decodeMessages)
    (JD.succeed 0) -- FIXME


decodeMessage : JD.Decoder Message
decodeMessage =
  JD.object4 Message
    ("id" := JD.string)
    ("from" := JD.string)
    ("to" := JD.string)
    ("body" := JD.string)

decodeMessages : JD.Decoder (List Message)
decodeMessages =
  JD.at ["messages"] (JD.list decodeMessage)

decodeRooms : JD.Decoder (List Room)
decodeRooms =
  JD.at ["rooms"] (JD.list decodeRoom)

isOnline : Room -> Bool
isOnline room =
  room.state == Online
