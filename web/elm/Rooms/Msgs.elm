module Rooms.Msgs exposing (..)

import Json.Encode as JE

type Msg
  = Presence JE.Value
  | SetCursor String
  | SetSelf String
  | Refresh JE.Value
