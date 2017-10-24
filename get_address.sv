module get_address(clk, reset, direction, address, get_new_address, got_new_address);
	input reset, clk, get_new_address, direction;
	output logic [22:0] address;
	output got_new_address;

	logic [5:0] state;
	logic address_read_en, enable_out_address;
	logic [22:0] new_address;
	logic got_new_address;

	parameter start_address =  		23'h0;
	parameter end_address =     	23'h7FFFF;
	
	parameter idle = 				6'b001_000;
	parameter get_addr = 	   		6'b010_001;
	parameter got_address =     	6'b011_010;
	parameter send_address_out = 	6'b100_100;

	assign address_read_en =        state[0]; // assigning bits
	assign enable_out_address =     state[1]; 
	assign got_new_address =        state[2];


	always_ff @(posedge clk or posedge reset) 
		begin
			if(reset) 
			 	state <= idle;
			else
				begin
					case(state)
						idle: // wait till we get a start signal from flash_fsm
							begin
								if(get_new_address) 
									state <= get_addr;
								else 
									state <= idle;
							end

						get_addr: // enable enable_out_address to increment address
							begin
								state <= got_address;
							end

						got_address: // send signal to flash_fsm that the address is ready
							begin
								state <= send_address_out;
							end
						
						send_address_out: // go back to idle and wait for start signal
							begin
								state <= idle;
							end

						default: // default
							begin
								state <= idle;
							end

					endcase
				end 		
		end

	

	always_ff @(posedge enable_out_address or posedge reset) 
		begin
			if(reset) // give the starting address
				new_address = start_address;
			
			else if(!direction)// if the direction is moving forward 
				begin
					if(address == start_address)
						new_address <= end_address;
					else 
						new_address <= new_address - 1;
				end

			else 
				begin      // direction moving backwards 
					if(address == end_address)
						new_address <= start_address;
					else 
						new_address <= new_address + 1;

				end
			
		end


	always_ff @(posedge address_read_en or posedge reset) // wait for state to get send_address_out and then give the address the final value
		begin
			address = new_address;
		end




endmodule  


module tb();
	logic reset, clk, get_new_address, direction;
	wire [22:0] address;
	wire got_new_address;

	get_address testing(clk, reset, direction, address, get_new_address, got_new_address);

	initial begin
		clk = 1'b0;
		reset = 1'b1;
		get_new_address = 1'b0;
		direction = 1'b1;
		#5
		clk = 1'b1;
		#5
		clk = 1'b0;
		reset = 1'b0;
		#5
		get_new_address = 1'b1;
		clk = 1'b1;
		#5
		clk = 1'b0;
		get_new_address = 1'b0;
		#5
		clk = 1'b1;
		get_new_address = 1'b1;
		#5
		clk = 1'b0;
		#5
		clk = 1'b1;
		#5
		clk = 1'b0;
		get_new_address = 1'b0;
		#5
		clk = 1'b1;
		get_new_address = 1'b1;
		#5
		clk = 1'b0;
		#5
		clk = 1'b1;
		get_new_address = 1'b1;
		#5
		clk = 1'b0;
		#5
		get_new_address = 1'b0;
		clk = 1'b1;
		#5
		clk = 1'b0;
		#5
		clk = 1'b1;
		#5
		clk = 1'b0;
		#5
		clk = 1'b1;
		#5
		clk = 1'b0;
		#5
		clk = 1'b1;
		#5
		clk = 1'b0;
		#5;

	end

endmodule