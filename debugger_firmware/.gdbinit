target extended-remote /dev/ttyACM0
monitor swdp_scan
attach 1
load blackmagic_dfu
load blackmagic
q

