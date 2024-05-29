.PHONY: all clean

rtl:
	vcs $(TB) $(SRC) -full64 -R -debug_access+all +v2k +define+$(TB_DEFINE)

syn:
	vcs $(TB) $(SRC) -v $(TSMC13) -full64 -R -debug_access+all +v2k +define+$(TB_DEFINE) +define+SDF  +define+SDF_FILE=\"Syn/CHIP_syn.sdf\" \
	+define+CYCLE=$(CYCLE)
