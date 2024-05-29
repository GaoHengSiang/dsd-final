.PHONY: all clean

TB_DEFINE := noHazard
CYCLE := 10
TB = Final_tb.v slow_memory.v
SRC = CHIP.v cache.v alu.v decoder.v register_file.v HAZARD_DETECTION.v Forwarding_Unit.v RISCV_Pipeline.v RISCV_IF.v RISCV_ID.v RISCV_EX.v RISCV_MEM.v RISCV_WB.v
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
