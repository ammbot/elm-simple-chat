module Login.Login exposing (..)

import Html as Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Login.Models exposing (Model)
import Login.Msgs exposing (Msg(..))

view : Model -> Html Msg
view model =
  div [ class "ui middle aligned center aligned grid" ]
    [ div [ class "column" ]
        [ header
        , loginForm
        ]
    ]

header : Html Msg
header =
  h2 [ class "ui teal header" ]
    [ div [ class "content" ]
        [ text "Enter your name" ]
    ]

loginForm : Html Msg
loginForm =
  div [ class "ui stacked segment" ]
    [ div [ class "field" ]
        [ div [ class "ui left icon input" ]
            [ i [ class "user icon" ] []
            , input [ onInput SetName, placeholder "Your name" ] []
            ]
        ]
    , div [ class "ui teal submit button", onClick Join ] [ text "login" ]
    ]
