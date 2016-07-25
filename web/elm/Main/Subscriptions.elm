module Main.Subscriptions exposing (..)

import Phoenix.Socket

import Main.Msgs exposing (Msg(..))
import Main.Models exposing (Model)

subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.phxSocket PhoenixMsg
