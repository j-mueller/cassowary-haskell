{-# LANGUAGE
    FlexibleContexts
  #-}

module Linear.Constraints.Slack where

import Linear.Grammar
import Sets.Class

import qualified Data.Map as Map
import qualified Data.IntMap as IMap
import Data.Traversable (traverse)
import Control.Monad.State
import Control.Applicative


makeSlackVars :: ( MonadState Integer m
                 , Applicative m
                 ) => IMap.IntMap IneqStdForm
              -> m (IMap.IntMap IneqStdForm)
makeSlackVars = traverse mkSlackStdForm
  where
    mkSlackStdForm :: ( MonadState Integer m
                      , Applicative m
                      ) => IneqStdForm -> m IneqStdForm
    mkSlackStdForm (EquStd c) = return $ EquStd c
    mkSlackStdForm (LteStd (Lte (LinVarMap xs) xc)) = do
      s <- get
      put $ s+1
      return $ EquStd $ Equ (LinVarMap $ xs `union` Map.singleton (VarSlack s) 1) xc
    mkSlackStdForm (GteStd (Gte (LinVarMap xs) xc)) =
      mkSlackStdForm $ LteStd $ Lte (LinVarMap $ fmap (* (-1)) xs) $ xc * (-1)
