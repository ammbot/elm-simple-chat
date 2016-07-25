module Main.Commands exposing (..)

import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode as JE

import Main.Msgs exposing (Msg(..))
import Main.Models exposing (Model)

joinChannel : Model -> ( Phoenix.Socket.Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
joinChannel model =
  let
      room =
        "room:lobby"
      payload =
        JE.object [ ("name", JE.string model.login.name) ]
      channel =
        Phoenix.Channel.init room
          |> Phoenix.Channel.withPayload payload
          |> Phoenix.Channel.onJoin (always (JoinedChannel room))
          |> Phoenix.Channel.onClose (always (LeavedChannel room))
          |> Phoenix.Channel.onError (always (ErrorChannel room))
          |> Phoenix.Channel.onJoinError (always (JoinError room))
      ( phxSocket, phxCmd ) =
          model.phxSocket
            |> Phoenix.Socket.on "shout" room ReceivedMessage
            |> Phoenix.Socket.on "private" room PrivateMessage
            |> Phoenix.Socket.on "newcomer" room NewcomerMessage
            |> Phoenix.Socket.on "presence" room PresenceMessage
            |> Phoenix.Socket.on "leave" room LeavedMessage
            |> Phoenix.Socket.join channel
  in
      ( phxSocket , phxCmd )

push : Model -> ( Phoenix.Socket.Socket Msg, Cmd (Phoenix.Socket.Msg Msg))
push model =
  let
      payload =
        JE.object [ ("body", JE.string model.chatbox.body)
                  , ("from", JE.string model.login.name)
                  , ("to", JE.string "room:lobby")  -- FIXME
                  ]
      push' =
        Phoenix.Push.init "shout" "room:lobby"
          |> Phoenix.Push.withPayload payload
      ( phxSocket, phxCmd) =
        Phoenix.Socket.push push' model.phxSocket
  in
      ( phxSocket, phxCmd )
