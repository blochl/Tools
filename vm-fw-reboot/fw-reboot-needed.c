#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>
#include <stdlib.h>

#define VARFILE_SIZE                      (1 << 17)  /* 128 K */
#define VAR_INFO_SIZE                     6
#define EFI_OS_INDICATIONS_BOOT_TO_FW_UI  0x0000000000000001
#define LAST_USE                          0x000f

static const uint16_t var_pattern[] = {
    'O', 's', 'I', 'n', 'd', 'i', 'c', 'a', 't', 'i', 'o', 'n', 's', 0
};

typedef union info_val
{
    uint16_t aux[VAR_INFO_SIZE];
    uint64_t osind;
} info_val;

static bool is_fw_reboot_required(char *file_path) {
    FILE *ff;
    long fsize;
    uint16_t *buf = NULL;
    int i;
    int j = 0;
    int k = 0;
    bool match = false;
    info_val val;

    ff = fopen(file_path, "rb");
    if (ff == NULL) {
        fprintf(stderr, "Unable to open the vars file %s!\n", file_path);
        exit(1);
        /* return false; */
    }

    fseek(ff, 0, SEEK_END);
    fsize = ftell(ff);
    fseek(ff, 0, SEEK_SET);

    assert(fsize == VARFILE_SIZE);

    buf = malloc(fsize);
    if (buf == NULL)
    {
        fprintf(stderr, "Memory error for reading the vars file!\n");
        fclose(ff);
        exit(1);
        /* return false; */
    }

    fread(buf, fsize, 1, ff);
    fclose(ff);

    for(i = 0; i < VARFILE_SIZE / sizeof(buf[0]); i++) {
        if (match && k < VAR_INFO_SIZE) {
            val.aux[k] = buf[i];
            k++;
            continue;
        } else if (match) {
            k = 0;
            if ((val.osind & EFI_OS_INDICATIONS_BOOT_TO_FW_UI) &&
                ((val.aux[VAR_INFO_SIZE - 1] & LAST_USE) == LAST_USE)) {
                free(buf);
                return true;
            }
        }
        j = (buf[i] == var_pattern[j])? j + 1 : 0;
        match = (j == sizeof(var_pattern) / sizeof(var_pattern[0]));
    }

    free(buf);
    return false;
}

int main(int argc, char *argv[]) {
    int i;

    for (i = 1; i < argc; i++) {
        if (is_fw_reboot_required(argv[i])) {
            printf("FW reboot needed for: %s.\n", argv[i]);
        } else {
            printf("FW reboot NOT needed for: %s.\n", argv[i]);
        }
    }
}
