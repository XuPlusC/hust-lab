#include "common.h"
#include "syscall.h"
#include "fs.h"

#define SYSCALL_RET SYSCALL_ARG1(r)

enum {FD_STDIN, FD_STDOUT, FD_STDERR, FD_FB, FD_EVENTS, FD_DISPINFO, FD_NORMAL};

_RegSet* do_syscall_none(uintptr_t *args, _RegSet *r) {
  SYSCALL_RET = 1;
  return r;
}

_RegSet* do_syscall_open(uintptr_t *args, _RegSet *r) {
  return r;
}

_RegSet* do_syscall_read(uintptr_t *args, _RegSet *r) {
  return r;

}

_RegSet* do_syscall_write(uintptr_t *args, _RegSet *r) {
  int fd = args[1];
  char* buf = (char *)args[2];
  int len = args[3];
  SYSCALL_RET = fs_write(fd, buf, len);
  return r;
}

_RegSet* do_syscall_exit(uintptr_t *args, _RegSet *r) {
  _halt(args[1]);
  return r;
}

_RegSet* do_syscall_close(uintptr_t *args, _RegSet *r) {
  return r;
}

_RegSet* do_syscall_lseek(uintptr_t *args, _RegSet *r) {
  return r;
}

_RegSet* do_syscall_brk(uintptr_t *args, _RegSet *r) {
  SYSCALL_RET = 0;
  return r;
}

_RegSet* do_syscall(_RegSet *r) {
  uintptr_t a[4];
  a[0] = SYSCALL_ARG1(r);
  a[1] = SYSCALL_ARG2(r);
  a[2] = SYSCALL_ARG3(r);
  a[3] = SYSCALL_ARG4(r);

  switch (a[0]) {
    case SYS_none:
      return do_syscall_none(a, r);
    case SYS_open:
      return do_syscall_open(a, r);
    case SYS_read:
      return do_syscall_read(a, r);
    case SYS_write:
      return do_syscall_write(a, r);
    case SYS_exit:
      return do_syscall_exit(a, r);
    case SYS_kill:
      TODO();
      break;
    case SYS_getpid:
      TODO();
      break;
    case SYS_close:
      return do_syscall_close(a, r);
    case SYS_lseek:
      return do_syscall_lseek(a, r);
    case SYS_brk:
      return do_syscall_brk(a, r);
    case SYS_fstat:
      TODO();
      break;
    case SYS_time:
      TODO();
      break;
    case SYS_signal:
      TODO();
      break;
    case SYS_execve:
      TODO();
      break;
    case SYS_fork:
      TODO();
      break;
    case SYS_link:
      TODO();
      break;
    case SYS_unlink:
      TODO();
      break;
    case SYS_wait:
      TODO();
      break;
    case SYS_times:
      TODO();
      break;
    case SYS_gettimeofday:
      TODO();
      break;
    default: panic("Unhandled syscall ID = %d", a[0]);
  }

  return NULL;
}
