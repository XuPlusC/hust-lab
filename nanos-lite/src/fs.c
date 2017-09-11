#include "fs.h"

typedef struct {
  char *name;
  size_t size;
  off_t disk_offset;
  off_t open_offset;
} Finfo;

enum {FD_STDIN, FD_STDOUT, FD_STDERR, FD_FB, FD_EVENTS, FD_DISPINFO, FD_NORMAL};
// enum {SEEK_SET, SEEK_CUR, SEEK_END};

extern void ramdisk_read(void *buf, off_t offset, size_t len);
extern void ramdisk_write(const void *buf, off_t offset, size_t len);

/* This is the information about all files in disk. */
static Finfo file_table[] __attribute__((used)) = {
  {"stdin (note that this is not the actual stdin)", 0, 0},
  {"stdout (note that this is not the actual stdout)", 0, 0},
  {"stderr (note that this is not the actual stderr)", 0, 0},
  [FD_FB] = {"/dev/fb", 0, 0},
  [FD_EVENTS] = {"/dev/events", 0, 0},
  [FD_DISPINFO] = {"/proc/dispinfo", 128, 0},
#include "files.h"
};

#define NR_FILES (sizeof(file_table) / sizeof(file_table[0]))

void init_fs() {
  // TODO: initialize the size of /dev/fb

  // for (int i = 0; i < NR_FILES; ++i) {
    // file_table[i].open_offset = 0;
  // }
}

int fs_open(const char *pathname, int flags, int mode) {
  int fd = -1;

  for (int i = 0, nr_files = NR_FILES; i < nr_files; ++i) {
    if (strcmp(file_table[i].name, pathname) == 0) {
      fd = i;
      break;
    }
  }

  if (fd != -1) {
    file_table[fd].open_offset = 0;
  }

  return fd;
}


ssize_t fs_read(int fd, void *buf, size_t len) {
  size_t nr_read = -1;

  if (fd < FD_STDIN || fd >= NR_FILES || buf == NULL) {
    return nr_read;
  }

  if (fd > FD_DISPINFO && fd < NR_FILES) {
    Finfo *finfo = &file_table[fd];
    nr_read = finfo->size - finfo->open_offset;
    nr_read = (nr_read < len) ? nr_read : len;
    ramdisk_read(buf, finfo->disk_offset + finfo->open_offset, nr_read);
    finfo->open_offset += nr_read;
  } else if (fd >= FD_STDIN && fd < NR_FILES) {
    nr_read = 0;
  }

  return nr_read;
}

ssize_t fs_write(int fd, const void *buf, size_t len) {
  size_t nr_write = -1;
  char *_buf = (char *)buf;

  if (fd < FD_STDIN || fd >= NR_FILES || buf == NULL) {
    return nr_write;
  }

  if (fd > FD_DISPINFO && fd < NR_FILES) {
    Finfo *finfo = &file_table[fd];
    nr_write = finfo->size - finfo->open_offset;
    nr_write = (nr_write < len) ? nr_write : len;
    ramdisk_write(buf, finfo->disk_offset + finfo->open_offset, nr_write);
    finfo->open_offset += nr_write;
  } else if (fd == FD_STDOUT || fd == FD_STDERR) {
    nr_write = 0;

    while (len > 0) {
      _putc(_buf[nr_write]);
      --len;
      ++nr_write;
    }
  } else if (fd >= FD_STDIN && fd < NR_FILES) {
    nr_write = 0;
  }

  return nr_write;
}

off_t fs_lseek(int fd, off_t offset, int whence) {
  off_t result_offset = -1;

  if (fd < FD_STDIN || fd >= NR_FILES) {
    return result_offset;
  }

  if (fd > FD_DISPINFO && fd < NR_FILES) {
    Finfo *finfo = &file_table[fd];

    switch (whence) {
      case SEEK_SET:
        result_offset = offset;
        result_offset = (result_offset >= 0 && result_offset < finfo->size) ? result_offset : -1;
        finfo->open_offset = (result_offset != -1) ? result_offset : finfo->open_offset;
        break;
      case SEEK_CUR:
        result_offset = finfo->open_offset + offset;
        result_offset = (result_offset >= 0 && result_offset < finfo->size) ? result_offset : -1;
        finfo->open_offset = (result_offset != -1) ? result_offset : finfo->open_offset;
        break;
      case SEEK_END:
        result_offset = finfo->size - 1 + offset;
        result_offset = (result_offset >= 0 && result_offset < finfo->size) ? result_offset : -1;
        finfo->open_offset = (result_offset != -1) ? result_offset : finfo->open_offset;
        break;
      default:
        break;
    }
  }

  return result_offset;
}

int fs_close(int fd) {
  if (fd < FD_STDIN || fd >= NR_FILES) {
    return -1;
  } else {
    return 0;
  }
}

