  {-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
module Wobble where
import Rumpus.Systems.Physics
import Rumpus.Systems.Shared
import Rumpus.Types
import Linear.Extra
import Control.Lens.Extra
import Graphics.GL.Pal
import Data.Dynamic
import Control.Monad.Trans
import Control.Concurrent.STM
import Sound.Pd

update :: OnUpdate
update entityID = do
    now <- getNow
    let a     = (*5) . sin . (/10) $ now
        spatX = (*a) . sin  $ now
        spatZ = (*a) . cos  $ now
        newPose_ = Pose (V3 spatX 0.56  spatZ) (axisAngle (V3 0 1 0) (now + (pi/2)))
    setEntityPose newPose_ entityID

    traverseM_ (use (wldComponents . cmpScriptData . at entityID)) $ \scriptData -> do
        case fromDynamic scriptData of
            Just channel -> (liftIO . atomically . readTChan) channel >>= \case
                Atom (Float freq) -> setEntityColor (hslColor (freq/1000) 0.9 0.8 1) entityID
                _ -> return ()
            Nothing -> return ()

