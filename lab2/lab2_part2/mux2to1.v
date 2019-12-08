module and_2 (pin1, pin2, pin4, pin5,pin9, pin10, pin12, pin13, pin3, pin6, pin8, pin11);
				input pin1, pin2, pin4, pin5,pin9, pin10, pin12, pin13;
				output pin3, pin6, pin8, pin11;
				assign pin3 = (pin1 & pin2);
				assign pin6 = (pin4 & pin5);
				assign pin8 = (pin10 & pin9);
				assign pin11 = (pin12 & pin13);
endmodule

module or_2 (input pin1, pin2, pin4, pin5, pin10, pin9, pin12, pin13, 
						output pin3, pin6, pin8, pin11);
				assign pin3 = (pin1 | pin2);
				assign pin6 = (pin4 | pin5);
				assign pin8 = (pin10 | pin9);
				assign pin11 = (pin12 | pin13);
endmodule

module inverter (input pin1, pin3, pin5, pin8, pin10, pin12, 
						output pin2, pin4, pin6, pin9, pin11, pin13);
				assign pin2 = ~pin1;
				assign pin4 = ~pin3;
				assign pin6 = ~pin5;
				assign pin9 = ~pin8;
				assign pin11 = ~pin10;
				assign pin13 = ~pin12;
endmodule

module mux2to1 (SW, LEDR);
				input [9:0] SW;
				output [9:0] LEDR;
				wire w1, w2, w3;
				inverter u1 (.pin1(SW[9]), .pin2(w1));
				and_2 u2 (.pin1(SW[0]), .pin4(SW[1]), .pin2(SW[9]), .pin5(w1), .pin3(w2), .pin6(w3));
				or_2 u3 (.pin1(w2), .pin2(w3), .pin3(LEDR[0]));
endmodule

