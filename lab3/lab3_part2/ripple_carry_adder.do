vlib work

vlog ripple_carry_adder.v

vsim ripple_carry_adder

log {/*}

add wave {/*}

# 1 + 1 = 10
force {SW[8]} 0
force {SW[7]} 1
force {SW[6]} 0
force {SW[5]} 0 
force {SW[4]} 0
force {SW[3]} 1
force {SW[2]} 0 
force {SW[1]} 0
force {SW[0]} 0
run 10ns

# 101 + 1010 = 1111
force {SW[8]} 0
force {SW[7]} 0
force {SW[6]} 1
force {SW[5]} 0 
force {SW[4]} 1
force {SW[3]} 1
force {SW[2]} 0 
force {SW[1]} 1
force {SW[0]} 0
run 10ns

# 1112 + 1111 = 11111
force {SW[8]} 1
force {SW[7]} 1
force {SW[6]} 1
force {SW[5]} 1 
force {SW[4]} 1
force {SW[3]} 1
force {SW[2]} 1 
force {SW[1]} 1
force {SW[0]} 1
run 10ns
