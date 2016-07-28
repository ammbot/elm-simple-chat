module Main.Models exposing (..)

import Phoenix.Socket
import Phoenix.Channel

import Main.Msgs exposing (Msg)

import Login.Models as Login
import Rooms.Models as Rooms
import Chatbox.Models as Chatbox

type alias Model =
  { phxSocket : Phoenix.Socket.Socket Msg
  , login : Login.Model
  , chatbox : Chatbox.Model
  , rooms : Rooms.Model
  }

init : Model
init =
  { phxSocket = initPhxSocket
  , login = Login.init
  , chatbox = Chatbox.init
  , rooms = Rooms.init
  }

socketServer : String
socketServer =
  "ws://localhost:4000/socket/websocket"

initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
      |> Phoenix.Socket.withDebug
