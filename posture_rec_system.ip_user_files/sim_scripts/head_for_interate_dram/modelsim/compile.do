vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/dist_mem_gen_v8_0_12

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm
vmap dist_mem_gen_v8_0_12 modelsim_lib/msim/dist_mem_gen_v8_0_12

vlog -work xil_defaultlib -64 -incr -sv -L xil_defaultlib "+incdir+D:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" "+incdir+D:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"D:/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"D:/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work dist_mem_gen_v8_0_12 -64 -incr "+incdir+D:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" "+incdir+D:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"../../../ipstatic/simulation/dist_mem_gen_v8_0.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+D:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" "+incdir+D:/Xilinx/Vivado/2017.3/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/ip/head_for_interate_dram/sim/head_for_interate_dram.v" \

vlog -work xil_defaultlib \
"glbl.v"

