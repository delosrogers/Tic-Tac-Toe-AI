module Main exposing (main)

import AIPlayer
import Array
import Browser
import Canvas
import Canvas.Settings
import Canvas.Settings.Text
import Debug
import GameLogic exposing (..)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Events.Extra.Mouse as Mouse
import Http
import Json.Decode exposing (Decoder, array, field, int, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Serialize as S
import Types exposing (..)


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }


init : Model
init =
    { board = Array.fromList (PlayerX :: List.repeat 15 NoOne)
      , currentPlayer = PlayerO
      , message = ""
      , mousepos = ( 0, 0 )
      , ai = True
      , id_ = Maybe.Nothing
      }



-- getGameFromSave : String -> Cmd Msg
-- getGameFromSave id =
--     Http.get
--     { url = "http://localhost:5000/api/saves/" ++ id
--     , expect = Http.expectJson }
-- modelDecoder : Decoder Model
-- modelDecoder =
--     Decode.succeed Model
--     Json.map6
--         (field)


type Msg
    = Reset
    | MouseClick Mouse.Event
    | AIPlay
    | TogleAI


update : Msg -> Model -> Model
update msg model =
    case msg of
        MouseClick event ->
            let
                ( x, y ) =
                    event.offsetPos

                numRows =
                    Array.length model.board |> toFloat |> sqrt |> round
            in
            -- TODO remove hardcoded values that lock this to being just a 3 by 3 board 500 px by 500 px
            updateBoard ((x |> Basics.round) // (500 // numRows) + ((y |> Basics.round) // (500 // numRows) |> (*) numRows)) model False

        AIPlay ->
            updateBoard 0 model True

        Reset ->
            init

        TogleAI ->
            { model | ai = not model.ai }


useAIPlayer : Model -> Int -> Bool -> Maybe.Maybe Int
useAIPlayer model humanMove aiPlay =
    if model.ai && model.currentPlayer == PlayerX && aiPlay then
        Just (AIPlayer.bestMove model.board)

    else if model.currentPlayer == PlayerO then
        Just humanMove

    else if not model.ai then
        Just humanMove

    else
        Maybe.Nothing


updateBoard : Int -> Model -> Bool -> Model
updateBoard cell model aiPlay =
    let
        tmpModel =
            { model | board = boardSet (useAIPlayer model (Debug.log "cell" cell) aiPlay) model.currentPlayer model.board }
    in
    if model.message == "" then
        if aiPlay && model.currentPlayer == PlayerX then
            { tmpModel
                | message = checkWinandOutput tmpModel
                , currentPlayer = nextPlayer model.currentPlayer
            }

        else if not aiPlay then
            { tmpModel
                | message = checkWinandOutput tmpModel
                , currentPlayer = nextPlayer model.currentPlayer
            }

        else
            model

    else
        model


playerToText : Player -> String
playerToText player =
    case player of
        NoOne ->
            ""

        PlayerO ->
            "O"

        PlayerX ->
            "X: AI"


view : Model -> Html Msg
view model =
    let
        width =
            500

        height =
            500
    in
    div []
        [ div [] []
        , div [ Mouse.onDown MouseClick ]
            [ Canvas.toHtml ( width, height )
                []
                -- this is a sketch way of clearing the board and I think it should be better.
                ([ Canvas.clear ( 0, 0 ) width height
                 , Canvas.shapes []
                    (drawGrid width height model)
                 ]
                    ++ fillBoard width height model
                )
            ]
        , div []
            [ text model.message
            ]
        , div []
            [ text ("current player: " ++ playerToText model.currentPlayer)
            ]
        , div []
            [ button [ onClick Reset ] [ text "Reset Game" ]
            , button [ onClick AIPlay ] [ text "let the AI player make a move" ]
            , button [ onClick TogleAI ] [ text "Togle AI player" ]
            , text
                (if model.ai then
                    "the AI is playing"

                 else
                    "the AI is not playing"
                )
            ]
        ]



--implement a line drawing function


drawGrid : Int -> Int -> Model -> List Canvas.Shape
drawGrid width height model =
    let
        numRows =
            Array.length model.board |> toFloat |> Basics.sqrt |> round
    in
    List.concat
        [ List.map (\i -> Canvas.rect ( i * (width // numRows) |> toFloat, 0 ) 5 (toFloat height)) (List.range 1 numRows)
        , List.map (\i -> Canvas.rect ( 0, i * (height // numRows) |> toFloat ) (toFloat width) 5) (List.range 1 numRows)
        ]



{- [ Canvas.rect ( width // numRows |> toFloat, 0 ) 5 (toFloat height)
   , Canvas.rect ( 2 * (width // numRows) |> toFloat, 0 ) 5 (toFloat height)
   , Canvas.rect ( 0, height // numRows |> toFloat ) (toFloat width) 5
   , Canvas.rect ( 0, 2 * (height // numRows) |> toFloat ) (toFloat width) 5
   ]
-}


fillBoard : Int -> Int -> Model -> List Canvas.Renderable
fillBoard width height model =
    Array.indexedMap (drawXorO model width height) model.board |> Array.toList


drawXorO : Model -> Int -> Int -> Int -> Player -> Canvas.Renderable
drawXorO model width height idx player =
    let
        settings =
            [ Canvas.Settings.Text.font { size = 70, family = "sans-serif" }, Canvas.Settings.Text.align Canvas.Settings.Text.Center ]

        numRows =
            Array.length model.board |> toFloat |> Basics.sqrt |> round
    in
    case player of
        PlayerX ->
            Canvas.text settings (Debug.log "xplayer coord" (getCoordinate idx width height numRows)) "X"

        PlayerO ->
            Canvas.text settings (getCoordinate idx width height numRows) "O"

        NoOne ->
            Canvas.text settings ( 0, 0 ) ""


getCoordinate : Int -> Int -> Int -> Int -> Canvas.Point
getCoordinate idx width height numRows =
    ( Basics.remainderBy numRows idx * (width // numRows) + (width // (2 * numRows)) |> toFloat
    , ((idx // numRows) * (height // numRows) |> toFloat) + ((height |> toFloat) / (2 * ((numRows |> toFloat) - 0.5)))
    )



--return zero when dividing zero by something


remainderBy : Int -> Int -> Int
remainderBy x y =
    if x == 0 then
        0

    else
        Basics.remainderBy x y
