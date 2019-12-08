vlib work
vlog clock_counter.v
vsim RateDivider
log {/*}
add wave {/*}

force {clk} 0 0ns, 1 5ns -r 10ns

force {D} 28'b0000000000000000000000000000
run 10ns

#count to one
force {D} 28'b0000000000000000000000000001
run 10ns

#count to go back to zero since weve already counted to one
force {D} 28'b0000000000000000000000000001
run 10ns

#count 1
force {D} 28'b0000000000000000000000000010
run 10ns


#count 2
force {D} 28'b0000000000000000000000000010
run 10ns

#back to zero
force {D} 28'b0000000000000000000000000010
run 10ns

#count 1
force {D} 28'b0000000000000000000000000010
run 10ns