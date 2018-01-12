#!/bin/bash

clear

# TODO: test for the existence of:
# curl
# tar
# bzip2
# cc & ld (maybe)
# needed apt install curl bzip2 build-essential

GREEN='\033[0;92m'
MAG='\033[0;35m'
RESET='\033[0m'

function highlight {
    printf "$MAG>>> $GREEN"
    printf "$1 "
    printf "$MAG"
    printf "$2 "
    printf "$GREEN"
    printf "$3"
    printf "$RESET\n"
}

env_file=~/.cargo/env

if [ -e "$env_file" ]
then
	highlight "Existing" "rustup" "found, running an update"
	source $env_file
	rustup update
    highlight "Installing the" "Rust nightly toolchain"
    rustup toolchain add nightly
else
	highlight "Installing"  "rustup" "with the nightly toolchain"
	curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly
	source $env_file
fi

highlight "Selecting the" "rust nightly toolchain" "as default"
rustup default nightly

highlight "Installing" "rust stdlib sources"
rustup component add rust-src

if [ -e "$HOME/.armtoolchain/gcc-arm-none-eabi-7-2017-q4-major/bin/arm-none-eabi-ld" ]
then
    highlight "Found" "GNU Arm Embedded Toolchain"
else
    if [ -e /tmp/gcc-arm.tar.bz2 ]
    then
        highlight "Found existing download for" "GNU Arm Embedded toolchain" "at /tmp/gcc-arm.tar.bz2, not downloading now"
    else
        highlight "Downloading" "GNU Arm Embedded Toolchain"
        curl https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/7-2017q4/gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2 -o /tmp/gcc-arm.tar.bz2
    fi
    highlight "Creating" "GNU Arm Embedded toolchain" "directory at $MAG~/.armtoolchain"
    mkdir -p ~/.armtoolchain
    highlight "Extracting" "GNU Arm Embedded toolchain"
    cd ~/.armtoolchain && tar jxf /tmp/gcc-arm.tar.bz2
fi

export PATH=$PATH:"$HOME/.armtoolchain/gcc-arm-none-eabi-7-2017-q4-major/bin/"
highlight "Please add" "$HOME/.armtoolchain/gcc-arm-none-eabi-7-2017-q4-major/bin/" "to your PATH"

highlight "Installing (= building)" "xargo" ", the cross compilation toolchain for Rust"
cargo install xargo

highlight "Installing (=building)" "bobbin-cli" ", the embedded development tool for Rust"
cargo install --git https://github.com/bobbin-rs/bobbin-cli.git

highlight "Running" "bobbin check" "to check the installation"
bobbin check

highlight "Please check ABOVE the following lines are not 'Not Found'"
highlight "Bobbin"      "\t> 0.8.0 \t" "if the version is lower, run 'cargo install --force bobbin'"
highlight "Rust"        "\t> 1.25.0-nightly \t"
highlight "Cargo"       "\t> 0.25.0-nightly \t"
highlight "Xargo"       "\t> 0.3.10 \t" "if the version is lower, run 'cargo install --force xargo'"
highlight "GCC"         "\t> 7.2.1 \t" "check fails currently, check by hand using 'arm-none-eabi-gcc --version'"
highlight "dfu-util"    "\t> 0.8 \t\t" "(install with your package manager if not present and re-run 'bobbin check')"

printf "\n"
highlight "Script is done, now you need to do some work!\n"
highlight "Add rustup and cargo to your PATH, so run in you shell:" "\tsource ~/.cargo/env"
highlight "Add ARM toolchain to you PATH, so run in you shell:" "\texport PATH=\$PATH:$HOME/.armtoolchain/gcc-arm-none-eabi-7-2017-q4-major/bin"

printf "\n"
highlight "And yes, it is a smart move to put this stuff in your" ".profile" "(rustup does that by default, so all tools except the ARM toolchain should work after a logout/login)"
