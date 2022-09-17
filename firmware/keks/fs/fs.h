#include <stdint.h>

int fs_mount(void);
int fs_format(void);
void fs_list_dir(char *path);
void fs_mkdir(char *path);
void fs_unlink(char *path);
void *fs_mallocfile(char *path);
int fs_write_file(char *path, char *buf, uint32_t len);
int fs_touch(char *path);
int fs_size(char *path);

int fs_load(uint32_t ptr, char *path);

uint32_t fs_total(void);
uint32_t fs_free(void);

