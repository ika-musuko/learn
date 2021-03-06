module Clock exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
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


clockRadius =
    170


clockFaceRadius =
    clockRadius * 0.88


viewBoxSize =
    clockRadius * 2


svgSize =
    viewBoxSize


viewBoxSizeString =
    String.fromFloat viewBoxSize


fmod : Float -> Float -> Float
fmod lh rh =
    lh - (toFloat (floor (lh / rh)) * rh)


drawClock : Float -> Html Msg
drawClock timeInSeconds =
    let
        hour =
            timeInSeconds / 3600.0

        minute =
            fmod (timeInSeconds / 60) 60

        second =
            fmod (minute * 60) 60
    in
    div []
        [ svg
            [ Svg.Attributes.width "100%"
            , Svg.Attributes.height "100%"
            , viewBox ("0 0 " ++ viewBoxSizeString ++ " " ++ viewBoxSizeString)
            ]
            ((gradientDefs
                ++ clockFace
                ++ clockNumbers
                ++ clockTicks
             )
                ++ [ clockHand hour 12 "#333333" 6.0 0.45
                   , clockHand minute 60 "#333333" 6.0 0.7
                   , clockHand second 60 "#DD2222" 2.0 0.75

                   -- red second hand nub
                   , circle
                        [ cx (String.fromFloat clockRadius)
                        , cy (String.fromFloat clockRadius)
                        , r (String.fromFloat (clockFaceRadius * 0.035))
                        , Svg.Attributes.fill "#DD2222"
                        ]
                        []
                   ]
            )
        ]


clockHand : Float -> Float -> String -> Float -> Float -> Svg Msg
clockHand value maxValue color width length =
    let
        handRadius =
            clockRadius * length

        handPosition =
            value - (maxValue / 4.0)

        angle =
            handPosition * pi / (maxValue / 2)

        x1Pos =
            clockRadius + (handRadius * cos angle)

        y1Pos =
            clockRadius + (handRadius * sin angle)

        handStyle =
            "stroke:" ++ color ++ ";stroke-width:" ++ String.fromFloat width
    in
    line
        [ x1 (String.fromFloat x1Pos)
        , y1 (String.fromFloat y1Pos)
        , x2 (String.fromFloat clockRadius)
        , y2 (String.fromFloat clockRadius)
        , Svg.Attributes.style handStyle
        ]
        []


drawTick : Int -> Svg Msg
drawTick number =
    let
        isMainTick =
            remainderBy 5 number == 0

        tickRadius =
            clockRadius * 0.84

        tickLength =
            if isMainTick then
                tickRadius * 0.92

            else
                tickRadius * 0.95

        xSize =
            clockRadius - clockRadius * 0.0

        ySize =
            clockRadius + clockRadius * 0.0

        tickPosition =
            toFloat number - 15

        angle =
            tickPosition * pi / 30

        x1Pos =
            xSize + (tickRadius * cos angle)

        y1Pos =
            ySize + (tickRadius * sin angle)

        x2Pos =
            xSize + (tickLength * cos angle)

        y2Pos =
            ySize + (tickLength * sin angle)

        tickStyle =
            if isMainTick then
                "stroke:rgb(66, 66, 66);stroke-width:3"

            else
                "stroke:rgb(222, 44, 44);stroke-width:1"
    in
    line
        [ x1 (String.fromFloat x1Pos)
        , y1 (String.fromFloat y1Pos)
        , x2 (String.fromFloat x2Pos)
        , y2 (String.fromFloat y2Pos)
        , Svg.Attributes.style tickStyle
        ]
        []


clockTicks : List (Svg Msg)
clockTicks =
    List.map drawTick (List.range 0 59)


drawNumber : Int -> Svg Msg
drawNumber number =
    let
        numberRadius =
            clockRadius * 0.65

        xSize =
            clockRadius - clockRadius * 0.0

        ySize =
            clockRadius + clockRadius * 0.05

        numberPosition =
            toFloat number - 3

        xPos =
            xSize + (numberRadius * cos (numberPosition * pi / 6))

        yPos =
            ySize + (numberRadius * sin (numberPosition * pi / 6))
    in
    Svg.text_
        [ x (String.fromFloat xPos)
        , y (String.fromFloat yPos)
        , fontSize (String.fromFloat (clockRadius * 0.15))
        , fontFamily "Noto Sans"
        , fontWeight "bold"
        , Svg.Attributes.fill "#555555"
        , textAnchor "middle"
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
        , Svg.Attributes.fill "url(#metal)"
        ]
        []

    -- black edge
    , circle
        [ cx (String.fromFloat (clockRadius * 1.01))
        , cy (String.fromFloat (clockRadius * 1.01))
        , r (String.fromFloat (clockFaceRadius * 0.99))
        , Svg.Attributes.fill "black"
        ]
        []

    -- white inner face
    , circle
        [ cx (String.fromFloat clockRadius)
        , cy (String.fromFloat clockRadius)
        , r (String.fromFloat clockFaceRadius)
        , Svg.Attributes.fill "url(#clockFaceGradient)"
        ]
        []
    ]


gradientDefs : List (Svg Msg)
gradientDefs =
    [ defs
        []
        [ radialGradient
            [ Svg.Attributes.id "clockFaceGradient"
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
            [ Svg.Attributes.id "metal"
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
    div
        [ Html.Attributes.style "margin" "auto"
        , Html.Attributes.style "width" "50%"
        , Html.Attributes.style "top" "50%"
        , Html.Attributes.style "text-align" "center"
        ]
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
        , drawClock (toFloat (hour * 3600 + minute * 60 + second))
        ]
