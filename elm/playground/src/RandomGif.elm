module RandomGif exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, map2, string)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Failure
    | Loading
    | Success GifData


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getRandomDogGif )


type alias GifData =
    { image_url : String
    , title : String
    }



-- UPDATE


type Msg
    = MorePlease
    | GotGif (Result Http.Error GifData)


update : Msg -> model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MorePlease ->
            ( Loading, getRandomDogGif )

        GotGif result ->
            case result of
                Ok gifData ->
                    ( Success gifData, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Random dogs" ]
        , viewGif model
        ]


viewGif : Model -> Html Msg
viewGif model =
    case model of
        Failure ->
            div []
                [ text "dogs could not load..."
                , button [ onClick MorePlease ] [ text "Try again" ]
                ]

        Loading ->
            text "loadog..."

        Success gifData ->
            div []
                [ button [ onClick MorePlease, style "display" "block" ] [ text "more dogz pls" ]
                , h3 [] [ text gifData.title ]
                , img [ src gifData.image_url ] []
                ]



-- HTTP


getRandomDogGif : Cmd Msg
getRandomDogGif =
    Http.get
        { url = "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=dog"
        , expect = Http.expectJson GotGif gifDecoder
        }


gifDecoder : Decoder GifData
gifDecoder =
    map2 GifData
        (field "data" (field "image_url" string))
        (field "data" (field "title" string))
