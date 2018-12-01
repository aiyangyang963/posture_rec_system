vlib work
vlib riviera

vlib riviera/xilinx_vip
vlib riviera/xil_defaultlib
vlib riviera/xpm
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/smartconnect_v1_0
vlib riviera/axi_protocol_checker_v2_0_2
vlib riviera/axi_vip_v1_1_2
vlib riviera/zynq_ultra_ps_e_vip_v1_0_2
vlib riviera/lib_cdc_v1_0_2
vlib riviera/proc_sys_reset_v5_0_12
vlib riviera/xlconcat_v2_1_1
vlib riviera/axi_lite_ipif_v3_0_4
vlib riviera/interrupt_control_v3_1_4
vlib riviera/axi_gpio_v2_0_18
vlib riviera/generic_baseblocks_v2_1_0
vlib riviera/fifo_generator_v13_2_2
vlib riviera/axi_data_fifo_v2_1_15
vlib riviera/axi_register_slice_v2_1_16
vlib riviera/axi_protocol_converter_v2_1_16

vmap xilinx_vip riviera/xilinx_vip
vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap smartconnect_v1_0 riviera/smartconnect_v1_0
vmap axi_protocol_checker_v2_0_2 riviera/axi_protocol_checker_v2_0_2
vmap axi_vip_v1_1_2 riviera/axi_vip_v1_1_2
vmap zynq_ultra_ps_e_vip_v1_0_2 riviera/zynq_ultra_ps_e_vip_v1_0_2
vmap lib_cdc_v1_0_2 riviera/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_12 riviera/proc_sys_reset_v5_0_12
vmap xlconcat_v2_1_1 riviera/xlconcat_v2_1_1
vmap axi_lite_ipif_v3_0_4 riviera/axi_lite_ipif_v3_0_4
vmap interrupt_control_v3_1_4 riviera/interrupt_control_v3_1_4
vmap axi_gpio_v2_0_18 riviera/axi_gpio_v2_0_18
vmap generic_baseblocks_v2_1_0 riviera/generic_baseblocks_v2_1_0
vmap fifo_generator_v13_2_2 riviera/fifo_generator_v13_2_2
vmap axi_data_fifo_v2_1_15 riviera/axi_data_fifo_v2_1_15
vmap axi_register_slice_v2_1_16 riviera/axi_register_slice_v2_1_16
vmap axi_protocol_converter_v2_1_16 riviera/axi_protocol_converter_v2_1_16

vlog -work xilinx_vip  -sv2k12 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"D:/SDx/Vivado/2018.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/SDx/Vivado/2018.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/SDx/Vivado/2018.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/SDx/Vivado/2018.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/sc_util_v1_0_vl_rfs.sv" \

vlog -work axi_protocol_checker_v2_0_2  -sv2k12 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/3755/hdl/axi_protocol_checker_v2_0_vl_rfs.sv" \

vlog -work axi_vip_v1_1_2  -sv2k12 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/725c/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work zynq_ultra_ps_e_vip_v1_0_2  -sv2k12 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl/zynq_ultra_ps_e_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../bd/system/ip/system_zynq_ultra_ps_e_0_0/sim/system_zynq_ultra_ps_e_0_0_vip_wrapper.v" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_12 -93 \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/f86a/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system/ip/system_rst_ps8_0_149M_1/sim/system_rst_ps8_0_149M_1.vhd" \
"../../../bd/system/ip/system_rst_ps8_0_149M_1_1/sim/system_rst_ps8_0_149M_1_1.vhd" \

vlog -work xlconcat_v2_1_1  -v2k5 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/2f66/hdl/xlconcat_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../bd/system/ip/system_xlconcat_0_0/sim/system_xlconcat_0_0.v" \

vcom -work axi_lite_ipif_v3_0_4 -93 \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/cced/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work interrupt_control_v3_1_4 -93 \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/8e66/hdl/interrupt_control_v3_1_vh_rfs.vhd" \

vcom -work axi_gpio_v2_0_18 -93 \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/fbf9/hdl/axi_gpio_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system/ip/system_axi_gpio_0_1/sim/system_axi_gpio_0_1.vhd" \

vlog -work generic_baseblocks_v2_1_0  -v2k5 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_2  -v2k5 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/7aff/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_2 -93 \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_2  -v2k5 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_15  -v2k5 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/d114/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_16  -v2k5 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/0cde/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work axi_protocol_converter_v2_1_16  -v2k5 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/1229/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/02c8/hdl/verilog" "+incdir+../../../../posture_rec_system.srcs/sources_1/bd/system/ipshared/ad7b/hdl" "+incdir+D:/SDx/Vivado/2018.1/data/xilinx_vip/include" \
"../../../bd/system/ip/system_auto_pc_0/sim/system_auto_pc_0.v" \
"../../../bd/system/sim/system.v" \

vlog -work xil_defaultlib \
"glbl.v"

