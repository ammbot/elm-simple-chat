module Main.Update exposing (..)

import String
import Phoenix.Socket

import Main.Msgs exposing (Msg(..))
import Main.Models exposing (Model)
import Main.Commands exposing (joinChannel)

import Login.Msgs
import Login.Update

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
          ( updatedLogin, cmd ) =
            Login.Update.update Login.Msgs.Join model.login
      in
          ( { model | login = updatedLogin }
          , Cmd.map LoginMsg cmd
          )

    LeavedChannel room ->
      ( model, Cmd.none )

    JoinError room ->
      ( model, Cmd.none )

    ReceivedMessage raw ->
      ( model, Cmd.none )

    NewcomerMessage raw ->
      ( model, Cmd.none )

    PresenceMessage raw ->
      ( model, Cmd.none )

    LeavedMessage raw ->
      ( model, Cmd.none )

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
