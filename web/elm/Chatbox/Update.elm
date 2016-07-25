module Chatbox.Update exposing (..)

import Chatbox.Msgs exposing (Msg(..))
import Chatbox.Models exposing (Model)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Send ->
      ( model, Cmd.none )

    SetMsg body ->
      ( { model | body = body }
      , Cmd.none
      )
