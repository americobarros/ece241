
module RateDivider(input [27:0] D,
							input clk,
							output [27:0] Q);
							
	reg [27:0] QR = 28'b0000000000000000000000000000;
	assign Q = QR;
	always @ (posedge clk) begin
		if (QR == D|| QR > D)
			QR <= 0;
		else
			QR <= QR+1;
	end
endmodule

module DisplayCounter(input Enable,
							input clk,
							output reg [3:0] Q);
	initial Q <= {4{1'b0}};
	always @(posedge clk) begin
		if(Q == 4'b1001 && Enable == 1'b1)
			Q <=4'b0000;
		else if (Enable == 1'b1)
			Q <= Q+1;
	end
endmodule

module clock_counter (input [1:0] SW,
							input CLOCK_50,
	 						output [6:0] HEX0);
	reg [27:0] w0;
	wire w2;
	wire [3:0] w3;
	wire [27:0] w1;
	
	
	always @ (*) begin//posedge CLOCK_50) begin
		case (SW[1:0])
			2'b00:	w0 <= 28'b0000000000000000000000000000;
			/*2'b01:	w0 <= 1;  //28'b0000000000000000000000000001;
			2'b10:	w0 <= 2;  //28'b0000000000000000000000000010;
			2'b11:	w0 <= 3;  //28'b0000000000000000000000000011;
			*/2'b01:	w0 <= 24999999;  //28'b0001011111010111100000111111;
			2'b10:	w0 <= 49999999;  //28'b0010111110101111000001111111;
			2'b11:	w0 <= 99999999;  //28'b0101111101011110000011111111;
		endcase
	end
	
	assign w2 = ~ (|w1);
	RateDivider U1(w0, CLOCK_50, w1);
	DisplayCounter U2(.Enable(w2), .clk(CLOCK_50), .Q(w3));
	bitsToHex U3(w3, HEX0); 
endmodule
	
//The following is to controlthe hex displays

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

