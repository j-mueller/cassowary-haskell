module Linear.Constraints.Cassowary.Basic where

import Prelude hiding (const)
import Linear.Constraints.Cassowary.Bland (blandRatioPrimal, blandRatioDual)
import Linear.Grammar.Types.Class (mapAllVars, getVars, getConst)
import Linear.Grammar.Types.Inequalities
  ( Equality (Equ, getEqu)
  , IneqStdForm
  )
import Linear.Constraints.Weights (Weight (Weight))

import Data.Semigroup (First (First, getFirst), Min (Min, getMin))
import qualified Data.Map as Map
import qualified Data.IntMap as IntMap
import qualified Data.Vector as V
import Control.Monad (guard)



-- | Most negative coefficient in objective function
nextBasicPrimal :: ( Ord a
                   , Num a
                   ) => Equality k a c -- ^ Objective function
                     -> Maybe k
nextBasicPrimal (Equ objective) = do
  -- gets the first successful, minimal result
  let minSnd var coeff = Just $ Min $ Snd (var, coeff)
      mKeyVal = Map.foldMapWithKey minSnd (getVars objective)
  (var,coeff) <- getSnd . getMin <$> mKeyVal
  guard (coeff < 0) -- Must be positive, but the /most/ negative out of the set
  pure var

nextBasicPrimalWeight :: ( Ord a
                         , Num a
                         ) => Equality k (Weight a) c -- ^ Objective function
                           -> Maybe k
nextBasicPrimalWeight (Equ objective) = go 0
  where
    go n
      | all (\(Weight x) -> length x <= n) (getVars objective) = Nothing -- base case
      | otherwise =
          let currentResult =
                nextBasicPrimal $
                  Equ $
                    mapAllVars (Map.mapMaybe (\(Weight y) -> y V.!? n)) objective -- get the weight at n
              recurseResult = go (n + 1)
          in  getFirst (First currentResult <> First recurseResult)

-- ** Dual

nextBasicDual :: ( Ord k
                 , Ord a
                 , Num a
                 , Fractional a
                 ) => Equality k a c -- ^ Objective
                   -> IneqStdForm k a c -- ^ Row
                   -> Maybe k
nextBasicDual objective row = do
  let osMap = getVars (getEqu objective)
      xsMap = getVars row
      allVars = osMap <> xsMap
      mKeyVar =
        let go var _ = (\ratio -> Min $ Snd (var,ratio)) <$> blandRatioDual var objective row
        in  Map.foldMapWithKey go allVars
  (var,_) <- getSnd . getMin <$> mKeyVar
  pure var

nextBasicDualWeight :: ( Ord k
                       , Ord a
                       , Num a
                       , Fractional a
                       ) => Equality k (Weight a) c
                         -> IneqStdForm k a c
                         -> Maybe k
nextBasicDualWeight (Equ objective) row =
  go 0
  where
    go n
      | all (\(Weight x) -> length x <= n) (getVars objective) = Nothing
      | otherwise =
          let currentResult =
                nextBasicDual
                  (Equ (mapAllVars (Map.mapMaybe (\(Weight y) -> y V.!? n)) objective))
                      row
              recurseResult = go (n + 1)
          in  getFirst (First currentResult <> First recurseResult)



-- | Finds the index of the next row to pivot on
nextRowPrimal :: ( Ord k
                 , Fractional a
                 , Ord a
                 ) => k
                   -> IntMap.IntMap (IneqStdForm k a a) -- ^ Restricted "slack" tableau
                   -> Maybe Int
nextRowPrimal var xs = do
  let mKeyVal =
        let go slack row = (\ratio -> Min $ Snd (slack,ratio)) <$> blandRatioPrimal var row
        in  IntMap.foldMapWithKey go xs
  (slack,_) <- getSnd . getMin <$> mKeyVal
  pure slack


nextRowDual :: ( Ord c
               , Num c
               ) => IntMap.IntMap (IneqStdForm k a c)
                 -> Maybe Int
nextRowDual xs = do
  let mKeyVal =
        IntMap.foldMapWithKey
          (\slack row -> Just $ Min $ Snd (slack, getConst row))
          xs
  (slack,const) <- getSnd . getMin <$> mKeyVal
  guard (const < 0)
  pure slack


newtype Snd a b = Snd {getSnd :: (a,b)}

instance Eq b => Eq (Snd a b) where
  (Snd (_,y1)) == (Snd (_,y2)) = y1 == y2

instance (Ord b) => Ord (Snd a b) where
  (Snd (_,y1)) `compare` (Snd (_,y2)) = compare y1 y2

-- TODO: Turn all of this into a class, overloaded by the coefficient type.
-- Also, objective function should be raw Rational
