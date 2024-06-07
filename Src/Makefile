.PHONY: all clean

rtl:
	vcs $(TB) -f $(SRCLIST) -full64 -R -debug_access+all +v2k +define+$(TB_DEFINE) #+vcs+fsdbon
	# ncverilog $(TB) $(SRC) +access+wrc +v2k +define+$(TB_DEFINE)

syn:
	vcs $(TB) $(SYN_SRC) -v $(TSMC13) -full64 -R -debug_access+all +v2k +define+$(TB_DEFINE) \
	+define+SDF  +define+SDF_FILE=\"../Syn/CHIP_syn.sdf\" +define+CYCLE=$(CYCLE) +neg_tchk
	# ncverilog $(TB) $(SYN_SRC) -v $(TSMC13) +access+wrc +v2k +define+$(TB_DEFINE) \
	# +define+SDF  +define+SDF_FILE=\"../Syn/CHIP_syn.sdf\" +define+CYCLE=$(CYCLE) +neg_tchk
	