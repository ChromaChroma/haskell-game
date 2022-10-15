module View.InfoSection (renderInfoSection) where

import Graphics.Gloss (Picture (Blank), color, pictures, polygon, rectangleSolid, rose, translate)
import Model.Game (GameState (elapsedTime, level, player, points), Time)
import Model.Level (Level (layout), layoutSize)
import Model.Player (Lives (Lives, unlives), Player (lives))
import Model.Score (Score, Points)
import View.Config (tileSize)
import View.Helpers (smallText, smallTextOnly, translateToAboveLevelSection)

renderInfoSection :: GameState -> Picture
renderInfoSection gs =
  translateToAboveLevelSection (layoutSize . layout . level $ gs) $
    pictures
      [ renderScore . points $ gs,
        renderLives . lives . player $ gs,
        renderTime . elapsedTime $gs
      ]

-- | Render the players lives, if lives is bigger than 3, render a life picture with the number of lives
renderLives :: Lives -> Picture
renderLives (Lives lives)
  | lives <= 3 = pictures [lifePictures]
  | otherwise = pictures [life 1, translate (tileSize / 1.5) 0 . smallTextOnly . show $ lives]
  where
    lifePictures = pictures . map life $ [1 .. (fromIntegral lives)]
    life n = translate ((n -1) * tileSize) (tileSize / 5) . color rose . rectangleSolid (tileSize / 2) $ (tileSize / 2)

renderScore :: Points -> Picture
renderScore x = Blank

renderTime :: Time -> Picture
renderTime x = Blank
