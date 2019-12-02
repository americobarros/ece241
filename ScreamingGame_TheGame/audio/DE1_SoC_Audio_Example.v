
module audio (
	// Inputs
	CLOCK_50,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	jumpenable,
	jumpOUT,
	reset
	
);





/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input 			[6:0]jumpenable;
input 			reset;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output			AUD_XCK;
output			AUD_DACDAT;

output			FPGA_I2C_SCLK;

output reg 		jumpOUT;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire	signed	[31:0]	left_channel_audio_in;
wire				[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire 				[31:0]	left_channel_audio_out;
wire				[31:0]	right_channel_audio_out;
wire				write_audio_out;

reg ledenable;
reg [27:0]ledcnt;
reg [31:0]toppart;
reg [31:0]average;
reg toppart_available;
reg [27:0]topcnt;
reg topreset;
reg [31:0]audio_in;
wire playJump;
assign playJump = {|jumpenable};


// Internal Registers






// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
	localparam state1 = 2'b00, state2 = 2'b01,state3 = 2'b10,state4 = 2'b11;
	reg [1:0]keystate;
	reg [1:0]keynext;
	
	
	always @(posedge CLOCK_50)begin
		keystate <= keynext;
	end
	
	always @(*)begin
		case(keystate)
			state1:begin
				if(playJump)
				begin
					keynext = state3;
				end
				else begin
					keynext = state1;
				end
			end
			state3:begin
				if(keycount == 'd5)begin
					keynext = state4;
				end
				else begin
					keynext = state3;
				end
			end
			state4: begin
				if (keycount == 'd0 && (~playJump))begin
					keynext = state1;
				end
				else begin
					keynext = state4;
				end
			end
			default: keynext = state1; 
		endcase
	end
	reg [3:0]keycount = 'd0;
	always @(posedge CLOCK_50)begin
		if(keystate == state4)begin
		keycount<=0;
	end
	else if(keystate == state3)begin
			keycount <= keycount + 1;
	end
	end

	
	
	
	localparam playing = 2'b10, not_playing = 2'b00, waiting = 2'b01,returning = 2'b11;
	reg [1:0]current_s; 
	reg [1:0]next_s;
	
	always @(posedge CLOCK_50)begin
		current_s <= next_s;
	end
	
	always @(*)begin
		case(current_s)
			not_playing:begin
				if(keystate == state3)
				begin
					next_s = waiting;
				end
				else begin
					next_s = not_playing;
				end
			end
			waiting:begin
				if(~(keystate == state3))begin
					next_s = playing;
				end
				else begin
					next_s = waiting;
				end
			end
			playing:begin
				if(addy == 'd17722)begin
					next_s = returning;
				end
				else begin
					next_s = playing;
				end
			end
			returning: begin
				if (addy == 'd0)begin
					next_s = not_playing;
				end
				else begin
					next_s = returning;
				end
			end
			default: next_s = not_playing; 
		endcase
	end
				

	

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/



wire [32:0]soundout;
wire [14:0]address;
reg [14:0]addy = 'd0;
assign address = addy;
soundrom s1(address,CLOCK_50,soundout);

reg audenable;
reg [27:0]audcount;
always@(posedge CLOCK_50)begin
	if(audcount > 'd1041)begin
		audcount <= 0;
		audenable <= 1;
	end
	else begin
		audcount <= audcount + 1;
		audenable <= 0;
	end
end

wire sndenable = (current_s == playing);
 
always@(posedge CLOCK_50)begin
	if(current_s == returning)begin
		addy<=0;
	end
	else if(sndenable)begin
		if(audenable)begin
			addy <= addy + 1;
		end
	end
	
end


wire [31:0] sound = soundout >> 2;

always @(posedge CLOCK_50)begin
	if(ledcnt >= 'd12499999 && toppart_available == 1)
		begin
			ledcnt <= 0;
			topreset<=1;
			if(average > 'd150000000)
				begin
					jumpOUT <= 1;
				end
			else jumpOUT <= 0;
		end
	else ledcnt <= ledcnt + 1;topreset<=0;
end

	
always@(posedge CLOCK_50)begin
	audio_in <= left_channel_audio_in;
	average <= toppart;
end
	
always @(posedge CLOCK_50)
	begin
		if(topreset == 1)toppart <= 'd0;
		else if(audio_in_available == 1 && topcnt == 'd512)begin
			topcnt <= 0;
			toppart_available <= 1;
			toppart <= 0;
		end
		else if(audio_in_available == 1 )begin
			if(audio_in[31] == 0)begin
				toppart <= toppart + (audio_in >> 9);
			end
			topcnt <= topcnt + 1;
			toppart_available <= 0;
		end
	end
			

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/



assign read_audio_in			= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	=   sound;
assign right_channel_audio_out	=   sound;
assign write_audio_out			= audio_in_available & audio_out_allowed;



/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(reset),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(reset)
);

endmodule




