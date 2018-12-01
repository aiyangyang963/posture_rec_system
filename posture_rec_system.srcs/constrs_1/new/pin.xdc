#clock
set_property PACKAGE_PIN N4 [get_ports global_clk]
set_property IOSTANDARD LVCMOS18 [get_ports global_clk]

##error
#set_property IOSTANDARD LVCMOS33 [get_ports err_out]
#set_property IOSTANDARD LVCMOS33 [get_ports locked_out]
#set_property PACKAGE_PIN M14 [get_ports err_out]
#set_property PACKAGE_PIN M15 [get_ports locked_out]

##HDMI
#set_property IOSTANDARD TMDS_33 [get_ports TMDS_clk_n]
#set_property PACKAGE_PIN P19 [get_ports TMDS_clk_n]
#set_property PACKAGE_PIN N18 [get_ports TMDS_clk_p]
#set_property IOSTANDARD TMDS_33 [get_ports TMDS_clk_p]
#set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_n[0]}]
#set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_n[1]}]
#set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_n[2]}]
#set_property PACKAGE_PIN V20 [get_ports {TMDS_data_p[0]}]
#set_property PACKAGE_PIN W20 [get_ports {TMDS_data_n[0]}]
#set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_p[0]}]
#set_property PACKAGE_PIN T20 [get_ports {TMDS_data_p[1]}]
#set_property PACKAGE_PIN U20 [get_ports {TMDS_data_n[1]}]
#set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_p[1]}]
#set_property PACKAGE_PIN N20 [get_ports {TMDS_data_p[2]}]
#set_property PACKAGE_PIN P20 [get_ports {TMDS_data_n[2]}]
#set_property IOSTANDARD TMDS_33 [get_ports {TMDS_data_p[2]}]
#set_property PACKAGE_PIN Y19 [get_ports {hdmi_hpd_tri_i[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {hdmi_hpd_tri_i[0]}]
#set_property PACKAGE_PIN V16 [get_ports {HDMI_OEN[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {HDMI_OEN[0]}]
#set_property PACKAGE_PIN R18 [get_ports hdmi_ddc_scl_io]
#set_property IOSTANDARD LVCMOS33 [get_ports hdmi_ddc_scl_io]
#set_property PACKAGE_PIN R16 [get_ports hdmi_ddc_sda_io]
#set_property IOSTANDARD LVCMOS33 [get_ports hdmi_ddc_sda_io]




##IIC
#set_property PACKAGE_PIN T19 [get_ports iic_0_scl_io]
#set_property IOSTANDARD LVCMOS33 [get_ports iic_0_scl_io]
#set_property PACKAGE_PIN W16 [get_ports iic_0_sda_io]
#set_property IOSTANDARD LVCMOS33 [get_ports iic_0_sda_io]












