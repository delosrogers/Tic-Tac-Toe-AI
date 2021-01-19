module Main exposing (main)
--import AIPlayer
import Browser
import Html exposing (Html, Attribute, div, input, text, button, option, select)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Events.Extra.Mouse as Mouse
import String
import List
import Array
import Array.Extra
import Maybe
import Bool.Extra
import Debug
import Canvas
import Canvas.Settings
import Canvas.Settings.Text


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
    , mousepos : ( Float,  Float )
    }
  
nextPlayer : Player -> Player
nextPlayer player =
  case player of
    PlayerO -> PlayerX
    PlayerX -> PlayerO
    NoOne -> NoOne


init : Model
init = 
    { board = Array.repeat 9 NoOne
    , currentPlayer = PlayerX
    , message = ""
    , mousepos = ( 0, 0 )
    }


type Msg
    = Reset 
    | MouseClick Mouse.Event


update : Msg -> Model -> Model
update msg model =
  
  case msg of
    MouseClick event ->
      let
        ( x, y ) = event.offsetPos
      in
      -- TODO remove hardcoded values that lock this to being just a 3 by 3 board 500 px by 500 px
      updateBoard ( (x |> Basics.round) // 167 + ( (y |> Basics.round) // 167 |> ((*) 3) )) model

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
    equal3 (Debug.log "sliced Arr in outerWinMap" slicedArr)

checkWinandOutput : Model -> String
checkWinandOutput model = 
  if checkPlayerWin model.board then
    case model.currentPlayer of
       PlayerX -> "Player X won"
       PlayerO -> "Player O won"
       NoOne -> ""
  else if not (Bool.Extra.any (Array.Extra.mapToList (\player -> player == NoOne) model.board)) then
    "tie"
  else
    ""

checkPlayerWin : Board -> Bool
checkPlayerWin board =
  {- let  
    curriedwinCheckCols = winCheckCols (sqrt (Array.length model.board)) player
  in -}
  -- write a function to generate this array generally
  let
    idx_array = generateIdxArray board
  in
  Bool.Extra.any (Array.toList (Array.map (outerWinMap (Debug.log "board in checkplayerwin" board)) (Debug.log "idx_array" idx_array)))
  
generateIdxArray : Board -> Array.Array (Array.Array Int)
generateIdxArray board =
  let
    -- An array that is 0,1,2 ... the length of a row/col
    baseArray = 
      Array.initialize ( Array.length board |> toFloat |> Basics.sqrt |> Basics.round) identity
    
    -- an array 0,1,2 ... that is the number of rows + cols + diagonals
    numberofArraysArray = Array.initialize (Array.length board |> toFloat |> Basics.sqrt |> (*) 2 |> (+) 2 |> Basics.round) identity
    
    -- the number of rows
    numberofRows = Array.length board |> toFloat |> Basics.sqrt |> Basics.round
  in
  Array.map (generateChildIdxArray baseArray numberofRows) numberofArraysArray

generateChildIdxArray : Array.Array Int -> Int -> Int -> Array.Array Basics.Int
generateChildIdxArray baseArr numberofRows idx =
  -- you are making column skip index arrays
  if idx < numberofRows then
    Array.map (\i -> i*numberofRows + idx) baseArr

  -- you are making row slices
  else if idx < (numberofRows * 2) then
    Array.map (\i -> i + (idx - numberofRows) * numberofRows) baseArr

  --diagonal top left to bottom right
  else if idx == Array.length baseArr * 2 then
  -- figure out exactly what I'm doing here and why it works
    Array.map (\i -> i * (Array.length baseArr + 1) + Array.length baseArr + 1 - numberofRows - 1) baseArr

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
    div [] []
    , div [Mouse.onDown MouseClick] [
        Canvas.toHtml ( width, height )
    []
    -- this is a sketch way of clearing the board and I think it should be better.
    ([ Canvas.clear (0, 0) width height, Canvas.shapes []
    (drawGrid width height model)
    ] ++ fillBoard width height model)
    ]
    , div [] 
    [ text model.message
    ]
    , div [] 
    [ text ("current player: " ++ (notMaybePlayerToText model.currentPlayer))
    ]
    , div []
    [ button [onClick Reset] [text "Reset Game"]]
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
  , ((idx // numRows) * (height // numRows) |> toFloat) + ( (height |> toFloat) / (2 * ((numRows |> toFloat) - 0.5)))
  
   )
--return zero when dividing zero by something
remainderBy : Int -> Int -> Int
remainderBy x y =
  if x == 0 then
    0
  else
    Basics.remainderBy x y





