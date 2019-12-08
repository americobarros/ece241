vlib work
vlog counter8bit_main.v
vsim counter8bit
log {/*}
add wave {/*}

force {clock} 0 0ns, 1 5ns -r 10ns

force {clear_b} 1
force {enable} 0
run 10ns

force {clear_b} 0
force {enable} 0
run 10ns

force {clear_b} 1
force {enable} 0
run 10ns

force {clear_b} 1
force {enable} 1
run 10ns

force {clear_b} 1
force {enable} 0
run 10ns

force {clear_b} 1
force {enable} 1
run 10ns


force {clear_b} 1
force {enable} 0
run 10ns


force {clear_b} 1
force {enable} 1
run 10ns

force {clear_b} 1
force {enable} 0
run 10ns


force {clear_b} 1
force {enable} 1
run 10ns

force {clear_b} 1
force {enable} 0
run 10ns


force {clear_b} 1
force {enable} 1
run 10ns

force {clear_b} 1
force {enable} 0
run 10ns


force {clear_b} 1
force {enable} 1
run 10ns

force {clear_b} 1
force {enable} 0
run 10ns


force {clear_b} 1
force {enable} 1
run 10ns