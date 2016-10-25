#ifndef BIN_LAYOUT_H_
#define BIN_LAYOUT_H_

#define __to_section(x)	__attribute__((section(x)))

#define LAYOUT_CODE_SECTION	"__libc_freeres_fn"
#define LAYOUT_DATA_SECTION	"__libc_lock_fhs"

#endif
