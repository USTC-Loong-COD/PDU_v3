#include "memory.h"
#include "abort.h"
#include "macros.h"
#include "mmap.h"
#include "uart_io.h"

struct Block {
    unsigned long size;
    struct Block * next;
};

static struct Block * freeBlocks;
static struct Block * usedBlocks;

void memory_init() {
    freeBlocks = (struct Block *)HEAP_START;
    freeBlocks->size = HEAP_END - HEAP_START;
    freeBlocks->next = NULL;
    usedBlocks = NULL;
}

void * malloc(unsigned long size) {
    unsigned long alignedSize = (size + 7) & ~7;
    struct Block * prev = NULL;
    struct Block * curr = freeBlocks;
    while(curr != NULL) {
        if(curr->size >= alignedSize && curr->size <= alignedSize + sizeof(struct Block)) {
            if(prev == NULL) {
                freeBlocks = curr->next;
            }
            else {
                prev->next = curr->next;
            }
            curr->size = alignedSize;
            curr->next = usedBlocks;
            usedBlocks = curr;
            return (void *)(curr + 1);
        }
        else if(curr->size > alignedSize + sizeof(struct Block)) {
            struct Block * newBlock = (struct Block *)((char *)(curr + 1) + alignedSize);
            newBlock->size = curr->size - alignedSize - sizeof(struct Block);
            newBlock->next = curr->next;
            curr->size = alignedSize;
            curr->next = usedBlocks;
            usedBlocks = curr;
            return (void *)(curr + 1);
        }
        prev = curr;
        curr = curr->next;
    }
    return NULL;
}

void free(void * ptr) {
    struct Block * prev = NULL;
    struct Block * curr = usedBlocks;
    while(curr != NULL) {
        if(curr + 1 == ptr) {
            if(prev == NULL) {
                usedBlocks = curr->next;
            }
            else {
                prev->next = curr->next;
            }
            break;
        }
        prev = curr;
        curr = curr->next;
    }

    if(curr == NULL) {
        uart_puts("\n\rError: Invalid pointer to free: ");
        uart_put_uint32_hex8((unsigned long)ptr);
        uart_puts("\n\r");
        abort();
    }

    // keep free blocks sorted by address
    // if curr is continuous with the some freed block, merge them
    if(freeBlocks == NULL) {
        freeBlocks = curr;
        freeBlocks->next = NULL;
    }
    else {
        struct Block * prev = NULL;
        struct Block * next = freeBlocks;
        while(next != NULL && next < curr) {
            prev = next;
            next = next->next;
        }

        if(next == NULL) {
            curr->next = NULL;
        }
        else if((char *)(curr + 1) + curr->size == (char *)next) {
            curr->size += next->size + sizeof(struct Block);
            curr->next = next->next;
        }
        else {
            curr->next = next;
        }

        if(prev == NULL) {
            freeBlocks = curr;
        }
        else if((char *)(prev + 1) + prev->size == (char *)(curr)) {
            prev->size += curr->size + sizeof(struct Block);
            prev->next = curr->next;
        }
        else {
            prev->next = curr;
        }
    }
}

#if HAS_SB_LB == 1

int load_byte_volatile(volatile const void * addr) {
    return *((volatile char *)addr);
}

void store_byte_volatile(volatile void * addr, int value) {
    *((volatile char *)addr) = value;
}

int load_byte(const void * addr) {
    return *((char *)addr);
}

void store_byte(void * addr, int value) {
    *((char *)addr) = value;
}

#else

static volatile void * align_volatile(volatile void * _ptr, unsigned int alignment) {
    unsigned long ptr = (unsigned long)_ptr;
    unsigned long mask = alignment - 1;
    return (volatile void *)((ptr + mask) & ~mask);
}

static void * align(void * _ptr, unsigned int alignment) {
    unsigned long ptr = (unsigned long)_ptr;
    unsigned long mask = alignment - 1;
    return (void *)((ptr + mask) & ~mask);
}

static volatile void * align_down_volatile(volatile void * _ptr, unsigned int alignment) {
    unsigned long ptr = (unsigned long)_ptr;
    unsigned long mask = alignment - 1;
    return (volatile void *)(ptr & ~mask);
}

static void * align_down(void * _ptr, unsigned int alignment) {
    unsigned long ptr = (unsigned long)_ptr;
    unsigned long mask = alignment - 1;
    return (void *)(ptr & ~mask);
}

int load_byte_volatile(volatile const void * _ptr) {
    volatile const int * p = align_down_volatile((volatile void *)_ptr, 4);
    int data = *p;
    int shiftAmount = ((unsigned long)_ptr & 3) << 3;
    return (data >> shiftAmount) & 0xFF;
}

void store_byte_volatile(volatile void * _ptr, int value) {
    volatile int * p = align_down_volatile(_ptr, 4);
    int data = *p;
    int shiftAmount = ((unsigned long)_ptr & 3) << 3;
    int mask = 0xFF << shiftAmount;
    data = (data & ~mask) | ((value & 0xFF) << shiftAmount);
    *p = data;
}

int load_byte(const void * _ptr) {
    const int * p = align_down((void *)_ptr, 4);
    int data = *p;
    int shiftAmount = ((unsigned long)_ptr & 3) << 3;
    return (data >> shiftAmount) & 0xFF;
}

void store_byte(void * _ptr, int value) {
    int * p = align_down(_ptr, 4);
    int data = *p;
    int shiftAmount = ((unsigned long)_ptr & 3) << 3;
    int mask = 0xFF << shiftAmount;
    data = (data & ~mask) | ((value & 0xFF) << shiftAmount);
    *p = data;
}

#endif