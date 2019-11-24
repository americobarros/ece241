module visuals(CLOCK_50, 
	SW, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, //my inputs
	VGA_CLK,   						//	VGA Clock
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK_N,						//	VGA BLANK
	VGA_SYNC_N,						//	VGA SYNC
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B   						//	VGA Blue[9:0]
	);

	input CLOCK_50;
	input [1:0] KEY;
	input [2:0] SW;
	output[6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire [9:0] CounterA;
	wire [8:0] counter_X;
	wire [8:0] counter_Y;
	wire [25:0] Frequency;
	wire [8:0] colour, colourPlayer, colourBG, colourWIN;
	wire [8:0] x;
	wire [8:0] y;
	wire [8:0] yAnchor;
	wire [8:0] xAnchor;
	wire go, erase, update, resetn,plot_en, reset, win, transparent, runTimer; //plot

	assign resetn= KEY[0];

	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(go && !transparent),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));

		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
		defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";

	datapath d(CLOCK_50, plot_en, resetn, go, erase, update, reset, ~KEY[1], win, x, y, colour,CounterA, counter_X, counter_Y, Frequency, xAnchor, yAnchor, colourPlayer, colourBG, colourWIN, transparent, runTimer);
	control cc(CLOCK_50, resetn, CounterA, counter_X, counter_Y, Frequency, xAnchor, yAnchor, go, erase, update, plot_en, reset, win);
	player  pl(.address(CounterA),.clock(CLOCK_50),.data(000),.wren(0),.q(colourPlayer));//should have been rom instead of ram...
	background  bg(.address(y*320 + x),.clock(CLOCK_50),.data(000),.wren(0),.q(colourBG));
	background  bg2(.address(y*320 + x),.clock(CLOCK_50),.data(000),.wren(0),.q(colourWIN));//change this to the win screen module
	clock_counter cc1(.rate(01), .clk(CLOCK_50), .enable(!win), .reset(!resetn), .segments({HEX5[6:0],HEX4[6:0],HEX3[6:0],HEX2[6:0],HEX1[6:0],HEX0[6:0]}));

endmodule


module datapath(input clk, plot_en, resetn, go, erase, update, reset, jump, win,
		output reg [8:0] colourLocX,
		output reg [8:0] colourLocY,
		output reg [8:0] colour_out,
		output reg [9:0] CounterA,
		output reg [8:0] CounterX,
		output reg [8:0] CounterY,
		output reg [25:0] Frequency,
		output reg [8:0] xAnchor, //this represents the x of the bottom left corner of the moving object
		output reg [8:0] yAnchor, //this represents the y of the bottom left corner of the moving object
		input [8:0] colourPlayer, 
		input [8:0] colourBG,
		input [8:0] colourWIN,
		output reg transparent, runTimer);
	
	reg jumpAllow;
	reg opX;
	reg [1:0] opY; //00 = move up, 01 move down, 10 = dont move
	reg [6:0] jumpHeight;
	reg [5:0] CounterXColour, CounterYColour;
	reg [9:0] CounterADelayer; //this will be one numebr ahead counter A
	initial CounterADelayer = 0;
	initial colourLocX = 0;
	initial colourLocY = 0;
	initial CounterA = 0;
	initial CounterX = 0;
	initial CounterY = 0;
	initial CounterXColour = 0;
	initial CounterYColour = 9'd181;
	initial jumpHeight = 0;
	initial jumpAllow = 1; //start on platform
	initial transparent = 0;
	initial xAnchor = 0;
	initial yAnchor = 9'd181;
	



	always@(posedge clk) begin
		transparent = 0;
		if (reset || !resetn)begin
			colourLocX<= 9'd0;//x location to be coloured
			colourLocY<= 9'd181;//ylocation to be coloured
			xAnchor <= 9'd0;
			yAnchor <= 9'd181;
			CounterA<= 0;
			CounterX<= 9'b0;
			CounterY <= 9'b0;
			colour_out <= 9'b0;
			Frequency <= 25'd0;
			CounterADelayer <=0;
			CounterXColour <= 0;//this must start with zero becasue on the first clock tick, 1 gets added to them, making their effective start value zero
			CounterYColour <= 0;//this must start with zero becasue on the first clock tick, 1 gets added to them, making their effective start value zero
										//neg one above also fixes the texture offset for the player caused by the extra pixel
			opX <= 1'b0;//X operator, controlls whether x is upcounting (1) or down counting(0)
			//opY <= 2'b00;//Y operator, controlls whether y is upcounting (1) or down counting(0)
			//jumpHeight <= 0;
		end
		else begin
			if(win) begin
				if (CounterX == 9'd320 && CounterY!= 9'd240) begin //if you get to the end of the right of the screen, but youre not at the bottom, move one
					CounterX <= 9'b0;											//line closer to the bottom, and reset the erase cursor to the left
					CounterY <= CounterY +1;
				end

				else begin
					CounterX <= CounterX+1;
					colourLocX<= CounterX;
					colourLocY<= CounterY;
					colour_out <= colourWIN; 
				end
				runTimer = 0;
			end //end of if win
			if (erase & !plot_en) begin //this case happens when you click reset
				if (CounterX == 9'd320 && CounterY!= 9'd240) begin //if you get to the end of the right of the screen, but youre not at the bottom, move one
					CounterX <= 9'b0;											//line closer to the bottom, and reset the erase cursor to the left
					CounterY <= CounterY +1;
				end

				else begin
					CounterX <= CounterX+1;
					colourLocX<= CounterX;
					colourLocY<= CounterY;
					colour_out <= colourBG; 
				end
				 
			end //end of erase & !plot_en
			
			if (!erase) colour_out <= 9'b000010010; //there is a moment where colour out is not assigned a colour, this fixes that problem
			
			if (Frequency == 26'd3255731) Frequency <= 26'd0;//this is how often our pixel will be updated, calculated with 50000000/60*4-(802+240x340)
			else Frequency<= Frequency +1;
			
			if (plot_en) begin
				if(erase) begin
					if (CounterX == 9'd320 && CounterY!= 9'd240) begin //if you get to the end of the right of the screen, but youre not at the bottom, move one
						CounterX <= 9'b0;											//line closer to the bottom, and reset the erase cursor to the left
						CounterY <= CounterY +1;
					end
					else if (CounterX == 9'd320 && CounterY== 9'd240) begin
						CounterX<=0;
						CounterY<=0;
					end
					else begin
						CounterX <= CounterX+1;
						colourLocX<= CounterX;
						colourLocY<= CounterY;
						colour_out <= colourBG; 
					end
					
				end
				else begin 
					colour_out <= colourPlayer;
					if (colourPlayer == 9'b000010010) transparent = 1;
					//the next three lines set up the delay, which allows us acess the first pixel of the photo from memory before writing the screen
					if(CounterADelayer == 0) CounterA <= 0;
					if(CounterA == 0) CounterADelayer<=CounterADelayer + 1;
					if(CounterADelayer > 0) begin
					
						if (CounterA == 10'd800)begin //copy the image of 800pixels
							CounterA<= 0;
							CounterADelayer <= 0;
							CounterXColour <= 6'b0;
							CounterYColour <= 6'b0;
							colourLocX <= xAnchor;
							colourLocY <= yAnchor;
						end
						else CounterA<=CounterA+1;//if you havent reached 800 pixels, keep counting
						if((CounterA!=800)&(CounterA > 0))begin//while we are counting to 800, the X and Y are moving on the screen, on order to print our image
							if((CounterYColour == 6'd39) & (CounterXColour == 6'd19))begin//they must move 20 pixels wide and 40 pixels tall
								CounterYColour <=0;
								CounterXColour <= 0;
							end
							if (CounterXColour >= 6'd19)begin
								CounterYColour <= CounterYColour + 1;
								CounterXColour <= 0;
							end
							else CounterXColour <= CounterXColour+1;
						end
					end
					colourLocX <= xAnchor + CounterXColour;//this adds the player location +20 and +40 to draw the player at that location
					colourLocY <= yAnchor + CounterYColour;
				end
			end //end of enable plt
			
			
			if( jump == 1 && jumpAllow ==1) opY=00; 

			if (update) begin //this is going to actually move our player
				
				if (xAnchor <= 9'd3) begin
					
					opX = 1;
				end
				if ( xAnchor >= 9'd300) begin//since player is 20 wide, must start down couting 20 before end of screen (320-4)
					opX = 0;
				end
				if ( jumpHeight >= 7'd79 || yAnchor < 4) begin // only jump 79 px high OR up to the top of the screen
					opY = 2'b01;
				end 
				if ( jumpAllow==1 && opY !=00) begin//the player is on a platform and not in the middle of a jump (becasue it should never stop mid jump, should only stop on the platform at the end of the jump)
					opY = 2'b10;
				end
				else if (opY!=00) begin //if the player isnt jumping and isnt on a platform then make them fall (they fell off a platform)
					opY = 2'b01;
				end
				if (opX == 1'b1) begin	
					colourLocX <= xAnchor + 4;
					xAnchor <= xAnchor + 4;
				end
				if (opX == 1'b0) begin
					colourLocX <= xAnchor-4;
					xAnchor <= xAnchor - 4;
				end
				if (opY == 2'b01) begin //move player down on screen
					colourLocY <= yAnchor + 4;
					yAnchor <= yAnchor + 4;
					jumpHeight <=0; //we are no longer moving upwards, so the jump height can be reset (no need to track the fall)
				end
				if (opY == 2'b00) begin //move player higher on screen
					colourLocY <= yAnchor -4;
					yAnchor <= yAnchor - 4;
					jumpHeight <= jumpHeight + 4; //the higher you jump, the higher the jump height
					
				end
			end //end of if(update)
			
			
			//this will tell if the player is on a platform and therefore, jump should be allowed
			if (( ( yAnchor >= 9'd181)//on the ground
										|| (yAnchor <= 9'd106 & yAnchor >= 9'd102)&(xAnchor >= 0 & xAnchor <=9'd109) //the left middle platform located at yAnchor = 104 (actual position is 104+40 bc player height)
										|| (yAnchor <= 9'd106 & yAnchor >= 9'd102)&(xAnchor >= 191 & xAnchor <=9'd301) //the right middle platform located at yAnchor = 104 (actual position is 104+40 bc player height)
										|| (yAnchor <= 9'd56 & yAnchor >= 9'd52)&(xAnchor >= 191 & xAnchor <=9'd268) //right top platform
										|| (yAnchor <= 9'd56 & yAnchor >= 9'd52)&(xAnchor >= 30 & xAnchor <=9'd109)//left top platform
										|| (yAnchor <= 9'd13 & yAnchor >= 9'd10)&(xAnchor >= 117 & xAnchor <=9'd183) //top middle platform
										)) jumpAllow=1;
			else jumpAllow = 0;
			
			
			//(yAnchor <= 9'd13 & yAnchor >= 9'd10)&(xAnchor >= 133 & xAnchor <=9'd167) winning platform!!!
			
			
		end//end of reset / !resetn
		if (erase==0 & plot_en==0)begin
			CounterA<= 0; 
			colourLocX<=xAnchor;
			colourLocY<=yAnchor;
			CounterADelayer <=0;
			CounterXColour <= 6'b0;
			CounterYColour <= 6'b0;
		end
	end//end of always@
endmodule


module control(input clk, resetn, 
					input [9:0] CounterA,
					input [9:0] CounterX,
					input [9:0] CounterY,
					input [25:0] Frequency,
					input [8:0] xAnchor, 
					inout [8:0] yAnchor,
					output reg go, erase,update, plot_en, reset, win);

	reg [2:0] current_state, next_state;

	localparam RESET = 3'b0,
	DRAW= 3'b001,
	WAIT = 3'b010,
	ERASE= 3'b011,
	UPDATE= 3'b100,
	CLEAR= 3'b101,
	ENDGAME = 3'b110;

	always@(*)begin: state_table
		case(current_state)
			RESET: next_state = DRAW;
			
			DRAW:	begin
				if (CounterA < 10'd800) next_state = DRAW; //keep draw going for long enough to draw 800 pixels
				else next_state= WAIT;
			end
			WAIT: begin
				if (Frequency < 26'd3255731) next_state= WAIT;
				else next_state = ERASE;
			end
			ERASE: begin
				if ((CounterX < 9'd320) | (CounterY < 9'd240)) next_state = ERASE;//keep erase going so it can erase the whole screen
				else next_state= UPDATE;
			end
			UPDATE:begin
				if ((yAnchor <= 9'd13 & yAnchor >= 9'd10)&(xAnchor >= 133 & xAnchor <=9'd167)) next_state = ENDGAME;
				else next_state = DRAW;
			end
			CLEAR: next_state = (CounterX == 10'd320 & CounterY == 10'd240) ? RESET : CLEAR;//when youre erasing the whole screen, wait until you get to the end to reset
			ENDGAME: next_state = ENDGAME;
			default: next_state = RESET;
		endcase
	end//end of always @



	always@(*)begin: enable_signals
		go = 1'b0;//go=1 means to enable the vga output
		update = 1'b0;//move the player in the desired direction
		reset = 1'b0;//move player to initial position, reset all values
		erase = 1'b0;//redraw the background
		plot_en = 1'b0;//draw the player
		win = 1'b0;

		case(current_state)
			RESET:begin
				reset = 1'b1;
			end
			DRAW: begin
				go  = 1'b1;
				erase = 1'b0;
				plot_en = 1'b1;
			end
			ERASE: begin
				go  = 1'b1;
				erase = 1'b1;
				plot_en = 1'b1;
			end
			UPDATE: update = 1'b1;
			CLEAR: begin
				erase = 1'b1;
				go = 1'b1;
			end
			ENDGAME: begin
				win = 1'b1;
			end
			default: begin
				go = 1'b0;
				update = 1'b0;
				reset = 1'b0;
				erase = 1'b0;
				plot_en = 1'b0;
			end
		endcase
	end//end of always @

	always@(posedge clk)begin: state_FFs
      if(!resetn /*|| reset*/) current_state <= CLEAR;
     	else current_state <= next_state;
 	end // state_FFS

endmodule





//NEXT MODULES ARE FOR THE HEX DISPLAYS

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

module DisplayCounter(input rateDivIn,
							input Enable,
							input clk,
							input reset,
							output reg [4:0] Q,
							output reg HalfTick);

	initial Q <= {4{1'b0}};
	always @(posedge clk) begin
		HalfTick = 0;
		if (reset) Q <= 4'b0;
		else if(Q == 4'b1001 && Enable == 1'b1 && rateDivIn == 1'b1)begin
			Q <=4'b0000;
			HalfTick = 1;
		end
		else if (Enable == 1'b1 && rateDivIn == 1'b1)begin
			Q <= Q+1;
		end
	end
endmodule

module clock_counter (input [1:0] rate,
							input clk,
							input enable,
							input reset,
	 						output [41:0] segments);
	reg [27:0] w0;
	wire [23:0] w3;
	wire [27:0] w1;
	wire [7:0] w2;
	
	
	always @ (*) begin//posedge CLOCK_50) begin
		case (rate[1:0])
			2'b00:	w0 <= 28'b0000000000000000000000000000;
			2'b01:	w0 <= 24999999;
			2'b10:	w0 <= 49999999; 
			2'b11:	w0 <= 99999999; 
		endcase
	end
	
	assign w2[0] = ~ (|w1);
	
	RateDivider U1(w0, clk, w1);
	DisplayCounter c1(.rateDivIn(w2[0]), .Enable(enable), .clk(clk), .Q(w3[3:0]), .reset(reset), .HalfTick(w2[1]));
	DisplayCounter c2(.rateDivIn(w2[1]), .Enable(enable), .clk(clk), .Q(w3[7:4]), .reset(reset), .HalfTick(w2[2]));
	DisplayCounter c3(.rateDivIn(w2[2]), .Enable(enable), .clk(clk), .Q(w3[11:8]), .reset(reset), .HalfTick(w2[3]));
	DisplayCounter c4(.rateDivIn(w2[3]), .Enable(enable), .clk(clk), .Q(w3[15:12]), .reset(reset), .HalfTick(w2[4]));
	DisplayCounter c5(.rateDivIn(w2[4]), .Enable(enable), .clk(clk), .Q(w3[19:16]), .reset(reset), .HalfTick(w2[5]));
	DisplayCounter c6(.rateDivIn(w2[5]), .Enable(enable), .clk(clk), .Q(w3[23:20]), .reset(reset), .HalfTick(w2[6]));
	hex_decoder d1(w3[3:0], segments[6:0]);
	hex_decoder d2(w3[7:4], segments[13:7]);
	hex_decoder d3(w3[11:8], segments[20:14]);
	hex_decoder d4(w3[15:12], segments[27:21]);
	hex_decoder d5(w3[19:16], segments[34:28]);
	hex_decoder d6(w3[23:20], segments[41:35]);
	
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule


