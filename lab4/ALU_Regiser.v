module ALU_Regiser(SW, LEDR, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6);
	input [9:0]SW;
	input [3:0]KEY;
	output [9:0]LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6;
	
	//Making hex0 display A
	bitsToHex hex0(SW[3:0],HEX0[6:0]);
	
	//Setting unused hexs to zero
	bitsToHex hex1empty(4'b0000 ,HEX1[6:0]);
	bitsToHex hex2empty(4'b0000 ,HEX2[6:0]);
	bitsToHex hex3empty(4'b0000 ,HEX3[6:0]);
	
	wire [7:0]ALUout;
	wire [3:0] regMostSig, regLeastSig;
	
	ALU alu(.DataIN({SW[3:0],regLeastSig}), .Fcn(KEY[3:1]), .DataOUT(ALUout));
	Register register(.DataIN(ALUout), .clock(KEY[0]), .Reset_b(SW[9]), .DataOUT({regMostSig, regLeastSig}));
	bitsToHex hex5(regMostSig, HEX5);
	bitsToHex hex4(regLeastSig, HEX4);
	assign LEDR[7:0] = {regMostSig, regLeastSig};
endmodule
	
	
	
	
	
	
	
module Register (input [7:0] DataIN,
						input clock, Reset_b,
						output [7:0] DataOUT);
	reg [7:0] DataOUTreg;
	always @ (posedge clock) begin
		if(Reset_b == 0)
			DataOUTreg <= 8'b00000000;
		else
			DataOUTreg <= DataIN;
	end
	assign DataOUT = DataOUTreg;
endmodule


module ALU (DataIN, Fcn, DataOUT);
	input [7:0]DataIN; //[7:4] = A, [3:0] = B
	input [3:1]Fcn;
	output [7:0] DataOUT;
	
	
	
	reg [7:0] finalOUT, f4wireR, f5wireR;
	wire [7:0] f1wire, f2wire, f3wire, f4wire, f5wire, f6wire, f7wire;
	
	always@(*)
	begin
		case(Fcn[3:1])
			3'b111:  finalOUT = f1wire;
			3'b110:  finalOUT = f2wire;
			3'b101:  finalOUT = f3wire;
			3'b100:  finalOUT = f4wire;
			3'b011:  finalOUT = f5wire;
			3'b010:  finalOUT = f6wire;
			3'b000:  finalOUT = f7wire;
			default: finalOUT = 8'b00000000;
		endcase
		if (|DataIN[7:0])
			begin 
				f4wireR = 8'b00001111;
			end
		else
			begin
				f4wireR = 8'b00000000;
			end
		if (((DataIN[7]^DataIN[6])^(DataIN[5]^DataIN[4]))&(  ((DataIN[3]^DataIN[2])&(DataIN[1]^DataIN[0]))  ^  ((DataIN[3]^DataIN[1])&(DataIN[2]^DataIN[0]))  ))
			begin
				f5wireR = 8'b11110000;
			end
		else
			begin
				f5wireR = 8'b00000000;
			end
		
	end
	
	ripple_carry_adder u1(DataIN[7:0], f1wire);
	assign DataOUT = finalOUT;
	assign f2wire = DataIN[3:0]+DataIN[7:4];
	assign f3wire[3:0] =  ~(DataIN[3:0]^DataIN[7:4]);
	assign f3wire[7:4] =  ~(DataIN[3:0]&DataIN[7:4]);
	assign f4wire = f4wireR;
	assign f5wire = f5wireR;
	assign f6wire[7:4] = DataIN[7:4];
	assign f6wire[3:0] = ~DataIN[3:0];
	//assign f7wire[
	
	
endmodule

	
	
	
//The following will add the bits 

module FA(a, b, Cin, s, Cout);
	input a, b, Cin;
	output s, Cout;
	assign s = Cin^b^a;
	assign Cout = (a&b)|(Cin&b)|(Cin&a);
endmodule

module ripple_carry_adder(bitsIN, bitsOUT);
	input [7:0] bitsIN;
	output [7:0] bitsOUT;
	wire C1, C2, C3;
	
	FA FA0(bitsIN[4], bitsIN[0], 0, bitsOUT[0], C1);
	FA FA1(bitsIN[5], bitsIN[1], C1, bitsOUT[1], C2);
	FA FA2(bitsIN[6], bitsIN[2], C2, bitsOUT[2], C3);
	FA FA3(bitsIN[7], bitsIN[3], C3, bitsOUT[3], bitsOUT[4]);
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