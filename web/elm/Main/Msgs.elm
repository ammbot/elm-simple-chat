module Main.Msgs exposing (..)

import Phoenix.Socket

import Json.Encode as JE

import Login.Msgs
import Chatbox.Msgs

type Msg
  = PhoenixMsg (Phoenix.Socket.Msg Msg)
  | JoinedChannel String
  | LeavedChannel String
  | JoinError String
  | ReceivedMessage JE.Value
  | NewcomerMessage JE.Value
  | PresenceMessage JE.Value
  | LeavedMessage JE.Value
  | LoginMsg Login.Msgs.Msg
  | ChatboxMsg Chatbox.Msgs.Msg
