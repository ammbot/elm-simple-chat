module Main.Msgs exposing (..)

import Phoenix.Socket

import Json.Encode as JE

import Login.Msgs
import Rooms.Msgs
import Chatbox.Msgs

type Msg
  = PhoenixMsg (Phoenix.Socket.Msg Msg)
  | JoinedChannel String
  | LeavedChannel String
  | ErrorChannel String
  | JoinError String
  | RoomsMessage JE.Value
  | ReceivedMessage JE.Value
  | NewcomerMessage JE.Value
  | PresenceMessage JE.Value
  | LoginMsg Login.Msgs.Msg
  | RoomsMsg Rooms.Msgs.Msg
  | ChatboxMsg Chatbox.Msgs.Msg
