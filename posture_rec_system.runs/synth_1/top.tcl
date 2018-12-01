# 
# Synthesis run script generated by Vivado
# 

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xczu3eg-sfva625-2-i

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.cache/wt [current_project]
set_property parent.project_path C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_repo_paths c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/repo [current_project]
set_property ip_output_repo c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/post_image_ram/PostImage_ram_init_data.coe
read_verilog C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/network_parameters.vh
read_verilog -library xil_defaultlib {
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/AXI_4KBboundary.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/CalImageChannel_replication.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/activation.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/addTree.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/addr_mux.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/axi_interface_control.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/axi_read_image_cnt.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/axi_read_write_master.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/batch_norm.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/buffer_control.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/cal_channel_choose.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/cal_image.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/conv.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/counter_addr.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/data_from_window.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/deal_PostImage.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/head_bufer_control.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/image_ram_multi_addr.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/image_read_buffer_control.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/image_shift_rc_noaddzero_cnt.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/image_write_buffer_control.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/information_read_write.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/interrupt.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/iterate_head.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/kernel_buffer_control.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/leaky_activation.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/linear_activation.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/load_data.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/load_head.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/load_image.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/load_kernel.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/max_pooling.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/mul_results_adder.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/multi_div.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/multi_rd_addr.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/multiplier_3x.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/mux_3to1.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/mux_head_image_kernel.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/mux_ramtofifo_data.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/pl_top.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/postImage_channel_choose.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/post_to_ram_virtual_path.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/ram_to_cal_virtual_path.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/ram_to_post_virtual_path.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/reset.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/row_col_ptr_gen_for_2unite.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/shift_control.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/shift_window.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/stayInstep.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/sub_com.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/sumChannels.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/summation.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/imports/hdl/system_wrapper.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/update.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/user_maxpooling_fifo.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/user_update_fifo.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/wfifo_location_cal.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/wr_rd_finish_cnt_threshhold.v
  C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/new/top.v
}
add_files C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/system.bd
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_zynq_ultra_ps_e_0_0/system_zynq_ultra_ps_e_0_0_ooc.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_zynq_ultra_ps_e_0_0/system_zynq_ultra_ps_e_0_0.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_rst_ps8_0_149M_1/system_rst_ps8_0_149M_1_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_rst_ps8_0_149M_1/system_rst_ps8_0_149M_1.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_rst_ps8_0_149M_1/system_rst_ps8_0_149M_1_ooc.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_rst_ps8_0_149M_1_1/system_rst_ps8_0_149M_1_1_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_rst_ps8_0_149M_1_1/system_rst_ps8_0_149M_1_1.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_rst_ps8_0_149M_1_1/system_rst_ps8_0_149M_1_1_ooc.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_axi_gpio_0_1/system_axi_gpio_0_1_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_axi_gpio_0_1/system_axi_gpio_0_1_ooc.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_axi_gpio_0_1/system_axi_gpio_0_1.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/ip/system_auto_pc_0/system_auto_pc_0_ooc.xdc]
set_property used_in_implementation false [get_files -all C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/bd/system/system_ooc.xdc]

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/combine2data_fifo/combine2data_fifo.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/combine2data_fifo/combine2data_fifo.xdc]

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/floating_point_compare/floating_point_compare.xci

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/float_multiply/float_multiply.xci

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/float_add_IP_use_DSP_multilatency/float_add_IP_use_DSP_multilatency.xci

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/fifo_shift_window/fifo_shift_window.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/fifo_shift_window/fifo_shift_window.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/fifo_shift_window/fifo_shift_window_clocks.xdc]

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/stayInstep_fifo/stayInstep_fifo.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/stayInstep_fifo/stayInstep_fifo.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/stayInstep_fifo/stayInstep_fifo_clocks.xdc]

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/post_image_ram/post_image_ram.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/post_image_ram/post_image_ram_ooc.xdc]

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/image_prerd_toaxi_fifo/image_prerd_toaxi_fifo.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/image_prerd_toaxi_fifo/image_prerd_toaxi_fifo.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/image_prerd_toaxi_fifo/image_prerd_toaxi_fifo_clocks.xdc]

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/image_ram/image_ram.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/image_ram/image_ram_ooc.xdc]

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/image_ram_rd_addr_add/image_ram_rd_addr_add.xci

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/kernel_fifo/kernel_fifo.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/kernel_fifo/kernel_fifo.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/kernel_fifo/kernel_fifo_clocks.xdc]

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/head_fifo/head_fifo.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/head_fifo/head_fifo.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/head_fifo/head_fifo_clocks.xdc]

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/sub_unit/sub_unit.xci

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/head_for_interate_dram/head_for_interate_dram.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/head_for_interate_dram/head_for_interate_dram_ooc.xdc]

read_ip -quiet C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/PLL/PLL.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/PLL/PLL_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/PLL/PLL.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/sources_1/ip/PLL/PLL_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/constrs_1/new/pin.xdc
set_property used_in_implementation false [get_files C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/constrs_1/new/pin.xdc]

read_xdc C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/constrs_1/new/time.xdc
set_property used_in_implementation false [get_files C:/Users/Administrator/Desktop/posture_rec_system_20180724/posture_rec_system.srcs/constrs_1/new/time.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 0
close [open __synthesis_is_running__ w]

synth_design -top top -part xczu3eg-sfva625-2-i -directive AreaOptimized_medium -resource_sharing off -control_set_opt_threshold 1 -no_lc


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_utilization_synth.rpt -pb top_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]