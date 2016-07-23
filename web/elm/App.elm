module App exposing (..)

import Html.App

import Main.Msgs exposing (Msg)
import Main.View exposing (view)
import Main.Update exposing (update)
import Main.Models as Models exposing (Model)
import Main.Subscriptions exposing (subscriptions)

init : ( Model, Cmd Msg )
init =
  ( Models.init, Cmd.none )


main : Program Never
main =
  Html.App.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }
