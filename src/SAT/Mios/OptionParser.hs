-- | This is a part of MIOS.
{-# LANGUAGE Safe #-}

-- | command line option parser for mios
module SAT.Mios.OptionParser
       (
         MiosConfiguration (..)
       , defaultConfiguration
       , MiosProgramOption (..)
       , miosDefaultOption
       , miosOptions
       , miosUsage
       , miosParseOptions
       , miosParseOptionsFromArgs
       , toMiosConf
       )
       where

import System.Console.GetOpt (ArgDescr(..), ArgOrder(..), getOpt, OptDescr(..), usageInfo)
import System.Environment (getArgs)
import SAT.Mios.Types (MiosConfiguration (..), defaultConfiguration)

-- | configuration swithces
data MiosProgramOption = MiosProgramOption
                     {
                       _targetFile :: Maybe String
                     , _targets :: [String]
                     , _outputFile :: Maybe String
                     , _confVariableDecayRate :: !Double
                     , _confClauseDecayRate :: Double
--                     , _confRandomDecisionRate :: Int
                     , _confMaxSize :: !Int
                     , _confCheckAnswer :: !Bool
                     , _confVerbose :: !Bool
                     , _confBenchmark :: Integer
                     , _confBenchSeq :: !Int
                     , _confNoAnswer :: !Bool
                     , _confDumpStat :: !Int
                     , _validateAssignment :: !Bool
                     , _displayHelp :: !Bool
                     , _displayVersion :: !Bool
                     }

-- | default option settings
miosDefaultOption :: MiosProgramOption
miosDefaultOption = MiosProgramOption
  {
    _targetFile = Nothing
  , _targets = []
  , _outputFile = Nothing
  , _confVariableDecayRate = variableDecayRate defaultConfiguration
  , _confClauseDecayRate = clauseDecayRate defaultConfiguration
--  , _confRandomDecisionRate = randomDecisionRate defaultConfiguration
  , _confMaxSize = 2000000    -- 2,000,000 = 2M
  , _confCheckAnswer = False
  , _confVerbose = False
  , _confBenchmark = -1
  , _confBenchSeq = 0
  , _confNoAnswer = False
  , _confDumpStat = dumpStat defaultConfiguration
  , _validateAssignment = False
  , _displayHelp = False
  , _displayVersion = False
  }

-- | definition of mios option
miosOptions :: [OptDescr (MiosProgramOption -> MiosProgramOption)]
miosOptions =
  [
    Option ['d'] ["variable-decay-rate"]
    (ReqArg (\v c -> c { _confVariableDecayRate = read v }) (show (_confVariableDecayRate miosDefaultOption)))
    "[solver] variable activity decay rate (0.0 - 1.0)"
  , Option ['c'] ["clause-decay-rate"]
    (ReqArg (\v c -> c { _confClauseDecayRate = read v }) (show (_confClauseDecayRate miosDefaultOption)))
    "[solver] clause activity decay rate (0.0 - 1.0)"
--  , Option ['r'] ["random-decision-rate"]
--    (ReqArg (\v c -> c { _confRandomDecisionRate = read v }) (show (_confRandomDecisionRate miosDefaultOption)))
--    "[solver] random selection rate (0 - 1000)"
  , Option [] ["maxsize"]
    (ReqArg (\v c -> c { _confMaxSize = read v }) (show (_confMaxSize miosDefaultOption)))
    "[solver] limit of the number of clauses/variables"
  , Option [':'] ["validate-assignment"]
    (NoArg (\c -> c { _validateAssignment = True }))
    "[solver] read an assignment from STDIN and validate it"
  , Option [] ["validate"]
    (NoArg (\c -> c { _confCheckAnswer = True }))
    "[solver] self-check (satisfiable) assignment"
  , Option ['o'] ["output"]
    (ReqArg (\v c -> c { _outputFile = Just v }) "file")
    "[option] filename to store result"
{-
  , Option [] ["stdin"]
    (NoArg (\c -> c { _targetFile = Nothing }))
    "[option] read a CNF from STDIN instead of a file"
-}
  , Option ['v'] ["verbose"]
    (NoArg (\c -> c { _confVerbose = True }))
    "[option] display misc information"
  , Option ['X'] ["hide-solution"]
    (NoArg (\c -> c { _confNoAnswer = True }))
    "[option] hide solution"
  , Option [] ["benchmark"]
    (ReqArg (\v c -> c { _confBenchmark = read v }) "-1/0/N")
    "[devel] No/Exhaustive/N-second timeout benchmark"
  , Option [] ["sequence"]
    (ReqArg (\v c -> c { _confBenchSeq = read v }) "NUM")
    "[devel] set 2nd field of a CSV generated by benchmark"
  , Option [] ["dump"]
    (ReqArg (\v c -> c { _confDumpStat = read v }) (show (dumpStat defaultConfiguration)))
    "[devel] dump level; 1:solved, 2:reduction, 3:restart"
  , Option ['h'] ["help"]
    (NoArg (\c -> c { _displayHelp = True }))
    "[misc] display this message"
  , Option [] ["version"]
    (NoArg (\c -> c { _displayVersion = True }))
    "[misc] display program ID"
  ]

-- | generates help message
miosUsage :: String -> String
miosUsage mes = usageInfo mes miosOptions

-- | builds "MiosProgramOption" from string given as command option
miosParseOptions :: String -> [String] -> IO MiosProgramOption
miosParseOptions mes argv =
    case getOpt Permute miosOptions argv of
      (o, [], []) -> return $ foldl (flip id) miosDefaultOption o
      (o, l, []) -> do
        let conf = foldl (flip id) miosDefaultOption o
        return $ conf { _targetFile = Just (head l), _targets = l }
      (_, _, errs) -> ioError (userError (concat errs ++ miosUsage mes))

-- | builds "MiosProgramOption" from a String
miosParseOptionsFromArgs :: String -> IO MiosProgramOption
miosParseOptionsFromArgs mes = miosParseOptions mes =<< getArgs

-- | converts "MiosProgramOption" into "SIHConfiguration"
toMiosConf :: MiosProgramOption -> MiosConfiguration
toMiosConf opts = MiosConfiguration
                 {
                   variableDecayRate = _confVariableDecayRate opts
                 , clauseDecayRate = _confClauseDecayRate opts
--                 , randomDecisionRate = _confRandomDecisionRate opts
                 , dumpStat = _confDumpStat opts
                 }
