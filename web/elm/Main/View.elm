module Main.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App

import Main.Msgs exposing (Msg(..))
import Main.Models exposing (Model)

import Login.Msgs
import Login.Login as Login
import Rooms.View as Rooms
import Rooms.Messages as Messages
import Chatbox.Chatbox as Chatbox

import Debug

view : Model -> Html Msg
view model =
  case model.login.state of
    Login.Msgs.Joined ->
      div [ class "ui stackable fluid column grid" ]
        [ Html.App.map RoomsMsg (Rooms.view model.rooms)
        , div [ class "row" ]
            [ div [ class "column" ]
                [ Html.App.map ChatboxMsg (Chatbox.view model.chatbox) ]
            ]
        ]

    Login.Msgs.Unjoin ->
      Html.App.map LoginMsg (Login.view model.login)
