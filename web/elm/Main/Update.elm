module Main.Update exposing (..)

import Main.Msgs exposing (Msg)
import Main.Models exposing (Model)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( model, Cmd.none )
