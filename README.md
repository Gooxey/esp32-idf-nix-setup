# esp-idf-nix-template

## Entering the development environment

```bash
$ nix develop
```

## Important

I have used `sudo espflash flash --monitor` inside the `.cargo/config.toml` file because of lacking permissions when flashing the esp.
If you encounter any errors or do not need root permissions to flash, remove the `sudo`.

## Errors

### `NixOS cannot run dynamically linked executables intended for generic linux environments out of the box.`

Install [nix-ld](https://github.com/Mic92/nix-ld)

### Something inside `~/.rustup/toolchains/esp/...` is missing

Reinstall the esp-rs toolchain
```bash
$ espup uninstall
$ espup install
```

## Credit

Template used:
- <https://github.com/esp-rs/esp-idf-template>

Binary size optimizations from:
- <https://github.com/johnthagen/min-sized-rust>
- <https://docs.rust-embedded.org/book/unsorted/speed-vs-size.html>
