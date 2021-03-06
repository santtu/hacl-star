module Hacl.Bignum.Exponentiation

open FStar.HyperStack
open FStar.HyperStack.ST
open FStar.Mul

open Lib.IntTypes
open Lib.Buffer

open Hacl.Bignum.Definitions

module S = Hacl.Spec.Bignum.Exponentiation
module BN = Hacl.Bignum
module BM = Hacl.Bignum.Montgomery

include Hacl.Bignum.ExpBM
include Hacl.Bignum.ExpFW

#reset-options "--z3rlimit 50 --fuel 0 --ifuel 0"

inline_for_extraction noextract
let bn_mod_exp_raw_st (t:limb_t) (len:BN.meta_len t) =
    nBits:size_t{v nBits / bits t < v len}
  -> n:lbignum t len
  -> a:lbignum t len
  -> bBits:size_t{0 < v bBits /\ bits t * v (blocks bBits (size (bits t))) <= max_size_t}
  -> b:lbignum t (blocks bBits (size (bits t)))
  -> res:lbignum t len ->
  Stack unit
  (requires fun h ->
    live h n /\ live h a /\ live h b /\ live h res /\
    disjoint res a /\ disjoint res b /\ disjoint res n /\ disjoint n a)
  (ensures  fun h0 _ h1 -> modifies (loc res) h0 h1 /\
    as_seq h1 res == S.bn_mod_exp_raw (v len) (v nBits) (as_seq h0 n) (as_seq h0 a) (v bBits) (as_seq h0 b))


// This function is *NOT* constant-time on the exponent b.
inline_for_extraction noextract
val bn_mod_exp_raw:
    #t:limb_t
  -> k:BM.mont t
  -> bn_mod_exp_raw_precompr2:bn_mod_exp_raw_precompr2_st t k.BM.bn.BN.len ->
  bn_mod_exp_raw_st t k.BM.bn.BN.len


inline_for_extraction noextract
let bn_mod_exp_ct_st (t:limb_t) (len:BN.meta_len t) =
    nBits:size_t{v nBits / bits t < v len}
  -> n:lbignum t len
  -> a:lbignum t len
  -> bBits:size_t{0 < v bBits /\ bits t * v (blocks bBits (size (bits t))) <= max_size_t}
  -> b:lbignum t (blocks bBits (size (bits t)))
  -> res:lbignum t len ->
  Stack unit
  (requires fun h ->
    live h n /\ live h a /\ live h b /\ live h res /\
    disjoint res a /\ disjoint res b /\ disjoint res n /\ disjoint n a)
  (ensures  fun h0 _ h1 -> modifies (loc res) h0 h1 /\
    as_seq h1 res == S.bn_mod_exp_ct (v len) (v nBits) (as_seq h0 n) (as_seq h0 a) (v bBits) (as_seq h0 b))


// This function is constant-time on the exponent b.
inline_for_extraction noextract
val bn_mod_exp_ct:
    #t:limb_t
  -> k:BM.mont t
  -> bn_mod_exp_ct_precompr2:bn_mod_exp_ct_precompr2_st t k.BM.bn.BN.len ->
  bn_mod_exp_ct_st t k.BM.bn.BN.len


inline_for_extraction noextract
let bn_mod_exp_fw_st (t:limb_t) (len:BN.meta_len t) =
    nBits:size_t{v nBits / bits t < v len}
  -> n:lbignum t len
  -> a:lbignum t len
  -> bBits:size_t{0 < v bBits /\ bits t * v (blocks bBits (size (bits t))) <= max_size_t}
  -> b:lbignum t (blocks bBits (size (bits t)))
  -> l:size_t{0 < v l /\ v l < bits U32 /\ pow2 (v l) * v len <= max_size_t}
  -> res:lbignum t len ->
  Stack unit
  (requires fun h ->
    live h n /\ live h a /\ live h b /\ live h res /\
    disjoint res a /\ disjoint res b /\ disjoint res n /\ disjoint n a)
  (ensures  fun h0 _ h1 -> modifies (loc res) h0 h1 /\
    as_seq h1 res == S.bn_mod_exp_fw (v len) (v nBits) (as_seq h0 n) (as_seq h0 a) (v bBits) (as_seq h0 b) (v l))


// This function is *NOT* constant-time on the exponent b.
inline_for_extraction noextract
val bn_mod_exp_fw_raw:
    #t:limb_t
  -> k:BM.mont t
  -> bn_mod_exp_fw_raw_precompr2:bn_mod_exp_fw_precompr2_st t k.BM.bn.BN.len ->
  bn_mod_exp_fw_st t k.BM.bn.BN.len


// This function is constant-time on the exponent b.
inline_for_extraction noextract
val bn_mod_exp_fw_ct:
    #t:limb_t
  -> k:BM.mont t
  -> bn_mod_exp_fw_ct_precompr2:bn_mod_exp_fw_precompr2_st t k.BM.bn.BN.len ->
  bn_mod_exp_fw_st t k.BM.bn.BN.len


inline_for_extraction noextract
class exp (t:limb_t) = {
  mont: BM.mont t;
  exp_check: bn_check_mod_exp_st t mont.BM.bn.BN.len;
  raw_mod_exp_precomp: bn_mod_exp_raw_precompr2_st t mont.BM.bn.BN.len;
  ct_mod_exp_precomp: bn_mod_exp_ct_precompr2_st t mont.BM.bn.BN.len;
  raw_mod_exp_fw_precomp: bn_mod_exp_fw_precompr2_st t mont.BM.bn.BN.len;
  ct_mod_exp_fw_precomp: bn_mod_exp_fw_precompr2_st t mont.BM.bn.BN.len;
}

// A completely run-time-only instance where the functions above exist in the C code.
inline_for_extraction noextract
val mk_runtime_exp: #t:limb_t -> len:BN.meta_len t -> exp t

val mk_runtime_exp_len_lemma: #t:limb_t -> len:BN.meta_len t ->
  Lemma ((mk_runtime_exp #t len).mont.BM.bn.BN.len == len) [SMTPat (mk_runtime_exp #t len)]
