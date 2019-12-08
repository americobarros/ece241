module morsetranslate(input [2:0] SW,
					input [1:0] KEY,
					input CLOCK_50,
					output [9:0] LEDR);
	parameter [13:0]  I_=14'b00000000001010, J_=14'b11101110111010,K_=14'b00001110101110, L_=14'b00001010111010, M_=14'b00000011101110, N_=14'b00000000101110, O_=14'b00111011101110, P_=14'b00101110111010;
	reg [27:0] R0 = 24999999;
	wire w2;
	reg [13:0] w3;
	wire [27:0] w1;
	
	RateDivider U1(R0, CLOCK_50, w1);
	assign w2 = ~ (|w1);
	//assign LEDR[8] = w2;
	
	always@(*)begin
		case(SW[2:0])
			3'b000:  w3 <= I_;
			3'b001:  w3 <= J_;
			3'b010:  w3 <= K_;
			3'b011:  w3 <= L_;
			3'b100:  w3 <= M_;
			3'b101:  w3 <= N_;
			3'b110:  w3 <= O_;
			3'b111:  w3 <= P_;
		endcase
	end
	
	shift_register U2(CLOCK_50, w2, KEY[0], KEY[1], w3, LEDR[0]);
	
endmodule
	
	
	

module RateDivider(input [27:0] D,
							input clk,
							output [27:0] Q);
							
	reg [27:0] QR = {28{1'b0}};
	assign Q = QR;
	always @ (posedge clk) begin
		if (QR == D|| QR > D)
			QR <= 0;
		else
			QR <= QR+1;
	end
endmodule

module shift_register(input clk, enable, resetn, loadn,
					input [13:0] data,
					output out);
	reg [13:0] Q = {14{1'b0}};
	always@(posedge clk) begin
		if(resetn==0)
			Q<=0;
		else if(loadn==0) begin
			Q<=data;
		end
		else if(enable) begin
			Q[13] <= 1'b0;
			Q[12] <= Q[13];
			Q[11] <= Q[12];
			Q[10] <= Q[11];
			Q[9] <= Q[10];
			Q[8] <= Q[9];
			Q[7] <= Q[8];
			Q[6] <= Q[7];
			Q[5] <= Q[6];
			Q[4] <= Q[5];
			Q[3] <= Q[4];
			Q[2] <= Q[3];
			Q[1] <= Q[2];
			Q[0] <= Q[1];
		end
	end
	//wire [13:0] Qtest = Q;
	assign out = Q[0];
endmodule
	
	