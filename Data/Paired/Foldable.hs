
-- | 

module Data.Paired.Foldable where

import Data.IntMap as IM
import Data.Foldable as F
import Data.List as L
import Control.Arrow ((***))
import Data.Vector as V
import Data.Vector.Generic as VG

import Data.Paired.Common
import Math.TriangularNumbers



-- | Generalized upper triangular elements. Given a list of elements
-- @[e_1,...,e_k]@, we want to return pairs @(e_i,e_j)@ such that we have
-- all ordered pairs with @i<j@ (if @NoDiag@onal elements), or @i<=j@ (if
-- @OnDiag@onal elements).
--
-- @upperTri@ will force the spine of @t a@.
--
-- This is important if the @Enumerate@ type is set to @FromN k n@. We
-- start at the @k@th element, and produce @n@ elements.

upperTri
  :: (Foldable t)
  => OnDiag
  -> Enumerate
  -> t a
  -> (IntMap a, Int, [(a,a)])
upperTri d e xs' = (undefined, numElems, ys)
  where xs   = V.fromList . F.toList $ xs'
        ys   = L.unfoldr go $ initEnum e d
        -- how many elements we will emit depends on enumeration and on
        -- diagonal element counting
        numElems
          | All <- e       = allSize
          | FromN s k <- e = if s+k > allSize then max 0 (allSize - s) else k
        -- We repeat part of @go@ because we generally do not want to force
        -- all of @xs@.
        --
        -- TODO if we do this right, we should consider getting rid of @xs@
        -- and use @imp@ directly. This will, however, incur some overhead
        -- as we then index into an @IntMap@, not a @vector@ anymore.
        imp  = undefined
        len = VG.length xs
        allSize = len * (len + if d == OnDiag then 1 else 0) `div` 2
        -- index into the generated vector @xs@ when generating elements
        -- via @go@
        go (k,l)
          | k >= len  = Nothing
          | l >= len  = go (k+1,k+1 + if d == OnDiag then 0 else 1)
          | otherwise = Just ((xs VG.! k, xs VG.! l), (k,l+1))
        -- Initialize the enumeration at the correct pair @(i,j)@. From
        -- then on we can @take@ the correct number of elements, or stream
        -- all of them.
        initEnum All OnDiag = (0,0)
        initEnum All NoDiag = (0,1)
        initEnum (FromN s k) OnDiag = fromLinear sz s
        initEnum (FromN s k) NoDiag = id *** (+1) $ fromLinear (sz-1) s
        sz = F.length xs'

{-
upperTriVG d as = (z, unfoldrN z go (0,if d == OnDiag then 0 else 1))
  where la = VG.length as
        z  = la * (la + if d == OnDiag then 1 else 0) `div` 2
        go (k,l)
          | k >= la   = Nothing
          | l >= la   = go (k+1,k+1 + if d == OnDiag then 0 else 1)
          | otherwise = Just ((as `VG.unsafeIndex` k, as `VG.unsafeIndex` l), (k,l+1))
{-# Inline upperTriVG #-}
-}
