module AIPlayer exposing (bestMove)

--import Main exposing (..)

import Array
import Basics exposing (..)
import GameLogic exposing (..)
import Html.Attributes exposing (ismap)
import Iter
import List
import List.Extra
import Maybe
import Tuple
import Types exposing (..)



{- bestMove : Model -> Int
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


   miniMax : Int -> Bool -> Board -> Int
   miniMax depth isMaximizing board =
       if Main.checkPlayerWin
       Tuple.second (Iter.head(Iter.drop 8 (Iter.iter (nextBestScore Board (depth + 1) isMaximizing) (0,0))))
-}


bestMove : Board -> Int
bestMove board =
    let
        bestScore =
            -1 / 0 |> Basics.round

        boardList =
            Array.toList board
    in
    --returns a tuple of bestmove and best score
    List.foldl (bestMoveReduce boardList) ( 0, bestScore ) (List.range 0 8) |> Tuple.first


bestMoveReduce : List Player -> Int -> ( Int, Int ) -> ( Int, Int )
bestMoveReduce board currentMove ( bestMoveInReduce, bestScore ) =
    if Maybe.withDefault NoOne (List.Extra.getAt currentMove board) == NoOne && bestScore <= 5 then
        let
            score =
                miniMax
                    (List.Extra.setAt currentMove PlayerX board)
                    0
                    False
        in
        ( if score > bestScore then
            currentMove

          else
            bestMoveInReduce
        , max score bestScore
        )

    else
        ( bestMoveInReduce, bestScore )


miniMax : List Player -> Int -> Bool -> Int
miniMax board depth isMaximizing =
    if checkWin (Array.fromList board) then
        if List.member NoOne board |> not then
            0

        else if isMaximizing then
            -10

        else
            10

    else if isMaximizing then
        let
            bestScore =
                -1 / 0 |> Basics.round
        in
        List.foldl (miniMaxReduce depth board isMaximizing) bestScore (List.range 0 8)

    else
        let
            bestScore =
                1 / 0 |> Basics.round
        in
        List.foldl (miniMaxReduce depth board isMaximizing) bestScore (List.range 0 8)


miniMaxReduce : Int -> List Player -> Bool -> Int -> Int -> Int
miniMaxReduce depth board isMaximizing idx bestScore =
    if Maybe.withDefault NoOne (List.Extra.getAt idx board) == NoOne then
        let
            score =
                miniMax
                    (List.Extra.setAt idx (isMaximizingtoPlayer isMaximizing) board)
                    (depth + 1)
                    (not isMaximizing)
        in
        if isMaximizing && bestScore < 5 then
            max score bestScore

        else if not isMaximizing && bestScore > -5 then
            min score bestScore

        else
            bestScore

    else
        bestScore


isMaximizingtoPlayer : Bool -> Player
isMaximizingtoPlayer isMaximizing =
    if isMaximizing then
        PlayerX

    else
        PlayerO
