module Login.Update exposing (..)

import Login.Models exposing (Model)
import Login.Msgs exposing (Msg(..), State(..))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SetName name ->
      ( { model | name = name }
      , Cmd.none
      )

    Join ->
      ( { model | state = Joined }
      , Cmd.none
      )

    Leave ->
      ( { model | state = Unjoin }
      , Cmd.none
      )
