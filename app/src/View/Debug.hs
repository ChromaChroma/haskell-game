module View.Debug where

import Controller.MovementController
import Graphics.Gloss
import Model.Game
import Model.Level
import Model.Movement
import Model.Player
import View.Config
import View.Helpers

renderDebug :: GameState -> Picture
renderDebug gs = pictures [(renderIntersections gs), (renderDebugDetails gs)]

renderDebugDetails :: GameState -> Picture
renderDebugDetails gs =
  let (x, y) = getPosition . player $ gs
   in pictures . stack 25 $
        reverse
          [ smallText "Status: " . status $ gs,
            smallText "Elapsed time (s): " . msToSec . elapsedTime $ gs,
            smallText "Tick time (ms): " . tickTimer $ gs,
            smallText "Lives: " . unlives . lives . player $ gs,
            smallText "Direction: " . direction $ gs,
            smallText "Buffer Direction: " . bufDirection $ gs,
            smallText "Position: " . getPosition . player $ gs,
            smallText "Coordinate decimals x, y: " $ show (formatDecimals x 1) ++ ", " ++ show (formatDecimals y 1),
            smallText "Can switch x, y: " $ (show . canMovePerpendicular $ x) ++ ", " ++ (show . canMovePerpendicular $ y),
            smallText "Intersections: " . levelIntersections . level $ gs
          ]

-- | Renders the intersections calculated by the game based on the level layout
renderIntersections :: GameState -> Picture
renderIntersections gs = translateToLevelSection $ pictures [block (x, y) | (x, y) <- levelIntersections . level $ gs]
  where
    block (x, y) = color (dim green) . translateByTileSize (fromIntegral x) (fromIntegral y) $ rectangleSolid renderSize renderSize
    renderSize = tileSize / 2