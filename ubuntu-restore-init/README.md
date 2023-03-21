# Script for rollbackable Ubuntu installations

## Usage:

1. Install Ubuntu on an EFI system, with two partitions:
    1. An [EFI System Partition (ESP)](https://www.google.com/search?&q=linux+esp).
    1. A **Btrfs** root partition.
1. Reboot as usual after the installation.
1. Copy the script to a volatile location (_e.g._ `/run/user/1000/`):
    ```
    rsync -a ubuntu-restore-init.sh <USER>@<HOST>:/run/user/1000/
    ```
1. Run it.
1. The system will reboot.
1. Enjoy playing with the station with an easy rollback.

## Instructions for rollback:

If you want to rollback your rollbackable Ubuntu installation, do (**as root**):

```bash
hard-restore-machine
```
