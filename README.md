This repo contains descriptions and scripts to install a development enviroment for the Rust-on-embedded workshop in Gouda, March 5th. 

# Preparing your laptop for the meetup

There are two ways to prepare:
1. Use the provided Virtual Machine 
2. Install the required tools on your Linux of MacOS machine

Note: for Windows users, please use the provided Virtual Machine

## Virtual Machine

__DO THIS BEFORE MONDAY EVENING !!!__  (our WiFi is limited)


The Virtual Machine was created with VirtualBox and was exported as an 'appliance'. 
It can be downloaded from https://goo.gl/9EJEx3.


  
## Install the required tools

Again, two choices:
1. use the scripts in the setting_up directory in this repo (Linux only)
2. do it by hand using the following guide:

### Install by hand
Commands to be entered on the command line are shown like `this`.

1. Rustup
    * install from https://rustup.rs
2. Rust nightly compiler 
    * `rustup add nightly`
3. Select the nightly compiler as default 
    * `rustup default nightly`
    * or remember to set it as an override for every project during the workshop
4. Install Xargo 
    * `cargo install xargo`
    * to update `cargo install --force xargo`
5. Install Bobbin (from my fork) 
    * `cargo install --git git://github.com/egribnau/bobbin-cli`
    * to update from my fork `cargo install --force --git git://github.com/egribnau/bobbin-cli`

### Install optional tools

These tools are installed in the VM, but are optional:

1. Visual Studio Code 
    * install from https://code.visualstudio.com/
2. Rust Language Server 
    * `rustup component add rls-preview rust-analysis rust-src`
    
    
## Fallback
On March 5th, we will provide support if you cannot get the tools installed. 
We will have a limited amount of USB-sticks with the VM available. 


