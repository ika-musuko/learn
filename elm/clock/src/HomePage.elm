module HomePage exposing (main)

import Browser
import Clock exposing (clock)
import Html exposing (..)
import Html.Attributes exposing (..)
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
    { time : Time.Posix
    , zones : List Time.Zone
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model (Time.millisToPosix 0)
        []
    , Task.perform AddCurrentTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AddCurrentTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AddCurrentTimeZone timeZone ->
            let
                newZones =
                    model.zones ++ [ timeZone ]
            in
            ( { model | zones = newZones }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


clockFromTime : Time.Posix -> String -> Time.Zone -> Html msg
clockFromTime time size zone =
    let
        hour =
            Time.toHour zone time

        minute =
            Time.toMinute zone time

        second =
            Time.toSecond zone time
    in
    clock hour minute second size


view : Model -> Html msg
view model =
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        ]
        (model.zones
            |> List.map (clockFromTime model.time "250px")
        )
