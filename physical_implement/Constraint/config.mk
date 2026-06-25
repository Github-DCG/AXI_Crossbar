export DESIGN_NICKNAME = interconnect
export DESIGN_NAME = axi_interconnect
export PLATFORM    = nangate45

export VERILOG_FILES = ./designs/src/$(DESIGN_NICKNAME)/axi_interconnect.v \
                       ./designs/src/$(DESIGN_NICKNAME)/axi_crossbar.v \
                       ./designs/src/$(DESIGN_NICKNAME)/axi_m2s_m3.v \
                       ./designs/src/$(DESIGN_NICKNAME)/axi_s2m_s3.v \
                       ./designs/src/$(DESIGN_NICKNAME)/axi_default_slave.v \
                       ./designs/src/$(DESIGN_NICKNAME)/axi_fifo_sync.v \
                       ./designs/src/$(DESIGN_NICKNAME)/axi_arbiter_mtos_m3.v \
                       ./designs/src/$(DESIGN_NICKNAME)/axi_arbiter_stom_s3.v \
                       ./designs/src/$(DESIGN_NICKNAME)/round_robin_m2s.v \
                       ./designs/src/$(DESIGN_NICKNAME)/round_robin_s2m.v \
                       ./designs/src/$(DESIGN_NICKNAME)/sid_buffer.v \
                       ./designs/src/$(DESIGN_NICKNAME)/reorder.v \
                       ./designs/src/$(DESIGN_NICKNAME)/apb_regs_cfg.v

export SDC_FILE = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export CORE_UTILIZATION ?= 50
export PLACE_DENSITY_LB_ADDON = 0.20
