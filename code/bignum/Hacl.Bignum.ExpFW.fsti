module Hacl.Bignum.ExpFW

open FStar.HyperStack
open FStar.HyperStack.ST
open FStar.Mul

open Lib.IntTypes
open Lib.Buffer

open Hacl.Bignum.Definitions

module S = Hacl.Spec.Bignum.ExpFW
module BN = Hacl.Bignum
module BM = Hacl.Bignum.Montgomery
module EBM = Hacl.Bignum.ExpBM

#reset-options "--z3rlimit 50 --fuel 0 --ifuel 0"

inline_for_extraction noextract
let bn_mod_exp_fw_precompr2_st (t:limb_t) (len:BN.meta_len t) =
    n:lbignum t len
  -> a:lbignum t len
  -> bBits:size_t{v bBits > 0}
  -> b:lbignum t (blocks bBits (size (bits t)))
  -> l:size_t{0 < v l /\ v l < bits U32 /\ pow2 (v l) * v len <= max_size_t}
  -> r2:lbignum t len
  -> res:lbignum t len ->
  Stack unit
  (requires fun h ->
    live h n /\ live h a /\ live h b /\ live h res /\ live h r2 /\
    disjoint res a /\ disjoint res b /\ disjoint res n /\ disjoint n a /\
    disjoint res r2 /\ disjoint a r2 /\ disjoint n r2)
  (ensures  fun h0 _ h1 -> modifies (loc res) h0 h1 /\
    as_seq h1 res ==
    S.bn_mod_exp_fw_precompr2 (v len) (as_seq h0 n) (as_seq h0 a) (v bBits) (as_seq h0 b) (v l) (as_seq h0 r2))


// This function is *NOT* constant-time on the exponent b.
inline_for_extraction noextract
val bn_mod_exp_fw_raw_precompr2: #t:limb_t -> k:BM.mont t -> bn_mod_exp_fw_precompr2_st t k.BM.bn.BN.len


// This function is constant-time on the exponent b.
inline_for_extraction noextract
val bn_mod_exp_fw_ct_precompr2: #t:limb_t -> k:BM.mont t -> bn_mod_exp_fw_precompr2_st t k.BM.bn.BN.len
