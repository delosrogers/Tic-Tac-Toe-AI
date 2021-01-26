module GameLogic exposing (..)

import Array
import Array.Extra
import Bool.Extra
import List
import List.Extra
import Maybe
import Types exposing (..)


nextPlayer : Player -> Player
nextPlayer player =
    case player of
        PlayerO ->
            PlayerX

        PlayerX ->
            PlayerO

        NoOne ->
            NoOne


boardSet : Maybe.Maybe Int -> Player -> Array.Array Player -> Array.Array Player
boardSet idx value arr =
    case idx of
        Just index ->
            if Maybe.withDefault NoOne (Array.get index arr) == NoOne then
                Array.set index value arr

            else
                arr

        Maybe.Nothing ->
            arr


equalAll : List Player -> Bool -> Player -> Bool
equalAll list lastBool lastElement =
    case list of
        [] ->
            lastBool

        x :: xs ->
            equalAll xs (lastBool && lastElement == x && x /= NoOne) x


innerWinMap : Array.Array Player -> Int -> Player
innerWinMap gameArr idx =
    Maybe.withDefault NoOne (Array.get idx gameArr)


outerWinMap : Array.Array Player -> Array.Array Int -> WinReport
outerWinMap gameArr idxes =
    let
        slicedList =
            Array.toList (Array.map (innerWinMap gameArr) idxes)
    in
    if equalAll slicedList True (Maybe.withDefault NoOne (List.Extra.getAt 0 slicedList)) then
        Win

    else if List.member PlayerX slicedList && List.member PlayerO slicedList then
        UnwinableRow

    else
        PlayContinues


checkWinandOutput : Model -> String
checkWinandOutput model =
    let
        gameWinState =
            checkWin model.board
    in
    if gameWinState == Win then
        case model.currentPlayer of
            PlayerX ->
                "Player X won"

            PlayerO ->
                "Player O won"

            NoOne ->
                ""

    else if not (Bool.Extra.any (Array.Extra.mapToList (\player -> player == NoOne) model.board)) || gameWinState == Tie then
        "tie"

    else
        ""


checkWin : Board -> WinReport
checkWin board =
    {- let
         curriedwinCheckCols = winCheckCols (sqrt (Array.length model.board)) player
       in
    -}
    -- write a function to generate this array generally
    let
        winReportList =
            Array.toList (Array.map (outerWinMap board) (generateIdxArray board))
    in
    if List.member Win winReportList then
        Win

    else if List.all ((==) UnwinableRow) winReportList then
        Debug.log "tie" Tie

    else
        PlayContinues


generateIdxArray : Board -> Array.Array (Array.Array Int)
generateIdxArray board =
    let
        -- An array that is 0,1,2 ... the length of a row/col
        baseArray =
            Array.initialize (Array.length board |> toFloat |> Basics.sqrt |> Basics.round) identity

        -- an array 0,1,2 ... that is the number of rows + cols + diagonals
        numberofArraysArray =
            Array.initialize (Array.length board |> toFloat |> Basics.sqrt |> (*) 2 |> (+) 2 |> Basics.round) identity

        -- the number of rows
        numberofRows =
            Array.length board |> toFloat |> Basics.sqrt |> Basics.round
    in
    Array.map (generateChildIdxArray baseArray numberofRows) numberofArraysArray


generateChildIdxArray : Array.Array Int -> Int -> Int -> Array.Array Basics.Int
generateChildIdxArray baseArr numberofRows idx =
    -- you are making column skip index arrays
    if idx < numberofRows then
        Array.map (\i -> i * numberofRows + idx) baseArr
        -- you are making row slices

    else if idx < (numberofRows * 2) then
        Array.map (\i -> i + (idx - numberofRows) * numberofRows) baseArr
        --diagonal top left to bottom right

    else if idx == Array.length baseArr * 2 then
        -- figure out exactly what I'm doing here and why it works
        Array.map (\i -> i * (Array.length baseArr + 1) + Array.length baseArr + 1 - numberofRows - 1) baseArr
        --diagonal top right to bottom left

    else
        Array.map (\i -> i * (Array.length baseArr - 1) + Array.length baseArr - 1) baseArr
