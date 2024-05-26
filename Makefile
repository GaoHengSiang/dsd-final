.PHONY: all clean

TB_DEFINE := noHazard
CYCLE := 10
TB = Src/Final_tb.v Src/slow_memory.v
SRC = Src/CHIP.v Src/cache.v Src/alu.v Src/decoder.v Src/register_file.v Src/RISCV_Pipeline.v Src/RISCV_IF.v Src/RISCV_ID.v Src/RISCV_EX.v Src/RISCV_MEM.v Src/RISCV_WB.v
SYN_SRC = Syn/CHIP_syn.v 
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
