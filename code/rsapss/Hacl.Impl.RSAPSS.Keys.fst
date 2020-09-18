module Hacl.Impl.RSAPSS.Keys

open FStar.HyperStack
open FStar.HyperStack.ST
open FStar.Mul

open Lib.IntTypes
open Lib.Buffer

open Hacl.Bignum.Definitions
open Hacl.Bignum

module ST = FStar.HyperStack.ST
module B = LowStar.Buffer
module HS = FStar.HyperStack
module LSeq = Lib.Sequence

module LS = Hacl.Spec.RSAPSS
module BM = Hacl.Bignum.Montgomery
module BN = Hacl.Bignum
module BB = Hacl.Spec.Bignum.Base

#reset-options "--z3rlimit 50 --fuel 0 --ifuel 0"


val bn_check_num_bits:
    bits:size_t{0 < v bits /\ 64 * v (blocks bits 64ul) <= max_size_t}
  -> b:lbignum (blocks bits 64ul) ->
  Stack uint64
  (requires fun h -> live h b)
  (ensures  fun h0 r h1 -> modifies0 h0 h1 /\
    r == LS.bn_check_num_bits (v bits) (as_seq h0 b))

[@CInline]
let bn_check_num_bits bits b =
  let bLen = blocks bits 64ul in
  if bits =. 64ul *! bLen then ones U64 SEC else bn_lt_pow2_mask bLen b bits


val rsapss_check_modulus:
    modBits:size_t{0 < v modBits /\ 64 * v (blocks modBits 64ul) <= max_size_t}
  -> n:lbignum (blocks modBits 64ul) ->
  Stack uint64
  (requires fun h -> live h n)
  (ensures  fun h0 r h1 -> modifies0 h0 h1 /\
    r == LS.rsapss_check_modulus (v modBits) (as_seq h0 n))

[@CInline]
let rsapss_check_modulus modBits n =
  let nLen = blocks modBits 64ul in
  let bits0 = bn_is_odd nLen n in
  let m0 = u64 0 -. bits0 in
  let m1 = bn_gt_pow2_mask nLen n (modBits -! 1ul) in
  let m2 = bn_check_num_bits modBits n in
  m0 &. (m1 &. m2)


val rsapss_check_exponent:
    eBits:size_t{0 < v eBits /\ 64 * v (blocks eBits 64ul) <= max_size_t}
  -> e:lbignum (blocks eBits 64ul) ->
  Stack uint64
  (requires fun h -> live h e)
  (ensures  fun h0 r h1 -> modifies0 h0 h1 /\
    r == LS.rsapss_check_exponent (v eBits) (as_seq h0 e))

[@CInline]
let rsapss_check_exponent eBits e =
  let eLen = blocks eBits 64ul in
  let m0 = bn_is_zero_mask eLen e in
  let m1 = bn_check_num_bits eBits e in
  (lognot m0) &. m1


//pkey = [n; r2; e]
inline_for_extraction noextract
let rsapss_load_pkey_st =
    modBits:size_t
  -> eBits:size_t{LS.pkey_len_pre (v modBits) (v eBits)}
  -> nb:lbuffer uint8 (blocks modBits 8ul)
  -> eb:lbuffer uint8 (blocks eBits 8ul)
  -> pkey:lbignum (2ul *! blocks modBits 64ul +! blocks eBits 64ul) ->
  Stack bool
  (requires fun h ->
    live h nb /\ live h eb /\ live h pkey /\
    disjoint pkey nb /\ disjoint pkey eb)
  (ensures  fun h0 b h1 -> modifies (loc pkey) h0 h1 /\
   (b, as_seq h1 pkey) == LS.rsapss_load_pkey (v modBits) (v eBits) (as_seq h0 nb) (as_seq h0 eb))


val rsapss_load_pkey: rsapss_load_pkey_st
[@CInline]
let rsapss_load_pkey modBits eBits nb eb pkey =
  let h0 = ST.get () in
  let nbLen = blocks modBits 8ul in
  let ebLen = blocks eBits 8ul in

  let nLen = blocks modBits 64ul in
  let eLen = blocks eBits 64ul in

  LS.blocks_bits_lemma (v modBits);
  LS.blocks_bits_lemma1 (v modBits);
  assert (0 < v nbLen /\ 8 * v nbLen <= max_size_t);
  assert (v (blocks nbLen 8ul) == v nLen);

  LS.blocks_bits_lemma (v eBits);
  LS.blocks_bits_lemma1 (v eBits);
  assert (0 < v ebLen /\ 8 * v ebLen <= max_size_t);
  assert (v (blocks ebLen 8ul) == v eLen);

  let n  = sub pkey 0ul nLen in
  let r2 = sub pkey nLen nLen in
  let e  = sub pkey (nLen +! nLen) eLen in

  bn_from_bytes_be nbLen nb n;
  BM.precomp_r2_mod_n #nLen #(BN.mk_runtime_bn nLen) n r2;
  bn_from_bytes_be ebLen eb e;
  let h1 = ST.get () in
  LSeq.lemma_concat3 (v nLen) (as_seq h1 n)
    (v nLen) (as_seq h1 r2) (v eLen) (as_seq h1 e) (as_seq h1 pkey);

  let m0 = rsapss_check_modulus modBits n in
  let m1 = rsapss_check_exponent eBits e in
  let m = m0 &. m1 in
  BB.unsafe_bool_of_u64 m


#set-options "--z3rlimit 300"

//skey = [pkey; d]
inline_for_extraction noextract
let rsapss_load_skey_st =
    modBits:size_t
  -> eBits:size_t
  -> dBits:size_t{LS.skey_len_pre (v modBits) (v eBits) (v dBits)}
  -> nb:lbuffer uint8 (blocks modBits 8ul)
  -> eb:lbuffer uint8 (blocks eBits 8ul)
  -> db:lbuffer uint8 (blocks dBits 8ul)
  -> skey:lbignum (2ul *! blocks modBits 64ul +! blocks eBits 64ul +! blocks dBits 64ul) ->
  Stack bool
  (requires fun h ->
    live h nb /\ live h eb /\ live h db /\ live h skey /\
    disjoint skey nb /\ disjoint skey eb /\ disjoint skey db)
  (ensures  fun h0 b h1 -> modifies (loc skey) h0 h1 /\
    (b, as_seq h1 skey) == LS.rsapss_load_skey (v modBits) (v eBits) (v dBits)
      (as_seq h0 nb) (as_seq h0 eb) (as_seq h0 db))


val rsapss_load_skey: rsapss_load_skey_st
[@CInline]
let rsapss_load_skey modBits eBits dBits nb eb db skey =
  let h0 = ST.get () in
  let nbLen = blocks modBits 8ul in
  let ebLen = blocks eBits 8ul in
  let dbLen = blocks dBits 8ul in

  let nLen = blocks modBits 64ul in
  let eLen = blocks eBits 64ul in
  let dLen = blocks dBits 64ul in

  let pkeyLen = nLen +! nLen +! eLen in
  let skeyLen = pkeyLen +! eLen in

  LS.blocks_bits_lemma (v dBits);
  LS.blocks_bits_lemma1 (v dBits);
  assert (0 < v dbLen /\ 8 * v dbLen <= max_size_t);
  assert (v (blocks dbLen 8ul) == v dLen);

  let pkey = sub skey 0ul pkeyLen in
  let d = sub skey pkeyLen dLen in

  let b = rsapss_load_pkey modBits eBits nb eb pkey in
  bn_from_bytes_be dbLen db d;
  let h1 = ST.get () in
  LSeq.lemma_concat2 (v pkeyLen) (as_seq h1 pkey) (v dLen) (as_seq h1 d) (as_seq h1 skey);

  let m1 = rsapss_check_exponent dBits d in
  let b1 = b && BB.unsafe_bool_of_u64 m1 in
  b1



inline_for_extraction noextract
let new_rsapss_load_pkey_st =
    r:HS.rid
  -> modBits:size_t{0 < v modBits}
  -> eBits:size_t{0 < v eBits}
  -> nb:lbuffer uint8 (blocks modBits 8ul)
  -> eb:lbuffer uint8 (blocks eBits 8ul) ->
  ST (B.buffer uint64)
  (requires fun h -> live h nb /\ live h eb /\
    ST.is_eternal_region r)
  (ensures  fun h0 pkey h1 -> B.(modifies loc_none h0 h1) /\
    not (B.g_is_null pkey) ==> (
      LS.pkey_len_pre (v modBits) (v eBits) /\
      B.(fresh_loc (loc_buffer pkey) h0 h1) /\
      B.(loc_includes (loc_region_only false r) (loc_buffer pkey)) /\
     (let nLen = blocks modBits 64ul in
      let eLen = blocks eBits 64ul in
      let pkeyLen = nLen +! nLen +! eLen in
      B.len pkey == pkeyLen /\
     (let pkey = pkey <: lbignum pkeyLen in

      LS.rsapss_load_pkey_post (v modBits) (v eBits)
	(as_seq h0 nb) (as_seq h0 eb) (as_seq h1 pkey)))))


inline_for_extraction noextract
val new_rsapss_load_pkey: new_rsapss_load_pkey_st
let new_rsapss_load_pkey r modBits eBits nb eb =
  let nLen = blocks modBits 64ul in
  let eLen = blocks eBits 64ul in
  let pkeyLen = nLen +! nLen +! eLen in

  if not (1ul <. modBits && 0ul <. eBits &&
    nLen <=. 0xfffffffful /. 128ul && eLen <=. 0xfffffffful /. 64ul &&
    nLen +! nLen <=. 0xfffffffful -. eLen) then
   B.null
  else
    let h0 = ST.get () in
    let pkey = LowStar.Monotonic.Buffer.mmalloc_partial r (u64 0) pkeyLen in
    if B.is_null pkey then
      pkey
    else
      let h1 = ST.get () in
      B.(modifies_only_not_unused_in loc_none h0 h1);
      assert (B.len pkey == pkeyLen);
      let pkey: Lib.Buffer.buffer Lib.IntTypes.uint64 = pkey in
      assert (B.length pkey == FStar.UInt32.v pkeyLen);
      let pkey: lbignum pkeyLen = pkey in
      let b = rsapss_load_pkey modBits eBits nb eb pkey in
      let h2 = ST.get () in
      B.(modifies_only_not_unused_in loc_none h0 h2);
      LS.rsapss_load_pkey_lemma (v modBits) (v eBits) (as_seq h0 nb) (as_seq h0 eb);
      if b then pkey else B.null


inline_for_extraction noextract
let new_rsapss_load_skey_st =
    r:HS.rid
  -> modBits:size_t{0 < v modBits}
  -> eBits:size_t{0 < v eBits}
  -> dBits:size_t{0 < v dBits}
  -> nb:lbuffer uint8 (blocks modBits 8ul)
  -> eb:lbuffer uint8 (blocks eBits 8ul)
  -> db:lbuffer uint8 (blocks dBits 8ul) ->
  ST (B.buffer uint64)
  (requires fun h -> live h nb /\ live h eb /\ live h db /\
    ST.is_eternal_region r)
  (ensures  fun h0 skey h1 -> B.(modifies loc_none h0 h1) /\
    not (B.g_is_null skey) ==> (
      LS.skey_len_pre (v modBits) (v eBits) (v dBits) /\
      B.(fresh_loc (loc_buffer skey) h0 h1) /\
      B.(loc_includes (loc_region_only false r) (loc_buffer skey)) /\
     (let nLen = blocks modBits 64ul in
      let eLen = blocks eBits 64ul in
      let dLen = blocks dBits 64ul in
      let skeyLen = nLen +! nLen +! eLen +! dLen in

      B.len skey == skeyLen /\
     (let skey = skey <: lbignum skeyLen in
      LS.rsapss_load_skey_post (v modBits) (v eBits) (v dBits)
	(as_seq h0 nb) (as_seq h0 eb) (as_seq h0 db) (as_seq h1 skey)))))


inline_for_extraction noextract
val new_rsapss_load_skey: new_rsapss_load_skey_st
let new_rsapss_load_skey r modBits eBits dBits nb eb db =
  let nLen = blocks modBits 64ul in
  let eLen = blocks eBits 64ul in
  let dLen = blocks dBits 64ul in
  let skeyLen = nLen +! nLen +! eLen +! dLen in

  if not (1ul <. modBits && 0ul <. eBits && 0ul <. dBits &&
    nLen <=. 0xfffffffful /. 128ul && eLen <=. 0xfffffffful /. 64ul && dLen <=. 0xfffffffful /. 64ul &&
    nLen +! nLen <=. 0xfffffffful -. eLen -. dLen) then
   B.null
  else
    let h0 = ST.get () in
    let skey = LowStar.Monotonic.Buffer.mmalloc_partial r (u64 0) skeyLen in
    if B.is_null skey then
      skey
    else
      let h1 = ST.get () in
      B.(modifies_only_not_unused_in loc_none h0 h1);
      assert (B.len skey == skeyLen);
      let skey: Lib.Buffer.buffer Lib.IntTypes.uint64 = skey in
      assert (B.length skey == FStar.UInt32.v skeyLen);
      let skey: lbignum skeyLen = skey in
      let b = rsapss_load_skey modBits eBits dBits nb eb db skey in
      let h2 = ST.get () in
      B.(modifies_only_not_unused_in loc_none h0 h2);
      LS.rsapss_load_skey_lemma (v modBits) (v eBits) (v dBits)
	(as_seq h0 nb) (as_seq h0 eb) (as_seq h0 db);
      if b then skey else B.null