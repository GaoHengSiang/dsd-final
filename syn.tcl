
set DESIGN CHIP
set src [list Src/CHIP.v Src/cache.v Src/decoder.v Src/alu.v Src/register_file.v Src/RISCV_Pipeline.v Src/RISCV_IF.v Src/RISCV_ID.v Src/RISCV_EX.v Src/RISCV_MEM.v Src/RISCV_WB.v]

sh mkdir -p Work
sh mkdir -p Report
sh mkdir -p Syn

define_design_lib WORK -path Work

analyze -format verilog $src
elaborate $DESIGN
current_design $DESIGN
link

source -echo -verbose CHIP_syn.sdc 
compile_ultra

write_sdf -version 2.1  -context verilog -load_delay cell "Syn/${DESIGN}_syn.sdf"
write -format verilog -hierarchy -output "Syn/${DESIGN}_syn.v"
write -format ddc -hierarchy -output "Syn/${DESIGN}_syn.ddc"

report_area -hierarchy > "Report/$DESIGN.area"
report_timing > "Report/$DESIGN.timing"
check_design