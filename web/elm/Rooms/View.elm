module Rooms.View exposing (..)

import Html.App
import Html exposing (..)
import Html.Attributes exposing (..)

import Rooms.Msgs exposing (Msg)
import Rooms.Models exposing (Model)
import Rooms.Rooms as Rooms
import Rooms.Messages as Messages

view : Model -> Html Msg
view model =
  div [ class "row" ]
    [ div [ class "six wide column" ]
        [ div [ class "ui segment" ]
            [ Rooms.view model ]
        ]
        , div [ class "eight wide column" ]
            ( Messages.view model )
    ]
