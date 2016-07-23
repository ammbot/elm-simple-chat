module Main.Subscriptions exposing (..)

import Main.Msgs exposing (Msg)
import Main.Models exposing (Model)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
