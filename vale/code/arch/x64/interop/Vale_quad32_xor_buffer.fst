module Vale_quad32_xor_buffer

open X64.Machine_s
open X64.Memory
open X64.Vale.State
open X64.Vale.Decls
open X64.Util

val va_code_quad32_xor_buffer: bool -> va_code

let va_code_quad32_xor_buffer = va_code_quad32_xor_buffer

//va_pre and va_post should correspond to the pre- and postconditions generated by Vale
let va_pre (va_b0:va_code) (va_s0:va_state) (win:bool) (stack_b:buffer64)
(src1:buffer128) (src2:buffer128) (dst:buffer128)  = va_req_quad32_xor_buffer va_b0 va_s0 win stack_b src1 src2 dst 

let va_post (va_b0:va_code) (va_s0:va_state) (va_sM:va_state) (va_fM:va_fuel) (win:bool)  (stack_b:buffer64)
(src1:buffer128) (src2:buffer128) (dst:buffer128)  = va_ens_quad32_xor_buffer va_b0 va_s0 win stack_b src1 src2 dst va_sM va_fM

val va_lemma_quad32_xor_buffer(va_b0:va_code) (va_s0:va_state) (win:bool) (stack_b:buffer64)
(src1:buffer128) (src2:buffer128) (dst:buffer128) : Ghost ((va_sM:va_state) * (va_fM:va_fuel))
  (requires va_pre va_b0 va_s0 win stack_b src1 src2 dst )
  (ensures (fun (va_sM, va_fM) -> va_post va_b0 va_s0 va_sM va_fM win stack_b src1 src2 dst ))

let va_lemma_quad32_xor_buffer = va_lemma_quad32_xor_buffer
