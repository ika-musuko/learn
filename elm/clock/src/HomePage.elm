module HomePage exposing (main)

import Browser
import Clock exposing (clock)
import Dict exposing (Dict, get, keys)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List.Extra exposing (getAt, setAt)
import Task
import Time
import TimeZone exposing (zones)



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
    , zones : List String
    }


utc =
    "Atlantic/Reykjavik"


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model (Time.millisToPosix 0)
        []
    , TimeZone.getZone |> Task.attempt GetLocalTimeZone
    )



-- UPDATE


addNewZone : String -> Model -> ( Model, Cmd Msg )
addNewZone zoneName model =
    let
        newZones =
            model.zones ++ [ zoneName ]
    in
    ( { model | zones = newZones }
    , Cmd.none
    )


changeZoneAt : Int -> String -> Model -> ( Model, Cmd Msg )
changeZoneAt index zoneName model =
    let
        newZones =
            model.zones |> setAt index zoneName
    in
    ( { model | zones = newZones }
    , Cmd.none
    )


type Msg
    = Tick Time.Posix
    | AddTimeZone String
    | ChangeTimeZone Int String
    | DeleteClock Int
    | GetLocalTimeZone (Result TimeZone.Error ( String, Time.Zone ))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetLocalTimeZone result ->
            let
                firstZone =
                    case result of
                        Ok ( zoneName, zone ) ->
                            zoneName

                        Err error ->
                            "Atlantic/Reykjavik"
            in
            model |> addNewZone firstZone

        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AddTimeZone zoneName ->
            model |> addNewZone zoneName

        ChangeTimeZone index zoneName ->
            model |> changeZoneAt index zoneName

        DeleteClock index ->
            let
                newZones =
                    (model.zones |> List.take index)
                        ++ (model.zones |> List.drop (index + 1))
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


option : Bool -> String -> Html msg
option isSelected name =
    Html.option
        [ value name
        , selected isSelected
        ]
        [ text name ]


zoneOptions : String -> List (Html msg)
zoneOptions zoneName =
    [ zoneName |> option True ]
        ++ (zones
                |> Dict.keys
                |> List.map (option False)
           )


clockWidget : Model -> Int -> Time.Zone -> Html Msg
clockWidget model index zone =
    div
        []
        [ clockFromTime model.time "250px" zone
        , select
            [ Html.Events.onInput (ChangeTimeZone index) ]
            (model.zones
                |> getAt index
                |> Maybe.withDefault utc
                |> zoneOptions
            )
        , button
            [ onClick (DeleteClock index) ]
            [ text "Delete" ]
        ]


allZones : Dict String Time.Zone
allZones =
    zones
        |> Dict.map (\zoneName lazyZone -> lazyZone ())


getZoneFromName : String -> Time.Zone
getZoneFromName zoneName =
    allZones
        |> Dict.get zoneName
        |> Maybe.withDefault Time.utc


view : Model -> Html Msg
view model =
    div []
        [ div
            [ style "display" "flex"
            , style "flex-direction" "row"
            , style "flex-wrap" "wrap"
            ]
            (model.zones
                |> List.map getZoneFromName
                |> List.indexedMap (clockWidget model)
            )
        , button
            [ onClick (AddTimeZone utc) ]
            [ text "Add clock" ]
        ]
