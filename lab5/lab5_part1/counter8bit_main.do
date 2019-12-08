vlib work
vlog counter8bit_main.v
vsim counter8bit_main
log {/*}

force {KEY[0]} 0 0ns, 1 5ns -r 10ns

force {SW[0]} 1
force {SW[1]} 0
run 10ns

force {SW[0]} 0
force {SW[1]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 1
run 10ns

force {SW[0]} 1
force {SW[1]} 0
run 10ns

force {SW[0]} 1
force {SW[1]} 1
run 10ns


force {SW[0]} 1
force {SW[1]} 0
run 10ns


force {SW[0]} 1
force {SW[1]} 1
run 10ns

force {SW[0]} 1
force {SW[1]} 0
run 10ns


force {SW[0]} 1
force {SW[1]} 1
run 10ns

force {SW[0]} 1
force {SW[1]} 0
run 10ns


force {SW[0]} 1
force {SW[1]} 1
run 10ns

force {SW[0]} 1
force {SW[1]} 0
run 10ns


force {SW[0]} 1
force {SW[1]} 1
run 10ns

force {SW[0]} 1
force {SW[1]} 0
run 10ns


force {SW[0]} 1
force {SW[1]} 1
run 10ns