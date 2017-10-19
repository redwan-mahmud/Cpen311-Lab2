module control_speed(clock, dec_speed, inc_speed, defaultSpeed, speed_control);
	

	input logic clock, dec_speed, inc_speed, defaultSpeed;
	output logic [15:0] speed_control;

	always_ff @(posedge clock) begin
		if(defaultSpeed)
				speed_control <= 1136;     // no need to adjust speed for def

		else if(inc_speed)
				speed_control <= speed_control + 5;  //adding 1 hex to increase speed 

		else if (dec_speed)
				speed_control <= speed_control - 5; // deducting 1 hex to decrease speed 

		else 
				speed_control <= speed_control;
		end 

endmodule