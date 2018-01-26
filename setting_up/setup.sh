#!/bin/bash

clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
MAG='\033[0;1;35m'
BOLD='\033[0;1m'
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

function cargo_install_helper {
# $1 = the command to check
# $2 = optional install method ('--git' for example)
# $3 = crate name or git URL
# $4 = description
    CMD="command -v $1"
    EXISTING_INSTALL=$($CMD)
    if [ "" != "$EXISTING_INSTALL" ]
    then
        highlight "Found existing" "$1" "at $EXISTING_INSTALL"
        highlight "\tif neccessary upgrade with 'cargo install --force $2 $3'"
    else
        highlight "Installing (= building)" "$3" ", $4"
        cargo install $2 $3
    fi
}

# STEP 1: Rustup toolchain manager, rust compiler and cargo build tool
CARGO_ENV_FILE=~/.cargo/env
if [ -e "$CARGO_ENV_FILE" ]
then
	highlight "Existing" "rustup" "found, running an update"
	source $CARGO_ENV_FILE
	rustup update
    highlight "Installing the" "Rust nightly toolchain"
    rustup toolchain add nightly
else
	highlight "Installing"  "rustup" "with the nightly toolchain"
	curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly
	source $CARGO_ENV_FILE
fi

# STEP 2: Defaulting to the nightly compiler
highlight "Selecting the" "rust nightly toolchain" "as default"
rustup default nightly

# STEP 3: Adding the Rust sources (needed by Xargo)
highlight "Installing" "rust stdlib sources"
rustup component add rust-src

# STEP 4: Installing the GNU Arm Embedded Toolchain
export PATH=$PATH:"$HOME/.armtoolchain/gcc-arm-none-eabi-7-2017-q4-major/bin/"
EXISTING_ARM_LOC=`command -v arm-none-eabi-ld`

if [ -x $EXISTING_ARM_LOC ]
then
    highlight "Found" "GNU Arm Embedded Toolchain" "at $EXISTING_ARM_LOC"
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
    highlight "Please add" "$HOME/.armtoolchain/gcc-arm-none-eabi-7-2017-q4-major/bin/" "to your PATH"
fi

# STEP 5: Installing Xargo
cargo_install_helper xargo "" xargo "the cross compilation toolchain for Rust"

# STEP 6: Installing bobbin-cli
cargo_install_helper bobbin "--git" "git://github.com/egribnau/bobbin-cli"  "the embedded development tool for Rust"

# STEP 7: Checking and informing about PATH
highlight "Running" "bobbin check" "to check the installation"
bobbin check

highlight "Please check ABOVE the following lines are not 'Not Found'"
highlight "Bobbin"      "\t> 0.8.1-dev \t" "if the version is lower, run 'cargo install --force --git git://github.com/egribnau/bobbin-cli'"
highlight "Rust"        "\t> 1.25.0-nightly \t"
highlight "Cargo"       "\t> 0.25.0-nightly \t"
highlight "Xargo"       "\t> 0.3.10 \t" "if the version is lower, run 'cargo install --force xargo'"
highlight "GCC"         "\t> 7.2.1 \t" "check fails currently, check by hand using 'arm-none-eabi-gcc --version'"
highlight "dfu-util"    "\t> 0.8 \t\t" "(install with your package manager if not present and re-run 'bobbin check')"

printf "\n"
highlight "" "Script is done, now YOU need to do some work!\n"
highlight "Add rustup and cargo to your PATH,"
highlight "" "so run in you shell:" "\tsource ~/.cargo/env"
highlight "Add ARM toolchain to you PATH if it was installed by this script, so run in you shell:"
highlight "" "\texport PATH=\$PATH:$HOME/.armtoolchain/gcc-arm-none-eabi-7-2017-q4-major/bin"

printf "\n"
highlight "And yes, it is a smart move to put this stuff in your" ".profile"
highlight "(rustup does that by default, so all tools except the ARM toolchain"
highlight "should work after a logout/login)"


