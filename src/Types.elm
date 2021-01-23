module Types exposing (..)

import Array
import Tree


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


type alias GameTree =
    Tree.Tree ( Board, Int )
