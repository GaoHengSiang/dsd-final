
set DESIGN CHIP
set src [list \
    Src/CHIP.v \
    Src/dcache.v \
    Src/icache_dm.v \
    Src/decoder.v \
    Src/alu.v \
    Src/Forwarding_Unit.v \
    Src/HAZARD_DETECTION.v \
    Src/register_file.v \
    Src/RISCV_Pipeline.v \
    Src/RISCV_IF.v \
    Src/RISCV_ID.v \
    Src/RISCV_EX.v \
    Src/RISCV_MEM.v \
    Src/realigner.v \
    Src/decompressor.v \
    Src/dcache_wrapper.v \
    Src/icache_wrapper.v \
    Src/dum_mul.v \
]

sh mkdir -p Work
sh mkdir -p Report
sh mkdir -p Syn

define_design_lib WORK -path Work

analyze -format verilog $src
elaborate $DESIGN
current_design $DESIGN
link

source -echo -verbose CHIP_syn.sdc 

# TODO: please check if this works with our chip
# set_ungroup   [get_designs  mul_unit]  false
# set_optimize_registers true -design mul_unit
# set_dont_retime [get_cells c_64_r_reg*]
# get_attribute [get_cells c_64_r_reg*] dont_retime

set_ungroup   [get_designs  dum_mul]  false
set_optimize_registers true -design dum_mul
set_dont_retime [get_cells i_RISCV/mul_inst/result_r_reg*]
get_attribute [get_cells i_RISCV/mul_inst/result_r_reg*] dont_retime

set_critical_range  0.3  [current_design]

compile_ultra

write_sdf -version 2.1  -context verilog -load_delay cell "Syn/${DESIGN}_syn.sdf"
write -format verilog -hierarchy -output "Syn/${DESIGN}_syn.v"
write -format ddc -hierarchy -output "Syn/${DESIGN}_syn.ddc"

report_area -hierarchy > "Report/$DESIGN.area"
report_timing > "Report/$DESIGN.timing"
check_design