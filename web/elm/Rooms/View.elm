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
  div [ class "row equal height", style [("height", "500px")] ]
    [ div [ class "six wide column", style [("overflow-y", "scroll")] ]
        [ div [ class "ui segment" ]
            [ Rooms.view model ]
        ]
        , div [ class "eight wide column", style [("overflow-y", "scroll")] ]
            ( Messages.view model )
    ]
