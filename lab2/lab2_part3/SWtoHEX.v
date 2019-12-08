module EQ1HEX00 (input c1, c2, c3, c0, output o);
				assign o = (~c3 & ~c2 & ~c1 & c0)|(~c3 & c2 & ~c1 & ~c0)|(c3 & ~c2 & c1 & c0)|(c3 & c2 & ~c1 & c0);
endmodule

module EQ2HEX01 (input c3, c2, c1, c0, output o);
				assign o = (~c3 & c2 & ~c1 & c0)|(~c3 & c2 & c1 & ~c0)|(c3 & ~c2 & c1 & c0)|(c3 & c2 & ~c1 & ~c0)|(c3 & c2 & c1 & ~c0)|(c3 & c2 & c1 & c0);
endmodule

module EQ3HEX02 (input c3, c2, c1, c0, output o);
				assign o = (~c3 & ~c2 & c1 & ~c0)|(c3 & c2 & ~c1 & ~c0)|(c3 & c2 & c1 & ~c0)|(c3 & c2 & c1 & c0);
endmodule

module EQ4HEX03 (input c3, c2, c1, c0, output o);
				assign o = (~c3 & ~c2 & ~c1 & c0)|(~c3 & c2 & ~c1 & ~c0)|(~c3 & c2 & c1 & c0)|(c3 & ~c2 & ~c1 & c0)|(c3 & ~c2 & c1 & ~c0)|(c3 & c2 & c1 & c0);
endmodule

module EQ5HEX04 (input c3, c2, c1, c0, output o);
				assign o = (~c3 & ~c2 & ~c1 & c0)|(~c3 & ~c2 & c1 & c0)|(~c3 & c2 & ~c1 & ~c0)|(~c3 & c2 & ~c1 & c0)|(~c3 & c2 & c1 & c0)|(c3 & ~c2 & ~c1 & c0);
endmodule

module EQ6HEX05 (input c3, c2, c1, c0, output o);
				assign o = (~c3 & ~c2 & ~c1 & c0)|(~c3 & ~c2 & c1 & ~c0)|(~c3 & ~c2 & c1 & c0)|(~c3 & c2 & c1 & c0)|(c3 & c2 & ~c1 & c0);
endmodule

module EQ7HEX06 (input c3, c2, c1, c0, output o);
				assign o = (~c3 & ~c2 & ~c1 & ~c0)|(~c3 & ~c2 & ~c1 & c0)|(~c3 & c2 & c1 & c0)|(c3 & c2 & ~c1 & ~c0);
endmodule

module SWtoHEX (SW, HEX0);
				input [3:0] SW;
				output [6:0] HEX0;
				EQ1HEX00 eq1 (.c0(SW[0]), .c1(SW[1]), .c2(SW[2]), .c3(SW[3]), .o(HEX0[0]));
				EQ2HEX01 eq2 (.c0(SW[0]), .c1(SW[1]), .c2(SW[2]), .c3(SW[3]), .o(HEX0[1]));
				EQ3HEX02 eq3 (.c0(SW[0]), .c1(SW[1]), .c2(SW[2]), .c3(SW[3]), .o(HEX0[2]));
				EQ4HEX03 eq4 (.c0(SW[0]), .c1(SW[1]), .c2(SW[2]), .c3(SW[3]), .o(HEX0[3]));
				EQ5HEX04 eq5 (.c0(SW[0]), .c1(SW[1]), .c2(SW[2]), .c3(SW[3]), .o(HEX0[4]));
				EQ6HEX05 eq6 (.c0(SW[0]), .c1(SW[1]), .c2(SW[2]), .c3(SW[3]), .o(HEX0[5]));
				EQ7HEX06 eq7 (.c0(SW[0]), .c1(SW[1]), .c2(SW[2]), .c3(SW[3]), .o(HEX0[6]));
endmodule
