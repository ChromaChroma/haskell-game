
module Model.GhostAI where



import Data.Fixed (mod')
import Data.Maybe (Maybe (..), fromJust, isJust)
import Model.Game (GameState (level, ghosts, ghostMode))
import Model.Ghosts
import Model.Level
import Model.Movement
import Numeric (showFFloat)
import Prelude hiding (Down, Left, Right, Up)



import Controller.MovementController






-----------------------------------------------------------------------------

makeGhostsMove :: GameState -> GameState
makeGhostsMove gs = gs {ghosts = map (make1GhostMove gs) (ghosts gs)}


make1GhostMove :: GameState -> Ghost -> Ghost
make1GhostMove gs ghst
  | isJust movedGhost = fromJust movedGhost
  | otherwise = next --KIEST NU DE EERSTE OPTIE -- case length possibledirections == 1: die kant. anders: ghost AI
  where
    movedGhost = makeDirectionMoveGhost gs ghst (direction ghst)
    next:nexts = checkMoveDirs gs ghst


makeDirectionMoveGhost :: GameState -> Ghost -> Direction -> Maybe Ghost
makeDirectionMoveGhost gs ghst dir
  | canMoveInDir && isValidMovePosition = Just updatedGhost
  | otherwise = Nothing
  where
    canMoveInDir = canMakeMoveToDir ghst dir lvl
    isValidMovePosition = isValidGhostPosition (ghostMode gs) lvl movedGhost

    updatedGhost = movedGhost {direction = dir, opDirection = opp dir}

    movedGhost = move ghst dir (layoutSize . layout $ lvl)
    lvl = level gs


checkMoveDirs :: GameState -> Ghost -> [Ghost]
checkMoveDirs gs gh
  = possiblemoves
  where
    possiblemoves = map fromJust $ filter (isJust) [makeDirectionMoveGhost gs gh x | x <- u]
    u = filter (/= opDirection gh) [Up,Left,Down,Right]



--END
