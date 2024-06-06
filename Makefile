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
clean:
	rm -rf Syn/ 
