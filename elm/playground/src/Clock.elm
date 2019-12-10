module Clock exposing (main)

import Browser
import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Task
import Time



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0)
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


handWidth =
    3.0


secondHandWidth =
    1.0


clockRadius =
    170.0


clockFaceRadius =
    clockRadius * 0.88


svgSize =
    clockRadius * 2


viewBoxSize =
    svgSize * 1.2


viewBoxSizeString =
    String.fromFloat viewBoxSize


drawClock : Int -> Int -> Int -> Html Msg
drawClock hour minute second =
    div []
        [ svg
            [ width (String.fromFloat svgSize)
            , height (String.fromFloat svgSize)
            , viewBox ("0 0 " ++ viewBoxSizeString ++ " " ++ viewBoxSizeString)
            ]
            (gradientDefs
                ++ clockFace
                ++ clockNumbers
            )
        ]


drawNumber : Int -> Svg Msg
drawNumber number =
    Svg.text_
        [ x (String.fromInt (number * 10))
        , y (String.fromInt (number * 10))
        , fontSize (String.fromFloat (clockRadius * 0.12))
        ]
        [ Html.text (String.fromInt number) ]


clockNumbers : List (Svg Msg)
clockNumbers =
    List.map drawNumber (List.range 1 12)


clockFace : List (Svg Msg)
clockFace =
    -- metal border
    [ circle
        [ cx (String.fromFloat clockRadius)
        , cy (String.fromFloat clockRadius)
        , r (String.fromFloat clockRadius)
        , fill "url(#metal)"
        ]
        []

    -- black edge
    , circle
        [ cx (String.fromFloat (clockRadius * 1.01))
        , cy (String.fromFloat (clockRadius * 1.01))
        , r (String.fromFloat (clockFaceRadius * 0.99))
        , fill "black"
        ]
        []

    -- white inner face
    , circle
        [ cx (String.fromFloat clockRadius)
        , cy (String.fromFloat clockRadius)
        , r (String.fromFloat clockFaceRadius)
        , fill "url(#clockFaceGradient)"
        ]
        []

    -- red second hand nub
    , circle
        [ cx (String.fromFloat clockRadius)
        , cy (String.fromFloat clockRadius)
        , r (String.fromFloat (clockFaceRadius * 0.035))
        , fill "#DD2222"
        ]
        []

    --, drawTicks
    --, drawHand hour "black" handWidth
    --, drawHand minute "black" handWidth
    --, drawHand second "#DD2222" secondHandWidth
    ]


gradientDefs : List (Svg Msg)
gradientDefs =
    [ defs
        []
        [ radialGradient
            [ id "clockFaceGradient"
            , cx "51%"
            , cy "51%"
            , r "50%"
            , fx "50%"
            , fy "50%"
            ]
            [ stop
                [ offset "90%"
                , Svg.Attributes.style "stop-color:rgb(255,255,255)"
                ]
                []
            , stop
                [ offset "100%"
                , Svg.Attributes.style "stop-color:rgb(188,188,188)"
                ]
                []
            ]
        , radialGradient
            [ id "metal"
            , cx "22%"
            , cy "25%"
            , r "99%"
            , fx "18%"
            , fy "20%"
            ]
            [ stop
                [ offset "0%"
                , Svg.Attributes.style "stop-color:rgb(222,222,222)"
                ]
                []
            , stop
                [ offset "45%"
                , Svg.Attributes.style "stop-color:rgb(128,128,128)"
                ]
                []
            ]
        ]
    ]


view : Model -> Html Msg
view model =
    let
        hour =
            Time.toHour model.zone model.time

        minute =
            Time.toMinute model.zone model.time

        second =
            Time.toSecond model.zone model.time
    in
    div []
        [ h1
            []
            [ Html.text
                (String.fromInt hour
                    ++ ":"
                    ++ String.fromInt minute
                    ++ ":"
                    ++ String.fromInt second
                )
            ]
        , drawClock hour minute second
        ]
