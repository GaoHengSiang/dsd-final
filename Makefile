.PHONY: all clean

TB_DEFINE := noHazard
CYCLE := 10
TB = Final_tb.v slow_memory.v
SRCLIST = src.f
SYN_SRC = ../Syn/CHIP_syn.v 
TSMC13=/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v
#TSMC13=/usr/cad/designkit/digital/T13/CBDK_IC_Contest_v2.5/Verilog/tsmc13_neg.v
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
	@summary=""; \
	total_time=0; \
	for testcase in $(TESTCASES); do \
		echo -e "[-] running $$testcase"; \
		TB_DEFINE=$$testcase; \
		make -C Src/ rtl > Report/$$testcase.log; \
		if grep -q CONGRATULATIONS!! Report/$$testcase.log; then \
			time_ps=$$(grep -Eo 'Time: *[0-9]+' Report/$$testcase.log | head -n 1 | grep -Eo '[0-9]+'); \
			total_time=$$(($$total_time + $$time_ps)); \
			echo -e "$(COLOR_GREEN)$$testcase: pass$(COLOR_RESET)"; \
			summary="$$summary\n$$testcase:    $(COLOR_GREEN)$$time_ps ps$(COLOR_RESET)"; \
		else \
			echo -e "$(COLOR_RED)$$testcase: fail$(COLOR_RESET)"; \
			exit 1; \
		fi; \
	done; \
	echo -e "$$summary" | tee Report/rtl_all.report; \
	echo -e "Total simulation time:    $(COLOR_GREEN)$$total_time ps$(COLOR_RESET)"
tb_syn_all:
	@summary=""; \
	total_time=0; \
	for testcase in $(TESTCASES); do \
		echo -e "[-] running $$testcase"; \
		TB_DEFINE=$$testcase; \
		make -C Src/ syn > Report/$$testcase_syn.log; \
		if grep -q CONGRATULATIONS!! Report/$$testcase_syn.log; then \
			time_ps=$$(grep -Eo 'Time: *[0-9]+' Report/$$testcase_syn.log | head -n 1 | grep -Eo '[0-9]+'); \
			total_time=$$(($$total_time + $$time_ps)); \
			echo -e "$(COLOR_GREEN)$$testcase: pass$(COLOR_RESET)"; \
			summary="$$summary\n$$testcase:    $(COLOR_GREEN)$$time_ps ps$(COLOR_GREEN)"; \
		else \
			echo -e "$(COLOR_RED)$$testcase: fail$(COLOR_RESET)"; \
			exit 1; \
		fi; \
	done; \
	echo -e "$$summary" | tee Report/syn_all.report; \
	echo -e "Total simulation time:    $(COLOR_GREEN)$$total_time ps$(COLOR_RESET)"

	
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
