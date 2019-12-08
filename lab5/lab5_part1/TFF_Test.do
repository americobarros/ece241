vlib work
vlog counter8bit_main.v
vsim TFF_
log {/*}
add wave {/*}

force {clk} 0 0ns, 1 5ns -r 10ns

force {Resetn} 1
force {T} 0
run 10ns

force {Resetn} 0
force {T} 1
run 10ns

force {Resetn} 1
force {T} 0
run 10ns

force {Resetn} 1
force {T} 1
run 10ns

force {Resetn} 1
force {T} 0
run 10ns