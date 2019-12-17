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
    , searchResults : Dict Int (List String)
    }


utc =
    "Atlantic/Reykjavik"


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model (Time.millisToPosix 0) [] Dict.empty
    , TimeZone.getZone |> Task.attempt GetLocalTimeZone
    )



-- UPDATE


addClock : String -> Model -> ( Model, Cmd Msg )
addClock zoneName model =
    ( { model | zones = model.zones ++ [ zoneName ] }
    , Cmd.none
    )


changeClockAt : Int -> String -> Model -> ( Model, Cmd Msg )
changeClockAt index zoneName model =
    ( { model
        | zones = model.zones |> setAt index zoneName
        , searchResults = Dict.empty
      }
    , Cmd.none
    )


deleteClockAt : Int -> Model -> ( Model, Cmd Msg )
deleteClockAt index model =
    let
        newZones =
            (model.zones |> List.take index)
                ++ (model.zones |> List.drop (index + 1))
    in
    ( { model
        | zones = newZones
        , searchResults = Dict.empty
      }
    , Cmd.none
    )


searchZones : String -> List String
searchZones query =
    case query of
        "" ->
            []

        _ ->
            zones
                |> Dict.keys
                |> List.filter
                    (\zone ->
                        String.toUpper zone
                            |> String.contains (query |> String.toUpper |> String.replace " " "_")
                    )


populateZoneSearchResults : Int -> String -> Model -> ( Model, Cmd Msg )
populateZoneSearchResults index query model =
    ( { model | searchResults = model.searchResults |> Dict.insert index (query |> searchZones) }
    , Cmd.none
    )


type Msg
    = Tick Time.Posix
    | AddClock String
    | ChangeClock Int String
    | DeleteClock Int
    | SearchZone Int String
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
            model |> addClock firstZone

        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AddClock zoneName ->
            model |> addClock zoneName

        ChangeClock index zoneName ->
            model |> changeClockAt index zoneName

        DeleteClock index ->
            model |> deleteClockAt index

        SearchZone index query ->
            model |> populateZoneSearchResults index query



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
    let
        zoneName =
            model.zones
                |> getAt index
                |> Maybe.withDefault utc

        searchResults =
            model.searchResults
                |> Dict.get index
                |> Maybe.withDefault []
    in
    div
        []
        [ clockFromTime model.time "250px" zone
        , h5 [] [ text zoneName ]
        , input
            [ Html.Events.onInput (SearchZone index)
            , placeholder "Search Timezone"
            ]
            []
        , searchResults
            |> List.map (\match -> li [] [ text match ])
            |> ul []
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
            [ onClick (AddClock utc) ]
            [ text "Add clock" ]
        ]
