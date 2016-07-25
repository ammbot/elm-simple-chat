module Chatbox.Models exposing (..)

type alias Model =
  { body : String }

init : Model
init =
  Model ""
