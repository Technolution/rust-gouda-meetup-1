#![feature(used)]
#![no_std]

extern crate cortex_m;
extern crate cortex_m_rt;
extern crate cortex_m_semihosting;
extern crate stm32f103xx;

use core::fmt::Write;

use cortex_m::asm;
use cortex_m_semihosting::hio;

fn main() {
    let mut loop_count = 0;
    loop {
        if let Ok(mut stdout) = hio::hstdout() {
            writeln!(stdout, "Hello, world {}!", loop_count).unwrap();
            loop_count += 1;

        }
    }
}

// As we are not using interrupts, we just register a dummy catch all handler
#[link_section = ".vector_table.interrupts"]
#[used]
static INTERRUPTS: [extern "C" fn(); 240] = [default_handler; 240];

extern "C" fn default_handler() {}
