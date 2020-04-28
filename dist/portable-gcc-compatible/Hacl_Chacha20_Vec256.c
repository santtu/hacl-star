/* MIT License
 *
 * Copyright (c) 2016-2020 INRIA, CMU and Microsoft Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


#include "Hacl_Chacha20_Vec256.h"

/* SNIPPET_START: double_round_256 */

static inline void double_round_256(Lib_IntVector_Intrinsics_vec256 *st)
{
  st[0U] = Lib_IntVector_Intrinsics_vec256_add32(st[0U], st[4U]);
  Lib_IntVector_Intrinsics_vec256 std = Lib_IntVector_Intrinsics_vec256_xor(st[12U], st[0U]);
  st[12U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std, (uint32_t)16U);
  st[8U] = Lib_IntVector_Intrinsics_vec256_add32(st[8U], st[12U]);
  Lib_IntVector_Intrinsics_vec256 std0 = Lib_IntVector_Intrinsics_vec256_xor(st[4U], st[8U]);
  st[4U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std0, (uint32_t)12U);
  st[0U] = Lib_IntVector_Intrinsics_vec256_add32(st[0U], st[4U]);
  Lib_IntVector_Intrinsics_vec256 std1 = Lib_IntVector_Intrinsics_vec256_xor(st[12U], st[0U]);
  st[12U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std1, (uint32_t)8U);
  st[8U] = Lib_IntVector_Intrinsics_vec256_add32(st[8U], st[12U]);
  Lib_IntVector_Intrinsics_vec256 std2 = Lib_IntVector_Intrinsics_vec256_xor(st[4U], st[8U]);
  st[4U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std2, (uint32_t)7U);
  st[1U] = Lib_IntVector_Intrinsics_vec256_add32(st[1U], st[5U]);
  Lib_IntVector_Intrinsics_vec256 std3 = Lib_IntVector_Intrinsics_vec256_xor(st[13U], st[1U]);
  st[13U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std3, (uint32_t)16U);
  st[9U] = Lib_IntVector_Intrinsics_vec256_add32(st[9U], st[13U]);
  Lib_IntVector_Intrinsics_vec256 std4 = Lib_IntVector_Intrinsics_vec256_xor(st[5U], st[9U]);
  st[5U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std4, (uint32_t)12U);
  st[1U] = Lib_IntVector_Intrinsics_vec256_add32(st[1U], st[5U]);
  Lib_IntVector_Intrinsics_vec256 std5 = Lib_IntVector_Intrinsics_vec256_xor(st[13U], st[1U]);
  st[13U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std5, (uint32_t)8U);
  st[9U] = Lib_IntVector_Intrinsics_vec256_add32(st[9U], st[13U]);
  Lib_IntVector_Intrinsics_vec256 std6 = Lib_IntVector_Intrinsics_vec256_xor(st[5U], st[9U]);
  st[5U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std6, (uint32_t)7U);
  st[2U] = Lib_IntVector_Intrinsics_vec256_add32(st[2U], st[6U]);
  Lib_IntVector_Intrinsics_vec256 std7 = Lib_IntVector_Intrinsics_vec256_xor(st[14U], st[2U]);
  st[14U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std7, (uint32_t)16U);
  st[10U] = Lib_IntVector_Intrinsics_vec256_add32(st[10U], st[14U]);
  Lib_IntVector_Intrinsics_vec256 std8 = Lib_IntVector_Intrinsics_vec256_xor(st[6U], st[10U]);
  st[6U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std8, (uint32_t)12U);
  st[2U] = Lib_IntVector_Intrinsics_vec256_add32(st[2U], st[6U]);
  Lib_IntVector_Intrinsics_vec256 std9 = Lib_IntVector_Intrinsics_vec256_xor(st[14U], st[2U]);
  st[14U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std9, (uint32_t)8U);
  st[10U] = Lib_IntVector_Intrinsics_vec256_add32(st[10U], st[14U]);
  Lib_IntVector_Intrinsics_vec256 std10 = Lib_IntVector_Intrinsics_vec256_xor(st[6U], st[10U]);
  st[6U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std10, (uint32_t)7U);
  st[3U] = Lib_IntVector_Intrinsics_vec256_add32(st[3U], st[7U]);
  Lib_IntVector_Intrinsics_vec256 std11 = Lib_IntVector_Intrinsics_vec256_xor(st[15U], st[3U]);
  st[15U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std11, (uint32_t)16U);
  st[11U] = Lib_IntVector_Intrinsics_vec256_add32(st[11U], st[15U]);
  Lib_IntVector_Intrinsics_vec256 std12 = Lib_IntVector_Intrinsics_vec256_xor(st[7U], st[11U]);
  st[7U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std12, (uint32_t)12U);
  st[3U] = Lib_IntVector_Intrinsics_vec256_add32(st[3U], st[7U]);
  Lib_IntVector_Intrinsics_vec256 std13 = Lib_IntVector_Intrinsics_vec256_xor(st[15U], st[3U]);
  st[15U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std13, (uint32_t)8U);
  st[11U] = Lib_IntVector_Intrinsics_vec256_add32(st[11U], st[15U]);
  Lib_IntVector_Intrinsics_vec256 std14 = Lib_IntVector_Intrinsics_vec256_xor(st[7U], st[11U]);
  st[7U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std14, (uint32_t)7U);
  st[0U] = Lib_IntVector_Intrinsics_vec256_add32(st[0U], st[5U]);
  Lib_IntVector_Intrinsics_vec256 std15 = Lib_IntVector_Intrinsics_vec256_xor(st[15U], st[0U]);
  st[15U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std15, (uint32_t)16U);
  st[10U] = Lib_IntVector_Intrinsics_vec256_add32(st[10U], st[15U]);
  Lib_IntVector_Intrinsics_vec256 std16 = Lib_IntVector_Intrinsics_vec256_xor(st[5U], st[10U]);
  st[5U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std16, (uint32_t)12U);
  st[0U] = Lib_IntVector_Intrinsics_vec256_add32(st[0U], st[5U]);
  Lib_IntVector_Intrinsics_vec256 std17 = Lib_IntVector_Intrinsics_vec256_xor(st[15U], st[0U]);
  st[15U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std17, (uint32_t)8U);
  st[10U] = Lib_IntVector_Intrinsics_vec256_add32(st[10U], st[15U]);
  Lib_IntVector_Intrinsics_vec256 std18 = Lib_IntVector_Intrinsics_vec256_xor(st[5U], st[10U]);
  st[5U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std18, (uint32_t)7U);
  st[1U] = Lib_IntVector_Intrinsics_vec256_add32(st[1U], st[6U]);
  Lib_IntVector_Intrinsics_vec256 std19 = Lib_IntVector_Intrinsics_vec256_xor(st[12U], st[1U]);
  st[12U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std19, (uint32_t)16U);
  st[11U] = Lib_IntVector_Intrinsics_vec256_add32(st[11U], st[12U]);
  Lib_IntVector_Intrinsics_vec256 std20 = Lib_IntVector_Intrinsics_vec256_xor(st[6U], st[11U]);
  st[6U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std20, (uint32_t)12U);
  st[1U] = Lib_IntVector_Intrinsics_vec256_add32(st[1U], st[6U]);
  Lib_IntVector_Intrinsics_vec256 std21 = Lib_IntVector_Intrinsics_vec256_xor(st[12U], st[1U]);
  st[12U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std21, (uint32_t)8U);
  st[11U] = Lib_IntVector_Intrinsics_vec256_add32(st[11U], st[12U]);
  Lib_IntVector_Intrinsics_vec256 std22 = Lib_IntVector_Intrinsics_vec256_xor(st[6U], st[11U]);
  st[6U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std22, (uint32_t)7U);
  st[2U] = Lib_IntVector_Intrinsics_vec256_add32(st[2U], st[7U]);
  Lib_IntVector_Intrinsics_vec256 std23 = Lib_IntVector_Intrinsics_vec256_xor(st[13U], st[2U]);
  st[13U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std23, (uint32_t)16U);
  st[8U] = Lib_IntVector_Intrinsics_vec256_add32(st[8U], st[13U]);
  Lib_IntVector_Intrinsics_vec256 std24 = Lib_IntVector_Intrinsics_vec256_xor(st[7U], st[8U]);
  st[7U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std24, (uint32_t)12U);
  st[2U] = Lib_IntVector_Intrinsics_vec256_add32(st[2U], st[7U]);
  Lib_IntVector_Intrinsics_vec256 std25 = Lib_IntVector_Intrinsics_vec256_xor(st[13U], st[2U]);
  st[13U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std25, (uint32_t)8U);
  st[8U] = Lib_IntVector_Intrinsics_vec256_add32(st[8U], st[13U]);
  Lib_IntVector_Intrinsics_vec256 std26 = Lib_IntVector_Intrinsics_vec256_xor(st[7U], st[8U]);
  st[7U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std26, (uint32_t)7U);
  st[3U] = Lib_IntVector_Intrinsics_vec256_add32(st[3U], st[4U]);
  Lib_IntVector_Intrinsics_vec256 std27 = Lib_IntVector_Intrinsics_vec256_xor(st[14U], st[3U]);
  st[14U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std27, (uint32_t)16U);
  st[9U] = Lib_IntVector_Intrinsics_vec256_add32(st[9U], st[14U]);
  Lib_IntVector_Intrinsics_vec256 std28 = Lib_IntVector_Intrinsics_vec256_xor(st[4U], st[9U]);
  st[4U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std28, (uint32_t)12U);
  st[3U] = Lib_IntVector_Intrinsics_vec256_add32(st[3U], st[4U]);
  Lib_IntVector_Intrinsics_vec256 std29 = Lib_IntVector_Intrinsics_vec256_xor(st[14U], st[3U]);
  st[14U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std29, (uint32_t)8U);
  st[9U] = Lib_IntVector_Intrinsics_vec256_add32(st[9U], st[14U]);
  Lib_IntVector_Intrinsics_vec256 std30 = Lib_IntVector_Intrinsics_vec256_xor(st[4U], st[9U]);
  st[4U] = Lib_IntVector_Intrinsics_vec256_rotate_left32(std30, (uint32_t)7U);
}

/* SNIPPET_END: double_round_256 */

/* SNIPPET_START: chacha20_core_256 */

static inline void
chacha20_core_256(
  Lib_IntVector_Intrinsics_vec256 *k,
  Lib_IntVector_Intrinsics_vec256 *ctx,
  uint32_t ctr
)
{
  memcpy(k, ctx, (uint32_t)16U * sizeof (ctx[0U]));
  uint32_t ctr_u32 = (uint32_t)8U * ctr;
  Lib_IntVector_Intrinsics_vec256 cv = Lib_IntVector_Intrinsics_vec256_load32(ctr_u32);
  k[12U] = Lib_IntVector_Intrinsics_vec256_add32(k[12U], cv);
  double_round_256(k);
  double_round_256(k);
  double_round_256(k);
  double_round_256(k);
  double_round_256(k);
  double_round_256(k);
  double_round_256(k);
  double_round_256(k);
  double_round_256(k);
  double_round_256(k);
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)16U; i++)
  {
    Lib_IntVector_Intrinsics_vec256 *os = k;
    Lib_IntVector_Intrinsics_vec256 x = Lib_IntVector_Intrinsics_vec256_add32(k[i], ctx[i]);
    os[i] = x;
  }
  k[12U] = Lib_IntVector_Intrinsics_vec256_add32(k[12U], cv);
}

/* SNIPPET_END: chacha20_core_256 */

/* SNIPPET_START: chacha20_init_256 */

static inline void
chacha20_init_256(Lib_IntVector_Intrinsics_vec256 *ctx, uint8_t *k, uint8_t *n, uint32_t ctr)
{
  uint32_t ctx1[16U] = { 0U };
  uint32_t *uu____0 = ctx1;
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
  {
    uint32_t *os = uu____0;
    uint32_t x = Hacl_Impl_Chacha20_Vec_chacha20_constants[i];
    os[i] = x;
  }
  uint32_t *uu____1 = ctx1 + (uint32_t)4U;
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)8U; i++)
  {
    uint32_t *os = uu____1;
    uint8_t *bj = k + i * (uint32_t)4U;
    uint32_t u = load32_le(bj);
    uint32_t r = u;
    uint32_t x = r;
    os[i] = x;
  }
  ctx1[12U] = ctr;
  uint32_t *uu____2 = ctx1 + (uint32_t)13U;
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)3U; i++)
  {
    uint32_t *os = uu____2;
    uint8_t *bj = n + i * (uint32_t)4U;
    uint32_t u = load32_le(bj);
    uint32_t r = u;
    uint32_t x = r;
    os[i] = x;
  }
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)16U; i++)
  {
    Lib_IntVector_Intrinsics_vec256 *os = ctx;
    uint32_t x = ctx1[i];
    Lib_IntVector_Intrinsics_vec256 x0 = Lib_IntVector_Intrinsics_vec256_load32(x);
    os[i] = x0;
  }
  Lib_IntVector_Intrinsics_vec256
  ctr1 =
    Lib_IntVector_Intrinsics_vec256_load32s((uint32_t)0U,
      (uint32_t)1U,
      (uint32_t)2U,
      (uint32_t)3U,
      (uint32_t)4U,
      (uint32_t)5U,
      (uint32_t)6U,
      (uint32_t)7U);
  Lib_IntVector_Intrinsics_vec256 c12 = ctx[12U];
  ctx[12U] = Lib_IntVector_Intrinsics_vec256_add32(c12, ctr1);
}

/* SNIPPET_END: chacha20_init_256 */

/* SNIPPET_START: Hacl_Chacha20_Vec256_chacha20_encrypt_256 */

void
Hacl_Chacha20_Vec256_chacha20_encrypt_256(
  uint32_t len,
  uint8_t *out,
  uint8_t *text,
  uint8_t *key,
  uint8_t *n,
  uint32_t ctr
)
{
  Lib_IntVector_Intrinsics_vec256 ctx[16U];
  for (uint32_t _i = 0U; _i < (uint32_t)16U; ++_i)
    ctx[_i] = Lib_IntVector_Intrinsics_vec256_zero;
  chacha20_init_256(ctx, key, n, ctr);
  uint32_t rem = len % (uint32_t)512U;
  uint32_t nb = len / (uint32_t)512U;
  uint32_t rem1 = len % (uint32_t)512U;
  for (uint32_t i = (uint32_t)0U; i < nb; i++)
  {
    uint8_t *uu____0 = out + i * (uint32_t)512U;
    uint8_t *uu____1 = text + i * (uint32_t)512U;
    Lib_IntVector_Intrinsics_vec256 k[16U];
    for (uint32_t _i = 0U; _i < (uint32_t)16U; ++_i)
      k[_i] = Lib_IntVector_Intrinsics_vec256_zero;
    chacha20_core_256(k, ctx, i);
    Lib_IntVector_Intrinsics_vec256 v00 = k[0U];
    Lib_IntVector_Intrinsics_vec256 v16 = k[1U];
    Lib_IntVector_Intrinsics_vec256 v20 = k[2U];
    Lib_IntVector_Intrinsics_vec256 v30 = k[3U];
    Lib_IntVector_Intrinsics_vec256 v40 = k[4U];
    Lib_IntVector_Intrinsics_vec256 v50 = k[5U];
    Lib_IntVector_Intrinsics_vec256 v60 = k[6U];
    Lib_IntVector_Intrinsics_vec256 v70 = k[7U];
    Lib_IntVector_Intrinsics_vec256
    v0_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v00, v16);
    Lib_IntVector_Intrinsics_vec256
    v1_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v00, v16);
    Lib_IntVector_Intrinsics_vec256
    v2_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v20, v30);
    Lib_IntVector_Intrinsics_vec256
    v3_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v20, v30);
    Lib_IntVector_Intrinsics_vec256
    v4_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v40, v50);
    Lib_IntVector_Intrinsics_vec256
    v5_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v40, v50);
    Lib_IntVector_Intrinsics_vec256
    v6_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v60, v70);
    Lib_IntVector_Intrinsics_vec256
    v7_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v60, v70);
    Lib_IntVector_Intrinsics_vec256 v0_0 = v0_;
    Lib_IntVector_Intrinsics_vec256 v1_0 = v1_;
    Lib_IntVector_Intrinsics_vec256 v2_0 = v2_;
    Lib_IntVector_Intrinsics_vec256 v3_0 = v3_;
    Lib_IntVector_Intrinsics_vec256 v4_0 = v4_;
    Lib_IntVector_Intrinsics_vec256 v5_0 = v5_;
    Lib_IntVector_Intrinsics_vec256 v6_0 = v6_;
    Lib_IntVector_Intrinsics_vec256 v7_0 = v7_;
    Lib_IntVector_Intrinsics_vec256
    v0_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v0_0, v2_0);
    Lib_IntVector_Intrinsics_vec256
    v2_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v0_0, v2_0);
    Lib_IntVector_Intrinsics_vec256
    v1_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v1_0, v3_0);
    Lib_IntVector_Intrinsics_vec256
    v3_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v1_0, v3_0);
    Lib_IntVector_Intrinsics_vec256
    v4_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v4_0, v6_0);
    Lib_IntVector_Intrinsics_vec256
    v6_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v4_0, v6_0);
    Lib_IntVector_Intrinsics_vec256
    v5_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v5_0, v7_0);
    Lib_IntVector_Intrinsics_vec256
    v7_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v5_0, v7_0);
    Lib_IntVector_Intrinsics_vec256 v0_10 = v0_1;
    Lib_IntVector_Intrinsics_vec256 v1_10 = v1_1;
    Lib_IntVector_Intrinsics_vec256 v2_10 = v2_1;
    Lib_IntVector_Intrinsics_vec256 v3_10 = v3_1;
    Lib_IntVector_Intrinsics_vec256 v4_10 = v4_1;
    Lib_IntVector_Intrinsics_vec256 v5_10 = v5_1;
    Lib_IntVector_Intrinsics_vec256 v6_10 = v6_1;
    Lib_IntVector_Intrinsics_vec256 v7_10 = v7_1;
    Lib_IntVector_Intrinsics_vec256
    v0_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v0_10, v4_10);
    Lib_IntVector_Intrinsics_vec256
    v4_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v0_10, v4_10);
    Lib_IntVector_Intrinsics_vec256
    v1_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v1_10, v5_10);
    Lib_IntVector_Intrinsics_vec256
    v5_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v1_10, v5_10);
    Lib_IntVector_Intrinsics_vec256
    v2_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v2_10, v6_10);
    Lib_IntVector_Intrinsics_vec256
    v6_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v2_10, v6_10);
    Lib_IntVector_Intrinsics_vec256
    v3_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v3_10, v7_10);
    Lib_IntVector_Intrinsics_vec256
    v7_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v3_10, v7_10);
    Lib_IntVector_Intrinsics_vec256 v0_20 = v0_2;
    Lib_IntVector_Intrinsics_vec256 v1_20 = v1_2;
    Lib_IntVector_Intrinsics_vec256 v2_20 = v2_2;
    Lib_IntVector_Intrinsics_vec256 v3_20 = v3_2;
    Lib_IntVector_Intrinsics_vec256 v4_20 = v4_2;
    Lib_IntVector_Intrinsics_vec256 v5_20 = v5_2;
    Lib_IntVector_Intrinsics_vec256 v6_20 = v6_2;
    Lib_IntVector_Intrinsics_vec256 v7_20 = v7_2;
    Lib_IntVector_Intrinsics_vec256 v0 = v0_20;
    Lib_IntVector_Intrinsics_vec256 v1 = v2_20;
    Lib_IntVector_Intrinsics_vec256 v2 = v1_20;
    Lib_IntVector_Intrinsics_vec256 v3 = v3_20;
    Lib_IntVector_Intrinsics_vec256 v4 = v4_20;
    Lib_IntVector_Intrinsics_vec256 v5 = v6_20;
    Lib_IntVector_Intrinsics_vec256 v6 = v5_20;
    Lib_IntVector_Intrinsics_vec256 v7 = v7_20;
    Lib_IntVector_Intrinsics_vec256 v01 = k[8U];
    Lib_IntVector_Intrinsics_vec256 v110 = k[9U];
    Lib_IntVector_Intrinsics_vec256 v21 = k[10U];
    Lib_IntVector_Intrinsics_vec256 v31 = k[11U];
    Lib_IntVector_Intrinsics_vec256 v41 = k[12U];
    Lib_IntVector_Intrinsics_vec256 v51 = k[13U];
    Lib_IntVector_Intrinsics_vec256 v61 = k[14U];
    Lib_IntVector_Intrinsics_vec256 v71 = k[15U];
    Lib_IntVector_Intrinsics_vec256
    v0_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v01, v110);
    Lib_IntVector_Intrinsics_vec256
    v1_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v01, v110);
    Lib_IntVector_Intrinsics_vec256
    v2_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v21, v31);
    Lib_IntVector_Intrinsics_vec256
    v3_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v21, v31);
    Lib_IntVector_Intrinsics_vec256
    v4_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v41, v51);
    Lib_IntVector_Intrinsics_vec256
    v5_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v41, v51);
    Lib_IntVector_Intrinsics_vec256
    v6_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v61, v71);
    Lib_IntVector_Intrinsics_vec256
    v7_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v61, v71);
    Lib_IntVector_Intrinsics_vec256 v0_4 = v0_3;
    Lib_IntVector_Intrinsics_vec256 v1_4 = v1_3;
    Lib_IntVector_Intrinsics_vec256 v2_4 = v2_3;
    Lib_IntVector_Intrinsics_vec256 v3_4 = v3_3;
    Lib_IntVector_Intrinsics_vec256 v4_4 = v4_3;
    Lib_IntVector_Intrinsics_vec256 v5_4 = v5_3;
    Lib_IntVector_Intrinsics_vec256 v6_4 = v6_3;
    Lib_IntVector_Intrinsics_vec256 v7_4 = v7_3;
    Lib_IntVector_Intrinsics_vec256
    v0_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v0_4, v2_4);
    Lib_IntVector_Intrinsics_vec256
    v2_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v0_4, v2_4);
    Lib_IntVector_Intrinsics_vec256
    v1_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v1_4, v3_4);
    Lib_IntVector_Intrinsics_vec256
    v3_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v1_4, v3_4);
    Lib_IntVector_Intrinsics_vec256
    v4_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v4_4, v6_4);
    Lib_IntVector_Intrinsics_vec256
    v6_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v4_4, v6_4);
    Lib_IntVector_Intrinsics_vec256
    v5_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v5_4, v7_4);
    Lib_IntVector_Intrinsics_vec256
    v7_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v5_4, v7_4);
    Lib_IntVector_Intrinsics_vec256 v0_12 = v0_11;
    Lib_IntVector_Intrinsics_vec256 v1_12 = v1_11;
    Lib_IntVector_Intrinsics_vec256 v2_12 = v2_11;
    Lib_IntVector_Intrinsics_vec256 v3_12 = v3_11;
    Lib_IntVector_Intrinsics_vec256 v4_12 = v4_11;
    Lib_IntVector_Intrinsics_vec256 v5_12 = v5_11;
    Lib_IntVector_Intrinsics_vec256 v6_12 = v6_11;
    Lib_IntVector_Intrinsics_vec256 v7_12 = v7_11;
    Lib_IntVector_Intrinsics_vec256
    v0_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v0_12, v4_12);
    Lib_IntVector_Intrinsics_vec256
    v4_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v0_12, v4_12);
    Lib_IntVector_Intrinsics_vec256
    v1_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v1_12, v5_12);
    Lib_IntVector_Intrinsics_vec256
    v5_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v1_12, v5_12);
    Lib_IntVector_Intrinsics_vec256
    v2_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v2_12, v6_12);
    Lib_IntVector_Intrinsics_vec256
    v6_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v2_12, v6_12);
    Lib_IntVector_Intrinsics_vec256
    v3_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v3_12, v7_12);
    Lib_IntVector_Intrinsics_vec256
    v7_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v3_12, v7_12);
    Lib_IntVector_Intrinsics_vec256 v0_22 = v0_21;
    Lib_IntVector_Intrinsics_vec256 v1_22 = v1_21;
    Lib_IntVector_Intrinsics_vec256 v2_22 = v2_21;
    Lib_IntVector_Intrinsics_vec256 v3_22 = v3_21;
    Lib_IntVector_Intrinsics_vec256 v4_22 = v4_21;
    Lib_IntVector_Intrinsics_vec256 v5_22 = v5_21;
    Lib_IntVector_Intrinsics_vec256 v6_22 = v6_21;
    Lib_IntVector_Intrinsics_vec256 v7_22 = v7_21;
    Lib_IntVector_Intrinsics_vec256 v8 = v0_22;
    Lib_IntVector_Intrinsics_vec256 v9 = v2_22;
    Lib_IntVector_Intrinsics_vec256 v10 = v1_22;
    Lib_IntVector_Intrinsics_vec256 v11 = v3_22;
    Lib_IntVector_Intrinsics_vec256 v12 = v4_22;
    Lib_IntVector_Intrinsics_vec256 v13 = v6_22;
    Lib_IntVector_Intrinsics_vec256 v14 = v5_22;
    Lib_IntVector_Intrinsics_vec256 v15 = v7_22;
    k[0U] = v0;
    k[1U] = v8;
    k[2U] = v1;
    k[3U] = v9;
    k[4U] = v2;
    k[5U] = v10;
    k[6U] = v3;
    k[7U] = v11;
    k[8U] = v4;
    k[9U] = v12;
    k[10U] = v5;
    k[11U] = v13;
    k[12U] = v6;
    k[13U] = v14;
    k[14U] = v7;
    k[15U] = v15;
    for (uint32_t i0 = (uint32_t)0U; i0 < (uint32_t)16U; i0++)
    {
      Lib_IntVector_Intrinsics_vec256
      x = Lib_IntVector_Intrinsics_vec256_load_le(uu____1 + i0 * (uint32_t)32U);
      Lib_IntVector_Intrinsics_vec256 y = Lib_IntVector_Intrinsics_vec256_xor(x, k[i0]);
      Lib_IntVector_Intrinsics_vec256_store_le(uu____0 + i0 * (uint32_t)32U, y);
    }
  }
  if (rem1 > (uint32_t)0U)
  {
    uint8_t *uu____2 = out + nb * (uint32_t)512U;
    uint8_t *uu____3 = text + nb * (uint32_t)512U;
    uint8_t plain[512U] = { 0U };
    memcpy(plain, uu____3, rem * sizeof (uu____3[0U]));
    Lib_IntVector_Intrinsics_vec256 k[16U];
    for (uint32_t _i = 0U; _i < (uint32_t)16U; ++_i)
      k[_i] = Lib_IntVector_Intrinsics_vec256_zero;
    chacha20_core_256(k, ctx, nb);
    Lib_IntVector_Intrinsics_vec256 v00 = k[0U];
    Lib_IntVector_Intrinsics_vec256 v16 = k[1U];
    Lib_IntVector_Intrinsics_vec256 v20 = k[2U];
    Lib_IntVector_Intrinsics_vec256 v30 = k[3U];
    Lib_IntVector_Intrinsics_vec256 v40 = k[4U];
    Lib_IntVector_Intrinsics_vec256 v50 = k[5U];
    Lib_IntVector_Intrinsics_vec256 v60 = k[6U];
    Lib_IntVector_Intrinsics_vec256 v70 = k[7U];
    Lib_IntVector_Intrinsics_vec256
    v0_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v00, v16);
    Lib_IntVector_Intrinsics_vec256
    v1_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v00, v16);
    Lib_IntVector_Intrinsics_vec256
    v2_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v20, v30);
    Lib_IntVector_Intrinsics_vec256
    v3_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v20, v30);
    Lib_IntVector_Intrinsics_vec256
    v4_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v40, v50);
    Lib_IntVector_Intrinsics_vec256
    v5_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v40, v50);
    Lib_IntVector_Intrinsics_vec256
    v6_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v60, v70);
    Lib_IntVector_Intrinsics_vec256
    v7_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v60, v70);
    Lib_IntVector_Intrinsics_vec256 v0_0 = v0_;
    Lib_IntVector_Intrinsics_vec256 v1_0 = v1_;
    Lib_IntVector_Intrinsics_vec256 v2_0 = v2_;
    Lib_IntVector_Intrinsics_vec256 v3_0 = v3_;
    Lib_IntVector_Intrinsics_vec256 v4_0 = v4_;
    Lib_IntVector_Intrinsics_vec256 v5_0 = v5_;
    Lib_IntVector_Intrinsics_vec256 v6_0 = v6_;
    Lib_IntVector_Intrinsics_vec256 v7_0 = v7_;
    Lib_IntVector_Intrinsics_vec256
    v0_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v0_0, v2_0);
    Lib_IntVector_Intrinsics_vec256
    v2_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v0_0, v2_0);
    Lib_IntVector_Intrinsics_vec256
    v1_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v1_0, v3_0);
    Lib_IntVector_Intrinsics_vec256
    v3_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v1_0, v3_0);
    Lib_IntVector_Intrinsics_vec256
    v4_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v4_0, v6_0);
    Lib_IntVector_Intrinsics_vec256
    v6_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v4_0, v6_0);
    Lib_IntVector_Intrinsics_vec256
    v5_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v5_0, v7_0);
    Lib_IntVector_Intrinsics_vec256
    v7_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v5_0, v7_0);
    Lib_IntVector_Intrinsics_vec256 v0_10 = v0_1;
    Lib_IntVector_Intrinsics_vec256 v1_10 = v1_1;
    Lib_IntVector_Intrinsics_vec256 v2_10 = v2_1;
    Lib_IntVector_Intrinsics_vec256 v3_10 = v3_1;
    Lib_IntVector_Intrinsics_vec256 v4_10 = v4_1;
    Lib_IntVector_Intrinsics_vec256 v5_10 = v5_1;
    Lib_IntVector_Intrinsics_vec256 v6_10 = v6_1;
    Lib_IntVector_Intrinsics_vec256 v7_10 = v7_1;
    Lib_IntVector_Intrinsics_vec256
    v0_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v0_10, v4_10);
    Lib_IntVector_Intrinsics_vec256
    v4_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v0_10, v4_10);
    Lib_IntVector_Intrinsics_vec256
    v1_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v1_10, v5_10);
    Lib_IntVector_Intrinsics_vec256
    v5_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v1_10, v5_10);
    Lib_IntVector_Intrinsics_vec256
    v2_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v2_10, v6_10);
    Lib_IntVector_Intrinsics_vec256
    v6_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v2_10, v6_10);
    Lib_IntVector_Intrinsics_vec256
    v3_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v3_10, v7_10);
    Lib_IntVector_Intrinsics_vec256
    v7_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v3_10, v7_10);
    Lib_IntVector_Intrinsics_vec256 v0_20 = v0_2;
    Lib_IntVector_Intrinsics_vec256 v1_20 = v1_2;
    Lib_IntVector_Intrinsics_vec256 v2_20 = v2_2;
    Lib_IntVector_Intrinsics_vec256 v3_20 = v3_2;
    Lib_IntVector_Intrinsics_vec256 v4_20 = v4_2;
    Lib_IntVector_Intrinsics_vec256 v5_20 = v5_2;
    Lib_IntVector_Intrinsics_vec256 v6_20 = v6_2;
    Lib_IntVector_Intrinsics_vec256 v7_20 = v7_2;
    Lib_IntVector_Intrinsics_vec256 v0 = v0_20;
    Lib_IntVector_Intrinsics_vec256 v1 = v2_20;
    Lib_IntVector_Intrinsics_vec256 v2 = v1_20;
    Lib_IntVector_Intrinsics_vec256 v3 = v3_20;
    Lib_IntVector_Intrinsics_vec256 v4 = v4_20;
    Lib_IntVector_Intrinsics_vec256 v5 = v6_20;
    Lib_IntVector_Intrinsics_vec256 v6 = v5_20;
    Lib_IntVector_Intrinsics_vec256 v7 = v7_20;
    Lib_IntVector_Intrinsics_vec256 v01 = k[8U];
    Lib_IntVector_Intrinsics_vec256 v110 = k[9U];
    Lib_IntVector_Intrinsics_vec256 v21 = k[10U];
    Lib_IntVector_Intrinsics_vec256 v31 = k[11U];
    Lib_IntVector_Intrinsics_vec256 v41 = k[12U];
    Lib_IntVector_Intrinsics_vec256 v51 = k[13U];
    Lib_IntVector_Intrinsics_vec256 v61 = k[14U];
    Lib_IntVector_Intrinsics_vec256 v71 = k[15U];
    Lib_IntVector_Intrinsics_vec256
    v0_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v01, v110);
    Lib_IntVector_Intrinsics_vec256
    v1_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v01, v110);
    Lib_IntVector_Intrinsics_vec256
    v2_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v21, v31);
    Lib_IntVector_Intrinsics_vec256
    v3_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v21, v31);
    Lib_IntVector_Intrinsics_vec256
    v4_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v41, v51);
    Lib_IntVector_Intrinsics_vec256
    v5_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v41, v51);
    Lib_IntVector_Intrinsics_vec256
    v6_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v61, v71);
    Lib_IntVector_Intrinsics_vec256
    v7_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v61, v71);
    Lib_IntVector_Intrinsics_vec256 v0_4 = v0_3;
    Lib_IntVector_Intrinsics_vec256 v1_4 = v1_3;
    Lib_IntVector_Intrinsics_vec256 v2_4 = v2_3;
    Lib_IntVector_Intrinsics_vec256 v3_4 = v3_3;
    Lib_IntVector_Intrinsics_vec256 v4_4 = v4_3;
    Lib_IntVector_Intrinsics_vec256 v5_4 = v5_3;
    Lib_IntVector_Intrinsics_vec256 v6_4 = v6_3;
    Lib_IntVector_Intrinsics_vec256 v7_4 = v7_3;
    Lib_IntVector_Intrinsics_vec256
    v0_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v0_4, v2_4);
    Lib_IntVector_Intrinsics_vec256
    v2_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v0_4, v2_4);
    Lib_IntVector_Intrinsics_vec256
    v1_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v1_4, v3_4);
    Lib_IntVector_Intrinsics_vec256
    v3_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v1_4, v3_4);
    Lib_IntVector_Intrinsics_vec256
    v4_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v4_4, v6_4);
    Lib_IntVector_Intrinsics_vec256
    v6_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v4_4, v6_4);
    Lib_IntVector_Intrinsics_vec256
    v5_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v5_4, v7_4);
    Lib_IntVector_Intrinsics_vec256
    v7_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v5_4, v7_4);
    Lib_IntVector_Intrinsics_vec256 v0_12 = v0_11;
    Lib_IntVector_Intrinsics_vec256 v1_12 = v1_11;
    Lib_IntVector_Intrinsics_vec256 v2_12 = v2_11;
    Lib_IntVector_Intrinsics_vec256 v3_12 = v3_11;
    Lib_IntVector_Intrinsics_vec256 v4_12 = v4_11;
    Lib_IntVector_Intrinsics_vec256 v5_12 = v5_11;
    Lib_IntVector_Intrinsics_vec256 v6_12 = v6_11;
    Lib_IntVector_Intrinsics_vec256 v7_12 = v7_11;
    Lib_IntVector_Intrinsics_vec256
    v0_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v0_12, v4_12);
    Lib_IntVector_Intrinsics_vec256
    v4_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v0_12, v4_12);
    Lib_IntVector_Intrinsics_vec256
    v1_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v1_12, v5_12);
    Lib_IntVector_Intrinsics_vec256
    v5_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v1_12, v5_12);
    Lib_IntVector_Intrinsics_vec256
    v2_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v2_12, v6_12);
    Lib_IntVector_Intrinsics_vec256
    v6_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v2_12, v6_12);
    Lib_IntVector_Intrinsics_vec256
    v3_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v3_12, v7_12);
    Lib_IntVector_Intrinsics_vec256
    v7_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v3_12, v7_12);
    Lib_IntVector_Intrinsics_vec256 v0_22 = v0_21;
    Lib_IntVector_Intrinsics_vec256 v1_22 = v1_21;
    Lib_IntVector_Intrinsics_vec256 v2_22 = v2_21;
    Lib_IntVector_Intrinsics_vec256 v3_22 = v3_21;
    Lib_IntVector_Intrinsics_vec256 v4_22 = v4_21;
    Lib_IntVector_Intrinsics_vec256 v5_22 = v5_21;
    Lib_IntVector_Intrinsics_vec256 v6_22 = v6_21;
    Lib_IntVector_Intrinsics_vec256 v7_22 = v7_21;
    Lib_IntVector_Intrinsics_vec256 v8 = v0_22;
    Lib_IntVector_Intrinsics_vec256 v9 = v2_22;
    Lib_IntVector_Intrinsics_vec256 v10 = v1_22;
    Lib_IntVector_Intrinsics_vec256 v11 = v3_22;
    Lib_IntVector_Intrinsics_vec256 v12 = v4_22;
    Lib_IntVector_Intrinsics_vec256 v13 = v6_22;
    Lib_IntVector_Intrinsics_vec256 v14 = v5_22;
    Lib_IntVector_Intrinsics_vec256 v15 = v7_22;
    k[0U] = v0;
    k[1U] = v8;
    k[2U] = v1;
    k[3U] = v9;
    k[4U] = v2;
    k[5U] = v10;
    k[6U] = v3;
    k[7U] = v11;
    k[8U] = v4;
    k[9U] = v12;
    k[10U] = v5;
    k[11U] = v13;
    k[12U] = v6;
    k[13U] = v14;
    k[14U] = v7;
    k[15U] = v15;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)16U; i++)
    {
      Lib_IntVector_Intrinsics_vec256
      x = Lib_IntVector_Intrinsics_vec256_load_le(plain + i * (uint32_t)32U);
      Lib_IntVector_Intrinsics_vec256 y = Lib_IntVector_Intrinsics_vec256_xor(x, k[i]);
      Lib_IntVector_Intrinsics_vec256_store_le(plain + i * (uint32_t)32U, y);
    }
    memcpy(uu____2, plain, rem * sizeof (plain[0U]));
  }
}

/* SNIPPET_END: Hacl_Chacha20_Vec256_chacha20_encrypt_256 */

/* SNIPPET_START: Hacl_Chacha20_Vec256_chacha20_decrypt_256 */

void
Hacl_Chacha20_Vec256_chacha20_decrypt_256(
  uint32_t len,
  uint8_t *out,
  uint8_t *cipher,
  uint8_t *key,
  uint8_t *n,
  uint32_t ctr
)
{
  Lib_IntVector_Intrinsics_vec256 ctx[16U];
  for (uint32_t _i = 0U; _i < (uint32_t)16U; ++_i)
    ctx[_i] = Lib_IntVector_Intrinsics_vec256_zero;
  chacha20_init_256(ctx, key, n, ctr);
  uint32_t rem = len % (uint32_t)512U;
  uint32_t nb = len / (uint32_t)512U;
  uint32_t rem1 = len % (uint32_t)512U;
  for (uint32_t i = (uint32_t)0U; i < nb; i++)
  {
    uint8_t *uu____0 = out + i * (uint32_t)512U;
    uint8_t *uu____1 = cipher + i * (uint32_t)512U;
    Lib_IntVector_Intrinsics_vec256 k[16U];
    for (uint32_t _i = 0U; _i < (uint32_t)16U; ++_i)
      k[_i] = Lib_IntVector_Intrinsics_vec256_zero;
    chacha20_core_256(k, ctx, i);
    Lib_IntVector_Intrinsics_vec256 v00 = k[0U];
    Lib_IntVector_Intrinsics_vec256 v16 = k[1U];
    Lib_IntVector_Intrinsics_vec256 v20 = k[2U];
    Lib_IntVector_Intrinsics_vec256 v30 = k[3U];
    Lib_IntVector_Intrinsics_vec256 v40 = k[4U];
    Lib_IntVector_Intrinsics_vec256 v50 = k[5U];
    Lib_IntVector_Intrinsics_vec256 v60 = k[6U];
    Lib_IntVector_Intrinsics_vec256 v70 = k[7U];
    Lib_IntVector_Intrinsics_vec256
    v0_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v00, v16);
    Lib_IntVector_Intrinsics_vec256
    v1_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v00, v16);
    Lib_IntVector_Intrinsics_vec256
    v2_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v20, v30);
    Lib_IntVector_Intrinsics_vec256
    v3_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v20, v30);
    Lib_IntVector_Intrinsics_vec256
    v4_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v40, v50);
    Lib_IntVector_Intrinsics_vec256
    v5_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v40, v50);
    Lib_IntVector_Intrinsics_vec256
    v6_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v60, v70);
    Lib_IntVector_Intrinsics_vec256
    v7_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v60, v70);
    Lib_IntVector_Intrinsics_vec256 v0_0 = v0_;
    Lib_IntVector_Intrinsics_vec256 v1_0 = v1_;
    Lib_IntVector_Intrinsics_vec256 v2_0 = v2_;
    Lib_IntVector_Intrinsics_vec256 v3_0 = v3_;
    Lib_IntVector_Intrinsics_vec256 v4_0 = v4_;
    Lib_IntVector_Intrinsics_vec256 v5_0 = v5_;
    Lib_IntVector_Intrinsics_vec256 v6_0 = v6_;
    Lib_IntVector_Intrinsics_vec256 v7_0 = v7_;
    Lib_IntVector_Intrinsics_vec256
    v0_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v0_0, v2_0);
    Lib_IntVector_Intrinsics_vec256
    v2_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v0_0, v2_0);
    Lib_IntVector_Intrinsics_vec256
    v1_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v1_0, v3_0);
    Lib_IntVector_Intrinsics_vec256
    v3_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v1_0, v3_0);
    Lib_IntVector_Intrinsics_vec256
    v4_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v4_0, v6_0);
    Lib_IntVector_Intrinsics_vec256
    v6_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v4_0, v6_0);
    Lib_IntVector_Intrinsics_vec256
    v5_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v5_0, v7_0);
    Lib_IntVector_Intrinsics_vec256
    v7_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v5_0, v7_0);
    Lib_IntVector_Intrinsics_vec256 v0_10 = v0_1;
    Lib_IntVector_Intrinsics_vec256 v1_10 = v1_1;
    Lib_IntVector_Intrinsics_vec256 v2_10 = v2_1;
    Lib_IntVector_Intrinsics_vec256 v3_10 = v3_1;
    Lib_IntVector_Intrinsics_vec256 v4_10 = v4_1;
    Lib_IntVector_Intrinsics_vec256 v5_10 = v5_1;
    Lib_IntVector_Intrinsics_vec256 v6_10 = v6_1;
    Lib_IntVector_Intrinsics_vec256 v7_10 = v7_1;
    Lib_IntVector_Intrinsics_vec256
    v0_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v0_10, v4_10);
    Lib_IntVector_Intrinsics_vec256
    v4_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v0_10, v4_10);
    Lib_IntVector_Intrinsics_vec256
    v1_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v1_10, v5_10);
    Lib_IntVector_Intrinsics_vec256
    v5_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v1_10, v5_10);
    Lib_IntVector_Intrinsics_vec256
    v2_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v2_10, v6_10);
    Lib_IntVector_Intrinsics_vec256
    v6_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v2_10, v6_10);
    Lib_IntVector_Intrinsics_vec256
    v3_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v3_10, v7_10);
    Lib_IntVector_Intrinsics_vec256
    v7_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v3_10, v7_10);
    Lib_IntVector_Intrinsics_vec256 v0_20 = v0_2;
    Lib_IntVector_Intrinsics_vec256 v1_20 = v1_2;
    Lib_IntVector_Intrinsics_vec256 v2_20 = v2_2;
    Lib_IntVector_Intrinsics_vec256 v3_20 = v3_2;
    Lib_IntVector_Intrinsics_vec256 v4_20 = v4_2;
    Lib_IntVector_Intrinsics_vec256 v5_20 = v5_2;
    Lib_IntVector_Intrinsics_vec256 v6_20 = v6_2;
    Lib_IntVector_Intrinsics_vec256 v7_20 = v7_2;
    Lib_IntVector_Intrinsics_vec256 v0 = v0_20;
    Lib_IntVector_Intrinsics_vec256 v1 = v2_20;
    Lib_IntVector_Intrinsics_vec256 v2 = v1_20;
    Lib_IntVector_Intrinsics_vec256 v3 = v3_20;
    Lib_IntVector_Intrinsics_vec256 v4 = v4_20;
    Lib_IntVector_Intrinsics_vec256 v5 = v6_20;
    Lib_IntVector_Intrinsics_vec256 v6 = v5_20;
    Lib_IntVector_Intrinsics_vec256 v7 = v7_20;
    Lib_IntVector_Intrinsics_vec256 v01 = k[8U];
    Lib_IntVector_Intrinsics_vec256 v110 = k[9U];
    Lib_IntVector_Intrinsics_vec256 v21 = k[10U];
    Lib_IntVector_Intrinsics_vec256 v31 = k[11U];
    Lib_IntVector_Intrinsics_vec256 v41 = k[12U];
    Lib_IntVector_Intrinsics_vec256 v51 = k[13U];
    Lib_IntVector_Intrinsics_vec256 v61 = k[14U];
    Lib_IntVector_Intrinsics_vec256 v71 = k[15U];
    Lib_IntVector_Intrinsics_vec256
    v0_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v01, v110);
    Lib_IntVector_Intrinsics_vec256
    v1_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v01, v110);
    Lib_IntVector_Intrinsics_vec256
    v2_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v21, v31);
    Lib_IntVector_Intrinsics_vec256
    v3_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v21, v31);
    Lib_IntVector_Intrinsics_vec256
    v4_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v41, v51);
    Lib_IntVector_Intrinsics_vec256
    v5_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v41, v51);
    Lib_IntVector_Intrinsics_vec256
    v6_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v61, v71);
    Lib_IntVector_Intrinsics_vec256
    v7_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v61, v71);
    Lib_IntVector_Intrinsics_vec256 v0_4 = v0_3;
    Lib_IntVector_Intrinsics_vec256 v1_4 = v1_3;
    Lib_IntVector_Intrinsics_vec256 v2_4 = v2_3;
    Lib_IntVector_Intrinsics_vec256 v3_4 = v3_3;
    Lib_IntVector_Intrinsics_vec256 v4_4 = v4_3;
    Lib_IntVector_Intrinsics_vec256 v5_4 = v5_3;
    Lib_IntVector_Intrinsics_vec256 v6_4 = v6_3;
    Lib_IntVector_Intrinsics_vec256 v7_4 = v7_3;
    Lib_IntVector_Intrinsics_vec256
    v0_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v0_4, v2_4);
    Lib_IntVector_Intrinsics_vec256
    v2_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v0_4, v2_4);
    Lib_IntVector_Intrinsics_vec256
    v1_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v1_4, v3_4);
    Lib_IntVector_Intrinsics_vec256
    v3_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v1_4, v3_4);
    Lib_IntVector_Intrinsics_vec256
    v4_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v4_4, v6_4);
    Lib_IntVector_Intrinsics_vec256
    v6_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v4_4, v6_4);
    Lib_IntVector_Intrinsics_vec256
    v5_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v5_4, v7_4);
    Lib_IntVector_Intrinsics_vec256
    v7_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v5_4, v7_4);
    Lib_IntVector_Intrinsics_vec256 v0_12 = v0_11;
    Lib_IntVector_Intrinsics_vec256 v1_12 = v1_11;
    Lib_IntVector_Intrinsics_vec256 v2_12 = v2_11;
    Lib_IntVector_Intrinsics_vec256 v3_12 = v3_11;
    Lib_IntVector_Intrinsics_vec256 v4_12 = v4_11;
    Lib_IntVector_Intrinsics_vec256 v5_12 = v5_11;
    Lib_IntVector_Intrinsics_vec256 v6_12 = v6_11;
    Lib_IntVector_Intrinsics_vec256 v7_12 = v7_11;
    Lib_IntVector_Intrinsics_vec256
    v0_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v0_12, v4_12);
    Lib_IntVector_Intrinsics_vec256
    v4_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v0_12, v4_12);
    Lib_IntVector_Intrinsics_vec256
    v1_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v1_12, v5_12);
    Lib_IntVector_Intrinsics_vec256
    v5_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v1_12, v5_12);
    Lib_IntVector_Intrinsics_vec256
    v2_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v2_12, v6_12);
    Lib_IntVector_Intrinsics_vec256
    v6_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v2_12, v6_12);
    Lib_IntVector_Intrinsics_vec256
    v3_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v3_12, v7_12);
    Lib_IntVector_Intrinsics_vec256
    v7_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v3_12, v7_12);
    Lib_IntVector_Intrinsics_vec256 v0_22 = v0_21;
    Lib_IntVector_Intrinsics_vec256 v1_22 = v1_21;
    Lib_IntVector_Intrinsics_vec256 v2_22 = v2_21;
    Lib_IntVector_Intrinsics_vec256 v3_22 = v3_21;
    Lib_IntVector_Intrinsics_vec256 v4_22 = v4_21;
    Lib_IntVector_Intrinsics_vec256 v5_22 = v5_21;
    Lib_IntVector_Intrinsics_vec256 v6_22 = v6_21;
    Lib_IntVector_Intrinsics_vec256 v7_22 = v7_21;
    Lib_IntVector_Intrinsics_vec256 v8 = v0_22;
    Lib_IntVector_Intrinsics_vec256 v9 = v2_22;
    Lib_IntVector_Intrinsics_vec256 v10 = v1_22;
    Lib_IntVector_Intrinsics_vec256 v11 = v3_22;
    Lib_IntVector_Intrinsics_vec256 v12 = v4_22;
    Lib_IntVector_Intrinsics_vec256 v13 = v6_22;
    Lib_IntVector_Intrinsics_vec256 v14 = v5_22;
    Lib_IntVector_Intrinsics_vec256 v15 = v7_22;
    k[0U] = v0;
    k[1U] = v8;
    k[2U] = v1;
    k[3U] = v9;
    k[4U] = v2;
    k[5U] = v10;
    k[6U] = v3;
    k[7U] = v11;
    k[8U] = v4;
    k[9U] = v12;
    k[10U] = v5;
    k[11U] = v13;
    k[12U] = v6;
    k[13U] = v14;
    k[14U] = v7;
    k[15U] = v15;
    for (uint32_t i0 = (uint32_t)0U; i0 < (uint32_t)16U; i0++)
    {
      Lib_IntVector_Intrinsics_vec256
      x = Lib_IntVector_Intrinsics_vec256_load_le(uu____1 + i0 * (uint32_t)32U);
      Lib_IntVector_Intrinsics_vec256 y = Lib_IntVector_Intrinsics_vec256_xor(x, k[i0]);
      Lib_IntVector_Intrinsics_vec256_store_le(uu____0 + i0 * (uint32_t)32U, y);
    }
  }
  if (rem1 > (uint32_t)0U)
  {
    uint8_t *uu____2 = out + nb * (uint32_t)512U;
    uint8_t *uu____3 = cipher + nb * (uint32_t)512U;
    uint8_t plain[512U] = { 0U };
    memcpy(plain, uu____3, rem * sizeof (uu____3[0U]));
    Lib_IntVector_Intrinsics_vec256 k[16U];
    for (uint32_t _i = 0U; _i < (uint32_t)16U; ++_i)
      k[_i] = Lib_IntVector_Intrinsics_vec256_zero;
    chacha20_core_256(k, ctx, nb);
    Lib_IntVector_Intrinsics_vec256 v00 = k[0U];
    Lib_IntVector_Intrinsics_vec256 v16 = k[1U];
    Lib_IntVector_Intrinsics_vec256 v20 = k[2U];
    Lib_IntVector_Intrinsics_vec256 v30 = k[3U];
    Lib_IntVector_Intrinsics_vec256 v40 = k[4U];
    Lib_IntVector_Intrinsics_vec256 v50 = k[5U];
    Lib_IntVector_Intrinsics_vec256 v60 = k[6U];
    Lib_IntVector_Intrinsics_vec256 v70 = k[7U];
    Lib_IntVector_Intrinsics_vec256
    v0_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v00, v16);
    Lib_IntVector_Intrinsics_vec256
    v1_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v00, v16);
    Lib_IntVector_Intrinsics_vec256
    v2_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v20, v30);
    Lib_IntVector_Intrinsics_vec256
    v3_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v20, v30);
    Lib_IntVector_Intrinsics_vec256
    v4_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v40, v50);
    Lib_IntVector_Intrinsics_vec256
    v5_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v40, v50);
    Lib_IntVector_Intrinsics_vec256
    v6_ = Lib_IntVector_Intrinsics_vec256_interleave_low32(v60, v70);
    Lib_IntVector_Intrinsics_vec256
    v7_ = Lib_IntVector_Intrinsics_vec256_interleave_high32(v60, v70);
    Lib_IntVector_Intrinsics_vec256 v0_0 = v0_;
    Lib_IntVector_Intrinsics_vec256 v1_0 = v1_;
    Lib_IntVector_Intrinsics_vec256 v2_0 = v2_;
    Lib_IntVector_Intrinsics_vec256 v3_0 = v3_;
    Lib_IntVector_Intrinsics_vec256 v4_0 = v4_;
    Lib_IntVector_Intrinsics_vec256 v5_0 = v5_;
    Lib_IntVector_Intrinsics_vec256 v6_0 = v6_;
    Lib_IntVector_Intrinsics_vec256 v7_0 = v7_;
    Lib_IntVector_Intrinsics_vec256
    v0_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v0_0, v2_0);
    Lib_IntVector_Intrinsics_vec256
    v2_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v0_0, v2_0);
    Lib_IntVector_Intrinsics_vec256
    v1_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v1_0, v3_0);
    Lib_IntVector_Intrinsics_vec256
    v3_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v1_0, v3_0);
    Lib_IntVector_Intrinsics_vec256
    v4_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v4_0, v6_0);
    Lib_IntVector_Intrinsics_vec256
    v6_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v4_0, v6_0);
    Lib_IntVector_Intrinsics_vec256
    v5_1 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v5_0, v7_0);
    Lib_IntVector_Intrinsics_vec256
    v7_1 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v5_0, v7_0);
    Lib_IntVector_Intrinsics_vec256 v0_10 = v0_1;
    Lib_IntVector_Intrinsics_vec256 v1_10 = v1_1;
    Lib_IntVector_Intrinsics_vec256 v2_10 = v2_1;
    Lib_IntVector_Intrinsics_vec256 v3_10 = v3_1;
    Lib_IntVector_Intrinsics_vec256 v4_10 = v4_1;
    Lib_IntVector_Intrinsics_vec256 v5_10 = v5_1;
    Lib_IntVector_Intrinsics_vec256 v6_10 = v6_1;
    Lib_IntVector_Intrinsics_vec256 v7_10 = v7_1;
    Lib_IntVector_Intrinsics_vec256
    v0_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v0_10, v4_10);
    Lib_IntVector_Intrinsics_vec256
    v4_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v0_10, v4_10);
    Lib_IntVector_Intrinsics_vec256
    v1_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v1_10, v5_10);
    Lib_IntVector_Intrinsics_vec256
    v5_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v1_10, v5_10);
    Lib_IntVector_Intrinsics_vec256
    v2_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v2_10, v6_10);
    Lib_IntVector_Intrinsics_vec256
    v6_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v2_10, v6_10);
    Lib_IntVector_Intrinsics_vec256
    v3_2 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v3_10, v7_10);
    Lib_IntVector_Intrinsics_vec256
    v7_2 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v3_10, v7_10);
    Lib_IntVector_Intrinsics_vec256 v0_20 = v0_2;
    Lib_IntVector_Intrinsics_vec256 v1_20 = v1_2;
    Lib_IntVector_Intrinsics_vec256 v2_20 = v2_2;
    Lib_IntVector_Intrinsics_vec256 v3_20 = v3_2;
    Lib_IntVector_Intrinsics_vec256 v4_20 = v4_2;
    Lib_IntVector_Intrinsics_vec256 v5_20 = v5_2;
    Lib_IntVector_Intrinsics_vec256 v6_20 = v6_2;
    Lib_IntVector_Intrinsics_vec256 v7_20 = v7_2;
    Lib_IntVector_Intrinsics_vec256 v0 = v0_20;
    Lib_IntVector_Intrinsics_vec256 v1 = v2_20;
    Lib_IntVector_Intrinsics_vec256 v2 = v1_20;
    Lib_IntVector_Intrinsics_vec256 v3 = v3_20;
    Lib_IntVector_Intrinsics_vec256 v4 = v4_20;
    Lib_IntVector_Intrinsics_vec256 v5 = v6_20;
    Lib_IntVector_Intrinsics_vec256 v6 = v5_20;
    Lib_IntVector_Intrinsics_vec256 v7 = v7_20;
    Lib_IntVector_Intrinsics_vec256 v01 = k[8U];
    Lib_IntVector_Intrinsics_vec256 v110 = k[9U];
    Lib_IntVector_Intrinsics_vec256 v21 = k[10U];
    Lib_IntVector_Intrinsics_vec256 v31 = k[11U];
    Lib_IntVector_Intrinsics_vec256 v41 = k[12U];
    Lib_IntVector_Intrinsics_vec256 v51 = k[13U];
    Lib_IntVector_Intrinsics_vec256 v61 = k[14U];
    Lib_IntVector_Intrinsics_vec256 v71 = k[15U];
    Lib_IntVector_Intrinsics_vec256
    v0_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v01, v110);
    Lib_IntVector_Intrinsics_vec256
    v1_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v01, v110);
    Lib_IntVector_Intrinsics_vec256
    v2_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v21, v31);
    Lib_IntVector_Intrinsics_vec256
    v3_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v21, v31);
    Lib_IntVector_Intrinsics_vec256
    v4_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v41, v51);
    Lib_IntVector_Intrinsics_vec256
    v5_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v41, v51);
    Lib_IntVector_Intrinsics_vec256
    v6_3 = Lib_IntVector_Intrinsics_vec256_interleave_low32(v61, v71);
    Lib_IntVector_Intrinsics_vec256
    v7_3 = Lib_IntVector_Intrinsics_vec256_interleave_high32(v61, v71);
    Lib_IntVector_Intrinsics_vec256 v0_4 = v0_3;
    Lib_IntVector_Intrinsics_vec256 v1_4 = v1_3;
    Lib_IntVector_Intrinsics_vec256 v2_4 = v2_3;
    Lib_IntVector_Intrinsics_vec256 v3_4 = v3_3;
    Lib_IntVector_Intrinsics_vec256 v4_4 = v4_3;
    Lib_IntVector_Intrinsics_vec256 v5_4 = v5_3;
    Lib_IntVector_Intrinsics_vec256 v6_4 = v6_3;
    Lib_IntVector_Intrinsics_vec256 v7_4 = v7_3;
    Lib_IntVector_Intrinsics_vec256
    v0_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v0_4, v2_4);
    Lib_IntVector_Intrinsics_vec256
    v2_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v0_4, v2_4);
    Lib_IntVector_Intrinsics_vec256
    v1_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v1_4, v3_4);
    Lib_IntVector_Intrinsics_vec256
    v3_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v1_4, v3_4);
    Lib_IntVector_Intrinsics_vec256
    v4_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v4_4, v6_4);
    Lib_IntVector_Intrinsics_vec256
    v6_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v4_4, v6_4);
    Lib_IntVector_Intrinsics_vec256
    v5_11 = Lib_IntVector_Intrinsics_vec256_interleave_low64(v5_4, v7_4);
    Lib_IntVector_Intrinsics_vec256
    v7_11 = Lib_IntVector_Intrinsics_vec256_interleave_high64(v5_4, v7_4);
    Lib_IntVector_Intrinsics_vec256 v0_12 = v0_11;
    Lib_IntVector_Intrinsics_vec256 v1_12 = v1_11;
    Lib_IntVector_Intrinsics_vec256 v2_12 = v2_11;
    Lib_IntVector_Intrinsics_vec256 v3_12 = v3_11;
    Lib_IntVector_Intrinsics_vec256 v4_12 = v4_11;
    Lib_IntVector_Intrinsics_vec256 v5_12 = v5_11;
    Lib_IntVector_Intrinsics_vec256 v6_12 = v6_11;
    Lib_IntVector_Intrinsics_vec256 v7_12 = v7_11;
    Lib_IntVector_Intrinsics_vec256
    v0_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v0_12, v4_12);
    Lib_IntVector_Intrinsics_vec256
    v4_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v0_12, v4_12);
    Lib_IntVector_Intrinsics_vec256
    v1_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v1_12, v5_12);
    Lib_IntVector_Intrinsics_vec256
    v5_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v1_12, v5_12);
    Lib_IntVector_Intrinsics_vec256
    v2_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v2_12, v6_12);
    Lib_IntVector_Intrinsics_vec256
    v6_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v2_12, v6_12);
    Lib_IntVector_Intrinsics_vec256
    v3_21 = Lib_IntVector_Intrinsics_vec256_interleave_low128(v3_12, v7_12);
    Lib_IntVector_Intrinsics_vec256
    v7_21 = Lib_IntVector_Intrinsics_vec256_interleave_high128(v3_12, v7_12);
    Lib_IntVector_Intrinsics_vec256 v0_22 = v0_21;
    Lib_IntVector_Intrinsics_vec256 v1_22 = v1_21;
    Lib_IntVector_Intrinsics_vec256 v2_22 = v2_21;
    Lib_IntVector_Intrinsics_vec256 v3_22 = v3_21;
    Lib_IntVector_Intrinsics_vec256 v4_22 = v4_21;
    Lib_IntVector_Intrinsics_vec256 v5_22 = v5_21;
    Lib_IntVector_Intrinsics_vec256 v6_22 = v6_21;
    Lib_IntVector_Intrinsics_vec256 v7_22 = v7_21;
    Lib_IntVector_Intrinsics_vec256 v8 = v0_22;
    Lib_IntVector_Intrinsics_vec256 v9 = v2_22;
    Lib_IntVector_Intrinsics_vec256 v10 = v1_22;
    Lib_IntVector_Intrinsics_vec256 v11 = v3_22;
    Lib_IntVector_Intrinsics_vec256 v12 = v4_22;
    Lib_IntVector_Intrinsics_vec256 v13 = v6_22;
    Lib_IntVector_Intrinsics_vec256 v14 = v5_22;
    Lib_IntVector_Intrinsics_vec256 v15 = v7_22;
    k[0U] = v0;
    k[1U] = v8;
    k[2U] = v1;
    k[3U] = v9;
    k[4U] = v2;
    k[5U] = v10;
    k[6U] = v3;
    k[7U] = v11;
    k[8U] = v4;
    k[9U] = v12;
    k[10U] = v5;
    k[11U] = v13;
    k[12U] = v6;
    k[13U] = v14;
    k[14U] = v7;
    k[15U] = v15;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)16U; i++)
    {
      Lib_IntVector_Intrinsics_vec256
      x = Lib_IntVector_Intrinsics_vec256_load_le(plain + i * (uint32_t)32U);
      Lib_IntVector_Intrinsics_vec256 y = Lib_IntVector_Intrinsics_vec256_xor(x, k[i]);
      Lib_IntVector_Intrinsics_vec256_store_le(plain + i * (uint32_t)32U, y);
    }
    memcpy(uu____2, plain, rem * sizeof (plain[0U]));
  }
}

/* SNIPPET_END: Hacl_Chacha20_Vec256_chacha20_decrypt_256 */

