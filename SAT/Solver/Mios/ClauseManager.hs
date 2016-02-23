{-# LANGUAGE
    FlexibleInstances
  , MagicHash
  , MultiParamTypeClasses
  , RecordWildCards
  , TupleSections
  , UndecidableInstances
  #-}
{-# LANGUAGE Trustworthy #-}

-- | __Version 0.8__
--
-- | Universal data structure for Clauses
-- | Both of watchlists and @learnt@ are implemented by this.
module SAT.Solver.Mios.ClauseManager
       (
         -- * Vector of Clause
         ClauseVector
       , getNthClause
       , setNthClause
         -- * higher level interface for ClauseVector
       , ClauseManager (..)
       , newClauseManager
       , numberOfClauses
       , clearClauseManager
       , getClauseVector
       , pushClause
       , removeClause
       )
       where

import Control.Monad (unless)
import qualified Data.IORef as IORef
import qualified Data.Vector as V
import qualified Data.Vector.Mutable as MV
import SAT.Solver.Mios.Types (ContainerLike (..))
import qualified SAT.Solver.Mios.Clause as C
import SAT.Solver.Mios.Data.Singleton

type ClauseVector = MV.IOVector C.Clause

instance ContainerLike ClauseVector C.Clause where
  asList cv = V.toList <$> V.freeze cv
  dump mes cv = do
    l <- take 10 <$> asList cv
    sts <- mapM (dump ",") (l :: [C.Clause])
    return $ mes ++ concat sts

getNthClause :: ClauseVector -> Int -> IO C.Clause
getNthClause = MV.unsafeRead

setNthClause :: ClauseVector -> Int -> C.Clause -> IO ()
setNthClause = MV.unsafeWrite

-- | The Clause Container
data ClauseManager = ClauseManager
  {
    _nActives     :: IntSingleton -- number of active clause
  , _clauseVector :: IORef.IORef ClauseVector -- clause list
  }

newClauseManager :: Int -> IO ClauseManager
newClauseManager initialSize = do
  i <- newInt 0
  v <- MV.new initialSize
  MV.set v C.NullClause
  ClauseManager i <$> IORef.newIORef v

numberOfClauses :: ClauseManager -> IO Int
numberOfClauses ClauseManager{..} = getInt _nActives

clearClauseManager :: ClauseManager -> IO ()
clearClauseManager ClauseManager{..} = setInt _nActives 0

getClauseVector :: ClauseManager -> IO ClauseVector
getClauseVector ClauseManager{..} = IORef.readIORef _clauseVector

-- | O(1) inserter
pushClause :: ClauseManager -> C.Clause -> IO ()
pushClause ClauseManager{..} c = do
  n <- getInt _nActives
  v <- IORef.readIORef _clauseVector
  v' <- if MV.length v <= n
       then do
        v' <- MV.grow v 200
        IORef.writeIORef _clauseVector v'
        return v'
       else return v
  MV.unsafeWrite v' n c
  modifyInt _nActives (1 +)

-- | O(n) but lightweight remove-and-compact function
removeClause :: ClauseManager -> C.Clause -> IO ()
removeClause ClauseManager{..} c = do
  n <- subtract 1 <$> getInt _nActives
  unless (0 <= n) $ error "removeClause catches 0"
  v <- IORef.readIORef _clauseVector
  let
    seekIndex :: Int -> IO Int
    seekIndex k = do
      c' <- MV.unsafeRead v k
      if c' == c then return k else seekIndex $ k + 1
  j <- seekIndex 0
  MV.unsafeSwap v j n           -- swap the last active element and it
  setInt _nActives n

instance ContainerLike ClauseManager C.Clause where
  dump mes ClauseManager{..} = do
    n <- IORef.readIORef _nActives
    l <- take n <$> (asList =<< IORef.readIORef _clauseVector)
    sts <- mapM (dump ",") (l :: [C.Clause])
    return $ mes ++ concat sts