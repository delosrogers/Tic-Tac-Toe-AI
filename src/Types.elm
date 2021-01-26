module Types exposing (..)

import Array
import Tree
import List
import Dict


type alias Model =
    { board : Board
    , currentPlayer : Player
    , message : String
    , mousepos : ( Float, Float )
    , ai : Bool
    }


type Player
    = PlayerX
    | PlayerO
    | NoOne


type alias Board =
    Array.Array Player


type alias ScoreDict =
    Dict.Dict String Int
