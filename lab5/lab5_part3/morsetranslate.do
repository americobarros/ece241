vlib work
vlog morsetranslate.v
vsim morsetranslate
log {/*}
add wave {/*}

force {CLOCK_50} 0 0ns, 1 1ns -r 2ns

force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 0
force {KEY[0]} 0
force {KEY[1]} 1
run 2ns

force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 0
force {KEY[0]} 1
force {KEY[1]} 0
run 2ns

force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 0
force {KEY[0]} 1
force {KEY[1]} 1
run 30ns

force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 0
force {KEY[0]} 0
force {KEY[1]} 1
run 2ns

force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 0
force {KEY[0]} 1
force {KEY[1]} 0
run 2ns

force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 0
force {KEY[0]} 1
force {KEY[1]} 1
run 60ns
