module Types exposing (..)

import Browser.Navigation as Nav
import Array
import Tree
import List
import Dict
import Array exposing (toIndexedList)
{- type Model = 
    Success (State, Nav.Key)
    | Failure
    | Loading -}

type alias Model =
    { board : Board
    , currentPlayer : Player
    , message : String
    , mousepos : ( Float, Float )
    , ai : Bool
    , id_ : Maybe.Maybe String
    }


type Player
    = PlayerX
    | PlayerO
    | NoOne


type alias Board =
    Array.Array Player


type alias ScoreDict =
    Dict.Dict String Int
type alias GameTree =
    Tree.Tree ( Board, Int )


type WinReport 
    = Win
    | UnwinableRow
    | Tie
    | PlayContinues
