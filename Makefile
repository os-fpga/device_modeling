#
# Makefile to update model files if yaml file changed
#
# These commands should run on SW machines.
#
#     make all (which calls the following targets):
#
#       make sim_models
  #     make bb_models
#
# The following needs
#     module load opensource/ghcli/2.31.0
#
#     make release

SPECS := $(wildcard specs/*.yaml)
VERSION := $(shell cat manifests/VERSION)
ASSET := models_internal

# replace specs/FOO.yaml with models/FOO.v
SIM_TARGETS := $(patsubst specs/%.yaml,models_internal/verilog/%.v,$(SPECS))
CUST_SIM_TARGETS := $(patsubst specs/%.yaml,models_customer/verilog/%.v,$(SPECS))
BB_TARGETS  := $(patsubst specs/%.yaml,models_internal/verilog_blackbox/rundir/%.v,$(SPECS))
PROLOGUES   := $(patsubst specs/%.yaml,models_internal/verilog/inc/%.pro.v,$(SPECS))
INCLUDES    := $(patsubst specs/%.yaml,models_internal/verilog/inc/%.inc.v,$(SPECS))

all: bb_models sim_models

bb_models: $(BB_TARGETS)
	@echo Generating single file
	ls models_internal/verilog_blackbox/rundir/*.v | xargs cat > models_internal/verilog_blackbox/cell_sim_blackbox.v
	bin/test_compile models_internal/verilog_blackbox/cell_sim_blackbox.v

# we need to make TDP_RAM36K.v first as it is used by the FIFO.
core_sim_models: models_internal/verilog/TDP_RAM36K.v

sim_models: core_sim_models  $(SIM_TARGETS) #$(CUST_SIM_TARGETS)

models_internal/verilog_blackbox/rundir/%.v: specs/%.yaml
	mkdir -p models_internal/verilog_blackbox/rundir
	@echo Generating black box model $@
	bin/gen_model.py -m etc/bb.mako -y $< -o $@

models_internal/verilog/%.v: specs/%.yaml bin/p4def_to_simv.py models_internal/verilog/inc/%.pro.v models_internal/verilog/inc/%.inc.v
	mkdir -p rundir
	@echo Generating simulation model $@
	bin/p4def_to_simv.py --input $< --include models_internal/verilog/inc --output $@ --log rundir/$(notdir $@).p4def_to_simv.log
	bin/test_compile $@

models_customer/verilog/%.v: models_internal/verilog/%.v
	mkdir -p models_customer/verilog
	@echo Generating customer simulation model
	bin/gen_customer_model.py --input $< --output $@ --log rundir/$(notdir $@).gen_customer_model.log

.PHONY: release

release: 
	tar -cvf $(ASSET)-$(VERSION).tar.gz -T manifests/$(ASSET).f
	gh release create $(VERSION) --generate-notes
	gh release upload $(VERSION) $(ASSET)-$(VERSION).tar.gz

