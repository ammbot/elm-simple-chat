module Rooms.Models exposing (..)

import Dict exposing (Dict)
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))

type State
  = Online
  | Offline

type alias Presence =
  { name : String
  , state : State
  }

type alias Message =
  { id : String
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

presenceToRoom : Presence -> Room
presenceToRoom presence =
  Room presence.name presence.state [] 0

toState : String -> State
toState state =
  case state of
    "online" ->
      Online
    _ ->
      Offline

toPresence : String -> String -> Presence
toPresence name state =
  Presence name (toState state)

toRoom : String -> String -> (List Message) -> Int -> Room
toRoom name state messages badge =
  Room name (toState state) messages badge

decodePresence : JD.Decoder Presence
decodePresence =
  JD.object2 toPresence
    ("name" := JD.string)
    ("state" := JD.string)

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
