WORKDIR ?= work/
WORKNAMEPREFIX ?= work
STD ?= 08
WORKNAMESUFFIX ?= obj$(STD).cf
MAXRUNTIME ?= 50000ns
GHDL ?= ghdl
VIEUWER ?= gtkwave

INCLUDEFLAGS = -i --work=$(WORKNAMEPREFIX) --std=$(STD) --workdir=$(WORKDIR)
BUILDFLAGS = -m --work=$(WORKNAMEPREFIX) --std=$(STD) --workdir=$(WORKDIR)
RUNFLAGS = -r --work=$(WORKNAMEPREFIX) --std=$(STD) --workdir=$(WORKDIR)
BENCHFLAGS = --wave=$@
VIEWFLAGS = --stdout
CLEANFLAGS = --remove --workdir=$(WORKDIR)

TESTBENCHFILE := tb_axi4_acp.vhd
TESTBENCH := tb_axi4_acp
WORKFILE := $(WORKDIR)$(WORKNAMEPREFIX)-$(WORKNAMESUFFIX)
TARGET := $(WORKDIR)$(TESTBENCH).ghw
SRC := $(wildcard *.vhd)

.PHONY: build clean run view pre-build distclean timedRun
.DELETE_ON_ERROR:

build: $(WORKFILE)
run: $(TARGET)

timedRun: BENCHFLAGS += --stop-time=$(MAXRUNTIME)
timedRun: $(TARGET)

$(WORKDIR) :
	@mkdir -p $@

$(WORKFILE) : $(SRC) | $(WORKDIR)
	$(GHDL) $(INCLUDEFLAGS) $^
	$(GHDL) $(BUILDFLAGS) $(TESTBENCH)

$(TARGET) : $(WORKFILE)
	$(GHDL) $(RUNFLAGS) $(TESTBENCH) $(BENCHFLAGS)

view: $(TARGET)
	$(VIEUWER) $(TARGET)

clean:
	$(GHDL) $(CLEANFLAGS)

distclean :
	rm -rf $(WORKDIR)
	rm *.o
	rm $(TESTBENCH)
