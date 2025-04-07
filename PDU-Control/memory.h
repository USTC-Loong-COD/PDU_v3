#ifndef __MEMORY_H__
#define __MEMORY_H__

void memory_init();
void * malloc(unsigned long size);
void free(void * ptr);

int load_byte_volatile(volatile const void * addr);
void store_byte_volatile(volatile void * addr, int value);
int load_byte(const void * addr);
void store_byte(void * addr, int value);

#endif // __MEMORY_H__