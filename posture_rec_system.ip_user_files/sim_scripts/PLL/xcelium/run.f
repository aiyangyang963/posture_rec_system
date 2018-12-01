-makelib xcelium_lib/xilinx_vip -sv \
  "D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
  "D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
  "D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
  "D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
  "D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
  "D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
  "D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
  "D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
  "D:/SDx/Vivado/2018.1/data/xilinx_vip/hdl/rst_vip_if.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "D:/SDx/Vivado/2018.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/SDx/Vivado/2018.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "D:/SDx/Vivado/2018.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/SDx/Vivado/2018.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../posture_rec_system.srcs/sources_1/ip/PLL/PLL_clk_wiz.v" \
  "../../../../posture_rec_system.srcs/sources_1/ip/PLL/PLL.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

