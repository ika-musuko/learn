module Password exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { name : String
    , password : String
    , confirmPassword : String
    }


init : Model
init =
    Model "" "" ""



-- UPDATE


type Msg
    = Name String
    | Password String
    | ConfirmPassword String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name name ->
            { model | name = name }

        Password password ->
            { model | password = password }

        ConfirmPassword confirmPassword ->
            { model | confirmPassword = confirmPassword }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewInput "Name" "text" "Name" model.name Name
        , viewInput "Password" "password" "Password" model.password Password
        , viewInput "Confirm Password" "password" "Confirm Password" model.confirmPassword ConfirmPassword
        , viewValidation model
        ]


viewInput : String -> String -> String -> String -> (String -> msg) -> Html msg
viewInput l t p v toMsg =
    div []
        [ label [] [ text l ]
        , input [ type_ t, placeholder p, value v, onInput toMsg ] []
        ]


isNotAlphaNum : Char -> Bool
isNotAlphaNum c =
    not (Char.isAlphaNum c)


viewValidation : Model -> Html msg
viewValidation model =
    if not (String.any isNotAlphaNum model.password) then
        errorMessage "Password must have a symbol"

    else if String.length model.password < 8 then
        errorMessage "Password must be more than 8 characters!"

    else if not (String.any Char.isUpper model.password) then
        errorMessage "Password must have uppercase letter"

    else if not (String.any Char.isLower model.password) then
        errorMessage "Password must have lowercase letter"

    else if not (String.any Char.isDigit model.password) then
        errorMessage "Password must have a number"

    else if model.password /= model.confirmPassword then
        errorMessage "Passwords do not match"

    else
        successMessage "OK!"


errorMessage : String -> Html msg
errorMessage message =
    div [ style "color" "red" ] [ text message ]


successMessage : String -> Html msg
successMessage message =
    div [ style "color" "green" ] [ text message ]
