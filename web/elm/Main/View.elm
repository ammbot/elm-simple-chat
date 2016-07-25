module Main.View exposing (..)

import Html exposing (..)
import Html.App

import Main.Msgs exposing (Msg(..))
import Main.Models exposing (Model)

import Login.Login as Login
import Login.Msgs

view : Model -> Html Msg
view model =
  case model.login.state of
    Login.Msgs.Joined ->
      div [] [ text "Welcome" ]
    Login.Msgs.Unjoin ->
      Html.App.map LoginMsg (Login.view model.login)
