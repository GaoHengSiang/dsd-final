.PHONY: all clean

TB_DEFINE := noHazard
CYCLE := 10
TB = Final_tb.v slow_memory.v
SRCLIST = src.f
SYN_SRC = ../Syn/CHIP_syn.v 
TSMC13=/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v

export 

all: clean syn tb_rtl tb_syn
syn:
	dc_shell-t -f syn.tcl
tb_rtl:
	make -C Src/ rtl
tb_syn:
	make -C Src/ syn
tb_baseline:
	TB_DEFINE=noHazard
	make -C Src/ rtl > Report/noHazard.log
	if grep -q CONGRATULATIONS!! Report/noHazard.log; then echo "noHazard pass"; else echo "noHazard fail"; exit 1; fi
	TB_DEFINE=hasHazard
	make -C Src/ rtl > Report/hasHazard.log
	if grep -q CONGRATULATIONS!! Report/hasHazard.log; then echo "hasHazard pass"; else echo "hasHazard fail"; fi
tb_mul:
	make -C Src/ mul
tb_mul_syn:
	make -C Src/ mul_syn
clean:
	rm -rf Syn/ 
