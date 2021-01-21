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
    (bestMoveLoop bestScore 0 boardList (List.range 0 8)) |> Tuple.first


bestMoveLoop : Int -> Int -> List Player -> List Int -> ( Int, Int )
bestMoveLoop bestScore bestMoveInLoop board iteratingList =
    if Maybe.withDefault NoOne (List.Extra.getAt (Maybe.withDefault 0 (List.head iteratingList)) board) == NoOne then
        let
            score =
                miniMax
                    (List.Extra.setAt (Maybe.withDefault 0 (List.head iteratingList)) PlayerX board)
                    0
                    False
        in
        if List.length iteratingList <= 1 && score > bestScore then
            ( Maybe.withDefault 0 (List.head iteratingList), score )

        else if List.length iteratingList <= 1 then
            ( bestMoveInLoop, bestScore )

        else if score > bestScore then
            bestMoveLoop score (Maybe.withDefault 0 (List.head iteratingList)) board (Maybe.withDefault [] (List.tail iteratingList))

        else
            bestMoveLoop bestScore bestMoveInLoop board (Maybe.withDefault [] (List.tail iteratingList))

    else
        bestMoveLoop bestScore bestMoveInLoop board (Maybe.withDefault [] (List.tail iteratingList))


miniMax : List Player -> Int -> Bool -> Int
miniMax board depth isMaximizing =
    if checkWin (Array.fromList board) then
        if List.member NoOne board |> not then
            0

        else if isMaximizing then
            10

        else
            -10

    else if isMaximizing then
        let
            bestScore =
                -1 / 0 |> Basics.round
        in
        miniMaxLoop bestScore depth board isMaximizing (List.range 0 8)

    else
        let
            bestScore =
                1 / 0 |> Basics.round
        in
        miniMaxLoop bestScore depth board isMaximizing (List.range 0 8)


isMaximizingtoPlayer : Bool -> Player
isMaximizingtoPlayer isMaximizing =
    if isMaximizing then
        PlayerX

    else
        PlayerO


miniMaxLoop : Int -> Int -> List Player -> Bool -> List Int -> Int
miniMaxLoop bestScore depth board isMaximizing iteratingList =
    if Maybe.withDefault NoOne (List.Extra.getAt (Maybe.withDefault 0 (List.head iteratingList)) board) == NoOne then
        let
            score =
                miniMax
                    (List.Extra.setAt (Maybe.withDefault 0 (List.head iteratingList)) (isMaximizingtoPlayer isMaximizing) board)
                    (depth + 1)
                    (not isMaximizing)
        in
        if List.length iteratingList <= 1 then
            if isMaximizing then
                max score bestScore

            else
                min score bestScore

        else if isMaximizing then
            miniMaxLoop (max bestScore score) depth board isMaximizing (Maybe.withDefault [] (List.tail iteratingList))

        else
            miniMaxLoop (min bestScore score) depth board isMaximizing (Maybe.withDefault [] (List.tail iteratingList))

    else
        miniMaxLoop bestScore depth board isMaximizing (Maybe.withDefault [] (List.tail iteratingList))
