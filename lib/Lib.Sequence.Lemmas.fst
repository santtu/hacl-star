module Lib.Sequence.Lemmas

open FStar.Mul
open Lib.IntTypes
open Lib.Sequence

// This is unnecessary because the same pragma is interleaved from the interface
#set-options "--z3rlimit 100 --max_fuel 0 --max_ifuel 0 \
             --using_facts_from '-* +Prims +Lib.Sequence.Lemmas +Lib.Sequence +FStar.Seq +FStar.Seq.Properties'"

let lemma_i_div_bs w bs i =
  let bs_v = w * bs in
  calc (==) {
    w * (i / bs_v) + i % (w * bs) / bs;
  (==) { Math.Lemmas.swap_mul w bs }
    w * (i / bs_v) + i % (bs * w) / bs;
  (==) { Math.Lemmas.modulo_division_lemma i bs w }
    w * (i / bs_v) + i / bs % w;
  (==) { Math.Lemmas.division_multiplication_lemma i bs w }
    w * ((i / bs) / w) + i / bs % w;
  (==) { Math.Lemmas.euclidean_division_definition (i / bs) w }
    i / bs;
  }

let lemma_mod_bs_v_bs a w bs =
  Math.Lemmas.modulo_modulo_lemma a bs w;
  Math.Lemmas.swap_mul w bs

let lemma_div_bs_v_le a w bs = lemma_i_div_bs w bs a

let lemma_i_div_bs_lt w bs len i =
  let bs_v = w * bs in
  lemma_i_div_bs w bs i;
  div_interval bs_v (len / bs_v) i;
  //assert (i / bs == w * (len / (w * bs)) + i % (w * bs) / bs)
  lemma_i_div_bs w bs len

let lemma_i_mod_bs_lt w bs len i =
  mod_div_lt bs (i % (w * bs)) (len % (w * bs));
  lemma_mod_bs_v_bs i w bs;
  lemma_mod_bs_v_bs len w bs

val lemma_len_div_bs: bs:pos -> len:nat -> i:nat{len / bs * bs <= i /\ i < len} ->
  Lemma (len / bs == i / bs)
let lemma_len_div_bs bs len i =
  div_interval bs (len / bs) i

val lemma_i_div_bs_mul_bs:
  bs:pos -> w:pos -> bs_v:pos{bs_v == w * bs} -> i:nat ->
  Lemma (i / bs * bs == bs_v * (i / bs_v) + i % bs_v / bs * bs)
let lemma_i_div_bs_mul_bs bs w bs_v i =
  lemma_i_div_bs w bs i;
  Math.Lemmas.distributivity_add_left (w * (i / bs_v)) (i % bs_v / bs) bs;
  assert (i / bs * bs == w * (i / bs_v) * bs + i % bs_v / bs * bs);
  Math.Lemmas.swap_mul w (i / bs_v);
  Math.Lemmas.paren_mul_left (i / bs_v) w bs;
  assert (i / bs * bs == bs_v * (i / bs_v) + i % bs_v / bs * bs)

val lemma_i_mod_bs_v:
  len:nat -> bs:pos -> w:pos -> bs_v:pos{bs_v == w * bs} -> i:nat{(len / bs_v) * bs_v <= i /\ i < len} ->
  Lemma (i % bs_v == i - len / bs * bs + len % bs_v / bs * bs)
let lemma_i_mod_bs_v len bs w bs_v i =
  lemma_i_div_bs_mul_bs bs w bs_v len;
  lemma_len_div_bs bs_v len i

val lemma_i_div_bs_g:
  w:pos -> bs:pos -> bs_v:pos{bs_v == w * bs} -> len:nat -> i:nat -> Lemma
  (requires
    (len % bs_v) / bs * bs <= i % bs_v /\
     i % bs_v < len % bs_v /\
     len / bs_v * bs_v <= i /\ i < len)
  (ensures i / bs == len / bs)
let lemma_i_div_bs_g w bs bs_v len i =
  calc (<=) {
    len / bs * bs;
    (==) { lemma_i_div_bs_mul_bs bs w bs_v len }
    bs_v * (len / bs_v) + len % bs_v / bs * bs;
    (==) { div_interval bs_v (len / bs_v) i }
    i / bs_v * bs_v + len % bs_v / bs * bs;
    (<=) { }
    i / bs_v * bs_v + i % bs_v;
    (==) { Math.Lemmas.euclidean_division_definition i bs_v }
    i;
  };
  assert (len / bs * bs <= i);
  div_interval bs (len / bs) i;
  assert (i / bs == len / bs)

val lemma_i_div_bs_mul_bs_lt: bs:pos -> len:nat -> i:nat{i < len / bs * bs} ->
  Lemma (i / bs * bs + bs <= len)
let lemma_i_div_bs_mul_bs_lt bs len i =
  calc (<=) {
    i / bs * bs + bs;
    (==) { Math.Lemmas.distributivity_add_left (i / bs) 1 bs }
    (i / bs + 1) * bs;
    (<=) { div_mul_lt bs i (len / bs);
         Math.Lemmas.lemma_mult_le_right bs (i / bs + 1) (len / bs) }
    len / bs * bs;
    (<=) { Math.Lemmas.multiply_fractions len bs }
    len;
  }


val lemma_slice_slice_f_vec_f:
    #a:Type
  -> #len:nat
  -> w:size_pos
  -> bs:size_pos{w * bs <= max_size_t}
  -> inp:seq a{length inp == len}
  -> i:nat{i < len / (w * bs) * (w * bs) /\ i < len / bs * bs} ->
  Lemma
  (let bs_v = w * bs in
   let b_v = get_block_s #a #len bs_v inp i in
   let b = get_block_s #a #len bs inp i in
   Math.Lemmas.cancel_mul_div w bs;
   //assert (i % bs_v < bs_v / bs * bs);
   let b1 = get_block_s #a #bs_v bs b_v (i % bs_v) in
   b1 == b)

let lemma_slice_slice_f_vec_f #a #len w bs inp i =
  let bs_v = w * bs in
  let j_v = i / bs_v in
  let j = i % bs_v / bs in

  let pre1 () : Lemma ((j_v + 1) * bs_v <= len) =
    lemma_i_div_bs_mul_bs_lt bs_v len i in

  let pre2 () : Lemma ((j + 1) * bs <= bs_v) =
    Math.Lemmas.swap_mul w bs;
    Math.Lemmas.modulo_division_lemma i bs w;
    assert (j < w);
    Math.Lemmas.lemma_mult_le_right bs (j + 1) w in

  let post1 () : Lemma (j_v * bs_v + (j + 1) * bs == (i / bs + 1) * bs) =
    Math.Lemmas.distributivity_add_left j 1 bs;
    lemma_i_div_bs_mul_bs bs w bs_v i;
    Math.Lemmas.distributivity_add_left (i / bs) 1 bs in

  pre1 ();
  pre2 ();
  Seq.slice_slice inp (j_v * bs_v) ((j_v + 1) * bs_v) (j * bs) ((j + 1) * bs);
  lemma_i_div_bs_mul_bs bs w bs_v i;
  post1 ()


#reset-options "--z3rlimit 150 --max_fuel 0 --max_ifuel 0"

val lemma_slice_slice_g_vec_f:
    #a:Type
 -> #len:nat
  -> w:size_pos
  -> bs:size_pos{w * bs <= max_size_t}
  -> inp:seq a{length inp == len}
  -> i:nat{len / (w * bs) * (w * bs) <= i /\ i < len / bs * bs /\
        i % (w * bs) < (len % (w * bs)) / bs * bs} ->
  Lemma
  (let bs_v = w * bs in
   let rem = len % bs_v in
   let b: lseq a bs = get_block_s #a #len bs inp i in
   let b_v: lseq a rem = get_last_s #a #len bs_v inp in
   let b1: lseq a bs = get_block_s #a #rem bs b_v (i % bs_v) in
   b1 == b)

let lemma_slice_slice_g_vec_f #a #len w bs inp i =
  let bs_v = w * bs in
  let rem = len % bs_v in
  let j = i % bs_v / bs in

  let post1 () : Lemma (len - rem + j * bs == i / bs * bs) =
    calc (==) {
      i / bs * bs;
      (==) { lemma_i_div_bs_mul_bs bs w bs_v i }
      i / bs_v * bs_v + j * bs;
      (==) { lemma_len_div_bs bs_v len i }
      len / bs_v * bs_v + j * bs;
      (==) { Math.Lemmas.euclidean_division_definition len bs_v }
      len - rem + j * bs;
    } in

  let post2 () : Lemma (len - rem + (j + 1) * bs == (i / bs + 1) * bs) =
    Math.Lemmas.distributivity_add_left j 1 bs;
    post1 ();
    Math.Lemmas.distributivity_add_left (i / bs) 1 bs;
    () in

  let pre1 () : Lemma ((j + 1) * bs <= rem) =
    calc (<=) {
      (j + 1) * bs;
      (==) { Math.Lemmas.distributivity_add_left j 1 bs }
      j * bs + bs;
      (==) { post1 () }
      i / bs * bs - len + rem + bs;
      (==) { Math.Lemmas.distributivity_add_left (i / bs) 1 bs }
      (i / bs + 1) * bs - len + rem;
      (<=) { div_mul_lt bs i (len / bs); Math.Lemmas.lemma_mult_le_right bs (i / bs + 1) (len / bs) }
      len / bs * bs - len + rem;
      (==) { }
      rem - (len - len / bs * bs);
      (<=) { Math.Lemmas.multiply_fractions len bs }
      rem;
    } in

  let pre2 () : Lemma (0 <= len - rem) =
    Math.Lemmas.euclidean_division_definition len bs_v;
    assert (len - rem == len / bs_v * bs_v);
    Math.Lemmas.nat_times_nat_is_nat (len / bs_v) bs_v;
    () in

  pre1 ();
  //assert ((j + 1) * bs <= rem);
  pre2 ();
  //assert (0 <= len - rem);
  Seq.slice_slice inp (len - rem) len (j * bs) (j * bs + bs);
  post1 ();
  post2 ()


val lemma_slice_slice_g_vec_g:
    #a:Type
  -> #len:nat
  -> w:size_pos
  -> bs:size_pos{w * bs <= max_size_t}
  -> inp:seq a{length inp == len} ->
  Lemma
  (let bs_v = w * bs in
   let rem = len % bs_v in
   let b_v = get_last_s #a #len bs_v inp in
   let b = get_last_s #a #len bs inp in
   let b1 = get_last_s #a #rem bs b_v in
   b1 == b)

let lemma_slice_slice_g_vec_g #a #len w bs inp =
  let bs_v = w * bs in
  let rem = len % bs_v in
  Seq.slice_slice inp (len - rem) len (rem - rem % bs) rem;
  lemma_mod_bs_v_bs len w bs;
  assert (len % bs == rem % bs)


val lemma_map_blocks_multi_vec_i_aux:
    #a:Type
  -> #len:nat
  -> w:size_pos
  -> blocksize:size_pos
  -> blocksize_v:size_pos{blocksize_v = w * blocksize}
  -> inp:seq a{length inp == len}
  -> f:(block len blocksize -> lseq a blocksize -> lseq a blocksize)
  -> f_v:(block len blocksize_v -> lseq a blocksize_v -> lseq a blocksize_v)
  -> pre:squash (forall (i:nat{i < len / blocksize_v * blocksize_v}) (b_v:lseq a blocksize_v).
         map_blocks_vec_equiv_pre_f_v #a #len w blocksize blocksize_v f f_v i b_v)
  -> i:nat{i < len / blocksize_v * blocksize_v} ->
  Lemma
   (lemma_div_bs_v_le len w blocksize;
   (get_block #_ #len blocksize_v inp f_v i).[i % blocksize_v] ==
   (get_block #_ #len blocksize inp f i).[i % blocksize])

let lemma_map_blocks_multi_vec_i_aux #a #len w blocksize blocksize_v inp f f_v pre i =
  lemma_div_bs_v_le len w blocksize;
  assert (i < len / blocksize * blocksize);
  let b_v = get_block_s #a #len blocksize_v inp i in
  assert (map_blocks_vec_equiv_pre_f_v #a #len w blocksize blocksize_v f f_v i b_v);
  Math.Lemmas.multiple_division_lemma w blocksize;
  assert (i % blocksize_v < blocksize_v / blocksize * blocksize);
  let b = get_block_s #_ #blocksize_v blocksize b_v (i % blocksize_v) in
  assert ((f_v (i / blocksize_v) b_v).[i % blocksize_v] == (f (i / blocksize) b).[i % blocksize]);
  assert ((get_block #_ #len blocksize_v inp f_v i).[i % blocksize_v] == (f_v (i / blocksize_v) b_v).[i % blocksize_v]);
  lemma_slice_slice_f_vec_f #a #len w blocksize inp i;
  assert ((get_block #_ #len blocksize inp f i).[i % blocksize] == (f (i / blocksize) b).[i % blocksize]);
  ()


val lemma_map_blocks_multi_vec_i:
    #a:Type
  -> #len:nat
  -> w:size_pos
  -> blocksize:size_pos
  -> blocksize_v:size_pos{blocksize_v == w * blocksize}
  -> inp:seq a{length inp == len /\ len % blocksize_v = 0 /\ len % blocksize = 0}
  -> f:(block len blocksize -> lseq a blocksize -> lseq a blocksize)
  -> f_v:(block len blocksize_v -> lseq a blocksize_v -> lseq a blocksize_v)
  -> pre:squash (forall (i:nat{i < len}) (b_v:lseq a blocksize_v).
         map_blocks_vec_equiv_pre_f_v #a #len w blocksize blocksize_v f f_v i b_v)
  -> i:nat{i < len} ->
  Lemma
   (Math.Lemmas.div_exact_r len blocksize_v;
    let nb_v = len / blocksize_v in
    let nb = len / blocksize in

    let v = map_blocks_multi blocksize_v nb_v nb_v inp f_v in
    let s = map_blocks_multi blocksize nb nb inp f in
    Seq.index v i == Seq.index s i)

let lemma_map_blocks_multi_vec_i #a #len w blocksize blocksize_v inp f f_v pre i =
  let nb_v = len / blocksize_v in
  let nb = len / blocksize in
  index_map_blocks_multi blocksize nb nb inp f i;
  index_map_blocks_multi blocksize_v nb_v nb_v inp f_v i;
  let s = map_blocks_multi blocksize nb nb inp f in
  let vec = map_blocks_multi blocksize_v nb_v nb_v inp f_v in
  //assert (Seq.index s i == (get_block #_ #len blocksize inp f i).[i % blocksize]);
  //assert (Seq.index vec i == (get_block #_ #len blocksize_v inp f_v i).[i % blocksize_v]);
  lemma_map_blocks_multi_vec_i_aux #a #len w blocksize blocksize_v inp f f_v pre i


let lemma_map_blocks_multi_vec #a #len w blocksize inp f f_v =
  let blocksize_v = w * blocksize in
  Math.Lemmas.div_exact_r len blocksize_v;
  let nb_v = len / blocksize_v in
  let nb = len / blocksize in

  let v = map_blocks_multi blocksize_v nb_v nb_v inp f_v in
  let s = map_blocks_multi blocksize nb nb inp f in
  Classical.forall_intro (lemma_map_blocks_multi_vec_i #a #len w blocksize blocksize_v inp f f_v ());
  Seq.lemma_eq_intro v s


val lemma_map_blocks_vec_g_v_f_i:
    #a:Type
  -> #len:nat
  -> w:size_pos
  -> blocksize:size_pos
  -> blocksize_v:size_pos{blocksize_v == w * blocksize}
  -> inp:seq a{length inp == len}
  -> f:(block len blocksize -> lseq a blocksize -> lseq a blocksize)
  -> g:(last len blocksize -> rem:size_nat{rem < blocksize} -> lseq a rem -> lseq a rem)
  -> g_v:(last len blocksize_v -> rem:size_nat{rem < blocksize_v} -> lseq a rem -> lseq a rem)
  -> pre:squash ((forall (i:nat{len / blocksize_v * blocksize_v <= i /\ i < len}) (b_v:lseq a (len % blocksize_v)).
      map_blocks_vec_equiv_pre_g_v #a #len w blocksize blocksize_v f g g_v i b_v))
  -> i:nat{len / blocksize_v * blocksize_v <= i /\ i < len / blocksize * blocksize /\
	 i % blocksize_v < (len % blocksize_v) / blocksize * blocksize} ->
  Lemma
  ((get_last #_ #len blocksize_v inp g_v i).[i % blocksize_v] ==
   (get_block #_ #len blocksize inp f i).[i % blocksize])

let lemma_map_blocks_vec_g_v_f_i #a #len w blocksize blocksize_v inp f g g_v pre i =
  let b_v = get_last_s #_ #len blocksize_v inp in
  assert (map_blocks_vec_equiv_pre_g_v #a #len w blocksize blocksize_v f g g_v i b_v);
  lemma_slice_slice_g_vec_f #a #len w blocksize inp i


val lemma_map_blocks_vec_g_v_g_i:
    #a:Type
  -> #len:nat
  -> w:size_pos
  -> blocksize:size_pos
  -> blocksize_v:size_pos{blocksize_v = w * blocksize}
  -> inp:seq a{length inp == len}
  -> f:(block len blocksize -> lseq a blocksize -> lseq a blocksize)
  -> g:(last len blocksize -> rem:size_nat{rem < blocksize} -> lseq a rem -> lseq a rem)
  -> g_v:(last len blocksize_v -> rem:size_nat{rem < blocksize_v} -> lseq a rem -> lseq a rem)
  -> pre:squash (forall (i:nat{len / blocksize_v * blocksize_v <= i /\ i < len}) (b_v:lseq a (len % blocksize_v)).
      map_blocks_vec_equiv_pre_g_v #a #len w blocksize blocksize_v f g g_v i b_v)
  -> i:nat{len / blocksize * blocksize <= i /\ i < len /\
         (len % blocksize_v) / blocksize * blocksize <= i % blocksize_v} ->
  Lemma
  (div_interval blocksize (len / blocksize) i;
   div_mul_l i len w blocksize;
   mod_interval_lt blocksize_v (i / blocksize_v) i len;
   (get_last #_ #len blocksize_v inp g_v i).[i % blocksize_v] ==
   (get_last #_ #len blocksize inp g i).[i % blocksize])

let lemma_map_blocks_vec_g_v_g_i #a #len w blocksize blocksize_v inp f g g_v pre i =
  lemma_div_bs_v_le len w blocksize;
  assert (len / blocksize_v * blocksize_v <= i);
  let b_v = get_last_s #_ #len blocksize_v inp in
  assert (map_blocks_vec_equiv_pre_g_v #a #len w blocksize blocksize_v f g g_v i b_v);

  let rem_v = len % blocksize_v in
  let rem = len % blocksize in
  lemma_mod_bs_v_bs len w blocksize;
  assert (rem_v % blocksize = rem);

  let j = i % blocksize_v in
  let gv_b = g_v (len / blocksize_v) rem_v b_v in
  assert ((get_last #_ #len blocksize_v inp g_v i).[i % blocksize_v] == (gv_b).[j]);

  assert (rem_v / blocksize * blocksize <= j);
  let b : lseq a rem = get_last_s #a #rem_v blocksize b_v in
  let g_b : lseq a rem = g (len / blocksize) rem b in
  mod_div_lt blocksize_v i len;
  assert (i % blocksize_v < len % blocksize_v);
  lemma_i_mod_bs_lt w blocksize len i;
  assert ((gv_b).[j] == g_b.[i % blocksize]);
  lemma_slice_slice_g_vec_g #a #len w blocksize inp;
  assert ((get_last #_ #len blocksize inp g i).[i % blocksize] == g_b.[i % blocksize])


val lemma_map_blocks_vec_i:
    #a:Type
  -> #len:nat
  -> w:size_pos
  -> blocksize:size_pos
  -> blocksize_v:size_pos{blocksize_v == w * blocksize}
  -> inp:seq a{length inp == len}
  -> f:(block len blocksize -> lseq a blocksize -> lseq a blocksize)
  -> g:(last len blocksize -> rem:size_nat{rem < blocksize} -> lseq a rem -> lseq a rem)
  -> f_v:(block len blocksize_v -> lseq a blocksize_v -> lseq a blocksize_v)
  -> g_v:(last len blocksize_v -> rem:size_nat{rem < blocksize_v} -> lseq a rem -> lseq a rem)
  -> pre1:squash (forall (i:nat{i < len / blocksize_v * blocksize_v}) (b_v:lseq a blocksize_v).
      map_blocks_vec_equiv_pre_f_v #a #len w blocksize blocksize_v f f_v i b_v)
  -> pre2:squash (forall (i:nat{len / blocksize_v * blocksize_v <= i /\ i < len}) (b_v:lseq a (len % blocksize_v)).
      map_blocks_vec_equiv_pre_g_v #a #len w blocksize blocksize_v f g g_v i b_v)
  -> i:nat{i < len} ->
  Lemma
   (let v = map_blocks blocksize_v inp f_v g_v in
    let s = map_blocks blocksize inp f g in
    Seq.index v i == Seq.index s i)

let lemma_map_blocks_vec_i #a #len w bs bs_v inp f g f_v g_v pre1 pre2 i =
  let aux1 (i:nat{(len / bs_v) * bs_v <= i /\ i < (len / bs) * bs}) : Lemma (i % bs_v < (len % bs_v) / bs * bs) =
    Math.Lemmas.multiply_fractions len bs;
    assert (len / bs_v * bs_v <= i /\ i < len);
    lemma_i_mod_bs_v len bs w bs_v i;
    () in

  let aux2 (i:nat{(len / bs) * bs <= i /\ i < len}) : Lemma ((len % bs_v) / bs * bs <= i % bs_v) =
    lemma_div_bs_v_le len w bs;
    assert (len / bs_v * bs_v <= i /\ i < len);
    lemma_i_mod_bs_v len bs w bs_v i;
    () in

  index_map_blocks bs inp f g i;
  index_map_blocks bs_v inp f_v g_v i;
  let s = map_blocks bs inp f g in
  let v = map_blocks (w * bs) inp f_v g_v in
  if i < (len / bs) * bs then begin
    div_mul_lt bs i (len / bs);
    if i < (len / bs_v) * bs_v then
      lemma_map_blocks_multi_vec_i_aux #a #len w bs bs_v inp f f_v pre1 i
    else begin
      aux1 i;
      //assert (i % bs_v < (len % bs_v) / bs * bs);
      lemma_map_blocks_vec_g_v_f_i #a #len w bs bs_v inp f g g_v pre2 i end end
  else begin
    div_interval bs (len / bs) i;
    div_mul_l i len w bs;
    mod_interval_lt bs_v (i / bs_v) i len;
    aux2 i;
    //assert ((len % bs_v) / bs * bs <= i % bs_v);
    lemma_map_blocks_vec_g_v_g_i #a #len w bs bs_v inp f g g_v pre2 i end


let lemma_map_blocks_vec #a #len w blocksize inp f g f_v g_v =
  let v = map_blocks (w * blocksize) inp f_v g_v in
  let s = map_blocks blocksize inp f g in
  Classical.forall_intro (lemma_map_blocks_vec_i #a #len w blocksize (w * blocksize) inp f g f_v g_v () ());
  Seq.lemma_eq_intro v s

///
///  lemma_map_blocks_ctr_vec
///

val update_sub_is_append:
    #a:Type
  -> #len:size_nat
  -> n:size_nat{n <= len}
  -> x:lseq a n
  -> zero:a -> Lemma
   (let i = create len zero in
    let zeros = create (len - n) zero in
    update_sub #a #len i 0 n x == Seq.append x zeros)

let update_sub_is_append #a #len n x zero =
  let i = create len zero in
  let i = update_sub #a #len i 0 n x in
  let zeros = create (len - n) zero in
  Seq.Properties.lemma_split i n;
  Seq.Properties.lemma_split (Seq.append x zeros) n;
  eq_intro i (Seq.append x zeros)


val update_sub_get_block_lemma:
    #a:Type
  -> w:size_pos
  -> blocksize:size_pos{w * blocksize <= max_size_t}
  -> zero:a
  -> len:nat{len < w * blocksize}
  -> b_v:lseq a len
  -> j:nat{j < len / blocksize * blocksize} -> Lemma
  (let blocksize_v = w * blocksize in
   let plain = create blocksize_v zero in
   let plain = update_sub plain 0 len b_v in
   div_mul_lt blocksize j w;
   Math.Lemmas.cancel_mul_div w blocksize;
   get_block_s #a #blocksize_v blocksize plain j ==
   get_block_s #a #len blocksize b_v j)

let update_sub_get_block_lemma #a w blocksize zero len b_v j =
  if len < blocksize then ()
  else begin
    let blocksize_v = w * blocksize in
    let plain = create blocksize_v zero in
    let plain = update_sub plain 0 len b_v in
    //assert (slice plain 0 len == b_v);
    div_mul_lt blocksize j w;
    Math.Lemmas.cancel_mul_div w blocksize;
    //assert (j / blocksize < w);
    //assert (j < blocksize_v / blocksize * blocksize);
    let b_p : lseq a blocksize = get_block_s #a #blocksize_v blocksize plain j in
    let b : lseq a blocksize = get_block_s #a #len blocksize b_v j in

    lemma_i_div_bs_mul_bs_lt blocksize len j;
    assert (j / blocksize * blocksize + blocksize <= len);
    let b_p_k (k:nat{k < blocksize}) : Lemma (b_p.[k] == b_v.[j / blocksize * blocksize + k]) =
      Seq.lemma_index_slice plain (j / blocksize * blocksize) (j / blocksize * blocksize + blocksize) k;
      update_sub_is_append #a #blocksize_v len b_v zero;
      assert (plain == Seq.append b_v (create (blocksize_v - len) zero));
      Seq.lemma_index_app1 b_v (create (blocksize_v - len) zero) (j / blocksize * blocksize + k);
      () in

    let eq_aux (k:nat{k < blocksize}) : Lemma (b_p.[k] == b.[k]) =
      b_p_k k in

    Classical.forall_intro eq_aux;
    eq_intro b b_p end


val update_sub_get_last_lemma:
    #a:Type
  -> w:size_pos
  -> blocksize:size_pos{w * blocksize <= max_size_t}
  -> zero:a
  -> len:nat{len < w * blocksize}
  -> b_v:lseq a len
  -> j:nat{len / blocksize * blocksize <= j /\ j < len} -> Lemma
  (let blocksize_v = w * blocksize in
   let plain = create blocksize_v zero in
   let plain = update_sub plain 0 len b_v in
   div_mul_lt blocksize j w;
   Math.Lemmas.cancel_mul_div w blocksize;

   let b_last = get_last_s #a #len blocksize b_v in
   let plain1 = create blocksize zero in
   let plain1 = update_sub plain1 0 (len % blocksize) b_last in

   get_block_s #a #blocksize_v blocksize plain j == plain1)

let update_sub_get_last_lemma #a w blocksize zero len b_v j =
  let blocksize_v = w * blocksize in
  let plain = create blocksize_v zero in
  let plain = update_sub plain 0 len b_v in
  update_sub_is_append #a #blocksize_v len b_v zero;
  assert (plain == Seq.append b_v (create (blocksize_v - len) zero));

  div_mul_lt blocksize j w;
  Math.Lemmas.cancel_mul_div w blocksize;
  let lp = get_block_s #a #blocksize_v blocksize plain j in
  let rem = len % blocksize in
  lemma_len_div_bs blocksize len j;
  assert (len - j / blocksize * blocksize = rem);

  let lp_append1 (k:nat{k < rem}) : Lemma (lp.[k] == b_v.[j / blocksize * blocksize + k]) =
    Seq.lemma_index_slice plain (j / blocksize * blocksize) (j / blocksize * blocksize + blocksize) k;
    Seq.lemma_index_app1 b_v (create (blocksize_v - len) zero) (j / blocksize * blocksize + k);
    () in

  let lp_append2 (k:nat{rem <= k /\ k < blocksize}) : Lemma (lp.[k] == zero) =
    Seq.lemma_index_slice plain (j / blocksize * blocksize) (j / blocksize * blocksize + blocksize) k;
    Seq.lemma_index_app2 b_v (create (blocksize_v - len) zero) (j / blocksize * blocksize + k);
    () in

  let b_last = get_last_s #a #len blocksize b_v in
  let plain1 = create blocksize zero in
  let plain1 = update_sub plain1 0 rem b_last in
  update_sub_is_append #a #blocksize rem b_last zero;
  assert (plain1 == Seq.append b_last (create (blocksize - rem) zero));

  let eq_aux (k:nat{k < blocksize}) : Lemma (lp.[k] == plain1.[k]) =
    if k < rem then lp_append1 k else lp_append2 k;
    () in

  Classical.forall_intro eq_aux;
  eq_intro lp plain1


val fv_last_ctr_lemma_i_f:
    #a:Type
  -> w:size_pos
  -> blocksize:size_pos
  -> blocksize_v:size_pos{blocksize_v == w * blocksize}
  -> len:nat{len / blocksize <= max_size_t /\ len / blocksize_v <= max_size_t}
  -> f:(block_ctr len blocksize -> lseq a blocksize -> lseq a blocksize)
  -> f_v:(block_ctr len blocksize_v -> lseq a blocksize_v -> lseq a blocksize_v)
  -> zero:a
  -> pre:squash (forall (i:nat{i <= len}) (b_v:lseq a blocksize_v).
         map_blocks_ctr_vec_equiv_pre #a #len w blocksize blocksize_v f f_v i b_v)
  -> b_v:lseq a (len % blocksize_v)
  -> i:nat{len / blocksize_v * blocksize_v <= i /\ i < len /\
         i % blocksize_v < (len % blocksize_v) / blocksize * blocksize} -> Lemma
  (let rem = len % blocksize_v in
   let j = i % blocksize_v in
   let g_v = f_last_ctr #a #len blocksize_v f_v zero in

   Math.Lemmas.lemma_div_le i len blocksize;
   assert (i / blocksize <= len / blocksize);

   let b = get_block_s #a #rem blocksize b_v j in
   let rp : lseq a blocksize = f (i / blocksize) b in
   (g_v (len / blocksize_v) rem b_v).[j] == rp.[i % blocksize])

let fv_last_ctr_lemma_i_f #a w blocksize blocksize_v len f f_v zero pre b_v i =
  let j = i % blocksize_v in
  let rem = len % blocksize_v in

  let plain = create blocksize_v zero in
  let plain = update_sub plain 0 rem b_v in
  assert (map_blocks_ctr_vec_equiv_pre #a #len w blocksize blocksize_v f f_v i plain);
  //Math.Lemmas.modulo_range_lemma i blocksize_v;
  //Math.Lemmas.multiple_division_lemma w blocksize;
  //let b = get_block_s #_ #blocksize_v blocksize plain j in
  //Math.Lemmas.lemma_div_le i len blocksize;
  //Math.Lemmas.lemma_div_le i len blocksize_v;
  //assert ((f_v (i / blocksize_v) plain).[j] == (f (i / blocksize) b).[i % blocksize]);

  //let g_v = f_last_ctr #a #len blocksize_v f_v zero in
  //assert ((g_v (i / blocksize_v) rem b_v).[j] == (f_v (i / blocksize_v) plain).[j]);
  //assert ((g_v (i / blocksize_v) rem b_v).[j] == (f (i / blocksize) b).[i % blocksize]);
  update_sub_get_block_lemma #a w blocksize zero rem b_v j;
  div_interval blocksize_v (len / blocksize_v) i


val fv_last_ctr_lemma_i_g_aux:
    #a:Type
  -> w:size_pos
  -> blocksize:size_pos
  -> blocksize_v:size_pos{blocksize_v == w * blocksize}
  -> len:nat{len / blocksize <= max_size_t}
  -> f:(block_ctr len blocksize -> lseq a blocksize -> lseq a blocksize)
  -> zero:a
  -> b_v:lseq a (len % blocksize_v)
  -> i:nat{(len % blocksize_v) / blocksize * blocksize <= i % blocksize_v /\
          i % blocksize_v < len % blocksize_v /\
          len / blocksize_v * blocksize_v <= i /\ i < len} -> Lemma
  (let rem = len % blocksize_v in
   lemma_mod_bs_v_bs len w blocksize;
   assert (rem % blocksize == len % blocksize);
   let plain = create blocksize_v zero in
   let plain = update_sub plain 0 rem b_v in

   let j = i % blocksize_v in
   Math.Lemmas.multiple_division_lemma w blocksize;
   let b = get_block_s #a #blocksize_v blocksize plain j in
   let b_last = get_last_s #a #rem blocksize b_v in
   lemma_i_mod_bs_lt w blocksize len i;
   assert (i % blocksize < rem % blocksize);
   (f (len / blocksize) b).[i % blocksize] ==
   (f_last_ctr #a #len blocksize f zero (len / blocksize) (rem % blocksize) b_last).[i % blocksize])

let fv_last_ctr_lemma_i_g_aux #a w blocksize blocksize_v len f zero b_v i =
  let rem = len % blocksize_v in
  lemma_mod_bs_v_bs len w blocksize;
  let b_last = get_last_s #a #rem blocksize b_v in
  let rp = f_last_ctr #a #len blocksize f zero (len / blocksize) (rem % blocksize) b_last in

  let plain1 = create blocksize zero in
  let plain1 = update_sub plain1 0 (rem % blocksize) b_last in
  let lp = f (len / blocksize) plain1 in
  lemma_i_mod_bs_lt w blocksize len i;
  assert (lp.[i % blocksize] == rp.[i % blocksize]);

  let j = i % blocksize_v in
  Math.Lemmas.multiple_division_lemma w blocksize;
  let plain = create blocksize_v zero in
  let plain = update_sub plain 0 rem b_v in
  let b = get_block_s #_ #blocksize_v blocksize plain j in

  update_sub_get_last_lemma #a w blocksize zero rem b_v j;
  assert (plain1 `Seq.equal` b)


val fv_last_ctr_lemma_i_g:
    #a:Type
  -> w:size_pos
  -> blocksize:size_pos
  -> blocksize_v:size_pos{blocksize_v == w * blocksize}
  -> len:nat{len / blocksize <= max_size_t /\ len / blocksize_v <= max_size_t}
  -> f:(block_ctr len blocksize -> lseq a blocksize -> lseq a blocksize)
  -> f_v:(block_ctr len blocksize_v -> lseq a blocksize_v -> lseq a blocksize_v)
  -> zero:a
  -> pre:squash (forall (i:nat{i <= len}) (b_v:lseq a blocksize_v).
         map_blocks_ctr_vec_equiv_pre #a #len w blocksize blocksize_v f f_v i b_v)
  -> b_v:lseq a (len % blocksize_v)
  -> i:nat{(len % blocksize_v) / blocksize * blocksize <= i % blocksize_v /\
          i % blocksize_v < len % blocksize_v /\
          len / blocksize_v * blocksize_v <= i /\ i < len} -> Lemma
  (let rem = len % blocksize_v in
   lemma_mod_bs_v_bs len w blocksize;
   let b : lseq a (rem % blocksize) = get_last_s #a #rem blocksize b_v in
   let rp : lseq a (rem % blocksize) = f_last_ctr #a #len blocksize f zero (len / blocksize) (rem % blocksize) b in
   let lp : lseq a rem = f_last_ctr #a #len blocksize_v f_v zero (len / blocksize_v) rem b_v in
   mod_div_lt blocksize_v i len;
   //assert (i % blocksize_v < rem);
   lemma_i_mod_bs_lt w blocksize len i;
   //assert (i % blocksize < rem);
   lp.[i % blocksize_v] == rp.[i % blocksize])

let fv_last_ctr_lemma_i_g #a w blocksize blocksize_v len f f_v zero pre b_v i =
  let j = i % blocksize_v in
  let rem = len % blocksize_v in

  let plain = create blocksize_v zero in
  let plain = update_sub plain 0 rem b_v in
  let c = i / blocksize_v in
  div_interval blocksize_v (len / blocksize_v) i;
  assert (i / blocksize_v == len / blocksize_v);
  let res = f_last_ctr #a #len blocksize_v f_v zero (len / blocksize_v) rem b_v in
  assert (res == sub (f_v c plain) 0 rem);
  assert (res.[j] == (f_v c plain).[j]);

  lemma_i_div_bs_g w blocksize blocksize_v len i;
  assert (i / blocksize == len / blocksize);

  assert (map_blocks_ctr_vec_equiv_pre #a #len w blocksize blocksize_v f f_v i plain);

  Math.Lemmas.multiple_division_lemma w blocksize;
  let b_last = get_block_s #a #blocksize_v blocksize plain j in
  assert ((f_v c plain).[j] == (f (len / blocksize) b_last).[i % blocksize]);
  fv_last_ctr_lemma_i_g_aux #a w blocksize blocksize_v len f zero b_v i


val map_blocks_vec_equiv_pre_g_v_lemma:
    #a:Type
  -> w:size_pos
  -> blocksize:size_pos
  -> blocksize_v:size_pos{blocksize_v == w * blocksize}
  -> len:nat{len / blocksize <= max_size_t /\ len / blocksize_v <= max_size_t}
  -> inp:seq a{length inp == len}
  -> f:(block_ctr len blocksize -> lseq a blocksize -> lseq a blocksize)
  -> f_v:(block_ctr len blocksize_v -> lseq a blocksize_v -> lseq a blocksize_v)
  -> zero:a
  -> pre:squash (forall (i:nat{i <= len}) (b_v:lseq a blocksize_v).
         map_blocks_ctr_vec_equiv_pre #a #len w blocksize blocksize_v f f_v i b_v)
  -> i:nat{len / blocksize_v * blocksize_v <= i /\ i < len}
  -> b_v:lseq a (len % blocksize_v) -> Lemma
  (let g = f_last_ctr #a #len blocksize f zero in
   let g_v = f_last_ctr #a #len blocksize_v f_v zero in
   map_blocks_vec_equiv_pre_g_v #a #len w blocksize blocksize_v f g g_v i b_v)

let map_blocks_vec_equiv_pre_g_v_lemma #a w blocksize blocksize_v len inp f f_v zero pre i b_v =
  let rem_v = len % blocksize_v in
  let rem = len % blocksize in
  lemma_mod_bs_v_bs len w blocksize;
  assert (rem_v % blocksize = rem);

  let j = i % blocksize_v in
  if j < (rem_v / blocksize) * blocksize then begin
    fv_last_ctr_lemma_i_f #a w blocksize blocksize_v len f f_v zero pre b_v i end
  else begin
    mod_div_lt blocksize_v i len;
    assert (i % blocksize_v < len % blocksize_v);
    lemma_i_mod_bs_lt w blocksize len i;
    assert (i % blocksize < rem);
    fv_last_ctr_lemma_i_g #a w blocksize blocksize_v len f f_v zero pre b_v i end


val map_blocks_vec_equiv_pre_f_v_lemma:
    #a:Type
  -> w:size_pos
  -> blocksize:size_pos
  -> blocksize_v:size_pos{blocksize_v == w * blocksize}
  -> len:nat{len / blocksize <= max_size_t /\ len / blocksize_v <= max_size_t}
  -> inp:seq a{length inp == len}
  -> f:(block_ctr len blocksize -> lseq a blocksize -> lseq a blocksize)
  -> f_v:(block_ctr len blocksize_v -> lseq a blocksize_v -> lseq a blocksize_v)
  -> zero:a
  -> pre:squash (forall (i:nat{i <= len}) (b_v:lseq a blocksize_v).
         map_blocks_ctr_vec_equiv_pre #a #len w blocksize blocksize_v f f_v i b_v)
  -> i:nat{i < len / blocksize_v * blocksize_v}
  -> b_v:lseq a blocksize_v -> Lemma
  (map_blocks_vec_equiv_pre_f_v #a #len w blocksize blocksize_v f f_v i b_v)

let map_blocks_vec_equiv_pre_f_v_lemma #a w blocksize blocksize_v len inp f f_v zero pre i b_v =
  assert (map_blocks_ctr_vec_equiv_pre #a #len w blocksize blocksize_v f f_v i b_v)


let lemma_map_blocks_ctr_vec #a #len w blocksize inp f f_v zero =
  let blocksize_v = w * blocksize in
  let g = f_last_ctr #a #len blocksize f zero in
  let g_v = f_last_ctr #a #len blocksize_v f_v zero in

  Classical.forall_intro_2 (map_blocks_vec_equiv_pre_f_v_lemma #a w blocksize blocksize_v len inp f f_v zero ());
  Classical.forall_intro_2 (map_blocks_vec_equiv_pre_g_v_lemma #a w blocksize blocksize_v len inp f f_v zero ());

  lemma_map_blocks_vec #a #len w blocksize inp f g f_v g_v


val lemma_aux: blocksize:pos -> len:nat -> len0:nat ->
  Lemma
  (requires len0 <= len /\ len0 % blocksize == 0)
  (ensures  len0 / blocksize + (len - len0) / blocksize == len / blocksize)

let lemma_aux bs len len0 =
  calc (==) {
    len0 / bs + (len - len0) / bs;
    == { FStar.Math.Lemmas.lemma_div_exact len0 bs }
    len0 / bs + (len - len0 / bs * bs) / bs;
    == { FStar.Math.Lemmas.lemma_div_plus len (- len0 / bs) bs }
    len0 / bs + len / bs - len0 / bs;
    == { }
    len / bs;
  }


val lemma_aux2: blocksize:pos -> len:nat -> len0:nat -> i:nat ->
  Lemma
  (requires len0 <= len /\ len0 % blocksize == 0 /\ i < (len - len0) / blocksize)
  (ensures  len0 + i * blocksize + blocksize <= len)

let lemma_aux2 blocksize len len0 i =
  let len1 = len - len0 in
  FStar.Math.Lemmas.lemma_mult_le_right blocksize (i + 1) (len1 / blocksize);
  assert (len0 + (i + 1) * blocksize <= len0 + len1 / blocksize * blocksize);
  FStar.Math.Lemmas.multiply_fractions len blocksize;
  assert (len1 / blocksize * blocksize <= len1);
  assert (len0 + (i + 1) * blocksize <= len)


val lemma_aux3: blocksize:pos -> len:nat -> len0:nat -> i:nat ->
  Lemma
  (requires len0 <= len /\ len0 % blocksize == 0)
  (ensures  (len0 / blocksize + i) * blocksize == len0 + i * blocksize)

let lemma_aux3 blocksize len len0 i =
  calc (==) {
    (len0 / blocksize + i) * blocksize;
    (==) { FStar.Math.Lemmas.distributivity_add_left (len0 / blocksize) i blocksize }
    len0 / blocksize * blocksize + i * blocksize;
    (==) { FStar.Math.Lemmas.lemma_div_exact len0 blocksize }
    len0 + i * blocksize;
  }


val lemma_aux4: blocksize:pos -> len:nat -> len0:nat ->
  Lemma
  (requires len0 <= len /\ len0 % blocksize == 0)
  (ensures  len0 + (len - len0) / blocksize * blocksize == len / blocksize * blocksize)

let lemma_aux4 bs len len0 =
  calc (==) {
    len0 + (len - len0) / bs * bs;
    == { FStar.Math.Lemmas.lemma_div_exact len0 bs }
    len0 + (len - len0 / bs * bs) / bs * bs;
    == { FStar.Math.Lemmas.lemma_div_plus len (- len0 / bs) bs }
    len0 + (len / bs - len0 / bs) * bs;
    == { FStar.Math.Lemmas.distributivity_sub_left (len / bs) (len0 / bs) bs }
    len0 + len / bs * bs - len0 / bs * bs;
    == { FStar.Math.Lemmas.lemma_div_exact len0 bs }
    len0 + len / bs * bs - len0;
    == { }
    len / bs * bs;
    }


val lemma_aux5: w:pos -> bs:pos -> bs_v:pos{bs_v == w * bs} -> len:nat -> i:nat ->
  Lemma
  (requires len % bs_v = 0 /\ len % bs = 0 /\ i < len / (w * bs))
  (ensures  (i + 1) * bs_v <= len / bs_v * bs_v)
let lemma_aux5 w bs bs_v len i = ()

val lemma_aux6: w:pos -> bs:pos -> bs_v:pos{bs_v == w * bs} -> j:nat{j < w} ->
  Lemma (j * bs + bs <= bs_v)
let lemma_aux6 w bs bs_v j =
  Math.Lemmas.distributivity_add_left j 1 bs;
  Math.Lemmas.lemma_mult_le_right bs (j + 1) w

val lemma_aux7: w:pos -> bs:pos -> bs_v:pos{bs_v == w * bs} -> len:nat -> i:nat -> j:nat{j < w} ->
  Lemma
  (requires len % bs_v = 0 /\ len % bs = 0 /\ i < len / (w * bs))
  (ensures  (w * i + j) * bs + bs <= len)
let lemma_aux7 w bs bs_v len i j =
  calc (<=) {
    (w * i + j) * bs + bs;
    (==) { Math.Lemmas.distributivity_add_left (w * i + j) 1 bs }
    (w * i + j + 1) * bs;
    (<=) { }
    (w * i + w) * bs;
    (==) { Math.Lemmas.distributivity_add_left i 1 w }
    (i + 1) * w * bs;
    (==) { Math.Lemmas.paren_mul_right (i + 1) w bs }
    (i + 1) * bs_v;
    (<=) { Math.Lemmas.lemma_mult_le_right bs_v (i + 1) (len / bs_v) }
    len / bs_v * bs_v;
    (==) { Math.Lemmas.div_exact_r len bs_v }
    len;
  }


val lemma_aux8: w:pos -> blocksize:pos -> len:nat ->
  Lemma
  (requires len % (w * blocksize) = 0 /\ len % blocksize = 0)
  (ensures  len / blocksize == len / (w * blocksize) * w)

let lemma_aux8 w blocksize len =
  let blocksize_v = w * blocksize in
  calc (==) {
    len / blocksize;
    (==) { Math.Lemmas.lemma_div_exact len blocksize_v }
    (len / blocksize_v * blocksize_v) / blocksize;
    (==) { Math.Lemmas.paren_mul_right (len / blocksize_v) w blocksize_v }
    ((len / blocksize_v * w) * blocksize) / blocksize;
    (==) { Math.Lemmas.multiple_division_lemma (len / blocksize_v * w) blocksize }
    len / blocksize_v * w;
  }


val lemma_slice_slice_f_vec_f1:
    #a:Type0
  -> w:size_pos
  -> blocksize:size_pos{w * blocksize <= max_size_t}
  -> inp:seq a{length inp % (w * blocksize) = 0 /\ length inp % blocksize = 0}
  -> i:nat{i < length inp / (w * blocksize)}
  -> j:nat{j < w} -> Lemma
  (let blocksize_v = w * blocksize in
   lemma_aux5 w blocksize blocksize_v (length inp) i;
   //assert ((i + 1) * blocksize_v <= length inp / blocksize_v * blocksize_v);
   let block = Seq.slice inp (i * blocksize_v) (i * blocksize_v + blocksize_v) in
   lemma_aux6 w blocksize blocksize_v j;
   //assert (j * blocksize + blocksize <= blocksize_v);
   let b1 = Seq.slice block (j * blocksize) (j * blocksize + blocksize) in
   lemma_aux7 w blocksize blocksize_v (length inp) i j;
   //assert ((w * i + j) * blocksize + blocksize <= length inp);
   let b2 = Seq.slice inp ((w * i + j) * blocksize) ((w * i + j) * blocksize + blocksize) in
   b1 == b2)

let lemma_slice_slice_f_vec_f1 #a w blocksize inp i j =
  let blocksize_v = w * blocksize in
  lemma_aux5 w blocksize blocksize_v (length inp) i;
  lemma_aux6 w blocksize blocksize_v j;
  lemma_aux7 w blocksize blocksize_v (length inp) i j;
  Seq.Properties.slice_slice inp (i * blocksize_v) (i * blocksize_v + blocksize_v) (j * blocksize) (j * blocksize + blocksize)


#reset-options "--z3rlimit 50 --max_fuel 0 --max_ifuel 0"

let rec repeati_extensionality #a n f g acc0 =
  if n = 0 then begin
    Loops.eq_repeati0 n f acc0;
    Loops.eq_repeati0 n g acc0 end
  else begin
    Loops.unfold_repeati n f acc0 (n-1);
    Loops.unfold_repeati n g acc0 (n-1);
    repeati_extensionality #a (n-1) f g acc0 end


let rec repeati_right_extensionality #a n lo_g hi_g f g acc0 =
  if n = 0 then begin
    Loops.eq_repeat_right 0 n (Loops.fixed_a a) f acc0;
    Loops.eq_repeat_right lo_g (lo_g+n) (Loops.fixed_a a) g acc0 end
  else begin
    Loops.unfold_repeat_right 0 n (Loops.fixed_a a) f acc0 (n-1);
    Loops.unfold_repeat_right lo_g (lo_g+n) (Loops.fixed_a a) g acc0 (lo_g+n-1);
    repeati_right_extensionality #a (n-1) lo_g hi_g f g acc0 end


val aux_repeat_bf_s0:
    #a:Type0
  -> #b:Type0
  -> blocksize:size_pos
  -> len0:nat{len0 % blocksize = 0}
  -> inp:seq a{len0 <= length inp}
  -> f:(lseq a blocksize -> b -> b)
  -> i:nat{i < len0 / blocksize}
  -> acc:b ->
  Lemma
   (let len = length inp in
    FStar.Math.Lemmas.lemma_div_le len0 len blocksize;
    let repeat_bf_s0 = repeat_blocks_f blocksize (Seq.slice inp 0 len0) f (len0 / blocksize) in
    let repeat_bf_t = repeat_blocks_f blocksize inp f (len / blocksize) in
    repeat_bf_s0 i acc == repeat_bf_t i acc)

let aux_repeat_bf_s0 #a #b blocksize len0 inp f i acc =
  let len = length inp in
  FStar.Math.Lemmas.lemma_div_le len0 len blocksize;
  let repeat_bf_s0 = repeat_blocks_f blocksize (Seq.slice inp 0 len0) f (len0 / blocksize) in
  let repeat_bf_t = repeat_blocks_f blocksize inp f (len / blocksize) in

  let nb = len0 / blocksize in
  assert ((i + 1) * blocksize <= nb * blocksize);
  let block = Seq.slice inp (i * blocksize) (i * blocksize + blocksize) in
  assert (repeat_bf_s0 i acc == f block acc);
  assert (repeat_bf_t i acc == f block acc)


val aux_repeat_bf_s1:
    #a:Type0
  -> #b:Type0
  -> blocksize:size_pos
  -> len0:nat{len0 % blocksize = 0}
  -> inp:seq a{len0 <= length inp}
  -> f:(lseq a blocksize -> b -> b)
  -> i:nat{i < (length inp - len0) / blocksize}
  -> acc:b ->
  Lemma
   (let len = length inp in
    let len1 = len - len0 in
    FStar.Math.Lemmas.lemma_div_le len0 len blocksize;
    FStar.Math.Lemmas.lemma_div_le len1 len blocksize;
    let t1 = Seq.slice inp len0 len in
    let repeat_bf_s1 = repeat_blocks_f blocksize t1 f (len1 / blocksize) in
    let repeat_bf_t = repeat_blocks_f blocksize inp f (len / blocksize) in
    lemma_aux blocksize len len0;
    repeat_bf_s1 i acc == repeat_bf_t (len0 / blocksize + i) acc)

let aux_repeat_bf_s1 #a #b blocksize len0 inp f i acc =
  let len = length inp in
  let len1 = len - len0 in
  FStar.Math.Lemmas.lemma_div_le len0 len blocksize;
  FStar.Math.Lemmas.lemma_div_le len1 len blocksize;
  let t1 = Seq.slice inp len0 len in
  let repeat_bf_s1 = repeat_blocks_f blocksize t1 f (len1 / blocksize) in
  let repeat_bf_t = repeat_blocks_f blocksize inp f (len / blocksize) in

  let i_start = len0 / blocksize in
  let nb = len1 / blocksize in
  lemma_aux blocksize len len0;
  assert (i_start + nb = len / blocksize);

  lemma_aux2 blocksize len len0 i;
  let block = Seq.slice inp ((len0 / blocksize + i) * blocksize) ((len0 / blocksize + i) * blocksize + blocksize) in
  lemma_aux3 blocksize len len0 i;
  assert (block == Seq.slice inp (len0 + i * blocksize) (len0 + i * blocksize + blocksize));
  assert (repeat_bf_t (len0 / blocksize + i) acc == f block acc);

  //FStar.Math.Lemmas.lemma_mult_le_right blocksize (i + 1) (len1 / blocksize);
  //assert (i * blocksize + blocksize <= len1);
  assert (repeat_bf_s1 i acc == f (Seq.slice t1 (i * blocksize) (i * blocksize + blocksize)) acc);
  //assert (len0 + (i + 1) * blocksize <= len);
  FStar.Seq.Properties.slice_slice inp len0 len (i * blocksize) (i * blocksize + blocksize);
  assert (repeat_bf_s1 i acc == f block acc)


val repeat_blocks_split12:
    #a:Type0
  -> #b:Type0
  -> blocksize:size_pos
  -> len0:nat{len0 % blocksize = 0}
  -> inp:seq a{len0 <= length inp}
  -> f:(lseq a blocksize -> b -> b)
  -> acc0:b ->
  Lemma
   (let len = length inp in
    let len1 = len - len0 in
    FStar.Math.Lemmas.lemma_div_le len0 len blocksize;
    FStar.Math.Lemmas.lemma_div_le len1 len blocksize;
    let repeat_bf_s0 = repeat_blocks_f blocksize (Seq.slice inp 0 len0) f (len0 / blocksize) in
    let repeat_bf_s1 = repeat_blocks_f blocksize (Seq.slice inp len0 len) f (len1 / blocksize) in
    let repeat_bf_t = repeat_blocks_f blocksize inp f (len / blocksize) in

    let acc1 = Loops.repeati (len0 / blocksize) repeat_bf_s0 acc0 in
    Loops.repeati (len1 / blocksize) repeat_bf_s1 acc1 ==
      Loops.repeati (len / blocksize) repeat_bf_t acc0)

let repeat_blocks_split12 #a #b blocksize len0 inp f acc0 =
  let len = length inp in
  let len1 = len - len0 in
  FStar.Math.Lemmas.lemma_div_le len0 len blocksize;
  FStar.Math.Lemmas.lemma_div_le len1 len blocksize;

  let repeat_bf_s0 = repeat_blocks_f blocksize (Seq.slice inp 0 len0) f (len0 / blocksize) in
  let repeat_bf_s1 = repeat_blocks_f blocksize (Seq.slice inp len0 len) f (len1 / blocksize) in
  let repeat_bf_t = repeat_blocks_f blocksize inp f (len / blocksize) in

  let acc1 = Loops.repeati (len0 / blocksize) repeat_bf_s0 acc0 in
  calc (==) {
      Loops.repeati (len0 / blocksize) repeat_bf_s0 acc0;
    == { FStar.Classical.forall_intro_2 (aux_repeat_bf_s0 #a #b blocksize len0 inp f);
	 repeati_extensionality (len0 / blocksize) repeat_bf_s0 repeat_bf_t acc0 }
      Loops.repeati (len0 / blocksize) repeat_bf_t acc0;
    == { Loops.repeati_def (len0 / blocksize) repeat_bf_t acc0 }
      Loops.repeat_right 0 (len0 / blocksize) (Loops.fixed_a b) repeat_bf_t acc0;
    };

  let i_start = len0 / blocksize in
  let nb = len1 / blocksize in
  lemma_aux blocksize len len0;
  assert (i_start + nb = len / blocksize);
  let acc3 = Loops.repeati (len1 / blocksize) repeat_bf_s1 acc1 in
  calc (==) {
      Loops.repeati (len1 / blocksize) repeat_bf_s1 acc1;
    == { Loops.repeati_def (len1 / blocksize) repeat_bf_s1 acc1 }
      Loops.repeat_right 0 nb (Loops.fixed_a b) repeat_bf_s1 acc1;
    == { FStar.Classical.forall_intro_2 (aux_repeat_bf_s1 #a #b blocksize len0 inp f);
	 repeati_right_extensionality nb i_start (nb+i_start) repeat_bf_s1 repeat_bf_t acc1 }
      Loops.repeat_right i_start (i_start+nb) (Loops.fixed_a b) repeat_bf_t acc1;
    == { }
      Loops.repeat_right (len0 / blocksize) (len / blocksize) (Loops.fixed_a b) repeat_bf_t acc1;
    == { Loops.repeat_right_plus 0 (len0 / blocksize) (len / blocksize) (Loops.fixed_a b) repeat_bf_t acc0 }
      Loops.repeat_right 0 (len / blocksize) (Loops.fixed_a b) repeat_bf_t acc0;
    == { Loops.repeati_def (len / blocksize) repeat_bf_t acc0 }
      Loops.repeati (len / blocksize) repeat_bf_t acc0;
    }


let repeat_blocks_multi_split #a #b blocksize len0 inp f acc0 =
  let len = length inp in
  let len1 = len - len0 in
  FStar.Math.Lemmas.modulo_addition_lemma len blocksize (- len0 / blocksize);
  assert (len % blocksize == len1 % blocksize);
  let t0 = Seq.slice inp 0 len0 in
  let t1 = Seq.slice inp len0 len in

  FStar.Math.Lemmas.lemma_div_le len0 len blocksize;
  FStar.Math.Lemmas.lemma_div_le len1 len blocksize;
  let repeat_bf_s0 = repeat_blocks_f blocksize t0 f (len0 / blocksize) in
  let repeat_bf_s1 = repeat_blocks_f blocksize t1 f (len1 / blocksize) in
  let repeat_bf_t  = repeat_blocks_f blocksize inp f (len / blocksize) in

  let acc1 = repeat_blocks_multi blocksize t0 f acc0 in
  let acc2 = repeat_blocks_multi blocksize t1 f acc1 in

  calc (==) {
    repeat_blocks_multi blocksize t1 f acc1;
    (==) { lemma_repeat_blocks_multi blocksize t1 f acc1 }
    Loops.repeati (len1 / blocksize) repeat_bf_s1 acc1;
    (==) { lemma_repeat_blocks_multi blocksize t0 f acc0 }
    Loops.repeati (len1 / blocksize) repeat_bf_s1 (Loops.repeati (len0 / blocksize) repeat_bf_s0 acc0);
    (==) { repeat_blocks_split12 blocksize len0 inp f acc0 }
    Loops.repeati (len / blocksize) repeat_bf_t acc0;
    (==) { lemma_repeat_blocks_multi blocksize inp f acc0 }
    repeat_blocks_multi blocksize inp f acc0;
  };
  assert (repeat_blocks_multi blocksize t1 f acc1 == repeat_blocks_multi blocksize inp f acc0)


let repeat_blocks_split #a #b #c blocksize len0 inp f l acc0 =
  let len = length inp in
  let len1 = len - len0 in
  FStar.Math.Lemmas.modulo_addition_lemma len blocksize (- len0 / blocksize);
  assert (len % blocksize == len1 % blocksize);
  let t0 = Seq.slice inp 0 len0 in
  let t1 = Seq.slice inp len0 len in

  FStar.Math.Lemmas.lemma_div_le len0 len blocksize;
  FStar.Math.Lemmas.lemma_div_le len1 len blocksize;
  let repeat_bf_s0 = repeat_blocks_f blocksize t0 f (len0 / blocksize) in
  let repeat_bf_s1 = repeat_blocks_f blocksize t1 f (len1 / blocksize) in
  let repeat_bf_t  = repeat_blocks_f blocksize inp f (len / blocksize) in

  let acc1 = repeat_blocks_multi blocksize t0 f acc0 in
  let acc2 = repeat_blocks blocksize t1 f l acc1 in

  let acc3 = Loops.repeati (len1 / blocksize) repeat_bf_s1 acc1 in

  calc (==) {
    repeat_blocks blocksize t1 f l acc1;
    (==) { lemma_repeat_blocks blocksize t1 f l acc1 }
    l (len1 % blocksize) (Seq.slice t1 (len1 / blocksize * blocksize) len1) acc3;
    (==) { FStar.Math.Lemmas.modulo_addition_lemma len blocksize (- len0 / blocksize) }
    l (len % blocksize) (Seq.slice (Seq.slice inp len0 len) (len1 / blocksize * blocksize) len1) acc3;
    (==) { lemma_aux4 blocksize len len0; FStar.Seq.Properties.slice_slice inp len0 len (len1 / blocksize * blocksize) len1 }
    l (len % blocksize) (Seq.slice inp (len / blocksize * blocksize) len) acc3;
    (==) { lemma_repeat_blocks_multi blocksize t0 f acc0 }
    l (len % blocksize) (Seq.slice inp (len / blocksize * blocksize) len)
      (Loops.repeati (len1 / blocksize) repeat_bf_s1 (Loops.repeati (len0 / blocksize) repeat_bf_s0 acc0));
    (==) { repeat_blocks_split12 blocksize len0 inp f acc0 }
    l (len % blocksize) (Seq.slice inp (len / blocksize * blocksize) len) (Loops.repeati (len / blocksize) repeat_bf_t acc0);
    (==) { lemma_repeat_blocks blocksize inp f l acc0 }
    repeat_blocks blocksize inp f l acc0;
  };
  assert (repeat_blocks blocksize t1 f l acc1 == repeat_blocks blocksize inp f l acc0)


val lemma_repeati_vec_:
    #a:Type0
  -> #a_vec:Type0
  -> w:pos
  -> n:nat
  -> normalize_v:(a_vec -> a)
  -> f:(i:nat{i < n * w} -> a -> a)
  -> f_v:(i:nat{i < n} -> a_vec -> a_vec)
  -> acc_v0:a_vec ->
  Lemma
  (requires (forall (i:nat{i < n}) (acc_v:a_vec).
   (assert (w * (i + 1) <= w * n);
   normalize_v (f_v i acc_v) == Loops.repeat_right (w * i) (w * (i + 1)) (Loops.fixed_a a) f (normalize_v acc_v))))
  (ensures
    normalize_v (Loops.repeat_right 0 n (Loops.fixed_a a_vec) f_v acc_v0) ==
    Loops.repeat_right 0 (w * n) (Loops.fixed_a a) f (normalize_v acc_v0))

let rec lemma_repeati_vec_ #a #a_vec w n normalize_v f f_v acc_v0 =
  if n = 0 then begin
    Loops.eq_repeat_right 0 n (Loops.fixed_a a_vec) f_v acc_v0;
    Loops.eq_repeat_right 0 (w * n) (Loops.fixed_a a) f (normalize_v acc_v0);
    () end
  else begin
    lemma_repeati_vec_ #a #a_vec w (n - 1) normalize_v f f_v acc_v0;
    let next_p : a_vec = Loops.repeat_right 0 (n - 1) (Loops.fixed_a a_vec) f_v acc_v0 in
    let next_v = Loops.repeat_right 0 (w * (n - 1)) (Loops.fixed_a a) f (normalize_v acc_v0) in
    assert (normalize_v next_p == next_v);
    let res1 = Loops.repeat_right 0 n (Loops.fixed_a a_vec) f_v acc_v0 in
    let res2 = Loops.repeat_right 0 (w * n) (Loops.fixed_a a) f (normalize_v acc_v0) in
    Loops.unfold_repeat_right 0 n (Loops.fixed_a a_vec) f_v acc_v0 (n - 1);
    assert (res1 == f_v (n - 1) next_p);
    Loops.repeat_right_plus 0 (w * (n - 1)) (w * n) (Loops.fixed_a a) f (normalize_v acc_v0);
    assert (res2 == Loops.repeat_right (w * (n - 1)) (w * n) (Loops.fixed_a a) f next_v);
    assert (normalize_v res1 == Loops.repeat_right (w * (n - 1)) (w * n) (Loops.fixed_a a) f next_v)
    end


let lemma_repeati_vec #a #a_vec w n normalize_v f f_v acc_v0 =
  lemma_repeati_vec_ #a #a_vec w n normalize_v f f_v acc_v0;
  Loops.repeati_def n f_v acc_v0;
  Loops.repeati_def (w * n) f (normalize_v acc_v0)


val repeat_blocks_multi_vec_step2:
    #a:Type0
  -> #b:Type0
  -> w:size_pos
  -> blocksize:size_pos{w * blocksize <= max_size_t}
  -> inp:seq a{length inp % (w * blocksize) = 0 /\ length inp % blocksize = 0}
  -> f:(lseq a blocksize -> b -> b)
  -> i:nat{i < length inp / (w * blocksize)}
  -> j:nat{j < w}
  -> acc:b -> Lemma
  (let len = length inp in
   let blocksize_v = w * blocksize in
   let nb_v = len / blocksize_v in
   let nb = len / blocksize in
   lemma_aux8 w blocksize len;
   assert (nb == w * nb_v);

   let repeat_bf_s = repeat_blocks_f blocksize inp f nb in
   lemma_aux5 w blocksize blocksize_v len i;
   assert ((i + 1) * blocksize_v <= nb_v * blocksize_v);
   let block = Seq.slice inp (i * blocksize_v) (i * blocksize_v + blocksize_v) in
   FStar.Math.Lemmas.cancel_mul_mod w blocksize;
   let repeat_bf_s1 = repeat_blocks_f blocksize block f w in

   repeat_bf_s1 j acc == repeat_bf_s (w * i + j) acc)

let repeat_blocks_multi_vec_step2 #a #b w blocksize inp f i j acc =
  lemma_slice_slice_f_vec_f1 #a w blocksize inp i j

#restart-solver

val repeat_blocks_multi_vec_step1:
    #a:Type0
  -> #b:Type0
  -> w:size_pos
  -> blocksize:size_pos{w * blocksize <= max_size_t}
  -> inp:seq a{length inp % (w * blocksize) = 0 /\ length inp % blocksize = 0}
  -> f:(lseq a blocksize -> b -> b)
  -> i:nat{i < length inp / (w * blocksize)}
  -> acc:b -> Lemma
  (let len = length inp in
   let blocksize_v = w * blocksize in
   let nb_v = len / blocksize_v in
   let nb = len / blocksize in
   lemma_aux8 w blocksize len;
   assert (nb == w * nb_v);

   let repeat_bf_s = repeat_blocks_f blocksize inp f nb in
   lemma_aux5 w blocksize blocksize_v len i;
   assert ((i + 1) * blocksize_v <= nb_v * blocksize_v);
   let block = Seq.slice inp (i * blocksize_v) (i * blocksize_v + blocksize_v) in
   FStar.Math.Lemmas.cancel_mul_mod w blocksize;
   let repeat_bf_s1 = repeat_blocks_f blocksize block f w in

   let lp = Loops.repeat_right 0 w (Loops.fixed_a b) repeat_bf_s1 acc in
   let rp = Loops.repeat_right (w * i) (w * i + w) (Loops.fixed_a b) repeat_bf_s acc in
   lp == rp)

let repeat_blocks_multi_vec_step1 #a #b w blocksize inp f i acc =
  let len = length inp in
  let blocksize_v = w * blocksize in
  let nb_v = len / blocksize_v in
  let nb = len / blocksize in
  lemma_aux8 w blocksize len;
  assert (nb == w * nb_v);

  let repeat_bf_s = repeat_blocks_f blocksize inp f nb in
  lemma_aux5 w blocksize blocksize_v len i;
  assert ((i + 1) * blocksize_v <= nb_v * blocksize_v);
  let block = Seq.slice inp (i * blocksize_v) (i * blocksize_v + blocksize_v) in
  FStar.Math.Lemmas.cancel_mul_mod w blocksize;
  let repeat_bf_s1 = repeat_blocks_f blocksize block f w in

  //let lp = Loops.repeat_right 0 w (Loops.fixed_a b) repeat_bf_s1 acc in
  //let rp = Loops.repeat_right (w * i) (w * i + w) (Loops.fixed_a b) repeat_bf_s acc in
  Classical.forall_intro_2
    #(j:nat{j < w})
    #(fun _ -> b)
    #(fun j acc -> repeat_bf_s1 j acc == repeat_bf_s (w * i + j) acc)
    (repeat_blocks_multi_vec_step2 #a #b w blocksize inp f i);
  repeati_right_extensionality w (w * i) (w * i + w) repeat_bf_s1 repeat_bf_s acc


#reset-options "--z3rlimit 300 --max_fuel 0 --max_ifuel 0"

val repeat_blocks_multi_vec_step:
    #a:Type0
  -> #b:Type0
  -> #b_vec:Type0
  -> w:size_pos
  -> blocksize:size_pos{w * blocksize <= max_size_t}
  -> inp:seq a{length inp % (w * blocksize) = 0 /\ length inp % blocksize = 0}
  -> f:(lseq a blocksize -> b -> b)
  -> f_v:(lseq a (w * blocksize) -> b_vec -> b_vec)
  -> normalize_v:(b_vec -> b)
  -> pre:squash (forall (b_v:lseq a (w * blocksize)) (acc_v:b_vec).
      repeat_blocks_multi_vec_equiv_pre w blocksize (w * blocksize) f f_v normalize_v b_v acc_v)
  -> i:nat{i < length inp / (w * blocksize)}
  -> acc_v:b_vec -> Lemma
  (let len = length inp in
   let blocksize_v = w * blocksize in
   let nb_v = len / blocksize_v in
   let nb = len / blocksize in
   lemma_aux8 w blocksize len;
   assert (nb == w * nb_v);

   let repeat_bf_v = repeat_blocks_f blocksize_v inp f_v nb_v in
   let repeat_bf_s = repeat_blocks_f blocksize inp f nb in

   normalize_v (repeat_bf_v i acc_v) ==
   Loops.repeat_right (w * i) (w * (i + 1)) (Loops.fixed_a b) repeat_bf_s (normalize_v acc_v))

let repeat_blocks_multi_vec_step #a #b #b_vec w blocksize inp f f_v normalize_v pre i acc_v =
  let len = length inp in
  let blocksize_v = w * blocksize in
  let nb_v = len / blocksize_v in
  let nb = len / blocksize in
  lemma_aux8 w blocksize len;
  assert (nb == w * nb_v);

  let repeat_bf_v = repeat_blocks_f blocksize_v inp f_v nb_v in
  let repeat_bf_s = repeat_blocks_f blocksize inp f nb in

  lemma_aux5 w blocksize blocksize_v len i;
  assert ((i + 1) * blocksize_v <= nb_v * blocksize_v);
  let block = Seq.slice inp (i * blocksize_v) (i * blocksize_v + blocksize_v) in
  FStar.Math.Lemmas.cancel_mul_mod w blocksize;
  let repeat_bf_s1 = repeat_blocks_f blocksize block f w in
  let acc = normalize_v acc_v in

  assert (repeat_blocks_multi_vec_equiv_pre w blocksize blocksize_v f f_v normalize_v block acc_v);
  //assert (normalize_v (repeat_bf_v i acc_v) == repeat_blocks_multi blocksize block f acc);
  lemma_repeat_blocks_multi blocksize block f acc;
  //assert (normalize_v (repeat_bf_v i acc_v) == Loops.repeati w repeat_bf_s1 acc);
  Loops.repeati_def w repeat_bf_s1 acc;
  repeat_blocks_multi_vec_step1 w blocksize inp f i acc


let lemma_repeat_blocks_multi_vec #a #b #b_vec w blocksize inp f f_v normalize_v acc_v0 =
  let len = length inp in
  let blocksize_v = w * blocksize in
  let nb_v = len / blocksize_v in
  let nb = len / blocksize in
  lemma_aux8 w blocksize len;
  assert (nb == w * nb_v);

  let repeat_bf_v = repeat_blocks_f blocksize_v inp f_v nb_v in
  let repeat_bf_s = repeat_blocks_f blocksize inp f nb in

  calc (==) {
    normalize_v (repeat_blocks_multi blocksize_v inp f_v acc_v0);
    (==) { lemma_repeat_blocks_multi blocksize_v inp f_v acc_v0 }
    normalize_v (Loops.repeati nb_v repeat_bf_v acc_v0);
    (==) { Classical.forall_intro_2 (repeat_blocks_multi_vec_step w blocksize inp f f_v normalize_v ());
      lemma_repeati_vec w nb_v normalize_v repeat_bf_s repeat_bf_v acc_v0}
    Loops.repeati nb repeat_bf_s (normalize_v acc_v0);
    (==) { lemma_repeat_blocks_multi blocksize inp f (normalize_v acc_v0) }
    repeat_blocks_multi blocksize inp f (normalize_v acc_v0);
  }
