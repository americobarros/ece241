module FA(a, b, Cin, s, Cout);
	input a, b, Cin;
	output s, Cout;
	assign s = Cin^b^a;
	assign Cout = (a&b)|(Cin&b)|(Cin&a);
endmodule

module ripple_carry_adder(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;
	wire C1, C2, C3;
	
	FA FA0(SW[7], SW[3], SW[8], LEDR[0], C1);
	FA FA1(SW[6], SW[2], C1, LEDR[1], C2);
	FA FA2(SW[5], SW[1], C2, LEDR[2], C3);
	FA FA3(SW[4], SW[0], C3, LEDR[3], LEDR[9]);
endmodule
	