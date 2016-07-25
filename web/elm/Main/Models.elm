module Main.Models exposing (..)

import Phoenix.Socket
import Phoenix.Channel

import Main.Msgs exposing (Msg)

import Login.Models

type alias Model =
  { phxSocket : Phoenix.Socket.Socket Msg
  , login : Login.Models.Model }

init : Model
init =
  { phxSocket = initPhxSocket
  , login = Login.Models.init }

socketServer : String
socketServer =
  "ws://localhost:4000/socket/websocket"

initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
      |> Phoenix.Socket.withDebug
