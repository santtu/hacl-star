module FastHybrid_helpers

open Words_s
open Types_s
open FStar.Mul
open FStar.Tactics
open CanonCommSemiring
open Fast_defs

let int_canon = fun _ -> canon_semiring int_cr //; dump "Final"

unfold let prime:nat = 57896044618658097711785492504343953926634992332820282019728792003956564819949 //(pow2 255) - 19
unfold let pow2_63:nat = 0x8000000000000000 

let _ = assert_norm (pow2_63 == pow2 63)

let lemma_mul_pow256_add (x y:nat) : 
  Lemma ((x + y * pow2_256) % prime == (x + y * 38) % prime)
  =
  assert_norm (pow2_256 % prime == 38);
  ()

#reset-options "--z3rlimit 100"
let lemma_carry_prime (a0 a1 a2 a3 a0' a1' a2' a3' carry_in:nat64) (carry:bit) : Lemma
  (requires pow2_five a0' a1' a2' a3' carry == pow2_four a0 a1 a2 a3 + carry_in * 38 /\
            carry_in * 38 - 1 + 38 < pow2_64)
  (ensures a0' + carry * 38 < pow2_64 /\
           pow2_four (a0' + carry * 38) a1' a2' a3' == (pow2_four a0 a1 a2 a3 + carry_in * pow2_256) % prime)
  =
  (*
  if a0 + carry_in * 38 < pow2_64 then (
    assert (carry == 0);
    assert (a0' == a0 + carry_in * 38)
  ) else (
    ()//admit()
  );*)
  assert (a0' + carry * 38 < pow2_64);
  


  // calc {
  //   (pow2_four a0 a1 a2 a3 + carry_in * pow2_256) % prime
       lemma_mul_pow256_add (pow2_four a0 a1 a2 a3) carry_in;
  //   (pow2_four a0 a1 a2 a3 + carry_in * 38) % prime
  assert ((pow2_four a0 a1 a2 a3 + carry_in * 38) % prime == (pow2_five a0' a1' a2' a3' carry) % prime);
  //   (pow2_five a0' a1' a2' a3' carry) % prime
       assert_by_tactic (pow2_five a0' a1' a2' a3' carry == pow2_four a0' a1' a2' a3' + (carry * pow2_256)) int_canon;
  //   (pow2_four a0' a1' a2' a3' + (carry * pow2_256)) % prime
       lemma_mul_pow256_add (pow2_four a0' a1' a2' a3') carry;
  //   (pow2_four a0' a1' a2' a3' + (carry * 38)) % prime
  //     calc {
  //       pow2_four (a0' + carry * 38) a1' a2' a3'
           assert_by_tactic (pow2_four (a0' + carry * 38) a1' a2' a3' == (pow2_four a0' a1' a2' a3') + (carry * 38)) int_canon;
  //      (pow2_four a0' a1' a2' a3') + (carry * 38)
       // }  
  //   pow2_four (a0' + carry * 38) a1' a2' a3'
  // }
  admit();
  ()

(*
open X64.Vale.Decls
open X64.Machine_s
let get_reg (to:tainted_operand{TReg? to}) : reg = TReg?.r to
*)
(*


#reset-options "--z3rlimit 300 --max_fuel 0 --max_ifuel 0"
let test (a:nat) 
         (a0 a1 a2 a3:nat64)
         (a0' a1' a2' a3':nat64)
         (c:nat64) (b:bit) : Lemma
  (requires a == pow2_four a0 a1 a2 a3 /\ 
            pow2_five a0' a1' a2' a3' b == a + c * 38 /\
            True)
  (ensures (pow2_four (a0' + b * 38) a1' a2' a3') % p = (a + c) % p)
  =
  assert_norm (pow2_256 % p == 38);
  //admit();
  ()
*)
