Src/
    Final_tb.v		testbench for project, use it when the pipelined datapath is debugged
    slow_memory.v	having higher latency compared with that in HW3
    CHIP.v			Top module of your design, including RISCV_Pipeline, I_cache, and D_cache	
                    Remember to add an output port "[31:0] PC", and connect it to your pc counter in RISCV_pipeline.v
                    You cannot modify this module!!			

Baseline/                        
    TestBed.v		expected write operation to data memory (DMEM) of final test
    I_mem			Instruction memory. machine code , series and sort  ( with assembly description )
    D_mem			Data memory. initial data for slow memory