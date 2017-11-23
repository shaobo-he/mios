# Mios -- Minisat-based Implementation and Optimization Study
----

`Mios` is yet another minisat-based SAT solver implementation in Haskell, as
a part of my research theme.

### > Features

* fundamentally it is developed based on Minisat-1.14 and 2.2.0.
  * Firstly, version 1.0 was based on N. Een and N. Sorensson, *“An extensible SAT-solver [extended version 1.2],”* in 6th Int. Conf. on Theory and Applications of Satisfiability Testing (SAT2003), 2003, pp. 502–518.
  * Version 1.1 was a *line-to-line* translation of [MiniSat 1.14](http://minisat.se/downloads/MiniSat_v1.14.2006-Aug-29.src.zip).
  * Version 1.2 imported some idea used in Glucose 4.0.
  * Version 1.5 uses Literal Block Distance (LBD).
* runs in `IO` monad, uses `Data.Primitive.ByteArray` mainly and `reallyUnsafePtrEquality`.
* very fast, compared with other SAT solvers written in Haskell; see below.

#### benchmark results

- SAT-Competition 2017 Main track, running 3 jobs *in parallel* with 400-second timeout on Intel Core i7-3930K @ 12x 3.8GHz
  (Therefore results near the threshold should be affected by other threads more or less.)

![Cactus plot 1: SAT Competition 2017 main](https://user-images.githubusercontent.com/997855/33189424-d2caaf04-d0e5-11e7-911a-7f2ff63e1b1c.png)


- A subset of SAT-Race 2015 Application Problems (timeout: 1200 sec)

This is a result on a subset the problems of which MiniSat-2.2.0 can solve
in 1000 secs. It shows that *mios-1.2.0 is only about 2 times slower than MiniSat-2.2.0*.

![Cactus plot 2:SAT-RACE2015](https://cloud.githubusercontent.com/assets/997855/18457723/e9c6b91c-7995-11e6-8cc5-ecad36259fa7.png)

- Performances on [various 3SAT problems (uf-* series)](http://www.cs.ubc.ca/~hoos/SATLIB/benchm.html)

![](https://docs.google.com/spreadsheets/d/1cNltZ4FIu_exSUQMcXe53w4fADr3sOUxpo3L7oM0H_Q/pubchart?oid=297581252&format=image)

### > Release Note

##### 1.5.1

* fix a bug in simplifyDB
* revise VARUPDATEACTIVITY (#52)
* revise blockers (#53)
* refactor mios.cabal
* add `--benchmark` option

##### 1.5.0

* **implement LBD**
* misc micro tuning
* add some utilities
* switch to SAT Competition 2017 main track for benchmark

##### 1.4.1

A maintenance release:

* use `ByteArray`; no performance boost.
* add a copy of a branch: MultiConflict.

##### 1.4.0

* new classes and methods

##### 1.3.0

* replace LBD heuristics with a simpler metrics, inspired by S. Jabbour et al.: “*Revisiting the Learned Clauses Database Reduction Strategies*,” 2013.
* change the module structure

##### 1.2.1

* tiny changes for uploading to [hackage](http://hackage.haskell.org/)
* add a CNF handling library under 'SAT.Util'

Note: Mios requires optimization flag `-O2`; it's crucial.

##### 1.2.0

* use *blocking literals*
* implement *literal block distance (LBD)* (not tested well)
* revise `reduceDB`
* use phase-saving
* remove random literal selection
* remove 'Criterion' from dependency list

##### 1.1.2

* fix a bug in DIMACS CNF parser; only single space between literals was accepted

This would be the last version based on [MiniSat 1.14](https://github.com/shnarazk/minisat114/).

##### 1.1.1

* tiny changes on the output format
* tiny changes on random variable decision rate
* update REDAME.md with a figure on a benchmark run sequentially; the old ones were multi-threaded and got very inaccurate numbers.

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
* adds self-checking option (`--validate`), which works only on satisfiable problems
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

### > Install

##### Requirements

* ghc-8.0.1 or upper (By deleting `default-extensions` from mios.cabal, you can use ghc-7.10.x.)
* [Stack](http://www.haskellstack.org/) or `cabal-install`

##### Stack

```
git clone https://github.com/shnarazk/mios
stack init --resolver nightly-2017-XX-XX  # for ghc-8.2.X
stack install
```

##### Cabal

Mios is registered in [hackage](http://hackage.haskell.org/package/mios) now.

```
cabal install mios
```

### > Usage

##### * As a standalone program

```
$ mios a.cnf
an assignment :: [Int]

$ mios --help
mios 1.4.0 -- https://github.com/shnarazk/mios
Usage: mios [OPTIONS] target.cnf
  -d 0.95  --variable-decay-rate=0.95  [solver] variable activity decay rate (0.0 - 1.0)
  -:       --validate-assignment       [solver] read an assignment from STDIN and validate it
           --validate                  [solver] self-check the (satisfied) answer
  -o file  --output=file               [option] filename to store the result
  -v       --verbose                   [option] display misc information
  -X       --hide-solution             [option] hide the solution
           --time                      [option] display execution time
           --stat                      [option] display statistics information
  -h       --help                      [misc] display this help message
           --version                   [misc] display program ID
```

##### * In Haskell

```haskell
module Main where -- this is sample.hs in app/
import SAT.Mios (CNFDescription (..), solveSAT)

clauses = [[1, 2], [1, 3], [-1, -2], [1, -2, 3], [-3]] :: [[Int]]
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
