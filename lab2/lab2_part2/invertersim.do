vlib work

vlog mux2to1.V

vsim inverter

log {/*}

add wave {/*}

#All outputs and inputs should be high
force {pin1} 0
force {pin3} 0
force {pin5} 0
force {pin8} 0
force {pin10} 0
force {pin12} 0
run 10ns

#All outputs should be low
force {pin1} 1
force {pin3} 1
force {pin5} 1
force {pin8} 1
force {pin10} 1
force {pin12} 1
run 10ns