# A simple tool for determining whether FW reboot is needed

## Intro

When running a virtual machine with the [OVMF](https://github.com/tianocore/edk2)
UEFI firmware, sometimes it is needed to determine whether the guest OS
requested a firmware interface reboot. This request is made using the
`OsIndications` UEFI variable. A possible use case for that, is stopping
the guest and rebooting the host into the physical firmware interface, _e.g._
using `systemctl reboot --firmware-setup`.

## Building

A simple `make` will do.

## Usage

```sh
./fw-reboot-needed /path/to/OVMF_VARS.fd [/path/to/another/OVMF_VARS.fd ...]
```

This works while the VM is running, as well as after it was shutdown. Note
that the variable is reset before the VM enters the FW interface. If the VM
is stopped after this reset but before the boot, `fw-reboot-needed` will still
detect that FW reboot is needed - this gives a chance to act on it while the
VM is down. But after VM restart, `fw-reboot-needed` will indicate that FW
reboot is not needed, which is true, as we have already rebooted.

## License

This code is released under the standard 3-clause BSD license.
