module TFF_ (input T, clk, Resetn, 
				output reg Q);
	always @(negedge Resetn, posedge clk) begin
		if (Resetn == 0)
			Q<= 1'b0;
		else if (T)
			Q<=~Q;
	end
endmodule


module counter8bit(input enable, clear_b, clock,
						output [7:0] out);
	wire w1, w2, w3, w4, w5, w6, w7, w8, l0, l1, l2, l3, l4, l5, l6, l7;
	assign w1 = enable & l0;
	assign w2 = w1 & l1;
	assign w3 = w2 & l2;
	assign w4 = w3 & l3;
	assign w5 = w4 & l4;
	assign w6 = w5 & l5;
	assign w7 = w6 & l6;
	assign w8 = w7 & l7;
	
	TFF_ U1(.T(enable), .clk(clock), .Resetn(clear_b), .Q(l0));
	TFF_ U2(.T(w1), .clk(clock), .Resetn(clear_b), .Q(l1));
	TFF_ U3(.T(w2), .clk(clock), .Resetn(clear_b), .Q(l2));
	TFF_ U4(.T(w3), .clk(clock), .Resetn(clear_b), .Q(l3));
	TFF_ U5(.T(w4), .clk(clock), .Resetn(clear_b), .Q(l4));
	TFF_ U6(.T(w5), .clk(clock), .Resetn(clear_b), .Q(l5));
	TFF_ U7(.T(w6), .clk(clock), .Resetn(clear_b), .Q(l6));
	TFF_ U8(.T(w7), .clk(clock), .Resetn(clear_b), .Q(l7));
	
	assign out = {l7, l6, l5, l4, l3, l2, l1, l0};
endmodule





module counter8bit_main (input [9:0] SW, 
									input [3:0] KEY,
									output [6:0] HEX0, HEX1);
	wire [7:0] countn;
	counter8bit U1(.enable(SW[1]), .clear_b(SW[0]), .clock(KEY[0]), .out(countn));
	bitsToHex U2(countn[3:0], HEX0);
	bitsToHex U3(countn[7:4], HEX1);
endmodule
	
	
	
	
	
	
//The following is to control the hex displays

module EQ1seg0 (input c1, c2, c3, c0, output o);
	assign o = (~c3 & ~c2 & ~c1 & c0)|(~c3 & c2 & ~c1 & ~c0)|(c3 & ~c2 & c1 & c0)|(c3 & c2 & ~c1 & c0);
endmodule

module EQ2seg1 (input c3, c2, c1, c0, output o);
	assign o = (~c3 & c2 & ~c1 & c0)|(~c3 & c2 & c1 & ~c0)|(c3 & ~c2 & c1 & c0)|(c3 & c2 & ~c1 & ~c0)|(c3 & c2 & c1 & ~c0)|(c3 & c2 & c1 & c0);
endmodule

module EQ3seg2 (input c3, c2, c1, c0, output o);
	assign o = (~c3 & ~c2 & c1 & ~c0)|(c3 & c2 & ~c1 & ~c0)|(c3 & c2 & c1 & ~c0)|(c3 & c2 & c1 & c0);
endmodule

module EQ4seg3 (input c3, c2, c1, c0, output o);
	assign o = (~c3 & ~c2 & ~c1 & c0)|(~c3 & c2 & ~c1 & ~c0)|(~c3 & c2 & c1 & c0)|(c3 & ~c2 & ~c1 & c0)|(c3 & ~c2 & c1 & ~c0)|(c3 & c2 & c1 & c0);
endmodule

module EQ5seg4 (input c3, c2, c1, c0, output o);
	assign o = (~c3 & ~c2 & ~c1 & c0)|(~c3 & ~c2 & c1 & c0)|(~c3 & c2 & ~c1 & ~c0)|(~c3 & c2 & ~c1 & c0)|(~c3 & c2 & c1 & c0)|(c3 & ~c2 & ~c1 & c0);
endmodule

module EQ6seg5 (input c3, c2, c1, c0, output o);
	assign o = (~c3 & ~c2 & ~c1 & c0)|(~c3 & ~c2 & c1 & ~c0)|(~c3 & ~c2 & c1 & c0)|(~c3 & c2 & c1 & c0)|(c3 & c2 & ~c1 & c0);
endmodule

module EQ7seg6 (input c3, c2, c1, c0, output o);
	assign o = (~c3 & ~c2 & ~c1 & ~c0)|(~c3 & ~c2 & ~c1 & c0)|(~c3 & c2 & c1 & c0)|(c3 & c2 & ~c1 & ~c0);
endmodule

module bitsToHex (hexIN, hexOUT);
	input [3:0] hexIN;
	output [6:0] hexOUT;
	EQ1seg0 eq1 (.c0(hexIN[0]), .c1(hexIN[1]), .c2(hexIN[2]), .c3(hexIN[3]), .o(hexOUT[0]));
	EQ2seg1 eq2 (.c0(hexIN[0]), .c1(hexIN[1]), .c2(hexIN[2]), .c3(hexIN[3]), .o(hexOUT[1]));
	EQ3seg2 eq3 (.c0(hexIN[0]), .c1(hexIN[1]), .c2(hexIN[2]), .c3(hexIN[3]), .o(hexOUT[2]));
	EQ4seg3 eq4 (.c0(hexIN[0]), .c1(hexIN[1]), .c2(hexIN[2]), .c3(hexIN[3]), .o(hexOUT[3]));
	EQ5seg4 eq5 (.c0(hexIN[0]), .c1(hexIN[1]), .c2(hexIN[2]), .c3(hexIN[3]), .o(hexOUT[4]));
	EQ6seg5 eq6 (.c0(hexIN[0]), .c1(hexIN[1]), .c2(hexIN[2]), .c3(hexIN[3]), .o(hexOUT[5]));
	EQ7seg6 eq7 (.c0(hexIN[0]), .c1(hexIN[1]), .c2(hexIN[2]), .c3(hexIN[3]), .o(hexOUT[6]));
endmodule

