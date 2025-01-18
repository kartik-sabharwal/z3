#lang scribble/base

@title{Personal readme}

@section{Debug build}

The following sequence has worked for me in the past.

@verbatim{
$ CXX=clang++ CC=clang python3 scripts/mk_make.py --prefix=$HOME/local/debug-z3 --debug
$ cd build
$ make -j8
$ make install
}

@emph{./scripts/mk_util.py} mentions more command-line options.

@section{Print instances}

The following SMT-LIB file is written such that @emph{le_Z_Sn} needs to be instantiated exactly 3 times by the solver to derive a contradiction and report @emph{unsat}.

@verbatim{
;; lessequal3.smt2
(set-logic UF)
(declare-sort Nat 0)
(declare-fun Z () Nat)
(declare-fun S (Nat) Nat)
(declare-fun le (Nat Nat) Bool)
(define-fun Q ((n Nat)) Bool (=> (le Z n) (le Z (S n))))
(assert (le Z Z))
(assert (forall ((n Nat)) (! (Q n) :pattern ((le Z (S n))) :qid le_Z_Sn)))
(assert (not (le Z (S (S (S Z))))))
(check-sat)
}

I can use my trace tag @emph{qi_queue_specific} to print each named formula added to the instance queue along with its arguments.

@verbatim{
# run-debug-z3.sh
result=$(debug-z3 -tr:qi_queue_specific pp.max_depth=100000 pp.single_line=true pp.no_lets=true auto_config=false smt.mbqi=false smt.ematching=true smt.qi.eager_threshold=100000 lessequal3.smt2)
cat .z3-trace >lessequal3.out
echo $result >>lessequal3.out
}

Once this script is finished lessequal3.out looks like:

@verbatim{
(le_Z_Sn (S (S Z)))
(le_Z_Sn (S Z))
(le_Z_Sn Z)
unsat
}