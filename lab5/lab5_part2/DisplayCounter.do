vlib work
vlog clock_counter.v
vsim clock_counter
log {/*}
add wave {/*}

force {CLOCK_50} 0 0ns, 1 1ns -r 2ns

force {SW[0]} 0
force {SW[1]} 0
run 15ns

force {SW[0]} 1
force {SW[1]} 0
run 15ns

force {SW[0]} 0
force {SW[1]} 1
run 15ns

force {SW[0]} 1
force {SW[1]} 1
run 15ns