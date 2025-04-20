-makelib xcelium_lib/xpm -sv \
  "C:/Xilinx/Vivado/2021.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2021.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../xadc_testing.gen/sources_1/ip/xadc_wiz_0/xadc_wiz_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

