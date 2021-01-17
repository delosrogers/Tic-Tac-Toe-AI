module Main exposing (main)
import AIPlayer
import Browser
import Html exposing (Html, Attribute, div, input, text, button, option, select)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import String
import List
import Array
import Maybe
import Bool.Extra
import Debug
import Canvas
import Canvas.Settings
import Canvas.Settings.Text
import Color
import Array exposing (indexedMap)


main = 
    Browser.sandbox {init = init, update=update, view = view}

type Player 
    = PlayerX | PlayerO | NoOne

type alias Board = 
  Array.Array Player


type alias Model = 
    { board : Board
    , currentPlayer : Player
    , message : String
    }
  
nextPlayer : Player -> Player
nextPlayer player =
  case player of
    PlayerO -> PlayerX
    PlayerX -> PlayerO
    NoOne -> NoOne


init : Model
init = 
    { board = Array.repeat 16 NoOne
    , currentPlayer = PlayerX
    , message = ""
    }


type Msg
    = C0 | C1 | C2 | C3 | C4 | C5 | C6 | C7 | C8 | Reset
{- checkWinAndUpdate : Model -> Model
checkWinAndUpdate model =
  if checkWin model then
        case model.turn of
          PlayerO -> "Player O wins" 
          PlayerX -> "Player X wins"
  else
    "" -}

update : Msg -> Model -> Model
update msg model =
  
  case msg of
  -- C stands for cell this nomenclature could be improved
    C0 ->
      updateBoard 0 model
    C1->
      updateBoard 1 model
    C2->
      updateBoard 2 model
    C3->
      updateBoard 3 model
    C4->
      updateBoard 4 model
    C5->
      updateBoard 5 model
    C6->
      updateBoard 6 model
    C7->
      updateBoard 7 model
    C8->
      updateBoard 8 model
    Reset ->
      init

boardSet : Int -> Player -> Array.Array Player -> Array.Array Player
boardSet idx value arr =
  if Maybe.withDefault NoOne (Array.get idx arr) == NoOne then
    Array.set idx value arr
  else
    arr

updateBoard : Int -> Model -> Model
updateBoard cell model =
  let
    tmpModel = {model | board = boardSet cell model.currentPlayer model.board}
  in
  if model.message == "" then
    {tmpModel | message = checkWinandOutput tmpModel
          , currentPlayer = nextPlayer model.currentPlayer}
  else
  model

equal3 : Array.Array Player -> Bool
equal3 arr =
  let
    get = Array.get
  in
  if Maybe.withDefault NoOne (get 0 arr) /= NoOne then
    get 0 arr == get 1 arr && get 1 arr == get 2 arr && get 0 arr == get 2 arr
  else
    False

innerWinMap : Array.Array Player -> Int -> Player
innerWinMap gameArr idx =
  Maybe.withDefault NoOne (Array.get idx gameArr)

outerWinMap : Array.Array Player-> Array.Array Int -> Bool
outerWinMap gameArr idxes =
  let
    slicedArr = Array.map (innerWinMap gameArr) idxes
  in
    -- this is somewhere that will need to be adjusted for different sized boards, this should be general
    equal3 slicedArr

checkWinandOutput : Model -> String
checkWinandOutput model = 
  let
    playerXWin = checkPlayerWin PlayerX model
  in
  if playerXWin then
    "Player X won"
  else if (checkPlayerWin PlayerO model) then
    "Player O won"
  else
    ""

checkPlayerWin : Player -> Model -> Bool
checkPlayerWin player model =
  {- let  
    curriedwinCheckCols = winCheckCols (sqrt (Array.length model.board)) player
  in -}
  -- write a function to generate this array generally
  let
    idx_array = generateIdxArray model
    {- idx_array = Array.fromList [Array.fromList[0,3,6]
      ,Array.fromList[1,4,7]
      ,Array.fromList[2,5,8]
      ,Array.fromList[0,1,2]
      ,Array.fromList[3,4,5]
      ,Array.fromList[6,7,8]
      ,Array.fromList[0,4,8]
      ,Array.fromList[2,4,6]] -}
  in
  Bool.Extra.any (Array.toList (Array.map (outerWinMap model.board) idx_array))
  
generateIdxArray : Model -> Array.Array (Array.Array Int)
generateIdxArray model =
  let
    baseArray = 
      Array.initialize ( Array.length model.board |> toFloat |> Basics.sqrt |> Basics.round) identity
    numberofArraysArray = Array.initialize (Array.length model.board |> toFloat |> Basics.sqrt |> (*) 2 |> (+) 2 |> Basics.round) identity
    numberofRows = Array.length model.board |> toFloat |> Basics.sqrt |> Basics.round
  in
  Array.map (generateChildIdxArray baseArray numberofRows) numberofArraysArray

generateChildIdxArray : Array.Array Int -> Int -> Int -> Array.Array Basics.Int
generateChildIdxArray baseArr numberofRows idx =
  -- you are making column skip index arrays
  if idx < numberofRows then
    Array.map (\i -> i*numberofRows + idx) baseArr

  -- you are making row slices
  else if idx < numberofRows * 2 then
    Array.map (\i -> i + idx) baseArr

  --diagonal top left to bottom right
  else if idx == Array.length baseArr ^ 2 then
    Array.map (\i -> i * (Array.length baseArr + 1) + Array.length baseArr + 1) baseArr

  --diagonal top right to bottom left
  else
    Array.map (\i -> i*(Array.length baseArr - 1) + Array.length baseArr - 1) baseArr




playerToText : Maybe.Maybe Player -> String
playerToText player =
  case player of
    Just NoOne -> ""
    Just PlayerO -> "O"
    Just PlayerX -> "X"
    Nothing -> ""  

--handles the case where Player is not nothing
notMaybePlayerToText : Player -> String
notMaybePlayerToText player =
  case player of
     NoOne -> ""
     PlayerO -> "O"
     PlayerX -> "X"



view : Model -> Html Msg
view model =
  let
        width = 500
        height = 500
  in
  div [] [
    div [] 
    [ button [ class "game_button", onClick C0] [text (playerToText (Array.get 0 model.board))]
    , button [ class "game_button", onClick C1] [text (playerToText (Array.get 1 model.board))]
    , button [ class "game_button", onClick C2] [text (playerToText (Array.get 2 model.board))]
    ]
    , div [] [
      button [ class "game_button", onClick C3] [text (playerToText (Array.get 3 model.board))]
    , button [ class "game_button", onClick C4] [text (playerToText (Array.get 4 model.board))]
    , button [ class "game_button", onClick C5] [text (playerToText (Array.get 5 model.board))]
    ]
    , div [] 
    [ button [ class "game_button", onClick C6] [text (playerToText (Array.get 6 model.board))]
    , button [ class "game_button", onClick C7] [text (playerToText (Array.get 7 model.board))]
    , button [ class "game_button", onClick C8] [text (playerToText (Array.get 8 model.board))]
    ]
    , div [] 
    [ text model.message
    ]
    , div [] 
    [ text ("current player: " ++ (notMaybePlayerToText model.currentPlayer))
    ]
    , div []
    [ button [onClick Reset] [text "Reset Game"]]
    , div [] [
        Canvas.toHtml ( width, height )
    []
    -- this is a sketch way of clearing the board and I think it should be better.
    ([ Canvas.clear (0, 0) width height, Canvas.shapes []
    (drawGrid width height model)
    ] ++ fillBoard width height model)
    ]
  ]

--implement a line drawing function 
drawGrid : Int -> Int -> Model -> List Canvas.Shape
drawGrid width height model = 
  let
    numRows = Array.length model.board |> toFloat |> Basics.sqrt |> round
  in
  [ Canvas.rect ( width // numRows |> toFloat, 0 ) 5 ( toFloat height )
  , Canvas.rect ( 2 * (width // numRows) |> toFloat, 0 ) 5 ( toFloat height )
  , Canvas.rect ( 0, height // numRows |> toFloat) ( toFloat width ) 5
  , Canvas.rect ( 0, 2 * (height // numRows) |> toFloat) ( toFloat width ) 5
  ]

fillBoard : Int -> Int -> Model -> List Canvas.Renderable
fillBoard width height model = 
  Array.indexedMap (drawXorO model width height) model.board |> Array.toList

drawXorO : Model -> Int -> Int -> Int -> Player -> Canvas.Renderable
drawXorO model width height idx player = 
  let
    settings = [ Canvas.Settings.Text.font {size = 70, family = "sans-serif"}, Canvas.Settings.Text.align Canvas.Settings.Text.Center]
    numRows = Array.length model.board |> toFloat |> Basics.sqrt |> round
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
  ( (Basics.remainderBy numRows idx) * ( width // numRows ) + (width // (2 * numRows)) |> toFloat
  , ((idx // numRows) * (width // numRows) |> toFloat) + ( (width |> toFloat) / (2 * ((numRows |> toFloat) - 0.5)))
  
   )
--return zero when dividing zero by something
remainderBy : Int -> Int -> Int
remainderBy x y =
  if x == 0 then
    0
  else
    Basics.remainderBy x y




