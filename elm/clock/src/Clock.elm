module Clock exposing (clock)

import Html exposing (..)
import Html.Attributes exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)


fmod : Float -> Float -> Float
fmod lh rh =
    lh - (toFloat (floor (lh / rh)) * rh)


drawClock : Float -> Html msg
drawClock timeInSeconds =
    let
        -- size related
        clockRadius =
            170.0

        clockFaceRadius =
            clockRadius * 0.88

        handWidth =
            clockRadius * 0.05

        secondHandWidth =
            clockRadius * 0.02

        viewBoxSize =
            clockRadius * 2

        svgSize =
            viewBoxSize

        viewBoxSizeString =
            String.fromFloat viewBoxSize

        -- time related
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
                ++ clockFace clockRadius clockFaceRadius
                ++ clockNumbers clockRadius
                ++ clockTicks clockRadius
             )
                ++ [ clockHand hour 12 "#333333" 6.0 0.45 clockRadius
                   , clockHand minute 60 "#333333" 6.0 0.7 clockRadius
                   , clockHand second 60 "#DD2222" 2.0 0.75 clockRadius

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


clockHand : Float -> Float -> String -> Float -> Float -> Float -> Svg msg
clockHand value maxValue color width length clockRadius =
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


drawTick : Float -> Int -> Svg msg
drawTick clockRadius number =
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

        tickPosition =
            toFloat number - 15

        angle =
            tickPosition * pi / 30

        x1Pos =
            clockRadius + (tickRadius * cos angle)

        y1Pos =
            clockRadius + (tickRadius * sin angle)

        x2Pos =
            clockRadius + (tickLength * cos angle)

        y2Pos =
            clockRadius + (tickLength * sin angle)

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


clockTicks : Float -> List (Svg msg)
clockTicks clockRadius =
    List.range 0 59
        |> List.map (drawTick clockRadius)


drawNumber : Int -> Float -> Svg msg
drawNumber number clockRadius =
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


clockNumbers : Float -> List (Svg msg)
clockNumbers clockRadius =
    let
        drawNumberWithRadius number =
            drawNumber number clockRadius
    in
    List.map drawNumberWithRadius (List.range 1 12)


clockFace : Float -> Float -> List (Svg msg)
clockFace clockRadius clockFaceRadius =
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


gradientDefs : List (Svg msg)
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


clock : Int -> Int -> Int -> String -> Html msg
clock hour minute second size =
    div
        [ Html.Attributes.style "width" size
        , Html.Attributes.style "height" size
        , Html.Attributes.style "display" "flex"
        , Html.Attributes.style "align-items" "center"
        , Html.Attributes.style "justify-content" "center"
        ]
        [ div
            [ Html.Attributes.style "width" "100%"
            ]
            [ drawClock (toFloat (hour * 3600 + minute * 60 + second)) ]
        ]


