vlib work

vlog ALU_Regiser.v

vsim ALU_Regiser


log {/*}

add wave {/*}

force {KEY[0]} 0 0ns, 1 {5ns} -r 10ns

#reset
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
force {SW[9]} 0
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0
run 10ns

#set B=b0011 
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
force {SW[9]} 1
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 1
run 10ns


#add b0001
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
force {SW[9]} 1
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 1
run 10ns

#reset
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
force {SW[9]} 0
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0
run 10ns

#set B=b0011 
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
force {SW[9]} 1
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 1
run 10ns

#set A=b0001 and run fcn3
force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 0
force {SW[9]} 1
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 1
run 10ns

#reset
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
force {SW[9]} 0
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0
run 10ns

#set B=b0011 
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
force {SW[9]} 1
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 1
run 10ns

#set A=b0001 and run fcn4
force {KEY[1]} 0
force {KEY[2]} 1
force {KEY[3]} 1
force {SW[9]} 1
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 1
run 10ns

#reset
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
force {SW[9]} 0
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0
run 10ns

#set A=b1111, use fcn 5, expecting b11111111
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
force {SW[9]} 0
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0
run 10ns
