module Dice exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Random
import Svg exposing (..)
import Svg.Attributes exposing (..)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { dieFace : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model 1
    , Cmd.none
    )



-- UPDATE


type Msg
    = Roll
    | NewFace Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            ( model
            , Random.generate NewFace (Random.int 1 6)
            )

        NewFace newFace ->
            ( Model newFace
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


drawDots : Int -> List (Svg Msg)
drawDots dieFace =
    case dieFace of
        1 ->
            [ drawDot 50 50 ]

        2 ->
            [ drawDot 15 15
            , drawDot 85 85
            ]

        3 ->
            [ drawDot 15 15
            , drawDot 50 50
            , drawDot 85 85
            ]

        4 ->
            [ drawDot 15 15
            , drawDot 15 85
            , drawDot 85 15
            , drawDot 85 85
            ]

        5 ->
            [ drawDot 15 15
            , drawDot 15 85
            , drawDot 50 50
            , drawDot 85 15
            , drawDot 85 85
            ]

        6 ->
            [ drawDot 15 15
            , drawDot 15 85
            , drawDot 15 50
            , drawDot 85 50
            , drawDot 85 15
            , drawDot 85 85
            ]

        _ ->
            []


drawDot : Int -> Int -> Svg Msg
drawDot x y =
    circle
        [ cx (String.fromInt x)
        , cy (String.fromInt y)
        , r "10"
        ]
        []


drawDie : Int -> List (Svg Msg)
drawDie dieFace =
    [ rect
        [ width "100"
        , height "100"
        , rx "15"
        , ry "15"
        , fill "white"
        ]
        []
    ]
        ++ drawDots dieFace


view : Model -> Html Msg
view model =
    div []
        [ h1
            []
            [ Html.text (String.fromInt model.dieFace) ]
        , svg
            [ width "100"
            , height "100"
            , viewBox "0 0 120 120"
            ]
            (drawDie model.dieFace)
        , button [ onClick Roll ] [ Html.text "Roll" ]
        ]
