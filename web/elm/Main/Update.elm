module Main.Update exposing (..)

import String
import Json.Decode as JD
import Phoenix.Socket

import Main.Msgs exposing (Msg(..))
import Main.Models exposing (Model)
import Main.Commands exposing (joinChannel, push)

import Login.Msgs
import Login.Update
import Rooms.Msgs
import Rooms.Update
import Rooms.Models as Rooms
import Chatbox.Msgs
import Chatbox.Update
import Chatbox.Models as Chatbox

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    PhoenixMsg subMsg ->
      let
          ( phxSocket, phxCmd ) =
            Phoenix.Socket.update subMsg model.phxSocket
      in
          ( { model | phxSocket = phxSocket }
          , Cmd.map PhoenixMsg phxCmd
          )

    JoinedChannel room ->
      let
          ( updatedLogin, loginCmd ) =
            Login.Update.update Login.Msgs.Join model.login
          ( updatedRooms, roomCmd ) =
            Rooms.Update.update (Rooms.Msgs.SetSelf updatedLogin.name) model.rooms
      in
          ( { model | login = updatedLogin, rooms = updatedRooms }
          , Cmd.none
          )

    LeavedChannel room ->
      ( model, Cmd.none )

    ErrorChannel room ->
      let
          ( phxSocket, phxCmd ) =
            joinChannel model
      in
          ( { model | phxSocket = phxSocket }
          , Cmd.map PhoenixMsg phxCmd
          )

    JoinError room ->
      ( model, Cmd.none )

    RoomsMessage raw ->
      let
          ( updatedRooms, cmd ) =
            Rooms.Update.update (Rooms.Msgs.Refresh raw) model.rooms
      in
          ( { model | rooms = updatedRooms }
          , Cmd.map RoomsMsg cmd
          )

    ReceivedMessage raw ->
      ( model, Cmd.none )

    PrivateMessage raw ->
      ( model, Cmd.none )

    NewcomerMessage raw ->
      ( model, Cmd.none )

    PresenceMessage raw ->
      let
          ( updatedRooms, cmd ) =
            Rooms.Update.update (Rooms.Msgs.Presence raw) model.rooms
      in
          ( { model | rooms = updatedRooms }
          , Cmd.none
          )

    LoginMsg Login.Msgs.Join ->
      if not (String.isEmpty model.login.name) then
        let
            ( phxSocket, phxCmd ) =
              joinChannel model
        in
            ( { model | phxSocket = phxSocket }
            , Cmd.map PhoenixMsg phxCmd
            )
      else
        ( model, Cmd.none )

    LoginMsg subMsg ->
      let
          ( updatedLogin, cmd ) =
            Login.Update.update subMsg model.login
      in
          ( { model | login = updatedLogin }
          , Cmd.map LoginMsg cmd
          )

    RoomsMsg subMsg ->
      let
          ( updatedRooms, cmd ) =
            Rooms.Update.update subMsg model.rooms
      in
          ( { model | rooms = updatedRooms }
          , Cmd.map RoomsMsg cmd
          )

    ChatboxMsg Chatbox.Msgs.Send ->
      if not (String.isEmpty model.chatbox.body) then
        let
            ( phxSocket, phxCmd ) =
              push model
        in
            ( { model | phxSocket = phxSocket
              , chatbox = Chatbox.init
              }
            , Cmd.map PhoenixMsg phxCmd
            )
      else
        ( model, Cmd.none )

    ChatboxMsg subMsg ->
      let
          ( updatedChatbox, cmd ) =
            Chatbox.Update.update subMsg model.chatbox
      in
          ( { model | chatbox = updatedChatbox }
          , Cmd.map ChatboxMsg cmd
          )
