module Main exposing (main)
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
    { board = Array.repeat 9 NoOne
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
    idx_array = Array.fromList [Array.fromList[0,3,6]
      ,Array.fromList[1,4,7]
      ,Array.fromList[2,5,8]
      ,Array.fromList[0,1,2]
      ,Array.fromList[3,4,5]
      ,Array.fromList[6,7,8]
      ,Array.fromList[0,4,8]
      ,Array.fromList[2,4,6]]
  in
  Bool.Extra.any (Array.toList (Array.map (outerWinMap model.board) idx_array))
  

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
    drawGrid
    ] ++ fillBoard model)
    ]
  ]

--implement a line drawing function 
drawGrid : List Canvas.Shape
drawGrid = 
  --hardcoded for now should make reactive
  [ Canvas.rect ( 167, 0 ) 5 500
  , Canvas.rect ( 333, 0 ) 5 500
  , Canvas.rect ( 0, 167 ) 500 5
  , Canvas.rect ( 0, 333 ) 500 5
  ]

fillBoard : Model -> List Canvas.Renderable
fillBoard model = 
  Array.indexedMap drawXorO model.board |> Array.toList

drawXorO : Int -> Player -> Canvas.Renderable
drawXorO idx player = 
  let
    settings = [ Canvas.Settings.Text.font {size = 70, family = "sans-serif"}, Canvas.Settings.Text.align Canvas.Settings.Text.Center]
  in
  case player of
    PlayerX ->
      Canvas.text settings (Debug.log "xplayer coord" (getCoordinate idx)) "X"
    PlayerO ->
      Canvas.text settings (getCoordinate idx) "O"
    NoOne ->
      Canvas.text settings ( 0, 0 ) ""
    
getCoordinate : Int -> Canvas.Point
getCoordinate idx =
  ( (Basics.remainderBy 3 idx) * 167 + 84 |> toFloat
  , ((Debug.log "index" idx) // 3) * 180 + 100 |> toFloat
  
   )
--return zero when dividing zero by something
remainderBy : Int -> Int -> Int
remainderBy x y =
  if x == 0 then
    0
  else
    Basics.remainderBy x y





