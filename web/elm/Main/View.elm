module Main.View exposing (..)

import Html exposing (..)

import Main.Msgs exposing (Msg)
import Main.Models exposing (Model)

view : Model -> Html Msg
view model =
  div []
    [ text "hello" ]
