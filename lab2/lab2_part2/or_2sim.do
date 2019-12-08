vlib work

vlog mux2to1.V

vsim or_2

log {/*}

add wave {/*}

#All outputs and inputs should be low
force {pin1} 0
force {pin2} 0
force {pin4} 0
force {pin5} 0
force {pin9} 0
force {pin10} 0
force {pin12} 0
force {pin13} 0
run 10ns


#Half of all inputs should be high, other half should be low, outputs should be high
force {pin1} 1
force {pin2} 0
force {pin4} 1
force {pin5} 0
force {pin9} 1
force {pin10} 0
force {pin12} 1
force {pin13} 0
run 10ns


#Other half of all inputs should be high, rest of inputs should be low and outputs should be high
force {pin1} 0
force {pin2} 1
force {pin4} 0
force {pin5} 1
force {pin9} 0
force {pin10} 1
force {pin12} 0
force {pin13} 1
run 10ns


#All inputs and outputs should be high
force {pin1} 1
force {pin2} 1
force {pin4} 1
force {pin5} 1
force {pin9} 1
force {pin10} 1
force {pin12} 1
force {pin13} 1
run 10ns