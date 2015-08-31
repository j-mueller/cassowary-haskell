{-# LANGUAGE
    FlexibleContexts
  #-}

module Linear.Constraints.Error where

import Linear.Class
import Linear.Constraints.Tableau
import Linear.Constraints.Cassowary
import Linear.Grammar
import Data.Set.Class as Sets

import qualified Data.Map as Map
import Data.Maybe
import Data.Composition


-- * Error Variables

-- | Replaces unrestricted variables with /two/ restricted variables - one for
-- the positive component and one for the negative component, whose difference
-- sums to be the original restricted variable:
--
-- >   -∞ <= x <= ∞
-- > x_+ >= 0; x_- >= 0
-- >
-- >   x = x_+ - x_-
makeErrorVars :: ( Eq b
                 , CanMultiplyTo b b b
                 , CanMultiplyTo Rational b b
                 , CanMultiplyTo Rational b Rational
                 , CanSubTo b b b
                 , CanSubTo Rational b Rational
                 , HasOne b
                 , HasNegOne b
                 , HasZero b
                 ) => (Tableau b, Equality b) -> (Tableau b, Equality b)
makeErrorVars (Tableau (BNFTableau bus, us) (BNFTableau sus, ss) u,f) =
  let toSub = Map.fromList $ do
        n <- u
        return ( VarMain n -- from Main var to its ErrVar equation
               , EquStd $ Equ (LinVarMap $ Map.fromList
                    [ (VarError n ErrPos, one')
                    , (VarError n ErrNeg, negone')
                    ]) 0
               )
      newsus = Map.fromList $ mapMaybe (\u' -> do
        -- Restricts unrestricted vars
        equation <- Map.lookup u' bus
        return ( VarError u' ErrPos
               , mapVars (\(LinVarMap xs) -> LinVarMap $
                  xs `union` Map.singleton (VarError u' ErrNeg) one') equation -- because (0 = 1 + -1) ~ (1 = 1)
               )) u -- "for every basic unrestricted var, re-orient to the positive error var in basic form"
      bus' = bus `union` Map.mapKeys (\(VarMain n) -> n) toSub -- unrestricted
      us'  = Map.foldWithKey (fmap .* substitute) us toSub -- post-substitution
      ss'  = Map.foldWithKey (fmap .* substitute) ss toSub
      sus' = Map.foldWithKey (fmap .* substitute) sus toSub `union` newsus
      f' = unEquStd $ Map.foldWithKey substitute (EquStd f) toSub
  in (Tableau (BNFTableau bus', us') (BNFTableau sus', ss') u, f')
