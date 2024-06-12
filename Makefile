.PHONY: all clean

TB_DEFINE := noHazard
CYCLE := 10
TB = Final_tb.v slow_memory.v
SRCLIST = src.f
SYN_SRC = ../Syn/CHIP_syn.v 
#TSMC13=/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v
TSMC13=/usr/cad/designkit/digital/T13/CBDK_IC_Contest_v2.5/Verilog/tsmc13_neg.v
export 


COLOR_RED = \033[1;31m
COLOR_GREEN = \033[1;32m
COLOR_RESET = \033[0m

TESTCASES = noHazard hasHazard BrPred compression compression_uncompressed Mul QSort QSort_uncompressed Conv Conv_uncompressed

all: clean syn tb_rtl tb_syn
syn:
	dc_shell-t -f syn.tcl
tb_rtl:
	make -C Src/ rtl
tb_syn:
	make -C Src/ syn
tb_rtl_all:
	@for testcase in $(TESTCASES); do \
		echo -e "[-] running $$testcase"; \
		TB_DEFINE=$$testcase; \
		make -C Src/ rtl > Report/$$testcase.log; \
		if grep -q CONGRATULATIONS!! Report/$$testcase.log; then echo -e "$(COLOR_GREEN)$$testcase: pass$(COLOR_RESET)"; else echo -e "$(COLOR_RED)$$testcase: fail$(COLOR_RESET)"; exit 1; fi; \
	done
	
tb_baseline:
	@echo -e "[-] running baseline"
	TB_DEFINE=noHazard
	@make -C Src/ rtl > Report/noHazard.log
	@if grep -q CONGRATULATIONS!! Report/noHazard.log; then echo -e "$(COLOR_GREEN)noHazard: pass$(COLOR_RESET)"; else echo -e "$(COLOR_RED)noHazard: fail$(COLOR_RESET)"; exit 1; fi
	TB_DEFINE=hasHazard
	@make -C Src/ rtl > Report/hasHazard.log
	@if grep -q CONGRATULATIONS!! Report/hasHazard.log; then echo -e "$(COLOR_GREEN)hasHazard: pass$(COLOR_RESET)"; else echo -e "$(COLOR_RED)hasHazard: fail$(COLOR_RESET)"; fi
tb_mul:
	make -C Src/ mul
tb_mul_syn:
	make -C Src/ mul_syn
clean:
	rm -rf Syn/ 
