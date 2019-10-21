(**

   This module defines a transformer that eliminates movbe
   instructions, and replaces them with movs and bswaps.

*)
module Vale.Transformers.MovbeElimination


/// Open all the relevant modules

open Vale.X64.Bytes_Code_s
open Vale.X64.Instruction_s
open Vale.X64.Instructions_s
open Vale.X64.Machine_Semantics_s
open Vale.X64.Machine_s
open Vale.X64.Print_s

module L = FStar.List.Tot

open Vale.Transformers.InstructionReorder // open so that we don't
                                          // need to redefine things
                                          // equivalence etc.

open Vale.X64.InsLemmas

let coerce_to_normal (#a:Type0) (x:a) : y:(normal a){x == y} = x

let rec replace_movbe_in_code (c:code) : code =
  match c with
  | Ins (Instr i oprs (AnnotateMovbe64 proof_of_movbe)) ->
    let oprs:normal (instr_operands_t [out op64] [op64]) =
      coerce_to_normal #(instr_operands_t [out op64] [op64]) oprs in
    let (dst, (src, ())) = oprs in
    Block [
      Ins (make_instr ins_Mov64 dst src);
      Ins (make_instr ins_Bswap64 dst);
    ]
  | Ins i -> Ins i
  | Block l -> Block (replace_movbe_in_codes l)
  | IfElse c t f -> IfElse c (replace_movbe_in_code t) (replace_movbe_in_code f)
  | While c b -> While c (replace_movbe_in_code b)

and replace_movbe_in_codes (c:codes) : codes =
  match c with
  | [] -> []
  | x :: xs ->
    replace_movbe_in_code x :: replace_movbe_in_codes xs

let lemma_movbe_is_mov_bswap_ins (i:ins{Instr? i}) (s:machine_state) :
  Lemma
    (requires (
        let Instr _ _ ann = i in
        AnnotateMovbe64? ann))
    (ensures (
        let Instr _ oprs (AnnotateMovbe64 proof_of_movbe) = i in
        let oprs:normal (instr_operands_t [out op64] [op64]) =
          coerce_to_normal #(instr_operands_t [out op64] [op64]) oprs in
        let (dst, (src, ())) = oprs in
        machine_eval_ins (make_instr ins_Bswap64 dst) (
          machine_eval_ins (make_instr ins_Mov64 dst src) s) ==
        machine_eval_ins i s)) =
  admit ()

#push-options "--initial_fuel 3 --max_fuel 3 --initial_ifuel 0 --max_ifuel 0"
let lemma_merge_mov_bswap dst src fuel (s:machine_state) :
  Lemma
    (ensures (
        let i1 = make_instr ins_Mov64 dst src in
        let i2 = make_instr ins_Bswap64 dst in
        let s_opt = machine_eval_code (Block [Ins i1; Ins i2]) fuel s in
        (Some? s_opt) /\
        (machine_eval_ins i2 (machine_eval_ins i1 ({s with ms_trace = []}))) ==
        {Some?.v s_opt with ms_trace = []})) =
  let i1 = make_instr ins_Mov64 dst src in
  let i2 = make_instr ins_Bswap64 dst in
  let s_opt = machine_eval_code (Block [Ins i1; Ins i2]) fuel s in
  assert_norm (Some? s_opt);
  let Some s1 = s_opt in
  let s2 = {s1 with ms_trace = []} in
  let s0 = {s with ms_trace = []} in
  let sopt1 = machine_eval_code (Ins i1) fuel s in
  assert_norm (Some? sopt1);
  let Some s11 = sopt1 in
  let sopt2 = machine_eval_code (Ins i2) fuel s11 in
  assert_norm (Some? sopt2);
  let Some s12 = sopt2 in
  assert (sopt2 == machine_eval_codes [Ins i1; Ins i2] fuel s);
  assert (sopt2 == s_opt);
  let o1 = ins_obs i1 s in
  let o2 = ins_obs i2 s11 in
  assert (s11 == {machine_eval_ins i1 s0 with ms_trace = o1 @ s.ms_trace});
  assert ({s11 with ms_trace = []} == {machine_eval_ins i1 s0 with ms_trace = []});
  assert ({s11 with ms_trace = []} == machine_eval_ins i1 s0);
  assert (machine_eval_ins i2 ({s11 with ms_trace = []}) == machine_eval_ins i2 (machine_eval_ins i1 s0));
  assert ({s12 with ms_trace = []} == machine_eval_ins i2 (machine_eval_ins i1 s0))
#pop-options

#push-options "--initial_fuel 3 --max_fuel 8 --initial_ifuel 0 --max_ifuel 2"
let lemma_replace_movbe_specifically (i:ins{Instr? i}) (fuel:nat) (s:machine_state) :
  Lemma
    (requires (
        let Instr _ _ ann = i in
        AnnotateMovbe64? ann))
    (ensures (
        let c = Ins i in
        let c' = replace_movbe_in_code c in
        equiv_ostates
          (machine_eval_code c fuel s)
          (machine_eval_code c' fuel s))) =
  let ins = i in
  let c = Ins i in
  let c' = replace_movbe_in_code c in
  let Instr i oprs (AnnotateMovbe64 proof_of_movbe) = i in
  let oprs:normal (instr_operands_t [out op64] [op64]) =
    coerce_to_normal #(instr_operands_t [out op64] [op64]) oprs in
  let (dst, (src, ())) = oprs in
  let ins_mov = make_instr ins_Mov64 dst src in
  let ins_bswap = make_instr ins_Bswap64 dst in
  assert (replace_movbe_in_code c == Block [Ins ins_mov; Ins ins_bswap]);
  let Some s1 = machine_eval_code c fuel s in
  let s2_opt = machine_eval_code (replace_movbe_in_code c) fuel s in
  assert_norm (Some? s2_opt); (* OBSERVE *)
  let Some s2 = s2_opt in
  let s_a = {s with ms_trace = []} in
  lemma_movbe_is_mov_bswap_ins ins s;
  lemma_merge_mov_bswap dst src fuel s;
  admit ();
  // let ob1 = ins_obs ins s in
  // assert (s1 == {machine_eval_ins ins s_a with ms_trace = ob1 @ s.ms_trace});
  // assert (s1 == {machine_eval_ins (make_instr ins_Bswap64 dst) (
  //     machine_eval_ins (make_instr ins_Mov64 dst src) s_a) with ms_trace = ob1 @ s.ms_trace});
  // let ob21 = ins_obs ins_mov s in
  // let s_b = {machine_eval_ins ins_mov s_a with ms_trace = ob21 @ s.ms_trace} in
  // let ob22 = ins_obs ins_bswap s_b in
  // let s_c = {s_b with ms_trace = []} in
  // assert (s_c == machine_eval_ins ins_mov s_a);
  // let s_d = {machine_eval_ins ins_bswap s_c with ms_trace = ob22 @ s_b.ms_trace} in
  // admit ();
  // // assert_norm (s_d == s2);
  // admit () (* TODO:FIXME *)
  ()
#pop-options

#push-options "--initial_fuel 2 --max_fuel 2 --initial_ifuel 1 --max_ifuel 1"
let rec lemma_replace_movbe_in_code (c:code) (fuel:nat) (s:machine_state) :
  Lemma
    (ensures (
        let c' = replace_movbe_in_code c in
        equiv_ostates
          (machine_eval_code c fuel s)
          (machine_eval_code c' fuel s)))
    (decreases %[fuel; c; 1]) =
  match c with
  | Ins (Instr i oprs (AnnotateMovbe64 proof_of_movbe)) ->
    lemma_replace_movbe_specifically (Instr i oprs (AnnotateMovbe64 proof_of_movbe)) fuel s
  | Ins i -> ()
  | Block l -> lemma_replace_movbe_in_codes l fuel s
  | IfElse c t f ->
    let (st, b) = machine_eval_ocmp s c in
    let s' = {st with ms_trace = (BranchPredicate b)::s.ms_trace} in
    if b then lemma_replace_movbe_in_code t fuel s' else lemma_replace_movbe_in_code f fuel s'
  | While _ _ ->
    lemma_replace_movbe_in_while c fuel s

and lemma_replace_movbe_in_codes (cs:codes) (fuel:nat) (s:machine_state) :
  Lemma
    (ensures (
        let cs' = replace_movbe_in_codes cs in
        equiv_ostates
          (machine_eval_codes cs fuel s)
          (machine_eval_codes cs' fuel s)))
    (decreases %[fuel; cs]) =
  match cs with
  | [] -> ()
  | x :: xs ->
    lemma_replace_movbe_in_code x fuel s;
    match machine_eval_code x fuel s with
    | None -> ()
    | Some s' ->
      let Some s'' = machine_eval_code (replace_movbe_in_code x) fuel s in
      lemma_eval_codes_equiv_states (replace_movbe_in_codes xs) fuel s' s'';
      lemma_replace_movbe_in_codes xs fuel s'

and lemma_replace_movbe_in_while (c:code{While? c}) (fuel:nat) (s:machine_state) :
  Lemma
    (ensures (
        let c' = replace_movbe_in_code c in
        equiv_ostates
          (machine_eval_code c fuel s)
          (machine_eval_code c' fuel s)))
    (decreases %[fuel; c; 0]) =
  if fuel = 0 then () else (
    let While cond body = c in
    let (s, b) = machine_eval_ocmp s cond in
    if not b then () else (
      let s = { s with ms_trace = (BranchPredicate true) :: s.ms_trace } in
      lemma_replace_movbe_in_code body (fuel - 1) s;
      let s_opt1 = machine_eval_code body (fuel - 1) s in
      let s_opt2 = machine_eval_code (replace_movbe_in_code body) (fuel - 1) s in
      assert (equiv_ostates s_opt1 s_opt2);
      match s_opt1 with
      | None -> ()
      | Some _ ->
        let Some s1, Some s2 = s_opt1, s_opt2 in
        if s1.ms_ok then (
          lemma_replace_movbe_in_while c (fuel - 1) s1;
          lemma_replace_movbe_in_while (replace_movbe_in_code c) (fuel - 1) s2;
          lemma_eval_code_equiv_states (replace_movbe_in_code c) (fuel - 1) s1 s2
        ) else ()
    )
  )
#pop-options