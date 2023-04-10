transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/dev/FPGA-GOL/src {C:/dev/FPGA-GOL/src/clk_multiplier.v}
vlog -vlog01compat -work work +incdir+C:/dev/FPGA-GOL/src/db {C:/dev/FPGA-GOL/src/db/clk_multiplier_altpll.v}
vlog -sv -work work +incdir+C:/dev/FPGA-GOL/src {C:/dev/FPGA-GOL/src/VGA_controller.sv}
vlog -sv -work work +incdir+C:/dev/FPGA-GOL/src {C:/dev/FPGA-GOL/src/game_of_life.sv}
