module GameLogic exposing (..)

import Array
import Array.Extra
import Bool.Extra
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


boardSet : Int -> Player -> Array.Array Player -> Array.Array Player
boardSet idx value arr =
    if Maybe.withDefault NoOne (Array.get idx arr) == NoOne then
        Array.set idx value arr

    else
        arr


equal3 : Array.Array Player -> Bool
equal3 arr =
    let
        get =
            Array.get
    in
    if Maybe.withDefault NoOne (get 0 arr) /= NoOne then
        get 0 arr == get 1 arr && get 1 arr == get 2 arr && get 0 arr == get 2 arr

    else
        False


innerWinMap : Array.Array Player -> Int -> Player
innerWinMap gameArr idx =
    Maybe.withDefault NoOne (Array.get idx gameArr)


outerWinMap : Array.Array Player -> Array.Array Int -> Bool
outerWinMap gameArr idxes =
    let
        slicedArr =
            Array.map (innerWinMap gameArr) idxes
    in
    -- this is somewhere that will need to be adjusted for different sized boards, this should be general
    equal3 (Debug.log "sliced Arr in outerWinMap" slicedArr)


checkWinandOutput : Model -> String
checkWinandOutput model =
    if checkWin model.board then
        case model.currentPlayer of
            PlayerX ->
                "Player X won"

            PlayerO ->
                "Player O won"

            NoOne ->
                ""

    else if not (Bool.Extra.any (Array.Extra.mapToList (\player -> player == NoOne) model.board)) then
        "tie"

    else
        ""


checkWin : Board -> Bool
checkWin board =
    {- let
         curriedwinCheckCols = winCheckCols (sqrt (Array.length model.board)) player
       in
    -}
    -- write a function to generate this array generally
    let
        idx_array =
            generateIdxArray board
    in
    Bool.Extra.any (Array.toList (Array.map (outerWinMap (Debug.log "board in checkplayerwin" board)) (Debug.log "idx_array" idx_array)))


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
