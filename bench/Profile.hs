module Main where

import Linear.Grammar.Types.Data
import Linear.Constraints.Data
import Linear.Constraints.Tableau.Data

import Linear.Grammar
import Linear.Class
import Linear.Constraints.Cassowary
import Linear.Constraints.Slack

import Criterion.Main


main :: IO ()
main = defaultMain
  [ bgroup "Grammar"
    [ bgroup "multLin"
      [ bench "1" $ whnf multLin linAst1
      , bench "2" $ whnf multLin linAst2
      , bench "3" $ whnf multLin linAst3
      , bench "4" $ whnf multLin linAst4
      , bench "5" $ whnf multLin linAst5
      ]
    , bgroup "addLin"
      [ bench "1" $ whnf (addLin . multLin) linAst1
      , bench "2" $ whnf (addLin . multLin) linAst2
      , bench "3" $ whnf (addLin . multLin) linAst3
      , bench "4" $ whnf (addLin . multLin) linAst4
      , bench "5" $ whnf (addLin . multLin) linAst5
      ]
    , bgroup "1 .==."
      [ bench "1" $ whnf (linAst1 .==.) linAst1
      , bench "2" $ whnf (linAst1 .==.) linAst2
      , bench "3" $ whnf (linAst1 .==.) linAst3
      , bench "4" $ whnf (linAst1 .==.) linAst4
      , bench "5" $ whnf (linAst1 .==.) linAst5
      ]
    , bgroup ".==. 1"
      [ bench "1" $ whnf (.==. linAst1) linAst1
      , bench "2" $ whnf (.==. linAst1) linAst2
      , bench "3" $ whnf (.==. linAst1) linAst3
      , bench "4" $ whnf (.==. linAst1) linAst4
      , bench "5" $ whnf (.==. linAst1) linAst5
      ]
    , bgroup "standardForm"
      [ bench "1" $ whnf (\x -> standardForm $ linAst1 .==. x) linAst1
      , bench "2" $ whnf (\x -> standardForm $ linAst1 .==. x) linAst2
      , bench "3" $ whnf (\x -> standardForm $ linAst1 .==. x) linAst3
      , bench "4" $ whnf (\x -> standardForm $ linAst1 .==. x) linAst4
      , bench "5" $ whnf (\x -> standardForm $ linAst1 .==. x) linAst5
      ]
    ]
  , bgroup "Constraints"
    [ bgroup "makeSlackVars"
      [ bench "10 x 1" $ whnf (makeSlackVars . replicate 10) ineqStd1
      , bench "10 x 2" $ whnf (makeSlackVars . replicate 10) ineqStd2
      , bench "10 x 3" $ whnf (makeSlackVars . replicate 10) ineqStd3
      , bench "10 x 4" $ whnf (makeSlackVars . replicate 10) ineqStd4
      , bench "10 x 5" $ whnf (makeSlackVars . replicate 10) ineqStd5
      ]
    , bgroup "makeErrorVars"
      [ bench "10 x 1" $ whnf makeErrorVars (tableau1, obj)
      , bench "10 x 2" $ whnf makeErrorVars (tableau2, obj)
      , bench "10 x 3" $ whnf makeErrorVars (tableau3, obj)
      , bench "10 x 4" $ whnf makeErrorVars (tableau4, obj)
      , bench "10 x 5" $ whnf makeErrorVars (tableau5, obj)
      ]
    , bgroup "Simplex"
      [ bgroup "nextBasicPrimal"
        [ bench "1" $ whnf (nextBasicPrimal . unEquStd) equStd1
        , bench "2" $ whnf (nextBasicPrimal . unEquStd) equStd2
        , bench "3" $ whnf (nextBasicPrimal . unEquStd) equStd3
        , bench "4" $ whnf (nextBasicPrimal . unEquStd) equStd4
        , bench "5" $ whnf (nextBasicPrimal . unEquStd) equStd5
        ]
      , bgroup "blandRatioPrimal"
        [ bench "1" $ whnf (blandRatioPrimal $ VarMain "a") ineqStd1
        , bench "2" $ whnf (blandRatioPrimal $ VarMain "a") ineqStd2
        , bench "3" $ whnf (blandRatioPrimal $ VarMain "a") ineqStd3
        , bench "4" $ whnf (blandRatioPrimal $ VarMain "a") ineqStd4
        , bench "5" $ whnf (blandRatioPrimal $ VarMain "a") ineqStd5
        ]
      , bgroup "nextRowPrimal"
        [ bench "1" $ whnf (nextRowPrimal $ VarMain "a") $ replicate 10 ineqStd1
        , bench "2" $ whnf (nextRowPrimal $ VarMain "a") $ replicate 10 ineqStd2
        , bench "3" $ whnf (nextRowPrimal $ VarMain "a") $ replicate 10 ineqStd3
        , bench "4" $ whnf (nextRowPrimal $ VarMain "a") $ replicate 10 ineqStd4
        , bench "5" $ whnf (nextRowPrimal $ VarMain "a") $ replicate 10 ineqStd5
        ]
      , bgroup "nextRowDual"
        [ bench "1" $ whnf nextRowDual $ replicate 10 ineqStd1
        , bench "2" $ whnf nextRowDual $ replicate 10 ineqStd2
        , bench "3" $ whnf nextRowDual $ replicate 10 ineqStd3
        , bench "4" $ whnf nextRowDual $ replicate 10 ineqStd4
        , bench "5" $ whnf nextRowDual $ replicate 10 ineqStd5
        ]
      , bgroup "blandRatioDual"
        [ bench "1" $ whnf (blandRatioDual (VarMain "a") $ unEquStd equStd1) ineqStd1
        , bench "2" $ whnf (blandRatioDual (VarMain "a") $ unEquStd equStd1) ineqStd2
        , bench "3" $ whnf (blandRatioDual (VarMain "a") $ unEquStd equStd1) ineqStd3
        , bench "4" $ whnf (blandRatioDual (VarMain "a") $ unEquStd equStd1) ineqStd4
        , bench "5" $ whnf (blandRatioDual (VarMain "a") $ unEquStd equStd1) ineqStd5
        ]
      , bgroup "nextBasicDual"
        [ bench "1" $ whnf (nextBasicDual $ unEquStd equStd1) ineqStd1
        , bench "2" $ whnf (nextBasicDual $ unEquStd equStd1) ineqStd2
        , bench "3" $ whnf (nextBasicDual $ unEquStd equStd1) ineqStd3
        , bench "4" $ whnf (nextBasicDual $ unEquStd equStd1) ineqStd4
        , bench "5" $ whnf (nextBasicDual $ unEquStd equStd1) ineqStd5
        ]
      ]
    ]
  ]
