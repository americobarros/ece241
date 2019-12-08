module mux6to1(SW, LEDR);
	input [9:0] SW;
	output [9:0]LEDR;
	wire [2:0] MuxSelect;
	wire [5:0] Input;
	assign MuxSelect = SW[9:7];
	assign Input = SW[5:0];
	
	
	muxLogic MuxLogic(.MuxSelect(MuxSelect[2:0]), .Input(Input[5:0]), .wireOut(LEDR[0]));
endmodule

module muxLogic (MuxSelect, Input, wireOut);
	input [2:0] MuxSelect;
	input [5:0] Input;
	output wireOut;
	reg Out;
	
	always@(*)
		begin
			case(MuxSelect[2:0])
				3'b000: Out = Input[5];
				3'b001: Out = Input[4];
				3'b010: Out = Input[3];
				3'b011: Out = Input[2];
				3'b100: Out = Input[1];
				3'b101: Out = Input[0];
				default: Out = 3'b000;
			endcase
		end
		assign wireOut = Out;
endmodule
