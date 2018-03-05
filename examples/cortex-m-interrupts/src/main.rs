//! Using a device crate
//!
//! Crates generated using [`svd2rust`] are referred to as device crates. These
//! crates provides an API to access the peripherals of a device. When you
//! depend on one of these crates and the "rt" feature is enabled you don't need
//! link to the cortex-m-rt crate.
//!
//! [`svd2rust`]: https://crates.io/crates/svd2rust
//!
//! Device crates also provide an `interrupt!` macro to register interrupt
//! handlers.
//!
//! This example depends on the [`stm32f103xx`] crate so you'll have to add it
//! to your Cargo.toml.
//!
//! [`stm32f103xx`]: https://crates.io/crates/stm32f103xx
//!
//! ```
//! $ edit Cargo.toml && cat $_
//! [dependencies.stm32f103xx]
//! features = ["rt"]
//! version = "0.8.0"
//! ```
//!
//! ---

#![feature(const_fn)]
#![no_std]

extern crate cortex_m;
extern crate cortex_m_semihosting;
#[macro_use(exception, interrupt)]
extern crate stm32f103xx;

use core::cell::RefCell;
use core::fmt::Write;

use cortex_m::interrupt::{self, Mutex};
use cortex_m::peripheral::syst::SystClkSource;
use cortex_m_semihosting::hio::{self, HStdout};
use stm32f103xx::Interrupt;
use stm32f103xx::GPIOC;

static HSTDOUT: Mutex<RefCell<Option<HStdout>>> = Mutex::new(RefCell::new(None));
static NVIC: Mutex<RefCell<Option<cortex_m::peripheral::NVIC>>> = Mutex::new(RefCell::new(None));
static GPIOC: Mutex<RefCell<Option<stm32f103xx::GPIOC>>> = Mutex::new(RefCell::new(None));
static GPIOA: Mutex<RefCell<Option<stm32f103xx::GPIOA>>> = Mutex::new(RefCell::new(None));
static EXTI: Mutex<RefCell<Option<stm32f103xx::EXTI>>> = Mutex::new(RefCell::new(None));

fn main() {
    let global_p = stm32f103xx::CorePeripherals::take().unwrap();
    let per = stm32f103xx::Peripherals::take().unwrap();

    interrupt::free(|cs| {
        //store a reference to the semihosted stdout
        let hstdout = HSTDOUT.borrow(cs);
        if let Ok(fd) = hio::hstdout() {
            *hstdout.borrow_mut() = Some(fd);
        }

        //enable interrupts
        let mut nvic = global_p.NVIC;
        nvic.enable(Interrupt::TIM2);
        nvic.enable(Interrupt::EXTI0);
        //store interrupt controller
        *NVIC.borrow(cs).borrow_mut() = Some(nvic);

        // Enable port a & c in the register clock control
        per.RCC
            .apb2enr
            .write(|w| w.iopcen().enabled().iopaen().enabled());

        let gpioc = per.GPIOC;
        let gpioa = per.GPIOA;

        // Change PIN13 on GPIOC to output
        gpioc.crh.write(|w| w.mode13().output());

        // Change pin 0 on A to input mode
        gpioa.crl.write(|w| w.mode0().input());
        // Change pin 1 on A to output mode
        gpioa.crl.write(|w| w.mode1().output());
        gpioa.crl.write(|w| w.cnf1().alt_push());

        // now store the GPIOC struct
        *GPIOC.borrow(cs).borrow_mut() = Some(gpioc);
        *GPIOA.borrow(cs).borrow_mut() = Some(gpioa);

        //enable interrupt on line 0, on rising flank
        per.EXTI.rtsr.write(|w| w.tr0().set_bit());
        per.EXTI.ftsr.write(|w| w.tr0().clear_bit());
        per.EXTI.imr.write(|w| w.mr0().set_bit());

        *EXTI.borrow(cs).borrow_mut() = Some(per.EXTI);

        let mut syst = global_p.SYST;
        syst.set_clock_source(SystClkSource::Core);
        syst.set_reload(16_000_000); // 2s
        syst.enable_counter();
        syst.enable_interrupt();
        //
    });
}

exception!(SYS_TICK, tick);

// This gets called every other second.
fn tick() {
    interrupt::free(|cs| {
        let hstdout = HSTDOUT.borrow(cs);
        if let Some(hstdout) = hstdout.borrow_mut().as_mut() {
            writeln!(*hstdout, "Tick").ok();
        }

        if let Some(nvic) = NVIC.borrow(cs).borrow_mut().as_mut() {
            // Mark interrupt TIM2 as pending
            nvic.set_pending(Interrupt::TIM2);
            //nvic.set_pending(Interrupt::EXTI0);
        }
    });
}

interrupt!(TIM2, tock, locals: {
    tocks: u32 = 0;
    output: bool = false;
});

interrupt!(EXTI0, pin0);

//this gets called when pin A1 is toggled
fn pin0() {
    interrupt::free(|cs| {

        let hstdout = HSTDOUT.borrow(cs);
        if let Some(hstdout) = hstdout.borrow_mut().as_mut() {
            writeln!(*hstdout, "Bang!").ok();
        }
        //clear pending register
        if let Some(exti) = EXTI.borrow(cs).borrow_mut().as_mut() {
            exti.pr.write(|w| w.pr0().set_bit());
        }
        if let Some(nvic) = NVIC.borrow(cs).borrow_mut().as_mut() {
            nvic.clear_pending(Interrupt::EXTI0);
        }
    });
}

// This gets called when TIM2 is pending
fn tock(l: &mut TIM2::Locals) {
    l.tocks += 1;

    interrupt::free(|cs| {
        //print stuff
        let hstdout = HSTDOUT.borrow(cs);
        if let Some(hstdout) = hstdout.borrow_mut().as_mut() {
            writeln!(*hstdout, "Tock ({}, {})", l.tocks, l.output).ok();
        }

        // toggle the led

        if let Some(gpioc) = GPIOC.borrow(cs).borrow_mut().as_mut() {
            match l.output {
                true => {
                    led_on(gpioc);
                }
                false => {
                    led_off(gpioc);
                }
            }
        }

        //toggle the output pin
        if let Some(gpioa) = GPIOA.borrow(cs).borrow_mut().as_mut() {
            match l.output {
                true => {
                    gpioa.bsrr.write(|w| w.br1().set_bit());
                }
                false => {
                    gpioa.bsrr.write(|w| w.bs1().set());
                }
            }
        }
    });
    l.output = !l.output;
}

fn led_on(gpioc: &GPIOC) {
    // Turn led on
    gpioc.bsrr.write(|w| w.br13().set_bit());
}

fn led_off(gpioc: &GPIOC) {
    // Turn led off
    gpioc.bsrr.write(|w| w.bs13().set());
}
