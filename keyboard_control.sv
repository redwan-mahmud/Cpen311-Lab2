module keyboard_control (clock, reset, key_pressed, direction, pause, restart);
	input logic clock, reset;
	input logic [7:0] key_pressed;
	output logic direction, pause, restart;

	logic[3:0] state;

	//Uppercase letters 
	parameter character_B =8'h42;
	parameter character_D =8'h44;
	parameter character_E =8'h45;
	parameter character_F =8'h46;
	parameter character_R =8'h52;


	//states             pause    direction   restart
//                       bit3     bit1        bit 0              
	parameter start  =         4'b0001;
	parameter start_Forward  = 4'b0010;
	parameter start_Backward = 4'b0000;
	parameter restart_Forward = 4'b0011;
	parameter restart_Backward = 4'b0101;
	parameter pause_Forward = 4'b1010;
	parameter pause_Backward = 4'b1000;

	always_ff @(posedge clock or posedge reset)begin
		if(reset)
			state <= start;
		else 
		begin
			case(state)
				start:  		if(key_pressed ==character_E)
										state <= start_Forward;
								else if (key_pressed == character_B)
										state <= start_Backward;
								else 
										state <= start;

				start_Forward:  if(key_pressed == character_D)    // playing forward 
										state <= pause_Forward;
							    else if(key_pressed == character_B)
										state <= start_Backward;
								else if(key_pressed == character_R)
										state <= restart_Forward;
								else 
										state <= start_Forward;

				start_Backward: if(key_pressed == character_D)    // playing backward
										state <= pause_Backward;
								else if (key_pressed == character_R)
										state <= restart_Backward;
								else if (key_pressed == character_F)
										state <= start_Forward;
								else 
										state <= start_Backward;

				pause_Forward:  if(key_pressed == character_E)
										state <= start_Forward;
								else if(key_pressed == character_B)
										state <= pause_Backward;
								else if(key_pressed == character_R)
										state <= restart_Forward;
								else 
										state <= pause_Forward;

				pause_Backward: if(key_pressed == character_E)
										state <= start_Backward;
								else if(key_pressed == character_F)
										state <= pause_Forward;
								else if(key_pressed == character_R)
										state <= restart_Backward;
								else 
										state <= pause_Backward;

				restart_Forward: 
										state <= start_Forward;
				restart_Backward:
										state <= start_Backward;
					

				default: 				state <= start;
				endcase // state
			end
		
	end 	

//setting outputs from states 
	always_comb
	begin
		direction <= state[1];
		pause     <= state[3];
		restart   <= state[0];
	end
	
	
	
endmodule

/*
module tb();
	logic clock, reset;
	logic [7:0] key_pressed;
	wire direction, pause, restart;


	control_speed testing(clock, reset, key_pressed, direction, pause, restart);

	

	initial begin
		clk = 1'b1;
		reset = 1'b1;
		key_pressed = 8'h45;

		#5

		clk = 1'b0;

		#5

		clk =1'b0;

		key_pressed = 8'h52;
		#5
		clk = 1'b0;

		#5
		clk = 1'b1;
		key_pressed = 8'h46;
		#5
		clk = 1'b0;


		#5
		clk = 1'b1;
		key_pressed = 8'h44;
		#5
		clk = 1'b0;


		#5
		clk = 1'b1;
		key_pressed = 8'h42;
		#5
		clk = 1'b0;


		#5

	end

endmodule
*/