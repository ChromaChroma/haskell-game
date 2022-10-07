module Controller.MovementController where

import Data.Fixed (mod')
import Data.Maybe
import Model.Characters
import Model.Game
import Model.Level
import Model.Movement
import Numeric
import Prelude hiding (Down, Left, Right, Up)

makePlayerMove :: GameState -> GameState
makePlayerMove gs
  | isJust bufMovedPlayer = gs {player = fromJust bufMovedPlayer, direction = bufDirection gs, bufDirection = Stop}
  | isJust movedPlayer = gs {player = fromJust movedPlayer}
  | otherwise = gs
  where
    bufMovedPlayer = makeDirectionMove gs (bufDirection gs)
    movedPlayer = makeDirectionMove gs (direction gs)

makeDirectionMove :: GameState -> Direction -> Maybe Player
makeDirectionMove gs dir
  | dir /= Stop && canMakeMoveToDir pl dir lvl && isValidPlayerPosition lvl movedPlayer =
    Just movedPlayer
  | otherwise = Nothing
  where
    movedPlayer = move pl dir

    pl = player gs
    lvl = level gs

-- Check for tile in next direction (x+1,y)
-- Stop movement on crossroads (0.1 diff)
canMakeMoveToDir :: Player -> Direction -> Level -> Bool
canMakeMoveToDir player dir lvl
  | isValid = case dir of
    Up -> canMovePerpendicular x
    Down -> canMovePerpendicular x
    Left -> canMovePerpendicular y
    Right -> canMovePerpendicular y
    Stop -> True
  | otherwise = False
  where
    isValid = isValidPlayerPosition lvl . moveFull player $ dir

    (x, y) = pPosition player

-- | Takes coordinate of axis perpendicular to direction you want to move on
-- | i.e. If you want move vertically, you pass the current x axis coordinate
canMovePerpendicular :: RealFloat a => a -> Bool
canMovePerpendicular n = let nFormat = formatDecimals n 1 in nFormat == 0.0 || nFormat == 1.0

-- | Takes float `n` and returns a float of the decimal places rounded to `j` decimals
-- | i.e formatDecimals 9.005 1 = 0.0, formatDecimals 9.05 1 = 0.5
formatDecimals :: RealFloat a => a -> Int -> Float
formatDecimals n j = read (showFFloat (Just j) (n `mod'` 1) "") :: Float



moveFull :: Movable a => a -> Direction -> a
moveFull m dir = setPosition m (moveFullUnit m dir)
  where
    moveFullUnit m dir = case dir of
      Up -> (x, y - validationOffset)
      Down -> (x, y + validationOffset)
      Left -> (x - validationOffset, y)
      Right -> (x + validationOffset, y)
      _ -> (x, y)
      where
        validationOffset = 0.55
        (x, y) = getPosition m



isValidPlayerPosition :: Level -> Player -> Bool
isValidPlayerPosition = isValidMovablePosition isValid
  where
    isValid Floor = True
    isValid _ = False

-- Higher order function to check a movables position with a provided Tile predicate
isValidMovablePosition :: Movable a => (Tile -> Bool) -> Level -> a -> Bool
isValidMovablePosition p level m = case tileAt level intPPos of
  Just t -> p t
  _ -> False --Out of bounds is invalid move when not wrapping movement
  where
    intPPos = intPosition (getPosition m)



-- isValidGhostPosition :: Level -> Ghost -> Bool
-- isValidGhostPosition = isValidPosition isValid
--   where
--     isValid Wall = False
--     isValid (GhostDoor Open) = False
--     isValid (GhostDoor Closed) = True
--     isValid _ = True

-- isValidPosition when using tileAtW
-- isValidPosition :: Movable a => (Tile -> Bool) -> Level -> a -> Bool
-- isValidPosition p level m = p . tileAtW level . intPosition $ getPosition m
