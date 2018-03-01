This repo contains descriptions and scripts to install a development enviroment for the Rust-on-embedded workshop in Gouda, March 5th. 

# Preparing your laptop for the meetup

There are two ways to prepare:
1. Use the provided Virtual Machine 
2. Install the required tools on your Linux of MacOS machine

Note: for Windows users, please use the provided Virtual Machine

## Virtual Machine

The Virtual Machine was created with VirtualBox and was exported as an 'appliance'. 
It can be downloaded from <<LINK HERE>>.
  
## Install the required tools

Again, two choices:
1. use the scripts in the setting_up directory in this repo (Linux only)
2. do it by hand using the following guide:

### Install by hand
1. Rustup - install from https://rustup.rs
2. Rust nightly compiler - `rustup add nightly`
3. Select the nightly compiler as default - `rustup default nightly`
  or remember to set it as an override for every project during the workshop
4. Install Xargo - `cargo install xargo`, to update `cargo install --force xargo`
5. Install Bobbin (from a fork) -  `cargo install --git git://github.com/egribnau/bobbin-cli`

### Install optional tools

These tools are installed in the VM, but are optional:

1. Visual Studio Code - install from <<link>>
2. Rust Language Server - `rustup component add rls-preview rust-analysis rust-src`


