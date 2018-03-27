#include "stdint.h"
#include "stdio.h"
#include "Spec_Lib_Print.h"

void Spec_Lib_Print_print_bytes(uint32_t len, uint8_t* buffer) {
  for (int i = 0; i < len; i++){
    printf("%02x ", buffer[i]);
  }
  printf("\n");
}

void Spec_Lib_Print_print_compare(uint32_t len, uint8_t* buffer1, uint8_t* buffer2) {
  for (int i = 0; i < len; i++){
    printf("%02x ", buffer1[i]);
  }
  printf("\n");
  for (int i = 0; i < len; i++){
    printf("%02x ", buffer2[i]);
  }
  printf("\n");
}

void Spec_Lib_Print_print_compare_display(uint32_t len, uint8_t* buffer1, uint8_t* buffer2) {
  Spec_Lib_Print_print_compare(len, buffer1, buffer2);
  int res = 1;
  for (int i = 0; i < len; i++) {
    res |= buffer1[i] ^ buffer2[i];
  }
  if (res) {
    printf("Success !\n");
  } else {
    printf("Failure !\n");
  }
  printf("\n");
}

