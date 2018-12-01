onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib head_for_interate_dram_opt

do {wave.do}

view wave
view structure
view signals

do {head_for_interate_dram.udo}

run -all

quit -force
