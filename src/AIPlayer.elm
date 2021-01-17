module AIPlayer exposing (bestMove)
import Main exposing (..)
import Basics exposing (..)
import Array
import Iter
import Tuple

bestMove : Model -> Int
bestMove model =
    let
        bestScore = -(1/0)
    in
    Array.indexedMap (\i state ->
        max)

isMaximizingToPlayer Bool -> Player
isMaximizingToPlayer isMaximizing =
    case isMaximizing of
       True -> PlayerX
       False -> PlayerO
    
nextBestScore : Board -> Int -> Bool -> ( Int, Int ) -> ( Int, Int )
nextBestScore board depth isMaximizing currentMoveAndScore =
    let
        ( currentMove, currentScore ) = currentMoveAndScore
        
    in
    if get (currentMove + 1) Board == NoOne then
        let 
            nextScore = get ( (Tuple.first currentMoveAndScore) + 1) (Array.set (currentMove + 1) PlayerX Board) |> ( miniMax 0 False )
        in
        if isMaximizing then
            if  nextScore > currentScore then
                ( currentMove + 1, nextScore)
            else
            currentMoveAndScore
        else
            if nextScore < currentScore then
                (currentMove + 1, nextScore)
            else
                currentMoveAndScore
    else
        currentMoveAndScore


miniMax : Int -> Bool -> Board
miniMax depth isMaximizing board =

