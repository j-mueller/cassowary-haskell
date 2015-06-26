{-# LANGUAGE
    MultiParamTypeClasses
  , FunctionalDependencies
  , TypeSynonymInstances
  , FlexibleInstances
  #-}

module Linear.Class where


class CanAddTo a b r | a b -> r where
  (.+.) :: a -> b -> r

infixr 8 .+.

instance CanAddTo Rational Rational Rational where
  (.+.) = (+)


class CanSubTo a b r | a b -> r where
  (.-.) :: a -> b -> r

infixl 8 .-.

instance CanSubTo Rational Rational Rational where
  (.-.) = (-)


class CanMultiplyTo a b r | a b -> r where
  (.*.) :: a -> b -> r

infixr 9 .*.

instance CanMultiplyTo Rational Rational Rational where
  (.*.) = (*)


class CanDivideTo a b r | a b -> r where
  (./.) :: a -> b -> r

infixl 9 ./.

instance CanDivideTo Rational Rational Rational where
  (./.) = (/)
