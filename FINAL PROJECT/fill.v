module visuals(CLOCK_50, 
	SW, KEY, //my inputs
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
	input [0:0] KEY;
	input [2:0] SW;
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
	wire [8:0] colour, colourPlayer, colourBG;
	wire [8:0] x;
	wire [8:0] y;
	wire go, erase, update, resetn,plot_en, reset; //plot

	assign resetn= KEY[0];

	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(go),
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

	datapath d(CLOCK_50, plot_en, resetn, go, erase, update, reset, /*SW[2:0],*/ x, y, colour,CounterA, counter_X, counter_Y, Frequency, colourPlayer, colourBG);
	control cc(CLOCK_50, resetn, CounterA, counter_X, counter_Y, Frequency, go, erase, update, plot_en, reset);
	player  pl(.address(CounterA),.clock(CLOCK_50),.data(000),.wren(0),.q(colourPlayer));
	background  bg(.address(y*320 + x),.clock(CLOCK_50),.data(000),.wren(0),.q(colourBG));

endmodule


module datapath(input clk, plot_en, resetn, go, erase, update, reset,
		/*input [2:0] colour_in,*///left over from when this was the pixel function
		output reg [8:0] colourLocX,
		output reg [8:0] colourLocY,
		output reg [8:0] colour_out,
		output reg [9:0] CounterA,
		output reg [8:0] CounterX,
		output reg [8:0] CounterY,
		output reg [25:0] Frequency,
		input [8:0] colourPlayer, 
		input [8:0] colourBG);

	reg opX, opY;
	reg [8:0] xAnchor; //this represents the x of the bottom left corner of the moving object
	reg [8:0] yAnchor; //this represents the y of the bottom left corner of the moving object
	reg [5:0] CounterXColour, CounterYColour;
	reg [9:0] CounterADelayer; //this will be one numebr ahead counter A
	initial CounterADelayer = 0;
	initial colourLocX = 0;
	initial colourLocY = 0;
	initial CounterA = 0;
	initial CounterX = 0;
	initial CounterY = 0;
	initial CounterXColour = 0;
	initial CounterYColour = 0;
	



	always@(posedge clk) begin
		if (reset || !resetn)begin
			colourLocX<= 9'd0;//x location to be coloured
			colourLocY<= 9'd181;//ylocation to be coloured
			xAnchor <= 9'd0;
			yAnchor <= 9'd181;
			CounterA<= 0;
			CounterX<= 9'b0;
			CounterY <= 9'b0;
			colour_out <= 3'b0;
			Frequency <= 25'd0;
			CounterADelayer <=0;
			CounterXColour <= 0;//this must start with zero becasue on the first clock tick, 1 gets added to them, making their effective start value zero
			CounterYColour <= 0;//this must start with zero becasue on the first clock tick, 1 gets added to them, making their effective start value zero
										//neg one above also fixes the texture offset for the player caused by the extra pixel
			opX <= 1'b0;//X operator, controlls whether x is upcounting (1) or down counting(0)
			opY <= 1'b0;//Y operator, controlls whether y is upcounting (1) or down counting(0)
		end
		else begin
			
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
					
					//the next three lines set up the delay, which allows us acess the firs tpixel of the photo from memory before writing the the screen
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
			

			if (update) begin //this is going to actually move our player
				if (xAnchor <= 9'd3) begin
					
					opX = 1;
				end
				if ( xAnchor >= 9'd300) begin//since player is 20 wide, must start down couting 20 before end of screen (320-4)
					opX = 0;
				end
				if ( yAnchor <= 9'd3) begin
					
					opY = 1;
				end
				if ( yAnchor >= 9'd200) begin//since pixel is 40 tall, must start down couting 40 before end of screen (240-4)
					opY = 0;
				end
				if (opX == 1'b1) begin	
					colourLocX <= xAnchor + 4;
					xAnchor <= xAnchor + 4;
				end
				if (opX == 1'b0) begin
					colourLocX <= xAnchor-4;
					xAnchor <= xAnchor - 4;
				end
				if (opY == 1'b1) begin
					colourLocY <= yAnchor ;//+ 4;
					yAnchor <= yAnchor ;//+ 4;
				end
				if (opY == 1'b0) begin
					colourLocY <= yAnchor ;//-4;
					yAnchor <= yAnchor ;//- 4;
					
				end
			end //end of if(update)
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
					output reg go, erase,update, plot_en, reset);

	reg [2:0] current_state, next_state;

	localparam RESET = 3'b0,
	DRAW= 3'b001,
	WAIT = 3'b010,
	ERASE= 3'b011,
	UPDATE= 3'b100,
	CLEAR= 3'b101;

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
			UPDATE: next_state = DRAW;
			CLEAR: next_state = (CounterX == 10'd320 & CounterY == 10'd240) ? RESET : CLEAR;//when youre erasing the whole screen, wait until you get to the end to reset
			default: next_state = RESET;
		endcase
	end//end of always @



	always@(*)begin: enable_signals
		go = 1'b0;
		update = 1'b0;
		reset = 1'b0;
		erase = 1'b0;
		plot_en = 1'b0;

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

