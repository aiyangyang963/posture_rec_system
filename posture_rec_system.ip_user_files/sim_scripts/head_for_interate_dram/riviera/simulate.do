onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+head_for_interate_dram -L xil_defaultlib -L xpm -L dist_mem_gen_v8_0_12 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.head_for_interate_dram xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {head_for_interate_dram.udo}

run -all

endsim

quit -force
