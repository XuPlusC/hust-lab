#include "nemu.h"
#include "device/mmio.h"

#define PMEM_SIZE (128 * 1024 * 1024)
#define PGSIZE    4096    // Bytes mapped by a page
#define PGMASK          (PGSIZE - 1)    // Mask for bit ops
#define PGROUNDUP(sz)   (((sz)+PGSIZE-1) & ~PGMASK)
#define PGROUNDDOWN(a)  (((a)) & ~PGMASK)

// Page directory and page table constants
#define NR_PDE    1024    // # directory entries per page directory
#define NR_PTE    1024    // # PTEs per page table
#define PGSHFT    12      // log2(PGSIZE)
#define PTXSHFT   12      // Offset of PTX in a linear address
#define PDXSHFT   22      // Offset of PDX in a linear address

// Page table/directory entry flags
#define PTE_P     0x001     // Present
#define PTE_W     0x002     // Writeable
#define PTE_U     0x004     // User
#define PTE_PWT   0x008     // Write-Through
#define PTE_PCD   0x010     // Cache-Disable
#define PTE_A     0x020     // Accessed
#define PTE_D     0x040     // Dirty

typedef uint32_t PTE;
typedef uint32_t PDE;
#define PDX(va)     (((uint32_t)(va) >> PDXSHFT) & 0x3ff)
#define PTX(va)     (((uint32_t)(va) >> PTXSHFT) & 0x3ff)
#define OFF(va)     ((uint32_t)(va) & 0xfff)

// construct virtual address from indexes and offset
#define PGADDR(d, t, o) ((uint32_t)((d) << PDXSHFT | (t) << PTXSHFT | (o)))

// Address in page table or page directory entry
#define PTE_ADDR(pte)   ((uint32_t)(pte) & ~0xfff)

#define pmem_rw(addr, type) *(type *)({\
    Assert(addr < PMEM_SIZE, "physical address(0x%08x) is out of bound, EIP = 0x%08x", addr, cpu.eip); \
    guest_to_host(addr); \
    })

uint8_t pmem[PMEM_SIZE];

/* Memory accessing interfaces */

uint32_t paddr_read(paddr_t addr, int len) {
  int map_NO = is_mmio(addr);

  if (map_NO == -1) {
    return pmem_rw(addr, uint32_t) & (~0u >> ((4 - len) << 3));
  } else {
    return mmio_read(addr, len, map_NO);
  }
}

void paddr_write(paddr_t addr, int len, uint32_t data) {
  int map_NO = is_mmio(addr);

  if (map_NO == -1) {
    memcpy(guest_to_host(addr), &data, len);
  } else {
    mmio_write(addr, len, data, map_NO);
  }
}

uint32_t vaddr_read(vaddr_t addr, int len) {
  if (PTX(addr) != PTX(addr + len - 1)) {
    // cross the page boundary
    vaddr_t page_bound = PGROUNDUP(addr);
    int nr_inpage = page_bound - addr;
    int nr_outpage = len - nr_inpage;

    Log("nr_inpage = %d, nr_outpage = %d, start ptx = %d, end ptx = %d",
        nr_inpage, nr_outpage, PTX(addr), PTX(addr + len-1));
    Assert(0, "cross the page boundary when read %d bytes in 0x%08x", len, addr);
  } else {
    return paddr_read(addr, len);
  }
}

void vaddr_write(vaddr_t addr, int len, uint32_t data) {
  if (PTX(addr) != PTX(addr + len - 1)) {
    // cross the page boundary
    vaddr_t page_bound = PGROUNDUP(addr);
    int nr_inpage = page_bound - addr;
    int nr_outpage = len - nr_inpage;

    Log("nr_inpage = %d, nr_outpage = %d, start ptx = %d, end ptx = %d",
        nr_inpage, nr_outpage, PTX(addr), PTX(addr + len-1));
    Assert(0, "cross the page boundary when write %d bytes in 0x%08x", len, addr);
  } else {
    paddr_write(addr, len, data);
  }
}
