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


boardListToString : String -> List Player -> String
boardListToString string board =
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


getScoreWithIsomorphisms : List Player -> ScoreDict -> Maybe Int
getScoreWithIsomorphisms board scoreDict =
    let
        score0 =
            Dict.get (board |> boardListToString "") scoreDict
    in
    case score0 of
        Just aScore ->
            Just aScore

        Maybe.Nothing ->
            let
                score1 =
                    Dict.get (board |> List.reverse |> boardListToString "") scoreDict
            in
            case score1 of
                Just aScore ->
                    Just aScore

                Maybe.Nothing ->
                    let
                        score2 =
                            Dict.get (board |> splitList |> List.reverse |> List.concat |> boardListToString "") scoreDict
                    in
                    case score2 of
                        Just aScore ->
                            Just aScore

                        Maybe.Nothing ->
                            let
                                score3 =
                                    Dict.get (board |> splitList |> List.map List.reverse |> List.concat |> boardListToString "") scoreDict
                            in
                            case score3 of
                                Just aScore ->
                                    Just aScore

                                Maybe.Nothing ->
                                    Maybe.Nothing


splitList : List Player -> List (List Player)
splitList board =
    let
        rowLength =
            board |> List.length |> toFloat |> sqrt |> round
    in
    List.map
        (\idxArr ->
            Array.map (\idx -> Maybe.withDefault NoOne (List.Extra.getAt idx board)) idxArr |> Array.toList
        )
        (generateIdxArray (Array.fromList board) |> Array.toList |> List.take rowLength)


type alias BestMoveRecord =
    { bestMoveInReduce : Int
    , bestScore : Int
    , dict : ScoreDict
    }


bestMoveReduce : List Player -> Int -> BestMoveRecord -> BestMoveRecord
bestMoveReduce board currentMove bestMoveBests =
    if Maybe.withDefault NoOne (List.Extra.getAt currentMove board) == NoOne && bestMoveBests.bestScore <= 5 then
        let
            ( newScoreDict, score ) =
                (\scoreDict modifiedBoard ->
                    let
                        existingScore =
                            getScoreWithIsomorphisms modifiedBoard scoreDict
                    in
                    case existingScore of
                        Just aScore ->
                            ( scoreDict, aScore )

                        Nothing ->
                            miniMax modifiedBoard 0 False scoreDict
                )
                    bestMoveBests.dict
                    (List.Extra.setAt currentMove PlayerX board)
        in
        Debug.log "bestMoveBests"
            { bestMoveBests
                | bestMoveInReduce =
                    if Debug.log "moveScore" score > bestMoveBests.bestScore then
                        currentMove

                    else
                        bestMoveBests.bestMoveInReduce
                , bestScore = max score bestMoveBests.bestScore
                , dict = Debug.log "dict" (Dict.insert (List.Extra.setAt currentMove PlayerX board |> boardListToString "") score newScoreDict)
            }

    else
        bestMoveBests


miniMax : List Player -> Int -> Bool -> ScoreDict -> ( ScoreDict, Int )
miniMax board depth isMaximizing scoreDict =
    if checkWin (Array.fromList board) == Win then
        if List.member NoOne board |> not then
            ( Dict.insert (board |> boardListToString "") 0 scoreDict, 0 )

        else if isMaximizing then
            ( Dict.insert (board |> boardListToString "") -10 scoreDict, -10 )

        else
            ( Dict.insert (board |> boardListToString "") 10 scoreDict, 10 )

    else if isMaximizing then
        let
            bestScore =
                -1 / 0 |> Basics.round
        in
        List.foldl (miniMaxReduce depth board isMaximizing) ( scoreDict, bestScore ) (List.range 0 (List.length board - 1))

    else
        let
            bestScore =
                1 / 0 |> Basics.round
        in
        List.foldl (miniMaxReduce depth board isMaximizing) ( scoreDict, bestScore ) (List.range 0 (List.length board - 1))


miniMaxReduce : Int -> List Player -> Bool -> Int -> ( ScoreDict, Int ) -> ( ScoreDict, Int )
miniMaxReduce depth board isMaximizing idx ( scoreDict, bestScore ) =
    if Maybe.withDefault NoOne (List.Extra.getAt idx board) == NoOne then
        if isMaximizing && bestScore < 5 then
            let
                ( newScoreDict, score ) =
                    (\boardScoreDict modifiedBoard callDepth callIsMaximizing ->
                        let
                            existingScore =
                                getScoreWithIsomorphisms modifiedBoard boardScoreDict
                        in
                        case existingScore of
                            Just aScore ->
                                ( scoreDict, aScore )

                            Nothing ->
                                miniMax modifiedBoard callDepth callIsMaximizing boardScoreDict
                    )
                        scoreDict
                        (List.Extra.setAt idx (isMaximizingtoPlayer isMaximizing) board)
                        (depth + 1)
                        (not isMaximizing)
            in
            ( Dict.insert (List.Extra.setAt idx PlayerX board |> boardListToString "") score newScoreDict, max score bestScore )

        else if not isMaximizing && bestScore > -5 then
            let
                ( newScoreDict, score ) =
                    (\boardScoreDict modifiedBoard callDepth callIsMaximizing ->
                        let
                            existingScore =
                                getScoreWithIsomorphisms modifiedBoard boardScoreDict
                        in
                        case existingScore of
                            Just aScore ->
                                ( boardScoreDict, aScore )

                            Nothing ->
                                miniMax modifiedBoard callDepth callIsMaximizing boardScoreDict
                    )
                        scoreDict
                        (List.Extra.setAt idx (isMaximizingtoPlayer isMaximizing) board)
                        (depth + 1)
                        (not isMaximizing)
            in
            ( Dict.insert (List.Extra.setAt idx PlayerX board |> boardListToString "") score newScoreDict, min score bestScore )

        else
            ( scoreDict, bestScore )

    else
        ( scoreDict, bestScore )


isMaximizingtoPlayer : Bool -> Player
isMaximizingtoPlayer isMaximizing =
    if isMaximizing then
        PlayerX

    else
        PlayerO
