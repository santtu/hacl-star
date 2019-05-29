module Vale.Transformers.InstructionReorder

/// Open all the relevant modules from the x64 semantics.

open Vale.X64.Bytes_Code_s
open Vale.X64.Instruction_s
open Vale.X64.Instructions_s
open Vale.X64.Machine_Semantics_s
open Vale.X64.Machine_s
open Vale.X64.Print_s

open Vale.X64.InsLemmas // this one is from [code]; is that ok?; we use it primarily for the sanity checks

/// Open the PossiblyMonad so that we can keep track of failure cases
/// for easier debugging.

open Vale.Transformers.PossiblyMonad

/// Finally some convenience module renamings

module L = FStar.List.Tot

/// We first need to talk about what locations may be accessed (either
/// via a read or via a write) by an instruction.
///
/// This allows us to define read and write sets for instructions.
///
/// TODO FIXME WARNING UNSOUND: We completely ignore [HavocFlags]
/// here. Technically, we need to add both flags to the write sets
/// whenever there is a flag havoc that happens.

type access_location =
  | ALoc64 : operand -> access_location
  | ALoc128 : operand128 -> access_location
  | ALocCf : access_location
  | ALocOf : access_location

let access_location_of_explicit (t:instr_operand_explicit) (i:instr_operand_t t) : access_location =
  match t with
  | IOp64 -> ALoc64 i
  | IOpXmm -> ALoc128 i

let access_location_of_implicit (t:instr_operand_implicit) : access_location =
  match t with
  | IOp64One i -> ALoc64 i
  | IOpXmmOne i -> ALoc128 i
  | IOpFlagsCf -> ALocCf
  | IOpFlagsOf -> ALocOf

type rw_set = (list access_location) & (list access_location)

let rec aux_read_set0 (args:list instr_operand) (oprs:instr_operands_t_args args) =
  match args with
  | [] -> []
  | (IOpEx i) :: args ->
    let l, r = coerce #(instr_operand_t i & instr_operands_t_args args) oprs in
    access_location_of_explicit i l :: aux_read_set0 args r
  | (IOpIm i) :: args ->
    access_location_of_implicit i :: aux_read_set0 args (coerce #(instr_operands_t_args args) oprs)

let rec aux_read_set1
    (outs:list instr_out) (args:list instr_operand) (oprs:instr_operands_t outs args) : list access_location =
  match outs with
  | [] -> aux_read_set0 args oprs
  | (Out, IOpEx i) :: outs ->
    let l, r = coerce #(instr_operand_t i & instr_operands_t outs args) oprs in
    aux_read_set1 outs args r
  | (InOut, IOpEx i) :: outs ->
    let l, r = coerce #(instr_operand_t i & instr_operands_t outs args) oprs in
    access_location_of_explicit i l :: aux_read_set1 outs args r
  | (Out, IOpIm i) :: outs ->
    aux_read_set1 outs args (coerce #(instr_operands_t outs args) oprs)
  | (InOut, IOpIm i) :: outs ->
    access_location_of_implicit i :: aux_read_set1 outs args (coerce #(instr_operands_t outs args) oprs)

let read_set (i:instr_t_record) (oprs:instr_operands_t i.outs i.args) : list access_location =
  aux_read_set1 i.outs i.args oprs

let rec aux_write_set
    (outs:list instr_out) (args:list instr_operand) (oprs:instr_operands_t outs args) : list access_location =
  match outs with
  | [] -> []
  | (_, IOpEx i) :: outs ->
    let l, r = coerce #(instr_operand_t i & instr_operands_t outs args) oprs in
    access_location_of_explicit i l :: aux_write_set outs args r
  | (_, IOpIm i) :: outs ->
    access_location_of_implicit i :: aux_write_set outs args (coerce #(instr_operands_t outs args) oprs)

let write_set (i:instr_t_record) (oprs:instr_operands_t i.outs i.args) : list access_location =
  aux_write_set i.outs i.args oprs

let rw_set_of_ins (i:ins) : rw_set =
  match i with
  | Instr i oprs _ ->
    read_set i oprs, write_set i oprs
  | Push src t ->
    [ALoc64 (OReg rRsp); ALoc64 src],
    [ALoc64 (OReg rRsp); ALoc64 (OStack (MReg rRsp (-8), t))]
  | Pop dst t ->
    [ALoc64 (OReg rRsp); ALoc64 (OStack (MReg rRsp 0, t))],
    [ALoc64 (OReg rRsp); ALoc64 dst]
  | Alloc _
  | Dealloc _ ->
    [ALoc64 (OReg rRsp)], [ALoc64 (OReg rRsp)]

/// We now need to define what it means for two different access
/// locations to be "disjoint".
///
/// Note that it is safe to say that two operands are not disjoint
/// even if they are, but the converse is not true. That is, to be
/// safe, we can say two operands are disjoint only if it is
/// guaranteed that they are disjoint.

let disjoint_access_locations (a1 a2:access_location) : pbool =
  match a1, a2 with
  | ALocCf, ALocCf -> ffalse "carry flag not disjoint from itself"
  | ALocOf, ALocOf -> ffalse "overflow flag not disjoint from itself"
  | ALocCf, _ | ALocOf, _ | _, ALocCf | _, ALocOf -> ttrue
  | ALoc64 o1, ALoc64 o2 -> (
      match o1, o2 with
      | OConst _, _ | _, OConst _ -> ttrue
      | OReg r1, OReg r2 -> (r1 <> r2) /- ("register " ^ print_reg_name r1 ^ " not disjoint from itself")
      | _ ->
        unimplemented "conservatively not disjoint ALoc64s"
    )
  | ALoc128 o1, ALoc128 o2 -> (
      match o1, o2 with
      | OReg128 r1, OReg128 r2 -> (r1 <> r2) /- ("register " ^ print_xmm r1 gcc ^ " not disjoint from itself")
      | _ ->
      unimplemented "conservatively not disjoint ALoc128s"
    )
  | ALoc64 o1, ALoc128 o2 | ALoc128 o1, ALoc64 o2 -> (
      unimplemented "conservatively not disjoint ALoc64 & ALoc128"
    )

/// Given two read/write sets corresponding to two neighboring
/// instructions, we can say whether exchanging those two instructions
/// should be allowed.

let rw_exchange_allowed (rw1 rw2 : rw_set) : pbool =
  let (r1, w1), (r2, w2) = rw1, rw2 in
  let (&&.) (x y:pbool) : pbool =
    match x with
    | Ok () -> y
    | Err reason -> Err reason in
  let rec for_all (f : 'a -> pbool) (l : list 'a) : pbool =
    match l with
    | [] -> ttrue
    | x :: xs -> f x &&. for_all f xs in
  let disjoint (l1 l2:list access_location) r : pbool =
    match l1 with
    | [] -> ttrue
    | x :: xs ->
      (for_all (fun y -> (disjoint_access_locations x y)) l2) /+< (r ^ " because ") in
  (disjoint r1 w2 "read set of 1st not disjoint from write set of 2nd") &&.
  (disjoint r2 w1 "read set of 2nd not disjoint from write set of 1st") &&.
  (disjoint w1 w2 "write sets not disjoint")

let ins_exchange_allowed (i1 i2 : ins) : pbool =
  (rw_exchange_allowed (rw_set_of_ins i1) (rw_set_of_ins i2))
  /+> normal (" for instructions " ^ print_ins i1 gcc ^ " and " ^ print_ins i2 gcc)

private abstract
let sanity_check_1 =
  assert_norm (!!(
    ins_exchange_allowed
      (make_instr ins_Mov64 (OReg rRax) (OConst 100))
      (make_instr ins_Add64 (OReg rRbx) (OConst 299))))

private abstract
let sanity_check_2 =
  assert_norm (not !!(
    ins_exchange_allowed
      (make_instr ins_Mov64 (OReg rRax) (OConst 100))
      (make_instr ins_Add64 (OReg rRax) (OConst 299))))

/// First, we must define what it means for two states to be
/// equivalent. Here, we basically say they must be exactly the same.
///
/// TODO: We should figure out a way to handle flags better. Currently
/// any two instructions that havoc flags cannot be exchanged since
/// they will not lead to equiv states.

let equiv_states (s1 s2 : machine_state) : GTot Type0 =
  (s1.ms_ok == s2.ms_ok) /\
  (s1.ms_regs == s2.ms_regs) /\
  (s1.ms_xmms == s2.ms_xmms) /\
  (s1.ms_flags == s2.ms_flags) /\
  (s1.ms_mem == s2.ms_mem) /\
  (s1.ms_memTaint == s2.ms_memTaint) /\
  (s1.ms_stack == s2.ms_stack) /\
  (s1.ms_stackTaint == s2.ms_stackTaint)

(** Same as [equiv_states] but uses extensionality to "think harder";
    useful at lower-level details of the proof. *)
let equiv_states_ext (s1 s2 : machine_state) : GTot Type0 =
  let open FStar.FunctionalExtensionality in
  (feq s1.ms_regs s2.ms_regs) /\
  (feq s1.ms_xmms s2.ms_xmms) /\
  (Map.equal s1.ms_mem s2.ms_mem) /\
  (Map.equal s1.ms_memTaint s2.ms_memTaint) /\
  (Map.equal s1.ms_stack.stack_mem s2.ms_stack.stack_mem) /\
  (Map.equal s1.ms_stackTaint s2.ms_stackTaint) /\
  (equiv_states s1 s2)

private abstract
let sanity_check_equiv_states (s1 s2 s3 : machine_state) :
  Lemma
    (ensures (
        (equiv_states s1 s1) /\
        (equiv_states s1 s2 ==> equiv_states s2 s1) /\
        (equiv_states s1 s2 /\ equiv_states s2 s3 ==> equiv_states s1 s3))) = ()

(** Convenience wrapper around [equiv_states] *)
unfold
let equiv_ostates (s1 s2 : option machine_state) : GTot Type0 =
  (Some? s1 = Some? s2) /\
  (Some? s1 ==>
   (equiv_states (Some?.v s1) (Some?.v s2)))

(** A stricter convenience wrapper around [equiv_states] *)
unfold
let equiv_ostates' (s1 : machine_state) (s2' : option machine_state) : GTot Type0 =
  (Some? s2') /\
  (equiv_states s1 (Some?.v s2'))

/// If evaluation starts from a set of equivalent states, and the
/// exact same thing is evaluated, then the final states are still
/// equivalent.

unfold
let proof_run (s:machine_state) (f:st unit) : machine_state =
  let (), s1 = f s in
  { s1 with ms_ok = s1.ms_ok && s.ms_ok }

let rec lemma_instr_apply_eval_args_equiv_states
    (outs:list instr_out) (args:list instr_operand)
    (f:instr_args_t outs args) (oprs:instr_operands_t_args args)
    (s1 s2:machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        (instr_apply_eval_args outs args f oprs s1) ==
        (instr_apply_eval_args outs args f oprs s2))) =
  match args with
  | [] -> ()
  | i :: args ->
    let (v, oprs) : option (instr_val_t i) & _ =
      match i with
      | IOpEx i -> let oprs = coerce oprs in (instr_eval_operand_explicit i (fst oprs) s1, snd oprs)
      | IOpIm i -> (instr_eval_operand_implicit i s1, coerce oprs)
    in
    let f:arrow (instr_val_t i) (instr_args_t outs args) = coerce f in
    match v with
    | None -> ()
    | Some v ->
      lemma_instr_apply_eval_args_equiv_states outs args (f v) oprs s1 s2

let rec lemma_instr_apply_eval_inouts_equiv_states
    (outs inouts:list instr_out) (args:list instr_operand)
    (f:instr_inouts_t outs inouts args) (oprs:instr_operands_t inouts args)
    (s1 s2:machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        (instr_apply_eval_inouts outs inouts args f oprs s1) ==
        (instr_apply_eval_inouts outs inouts args f oprs s2))) =
  match inouts with
  | [] ->
    lemma_instr_apply_eval_args_equiv_states outs args f oprs s1 s2
  | (Out, i) :: inouts ->
    let oprs =
      match i with
      | IOpEx i -> snd #(instr_operand_t i) (coerce oprs)
      | IOpIm i -> coerce oprs
    in
    lemma_instr_apply_eval_inouts_equiv_states outs inouts args (coerce f) oprs s1 s2
  | (InOut, i)::inouts ->
    let (v, oprs) : option (instr_val_t i) & _ =
      match i with
      | IOpEx i -> let oprs = coerce oprs in (instr_eval_operand_explicit i (fst oprs) s1, snd oprs)
      | IOpIm i -> (instr_eval_operand_implicit i s1, coerce oprs)
    in
    let f:arrow (instr_val_t i) (instr_inouts_t outs inouts args) = coerce f in
    match v with
    | None -> ()
    | Some v ->
      lemma_instr_apply_eval_inouts_equiv_states outs inouts args (f v) oprs s1 s2

let lemma_instr_write_output_implicit_equiv_states
    (i:instr_operand_implicit) (v:instr_val_t (IOpIm i))
    (s_orig1 s1 s_orig2 s2:machine_state) :
  Lemma
    (requires (
        (equiv_states s_orig1 s_orig2) /\
        (equiv_states s1 s2)))
    (ensures (
        (equiv_states
           (instr_write_output_implicit i v s_orig1 s1)
           (instr_write_output_implicit i v s_orig2 s2)))) =
  assert (equiv_states_ext
            (instr_write_output_implicit i v s_orig1 s1)
            (instr_write_output_implicit i v s_orig2 s2))

let rec lemma_instr_write_outputs_equiv_states
    (outs:list instr_out) (args:list instr_operand)
    (vs:instr_ret_t outs) (oprs:instr_operands_t outs args)
    (s_orig1 s1:machine_state)
    (s_orig2 s2:machine_state) :
  Lemma
    (requires (
        (equiv_states s_orig1 s_orig2) /\
        (equiv_states s1 s2)))
    (ensures (
        (equiv_states
           (instr_write_outputs outs args vs oprs s_orig1 s1)
           (instr_write_outputs outs args vs oprs s_orig2 s2)))) =
  match outs with
  | [] -> ()
  | (_, i)::outs ->
    (
      let ((v:instr_val_t i), (vs:instr_ret_t outs)) =
        match outs with
        | [] -> (vs, ())
        | _::_ -> let vs = coerce vs in (fst vs, snd vs)
      in
      match i with
      | IOpEx i ->
        let oprs = coerce oprs in
        let s1 = instr_write_output_explicit i v (fst oprs) s_orig1 s1 in
        let s2 = instr_write_output_explicit i v (fst oprs) s_orig2 s2 in
        assert (equiv_states_ext s1 s2);
        lemma_instr_write_outputs_equiv_states outs args vs (snd oprs) s_orig1 s1 s_orig2 s2
      | IOpIm i ->
        lemma_instr_write_output_implicit_equiv_states i v s_orig1 s1 s_orig2 s2;
        let s1 = instr_write_output_implicit i v s_orig1 s1 in
        let s2 = instr_write_output_implicit i v s_orig2 s2 in
        lemma_instr_write_outputs_equiv_states outs args vs (coerce oprs) s_orig1 s1 s_orig2 s2
    )

let lemma_eval_instr_equiv_states
    (it:instr_t_record) (oprs:instr_operands_t it.outs it.args) (ann:instr_annotation it)
    (s1 s2:machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        equiv_ostates
          (eval_instr it oprs ann s1)
          (eval_instr it oprs ann s2))) =
  let InstrTypeRecord #outs #args #havoc_flags i = it in
  let vs1 = instr_apply_eval outs args (instr_eval i) oprs s1 in
  let vs2 = instr_apply_eval outs args (instr_eval i) oprs s2 in
  lemma_instr_apply_eval_inouts_equiv_states outs outs args (instr_eval i) oprs s1 s2;
  assert (vs1 == vs2);
  let s1_new =
    match havoc_flags with
    | HavocFlags -> {s1 with ms_flags = havoc_state_ins s1 (Instr it oprs ann)}
    | PreserveFlags -> s1
  in
  let s2_new =
    match havoc_flags with
    | HavocFlags -> {s2 with ms_flags = havoc_state_ins s2 (Instr it oprs ann)}
    | PreserveFlags -> s2
  in
  assert (equiv_states s1_new s2_new);
  let os1 = FStar.Option.mapTot (fun vs -> instr_write_outputs outs args vs oprs s1 s1_new) vs1 in
  let os2 = FStar.Option.mapTot (fun vs -> instr_write_outputs outs args vs oprs s2 s2_new) vs2 in
  match vs1 with
  | None -> ()
  | Some vs ->
    lemma_instr_write_outputs_equiv_states outs args vs oprs s1 s1_new s2 s2_new

(* REVIEW: This proof is INSANELY annoying to deal with due to the [Pop].

   TODO: Figure out why it is slowing down so much. It practically
         brings F* to a standstill even when editing, and it acts
         worse during an interactive proof. *)
let lemma_untainted_eval_ins_equiv_states (i : ins) (s1 s2 : machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        equiv_states
          (run (untainted_eval_ins i) s1)
          (run (untainted_eval_ins i) s2))) =
  let s1_orig, s2_orig = s1, s2 in
  let s1_final = run (untainted_eval_ins i) s1 in
  let s2_final = run (untainted_eval_ins i) s2 in
  match i with
  | Instr it oprs ann ->
    lemma_eval_instr_equiv_states it oprs ann s1 s2
  | Push _ _ ->
    assert_spinoff (equiv_states_ext s1_final s2_final)
  | Pop dst t ->
    let stack_op = OStack (MReg rRsp 0, t) in
    let s1 = proof_run s1 (check (valid_src_operand stack_op)) in
    let s2 = proof_run s2 (check (valid_src_operand stack_op)) in
    // assert (equiv_states s1 s2);
    let new_dst1 = eval_operand stack_op s1 in
    let new_dst2 = eval_operand stack_op s2 in
    // assert (new_dst1 == new_dst2);
    let new_rsp1 = (eval_reg rRsp s1 + 8) % pow2_64 in
    let new_rsp2 = (eval_reg rRsp s2 + 8) % pow2_64 in
    // assert (new_rsp1 == new_rsp2);
    let s1 = proof_run s1 (update_operand_preserve_flags dst new_dst1) in
    let s2 = proof_run s2 (update_operand_preserve_flags dst new_dst2) in
    assert (equiv_states_ext s1 s2);
    let s1 = proof_run s1 (free_stack (new_rsp1 - 8) new_rsp1) in
    let s2 = proof_run s2 (free_stack (new_rsp2 - 8) new_rsp2) in
    // assert (equiv_states s1 s2);
    let s1 = proof_run s1 (update_rsp new_rsp1) in
    let s2 = proof_run s2 (update_rsp new_rsp2) in
    assert (equiv_states_ext s1 s2);
    assert_spinoff (equiv_states s1_final s2_final)
  | Alloc _ ->
    assert_spinoff (equiv_states_ext s1_final s2_final)
  | Dealloc _ ->
    assert_spinoff (equiv_states_ext s1_final s2_final)

let rec lemma_taint_match_args_equiv_states
    (args:list instr_operand)
    (oprs:instr_operands_t_args args)
    (memTaint:memTaint_t)
    (stackTaint:memTaint_t)
    (s1 s2:machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        (taint_match_args args oprs memTaint stackTaint s1) ==
        (taint_match_args args oprs memTaint stackTaint s2))) =
  match args with
  | [] -> ()
  | i :: args ->
    match i with
    | IOpEx i ->
      let oprs : instr_operand_t i & instr_operands_t_args args = coerce oprs in
      lemma_taint_match_args_equiv_states args (snd oprs) memTaint stackTaint s1 s2
    | IOpIm i ->
      lemma_taint_match_args_equiv_states args (coerce oprs) memTaint stackTaint s1 s2

let rec lemma_taint_match_inouts_equiv_states
    (inouts:list instr_out)
    (args:list instr_operand)
    (oprs:instr_operands_t inouts args)
    (memTaint:memTaint_t)
    (stackTaint:memTaint_t)
    (s1 s2:machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        (taint_match_inouts inouts args oprs memTaint stackTaint s1) ==
        (taint_match_inouts inouts args oprs memTaint stackTaint s2))) =
  match inouts with
  | [] -> lemma_taint_match_args_equiv_states args oprs memTaint stackTaint s1 s2
  | (Out, i) :: inouts ->
    let oprs =
      match i with
      | IOpEx i -> snd #(instr_operand_t i) (coerce oprs)
      | IOpIm i -> coerce oprs
    in
    lemma_taint_match_inouts_equiv_states inouts args oprs memTaint stackTaint s1 s2
  | (InOut, i)::inouts ->
    let (v, oprs) =
      match i with
      | IOpEx i ->
        let oprs = coerce oprs in
        (taint_match_operand_explicit i (fst oprs) memTaint stackTaint s1, snd oprs)
      | IOpIm i -> (taint_match_operand_implicit i memTaint stackTaint s1, coerce oprs)
    in
    lemma_taint_match_inouts_equiv_states inouts args oprs memTaint stackTaint s1 s2

let lemma_taint_match_ins_equiv_states (i : ins) (s1 s2 : machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        (taint_match_ins i s1.ms_memTaint s1.ms_stackTaint s1) ==
        (taint_match_ins i s2.ms_memTaint s2.ms_stackTaint s2))) =
  match i with
  | Instr (InstrTypeRecord #outs #args _) oprs _ ->
    assert (s1.ms_memTaint == s2.ms_memTaint);
    assert (s1.ms_stackTaint == s2.ms_stackTaint);
    lemma_taint_match_inouts_equiv_states outs args oprs s1.ms_memTaint s1.ms_stackTaint s1 s2
  | Push _ _ | Pop _ _ | Alloc _ | Dealloc _ -> ()

let rec lemma_update_taint_outputs_equiv_states
    (outs:list instr_out) (args:list instr_operand) (oprs:instr_operands_t outs args)
    (memTaint:memTaint_t) (stackTaint:memTaint_t)
    (s1 s2:machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        (update_taint_outputs outs args oprs memTaint stackTaint s1) ==
        (update_taint_outputs outs args oprs memTaint stackTaint s2))) =
  match outs with
  | [] -> ()
  | (_, i) :: outs ->
    let ((memTaint, stackTaint), oprs) =
      match i with
      | IOpEx i ->
        let oprs = coerce oprs in
        (update_taint_operand_explicit i (fst oprs) memTaint stackTaint s1, snd oprs)
      | IOpIm i -> (update_taint_operand_implicit i memTaint stackTaint s1, coerce oprs)
    in
    lemma_update_taint_outputs_equiv_states outs args oprs memTaint stackTaint s1 s2

let lemma_update_taint_ins_equiv_states
    (i : ins)
    (memTaint:memTaint_t)
    (stackTaint:memTaint_t)
    (s1 s2:machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        (update_taint_ins i memTaint stackTaint s1) ==
        (update_taint_ins i memTaint stackTaint s2))) =
  match i with
  | Instr (InstrTypeRecord #outs #args _) oprs _ ->
    lemma_update_taint_outputs_equiv_states outs args oprs memTaint stackTaint s1 s2
  | Push _ _ | Pop _ _ | Alloc _ | Dealloc _ -> ()

let lemma_eval_ins_equiv_states (i : ins) (s1 s2 : machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        equiv_states
          (machine_eval_ins i s1)
          (machine_eval_ins i s2))) =
  let s10 = run (check (taint_match_ins i s1.ms_memTaint s1.ms_stackTaint)) s1 in
  let s20 = run (check (taint_match_ins i s2.ms_memTaint s2.ms_stackTaint)) s2 in
  lemma_taint_match_ins_equiv_states i s1 s2;
  assert (equiv_states s10 s20);
  let memTaint1, stackTaint1 = update_taint_ins i s1.ms_memTaint s1.ms_stackTaint s10 in
  let memTaint2, stackTaint2 = update_taint_ins i s2.ms_memTaint s2.ms_stackTaint s20 in
  lemma_update_taint_ins_equiv_states i s1.ms_memTaint s2.ms_stackTaint s10 s20;
  assert (memTaint1 == memTaint2);
  assert (stackTaint1 == stackTaint2);
  let s11 = run (untainted_eval_ins i) s10 in
  let s21 = run (untainted_eval_ins i) s20 in
  lemma_untainted_eval_ins_equiv_states i s10 s20;
  let s12 = { s11 with ms_memTaint = memTaint1 ; ms_stackTaint = stackTaint1 } in
  let s22 = { s21 with ms_memTaint = memTaint2 ; ms_stackTaint = stackTaint2 } in
  assert (equiv_states s12 s22)

(** Filter out observation related stuff from the state.

    REVIEW: Figure out _why_ all the taint analysis related stuff is
    part of the core semantics of x64, rather than being separated
    out. *)
let filt_state (s:machine_state) =
  { s with
    ms_trace = [] }

let rec lemma_eval_code_equiv_states (c : code) (fuel:nat) (s1 s2 : machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        let s1'', s2'' =
          machine_eval_code c fuel s1,
          machine_eval_code c fuel s2 in
        equiv_ostates s1'' s2''))
    (decreases %[fuel; c; 1]) =
  match c with
  | Ins ins ->
    lemma_eval_ins_equiv_states ins (filt_state s1) (filt_state s2)
  | Block l ->
    lemma_eval_codes_equiv_states l fuel s1 s2
  | IfElse ifCond ifTrue ifFalse ->
    let (st1, b1) = machine_eval_ocmp s1 ifCond in
    let (st2, b2) = machine_eval_ocmp s2 ifCond in
    assert (equiv_states st1 st2);
    assert (b1 == b2);
    let s1' = { st1 with ms_trace = (BranchPredicate b1) :: s1.ms_trace } in
    let s2' = { st2 with ms_trace = (BranchPredicate b2) :: s2.ms_trace } in
    assert (equiv_states s1' s2');
    if b1 then (
      lemma_eval_code_equiv_states ifTrue fuel s1' s2'
    ) else (
      lemma_eval_code_equiv_states ifFalse fuel s1' s2'
    )
  | While _ _ ->
    lemma_eval_while_equiv_states c fuel s1 s2

and lemma_eval_codes_equiv_states (cs : codes) (fuel:nat) (s1 s2 : machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        let s1'', s2'' =
          machine_eval_codes cs fuel s1,
          machine_eval_codes cs fuel s2 in
        equiv_ostates s1'' s2''))
    (decreases %[fuel; cs]) =
  match cs with
  | [] -> ()
  | c :: cs ->
    lemma_eval_code_equiv_states c fuel s1 s2;
    let s1'', s2'' =
      machine_eval_code c fuel s1,
      machine_eval_code c fuel s2 in
    match s1'' with
    | None -> ()
    | _ ->
      let Some s1, Some s2 = s1'', s2'' in
      lemma_eval_codes_equiv_states cs fuel s1 s2

and lemma_eval_while_equiv_states (c : code{While? c}) (fuel:nat) (s1 s2:machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        equiv_ostates
          (machine_eval_while c fuel s1)
          (machine_eval_while c fuel s2)))
    (decreases %[fuel; c; 0]) =
  if fuel = 0 then () else (
    let While cond body = c in
    let (s1, b1) = machine_eval_ocmp s1 cond in
    let (s2, b2) = machine_eval_ocmp s2 cond in
    assert (equiv_states s1 s2);
    assert (b1 == b2);
    if not b1 then () else (
      let s1 = { s1 with ms_trace = (BranchPredicate true) :: s1.ms_trace } in
      let s2 = { s2 with ms_trace = (BranchPredicate true) :: s2.ms_trace } in
      assert (equiv_states s1 s2);
      let s_opt1 = machine_eval_code body (fuel - 1) s1 in
      let s_opt2 = machine_eval_code body (fuel - 1) s2 in
      lemma_eval_code_equiv_states body (fuel - 1) s1 s2;
      assert (equiv_ostates s_opt1 s_opt2);
      match s_opt1 with
      | None -> ()
      | Some _ ->
        let Some s1, Some s2 = s_opt1, s_opt2 in
        if s1.ms_ok then (
          lemma_eval_while_equiv_states c (fuel - 1) s1 s2
        ) else ()
    )
  )

/// If an exchange is allowed between two instructions based off of
/// their read/write sets, then both orderings of the two instructions
/// behave exactly the same, as per the previously defined
/// [equiv_states] relation.

let lemma_instruction_exchange' (i1 i2 : ins) (s1 s2 : machine_state) :
  Lemma
    (requires (
        !!(ins_exchange_allowed i1 i2) /\
        (equiv_states s1 s2)))
    (ensures (
        (let s1', s2' =
           machine_eval_ins i2 (machine_eval_ins i1 s1),
           machine_eval_ins i1 (machine_eval_ins i2 s2) in
         equiv_states s1' s2'))) =
  admit ()

let lemma_instruction_exchange (i1 i2 : ins) (s1 s2 : machine_state) :
  Lemma
    (requires (
        !!(ins_exchange_allowed i1 i2) /\
        (equiv_states s1 s2)))
    (ensures (
        (let s1', s2' =
           machine_eval_ins i2 (filt_state (machine_eval_ins i1 (filt_state s1))),
           machine_eval_ins i1 (filt_state (machine_eval_ins i2 (filt_state s2))) in
         equiv_states s1' s2'))) =
  lemma_eval_ins_equiv_states i1 s1 (filt_state s1);
  lemma_eval_ins_equiv_states i2 s2 (filt_state s2);
  lemma_eval_ins_equiv_states i2 (machine_eval_ins i1 (filt_state s1)) (filt_state (machine_eval_ins i1 (filt_state s1)));
  lemma_eval_ins_equiv_states i1 (machine_eval_ins i2 (filt_state s2)) (filt_state (machine_eval_ins i2 (filt_state s2)));
  lemma_eval_ins_equiv_states i2 (machine_eval_ins i1 s1) (machine_eval_ins i1 (filt_state s1));
  lemma_eval_ins_equiv_states i1 (machine_eval_ins i2 s2) (machine_eval_ins i2 (filt_state s2));
  lemma_instruction_exchange' i1 i2 s1 s2

/// Given that we can perform simple swaps between instructions, we
/// can do swaps between [code]s.

let code_exchange_allowed (c1 c2:code) : pbool =
  match c1, c2 with
  | Ins i1, Ins i2 -> ins_exchange_allowed i1 i2
  | _ -> ffalse "non instruction swaps conservatively disallowed"

let lemma_code_exchange (c1 c2 : code) (fuel:nat) (s1 s2 : machine_state) :
  Lemma
    (requires (
        !!(code_exchange_allowed c1 c2) /\
        (equiv_states s1 s2) /\
        (Some? (machine_eval_codes [c1; c2] fuel s1))))
    (ensures (
        (Some? (machine_eval_codes [c2; c1] fuel s2)) /\
        (let Some s1', Some s2' =
           machine_eval_codes [c1; c2] fuel s1,
           machine_eval_codes [c2; c1] fuel s2 in
         equiv_states s1' s2'))) =
  let Some s1', Some s2' =
    machine_eval_codes [c1; c2] fuel s1,
    machine_eval_codes [c2; c1] fuel s2 in
  match c1, c2 with
  | Ins i1, Ins i2 ->
    let Some s10 = machine_eval_code c1 fuel s1 in
    let Some s11 = machine_eval_code c1 fuel (filt_state s1) in
    // assert_norm (equiv_states s10 s11);
    // assert_norm (equiv_states (machine_eval_ins i1 (filt_state s1)) s11);
    let Some s12 = machine_eval_code c2 fuel (machine_eval_ins i1 (filt_state s1)) in
    // assert_norm (equiv_states s1' s12);
    let Some s13 = machine_eval_code c2 fuel (filt_state (machine_eval_ins i1 (filt_state s1))) in
    // assert_norm (equiv_states s12 s13);
    let s14 = machine_eval_ins i2 (filt_state (machine_eval_ins i1 (filt_state s1))) in
    // assert_norm (equiv_states s13 s14);
    assert_norm (equiv_states s1' s14);
    let Some s20 = machine_eval_code c2 fuel s2 in
    let Some s21 = machine_eval_code c2 fuel (filt_state s2) in
    // assert_norm (equiv_states s20 s21);
    // assert_norm (equiv_states (machine_eval_ins i2 (filt_state s2)) s21);
    let Some s22 = machine_eval_code c1 fuel (machine_eval_ins i2 (filt_state s2)) in
    // assert_norm (equiv_states s2' s22);
    let Some s23 = machine_eval_code c1 fuel (filt_state (machine_eval_ins i2 (filt_state s2))) in
    // assert_norm (equiv_states s22 s23);
    let s24 = machine_eval_ins i1 (filt_state (machine_eval_ins i2 (filt_state s2))) in
    // assert_norm (equiv_states s23 s24);
    assert_norm (equiv_states s2' s24);
    lemma_instruction_exchange i1 i2 s1 s2;
    assert (equiv_states s14 s24);
    sanity_check_equiv_states s1' s14 s24;
    sanity_check_equiv_states s1' s24 s2';
    assert (equiv_states s1' s2')
  | _ -> ()

/// Given that we can perform simple swaps between [code]s, we can
/// define a relation that tells us if some [codes] can be transformed
/// into another using only allowed swaps.

(* WARNING UNSOUND We need to figure out a way to check for equality
   between [code]s *)
assume val eq_code (c1 c2 : code) : (b:bool{b <==> c1 == c2})

let rec find_code (c1:code) (cs2:codes) : possibly (i:nat{i < L.length cs2 /\ c1 == L.index cs2 i}) =
  match cs2 with
  | [] -> Err ("Not found: " ^ fst (print_code c1 0 gcc))
  | h2 :: t2 ->
    if eq_code c1 h2 then (
      return 0
    ) else (
      match find_code c1 t2 with
      | Err reason -> Err reason
      | Ok i ->
        return (i+1)
    )

let rec bubble_to_top (cs:codes) (i:nat{i < L.length cs}) : possibly (cs':codes{
    let a, b, c = L.split3 cs i in
    cs' == L.append a c
  }) =
  match cs with
  | [_] -> return []
  | h :: t ->
    let x = L.index cs i in
    if i = 0 then (
      return t
    ) else (
      match bubble_to_top t (i - 1) with
      | Err reason -> Err reason
      | Ok res ->
        match code_exchange_allowed x h with
        | Err reason -> Err reason
        | Ok () ->
          return (h :: res)
    )

let rec reordering_allowed (c1 c2 : codes) : pbool =
  match c1, c2 with
  | [], [] -> ttrue
  | [], _ | _, [] -> ffalse "disagreeing lengths of codes"
  | h1 :: t1, _ ->
    i <-- find_code h1 c2;
    t2 <-- bubble_to_top c2 i;
    (* TODO: Also check _inside_ blocks/ifelse/etc rather than just at the highest level *)
    reordering_allowed t1 t2

/// If there are two sequences of instructions that can be transformed
/// amongst each other, then they behave identically as per the
/// [equiv_states] relation.

let rec lemma_bubble_to_top (cs : codes) (i:nat{i < L.length cs}) (fuel:nat) (s : machine_state)
    (x : _{x == L.index cs i}) (xs : _{Ok xs == bubble_to_top cs i})
    (s_0 : _{Some s_0 == machine_eval_code x fuel s})
    (s_1 : _{Some s_1 == machine_eval_codes xs fuel s_0}) :
  Lemma
    (ensures (
        let s_final' = machine_eval_codes cs fuel s in
        equiv_ostates' s_1 s_final')) =
  let s_final' = machine_eval_codes cs fuel s in
  match i with
  | 0 -> ()
  | _ ->
    assert !!(code_exchange_allowed x (L.hd cs));
    lemma_code_exchange x (L.hd cs) fuel s s;
    let Ok tlxs = bubble_to_top (L.tl cs) (i - 1) in
    assert (L.tl xs == tlxs);
    assert (L.hd xs == L.hd cs);
    let Some s_start = machine_eval_code (L.hd cs) fuel s in
    let Some s_0' = machine_eval_code x fuel s_start in
    let Some s_0'' = machine_eval_code (L.hd cs) fuel (Some?.v (machine_eval_code x fuel s)) in
    assert (equiv_states s_0' s_0'');
    lemma_eval_codes_equiv_states tlxs fuel s_0' s_0'';
    let Some s_1' = machine_eval_codes tlxs fuel s_0' in
    lemma_bubble_to_top (L.tl cs) (i - 1) fuel s_start x tlxs s_0' s_1'

let rec lemma_reordering (c1 c2 : codes) (fuel:nat) (s1 s2 : machine_state) :
  Lemma
    (requires (
        !!(reordering_allowed c1 c2) /\
        (equiv_states s1 s2) /\
        (Some? (machine_eval_codes c1 fuel s1))))
    (ensures (
        (Some? (machine_eval_codes c2 fuel s2)) /\
        (let Some s1', Some s2' =
           machine_eval_codes c1 fuel s1,
           machine_eval_codes c2 fuel s2 in
         equiv_states s1' s2'))) =
  match c1 with
  | [] -> ()
  | h1 :: t1 ->
    let Ok i = find_code h1 c2 in
    let Ok t2 = bubble_to_top c2 i in
    lemma_eval_code_equiv_states h1 fuel s1 s2;
    lemma_reordering t1 t2 fuel (Some?.v (machine_eval_code h1 fuel s1)) (Some?.v (machine_eval_code h1 fuel s2));
    let Some s_0 = machine_eval_code h1 fuel s2 in
    let Some s_1 = machine_eval_codes t2 fuel s_0 in
    lemma_bubble_to_top c2 i fuel s2 h1 t2 s_0 s_1