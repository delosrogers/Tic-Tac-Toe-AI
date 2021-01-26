module AIPlayer exposing (bestMove)

import Array
import Basics exposing (..)
import Dict
import GameLogic exposing (..)
import List
import List.Extra
import Maybe
import Tree
import Tuple
import Types exposing (..)
import Dict


boardListToString : String -> List Player -> String
boardListToString string board  =
    case board of
        [] ->
            string

        x :: xs ->
            case x of
                PlayerX ->
                    boardListToString (string ++ "x") xs
                PlayerO ->
                    boardListToString (string ++ "o") xs
                NoOne ->
                    boardListToString (string ++ "-") xs


bestMove : Board -> Int
bestMove board =
    let
        bestScore =
            -1 / 0 |> Basics.round

        boardList =
            Array.toList board
    in
    --returns a tuple of bestmove and best score
    (List.foldl (bestMoveReduce boardList) { bestMoveInReduce = 0, bestScore = bestScore, dict = Dict.empty } (List.range 0 (Array.length board - 1))).bestMoveInReduce


transformBoard : List Player -> Maybe Int
transformBoard board =
     



type alias BestMoveRecord =
    { bestMoveInReduce : Int
    , bestScore : Int
    , dict : ScoreDict
    }


bestMoveReduce : List Player -> Int -> BestMoveRecord -> BestMoveRecord
bestMoveReduce board currentMove bestMoveBests =
    if Maybe.withDefault NoOne (List.Extra.getAt currentMove board) == NoOne && bestMoveBests.bestScore <= 5 then
        let
            score =
                (\scoreDict modifiedBoard->
                    let
                        existingScore = Dict.get (modifiedBoard |> boardListToString "" ) scoreDict
                    in
                    case existingScore of
                        Just aScore ->
                            aScore
                        Nothing ->
                            miniMax modifiedBoard 0 False) bestMoveBests.dict (List.Extra.setAt currentMove PlayerX board)
        in
        { bestMoveBests
            | bestMoveInReduce =
                if score > bestMoveBests.bestScore then
                    currentMove

                else
                    bestMoveBests.bestMoveInReduce
            , bestScore = max score bestMoveBests.bestScore
            , dict = Debug.log "tree" (Dict.insert (( List.Extra.setAt currentMove PlayerX board ) |> boardListToString "") score bestMoveBests.dict)
        }

    else
        bestMoveBests



miniMax : List Player -> Int -> Bool -> Int
miniMax board depth isMaximizing =
    if checkWin (Array.fromList board) == Win then
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
        List.foldl (miniMaxReduce depth board isMaximizing) bestScore (List.range 0 (List.length board - 1))

    else
        let
            bestScore =
                1 / 0 |> Basics.round
        in
        List.foldl (miniMaxReduce depth board isMaximizing) bestScore (List.range 0 (List.length board - 1))


miniMaxReduce : Int -> List Player -> Bool -> Int -> Int -> Int
miniMaxReduce depth board isMaximizing idx bestScore =
    if Maybe.withDefault NoOne (List.Extra.getAt idx board) == NoOne then
        if isMaximizing && bestScore < 5 then
            let
                score =
                    miniMax
                        (List.Extra.setAt idx (isMaximizingtoPlayer isMaximizing) board)
                        (depth + 1)
                        (not isMaximizing)
            in
            max score bestScore

        else if not isMaximizing && bestScore > -5 then
            let
                score =
                    miniMax
                        (List.Extra.setAt idx (isMaximizingtoPlayer isMaximizing) board)
                        (depth + 1)
                        (not isMaximizing)
            in
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
