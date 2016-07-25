module Login.Msgs exposing (..)

type State
  = Joined
  | Unjoin

type Msg
  = SetName String
  | Join
  | Leave
