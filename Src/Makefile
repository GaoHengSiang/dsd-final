.PHONY: all clean

rtl:
	vcs $(TB) -f $(SRCLIST) -full64 -R -debug_access+all +v2k +define+$(TB_DEFINE) +define+DEBUG_STAT +define+USE_BTB +define+CYCLE=$(CYCLE) #+vcs+fsdbon
	
	# ncverilog $(TB) $(SRC) +access+wrc +v2k +define+$(TB_DEFINE) +define+CYCLE=$(CYCLE)

syn:
	vcs $(TB) $(SYN_SRC) -v $(TSMC13) -full64 -R -debug_access+all +v2k +define+$(TB_DEFINE) \
	+define+SDF  +define+SDF_FILE=\"../Syn/CHIP_syn.sdf\" +define+CYCLE=$(CYCLE) +neg_tchk 
	
	# ncverilog $(TB) $(SYN_SRC) -v $(TSMC13) +access+wrc +v2k +define+$(TB_DEFINE) \
	# +define+SDF  +define+SDF_FILE=\"../Syn/CHIP_syn.sdf\" +define+CYCLE=$(CYCLE) +neg_tchk
mul:
	vcs tb_mul.v mul_unit.v -full64 -R -debug_access+all +v2k 
mul_syn:
	vcs tb_mul.v ../Syn/mul_unit_syn.v -v $(TSMC13) -full64 -R -debug_access+all +v2k +define+SDF +define+CYCLE=$(CYCLE) +neg_tchk