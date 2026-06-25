set LIB_PATH "/home/chf/OpenROAD-flow-scripts/flow/platforms/nangate45/lib"
set OUT_PATH "/home/chf/OpenROAD-flow-scripts/flow/results/nangate45/interconnect/base"
read_liberty $LIB_PATH/NangateOpenCellLibrary_typical.lib
read_verilog $OUT_PATH/6_final.v
link_design axi_interconnect
read_sdc $OUT_PATH/6_final.sdc
read_spef $OUT_PATH/6_final.spef
set_power_activity -input -activity 0.1
set_power_activity -input_port AXI_RSTn -activity 0
report_power
