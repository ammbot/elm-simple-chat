module Login.Models exposing (..)

import Login.Msgs exposing (State(..))

type alias Model =
  { name : String
  , state : State
  }

init : Model
init =
  Model "" Unjoin
