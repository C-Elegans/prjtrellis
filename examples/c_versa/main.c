#include <stdint.h>

#define LED (*(volatile uint32_t*) 0x2000000)

void delay() {
  for(volatile int i=0; i<2500; i++) {}
}

int main() {
  int i = 0;
  while(1){
    LED = i++;
    delay();
  }
}
