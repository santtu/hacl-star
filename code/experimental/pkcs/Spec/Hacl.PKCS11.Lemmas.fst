module Hacl.PKCS11.Lemmas

open FStar.Seq
open Hacl.PKCS11.Lib
open Hacl.PKCS11.Types


val lemmaFindLExistIfSome: #a: Type -> f: (a -> bool) -> s: seq a -> Lemma
  (requires (Some? (find_l f s)))
  (ensures (exists (a: nat {a < Seq.length s}). f (index s a)))
  (decreases (Seq.length s))


let rec lemmaFindLExistIfSome #a f s = 
  if length s = 0 then ()
  else if length s = 1 then () 
  else
    if f (head s) then ()
    else
    lemmaFindLExistIfSome f (tail s)


val lemmaIfExistAndNotFirst: #a: Type -> f: (a -> bool) -> s: seq a -> 
  Lemma 
    (requires (exists (a: nat {a < Seq.length s}). f (index s a) /\ not (f (head s))))
    (ensures (exists (a: nat {a < Seq.length (tail s)}). f (index (tail s) a)))

let lemmaIfExistAndNotFirst #a f s = admit()


val lemmaFindLExistIfSomeOp: #a: Type -> f: (a -> bool) -> s: seq a -> 
  Lemma
    (requires (exists (k: nat). k < Seq.length s /\ f (index s k)))
    (ensures (Some? (find_l f s)))
    (decreases (Seq.length s))


let rec lemmaFindLExistIfSomeOp #a f s  = 
  if Seq.length s = 0 then ()
  else
    if f (head s) then ()
    else
      begin
	lemmaIfExistAndNotFirst f s;
	lemmaFindLExistIfSomeOp #a f (tail s)
    end


val lemma_index_0_elem: #a: Type0 -> p: a -> Lemma (index (seq_of_list [p]) 0 == p)

let lemma_index_0_elem #a p = FStar.Seq.Properties.lemma_seq_of_list_induction [p]


val containsFindL: #a: Type -> f: (a -> Tot bool) -> s: seq a -> 
  Lemma
    (requires (contains f s))
    (ensures Some? (find_l f s))
    [SMTPat (contains f s)]

let containsFindL #a f s = 
  lemmaFindLExistIfSomeOp #a f s

val containsFindL1: #a: Type -> f: (a -> Tot bool) -> s: seq a -> 
  Lemma
    (requires (Some? (find_l f s)))
    (ensures (contains f s))
    [SMTPat (find_l f s)]

let containsFindL1 #a f s = 
  lemmaFindLExistIfSome f s 


val lemmaContainsSelf: #a: eqtype -> s: seq a -> Lemma
  (
    forall (i: nat). i < Seq.length s /\ contains (fun x -> x = (index s i)) s
  )

let lemmaContainsSelf #a s = admit()