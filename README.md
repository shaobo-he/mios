# mios -- Minisat-based Implementation and Optimization Study
----

`mios` is yet another minisat-based SAT solver implementation in Haskell, as
a part of my research theme.

#### > Features

* fundamentally this is a *line-to-line* translation of [MiniSat 1.14](http://minisat.se/downloads/MiniSat_v1.14.2006-Aug-29.src.zip)
(And,  in the early stage of development, it was based on  N. Een and N. Sorensson, *“An extensible SAT-solver [extended version 1.2],”* in 6th Int. Conf. on Theory and Applications of Satisfiability Testing (SAT2003), 2003, pp. 502–518.)
* runs in `IO` monad, uses `Data.Vector` and *pointer-based equality* by `reallyUnsafePtrEquality`
* very fast, compared with SAT solvers written in Haskell; see below.

##### benchmark results

* On a subset of SAT-RACE 2015 Application Problems (timeout: 1200 sec)

This is a result on a subset the problems of which MiniSat-2.2.0 can solve
in 1000 secs. `3.4 * minisat` is the line scaled the result of MiniSat-1.14
by 3.4. This means that *mios-1.1.1 is 3.4 times slower than MiniSat-1.14*.

![scatter plot](https://cloud.githubusercontent.com/assets/997855/14322605/746d2652-fc58-11e5-9fdc-588c7dc02508.png)

* Performances on [various 3SAT problems (uf-* series)](http://www.cs.ubc.ca/~hoos/SATLIB/benchm.html)

![](https://docs.google.com/spreadsheets/d/1cNltZ4FIu_exSUQMcXe53w4fADr3sOUxpo3L7oM0H_Q/pubchart?oid=297581252&format=image)

#### > Release Note

##### 1.1.1

* tiny changes on the output format
* tiny changes on random variable decision rate
* update REDAME.md with a figure on a benchmark run sequentially; the old ones were multi-threaded and got very inaccurate numbers.

This would be the last version based on [MiniSat 1.14](https://github.com/shnarazk/minisat114/).

##### 1.1.0

* Based on [MiniSat 1.14](https://github.com/shnarazk/minisat114/), but lacks the binary clause implementation so far.
* The arguments of `solveSAT`and `validateAssignment` were curried.
* `Solver` holds a literal set internally in the case of contradiction.
* literals are encoded  to positive integers
* no more queue; `propQ` was merged to `trail`
* added a simple pre-processor
* a new CNF DIMACS parser
* solutions can be saved to a file with `--output` option

##### 1.0.3

* uses vector-based containers instead of pointer-based clause containers
* adds self checking option (`--validate`), which works only on satisfiable problems
* `stack install` installs `mios`. `stack install --flag mios:devel` installs `mios-1.0.3` for developers.

This is the last version based on *“An extensible SAT-solver [extended version 1.2].”*

##### 1.0.2

* fixes a bug on CNF reader at 1.0.1

##### 1.0.1 => canceled by a bug on CNF reader

* CNF reader was changed from a parser based on 'Parsec' to a simple *reader* based on `Data.ByteString.Char8.readInt`
* uses a true `sortOnActivity` implementation
* phase saving
* provides assignment validation mode (see below)

```
$ mios test/data/uf200-012.cnf | mios -: test/data/uf200-012.cnf      # `-:` is the option for validation.
It's a valid assignment.
$ echo "[1,2,-3,4,-5]" | mios -: test/data/uf200-012.cnf
It's an invalid assignment.
```

#### > Install

* ghc-7.10.2 or upper
* [Stack](http://www.haskellstack.org/) or `cabal-install`

```
stack init --resolver lts-5.5   # or upper
stack install
```

```
cabal install
```

#### > Usage

##### * As a standalone program

```
$ mios a.cnf
dumps an assignment :: [Int]

$ mios --help
mios* WIP-for-1.1.1$ mios
mios 1.1.1 #3.4*1.14
Usage: mios [OPTIONS] target.cnf
  -d 0.95   --variable-decay-rate=0.95  [solver] variable activity decay rate (0.0 - 1.0)
  -c 0.999  --clause-decay-rate=0.999   [solver] clause activity decay rate (0.0 - 1.0)
  -r 0      --random-decision-rate=0    [solver] random selection rate (0 - 1000)
  -:        --validate-assignment       [solver] read an assignment from STDIN and validate it
            --validate                  [solver] self-check the (satisfied) answer
  -o file   --output=file               [option] filename to store the result
  -v        --verbose                   [option] display misc information
  -X        --hide-solution             [option] hide the solution
            --time                      [option] display execution time
            --stat                      [option] display statistics information
  -h        --help                      [misc] display this help message
            --version                   [misc] display program ID
```

##### * In Haskell

```haskell
module Main where -- this is sample.hs in app/
import SAT.Solver.Mios (CNFDescription (..), solveSAT)

clauses = [[1, 2], [1, 3], [-1, -2], [1, -2, 3], [-3]]
desc = CNFDescription 3 5 Nothing    -- #vars, #clauses, Just pathname or Nothing

main = do
  asg <- solveSAT desc clauses    -- solveSAT :: Traversable m => CNFDescription -> m [Int] -> IO [Int]
  putStrLn $ if null asg then "unsatisfiable" else show asg
```

```
$ stack ghc app/sample.hs
$ app/sample
[1,-2,-3]
```
Of course, you can use mios in ghci similarly.

```
$ stack ghci
...>
```
