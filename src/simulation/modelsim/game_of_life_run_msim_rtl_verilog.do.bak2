transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/dev/FPGA_GOL/src {C:/dev/FPGA_GOL/src/clk_multiplier.v}
vlog -vlog01compat -work work +incdir+C:/dev/FPGA_GOL/src/db {C:/dev/FPGA_GOL/src/db/clk_multiplier_altpll.v}
vlog -sv -work work +incdir+C:/dev/FPGA_GOL/src {C:/dev/FPGA_GOL/src/VGA_controller.sv}
vlog -sv -work work +incdir+C:/dev/FPGA_GOL/src {C:/dev/FPGA_GOL/src/game_of_life.sv}

vlog -sv -work work +incdir+C:/dev/FPGA_GOL/src {C:/dev/FPGA_GOL/src/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
