#include "cpu/exec.h"

make_EHelper(mov) {
  operand_write(id_dest, &id_src->val);
  print_asm_template2(mov);
}

make_EHelper(push) {
  rtl_push(&id_dest->val);

  print_asm_template1(push);
}

make_EHelper(pop) {
  rtl_pop(&id_dest->val);
  operand_write(id_dest, &id_dest->val);

  print_asm_template1(pop);
}

make_EHelper(pusha) {
  int width = decoding.is_operand_size_16 ? 2 : 4;
  rtl_lr(&t0, R_ESP, width);
  rtl_lr(&t1, R_EAX, width);
  rtl_push(&t1);
  rtl_lr(&t1, R_ECX, width);
  rtl_push(&t1);
  rtl_lr(&t1, R_EDX, width);
  rtl_push(&t1);
  rtl_lr(&t1, R_EBX, width);
  rtl_push(&t1);
  rtl_push(&t0);
  rtl_lr(&t1, R_EBP, width);
  rtl_push(&t1);
  rtl_lr(&t1, R_ESI, width);
  rtl_push(&t1);
  rtl_lr(&t1, R_EDI, width);
  rtl_push(&t1);

  print_asm("pusha");
}

make_EHelper(popa) {
  int width = decoding.is_operand_size_16 ? 2 : 4;
  rtl_pop(&t1);
  rtl_sr(R_EDI, width, &t1);
  rtl_pop(&t1);
  rtl_sr(R_ESI, width, &t1);
  rtl_pop(&t1);
  rtl_sr(R_EBP, width, &t1);
  rtl_pop(&t1);
  rtl_pop(&t1);
  rtl_sr(R_EBX, width, &t1);
  rtl_pop(&t1);
  rtl_sr(R_EDX, width, &t1);
  rtl_pop(&t1);
  rtl_sr(R_ECX, width, &t1);
  rtl_pop(&t1);
  rtl_sr(R_EAX, width, &t1);

  print_asm("popa");
}

make_EHelper(leave) {
  int width = decoding.is_operand_size_16 ? 2 : 4;
  rtl_lr(&t0, R_EBP, width);
  rtl_sr(R_ESP, width, &t0);
  rtl_pop(&t1);
  rtl_sr(R_EBP, width, &t1);

  print_asm("leave");
}

make_EHelper(cltd) {
  if (decoding.is_operand_size_16) {
    rtl_msb(&t0, (rtlreg_t *)(&reg_w(R_AX)), 2);
    reg_w(R_DX) = t0 ? 0xffff : 0x0000;
  }
  else {
    rtl_msb(&t0, &reg_l(R_EAX), 4);
    reg_l(R_EDX) = t0 ? 0xffffffff : 0x00000000;
  }

  print_asm(decoding.is_operand_size_16 ? "cwtl" : "cltd");
}

make_EHelper(cwtl) {
  if (decoding.is_operand_size_16) {
    rtl_msb(&t0, (rtlreg_t *)(&reg_b(R_AL)), 1);
    reg_b(R_AH) = t0 ? 0xffff : 0x0000;
  }
  else {
    rtl_msb(&t0, (rtlreg_t *)(&reg_w(R_AX)), 2);
    reg_w(R_DX) = t0 ? 0xffff : 0x0000;
  }

  print_asm(decoding.is_operand_size_16 ? "cbtw" : "cwtl");
}

make_EHelper(movsx) {
  id_dest->width = decoding.is_operand_size_16 ? 2 : 4;
  rtl_sext(&t2, &id_src->val, id_src->width);
  operand_write(id_dest, &t2);
  print_asm_template2(movsx);
}

make_EHelper(movzx) {
  id_dest->width = decoding.is_operand_size_16 ? 2 : 4;
  operand_write(id_dest, &id_src->val);
  print_asm_template2(movzx);
}

make_EHelper(lea) {
  rtl_li(&t2, id_src->addr);
  operand_write(id_dest, &t2);
  print_asm_template2(lea);
}
