vlib work

vlog SWtoHEX.v

vsim SWtoHEX

log {/*}

add wave {/*}

force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 0
force {SW[3]} 0
run 10ms

force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 1
force {SW[3]} 1
run 10ms

force {SW[0]} 0
force {SW[1]} 1
force {SW[2]} 1
force {SW[3]} 0
run 10ms

force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 1
force {SW[3]} 0
run 10ms

force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 0
force {SW[3]} 1
run 10ms

force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 1
force {SW[3]} 1
run 10ms