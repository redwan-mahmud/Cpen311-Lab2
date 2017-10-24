module fsm_flash (CLK_50M, CLK_22K, data_in, mem_data_valid, address, start_read_memory, byteenable, reset, pause, direction, data_out, go_now);
	input [31:0] data_in;
	output logic [15:0] data_out;
	input mem_data_valid, CLK_50M, reset, CLK_22K, go_now, pause, direction;
	output [22:0] address;
	output logic start_read_memory;
	output logic [3:0] byteenable;

	logic [11:0] state;
	logic get_new_address, odd_addr, even_addr, got_new_address;

	parameter idle = 					12'b0000_0000_0000;
	parameter wait_state = 				12'b0001_0000_0000;
	parameter get_addressfsm_on = 		12'b0010_0010_0000;
	parameter get_addressfsm_off = 		12'b0011_0001_1111;
	parameter odd_address = 			12'b0100_1000_0000;
	parameter even_or_odd = 			12'b0101_0000_0000;
	parameter even_address = 			12'b0110_0100_0000;
	parameter clock_Wait =				12'b0111_0000_0000;
	parameter clock_Wait2 = 			12'b1000_0000_0000;
	
	assign	byteenable = 				state[3:0]; // bits for flash
	assign	start_read_memory =			state[4]; // read signal for flash
	assign	get_new_address = 			state[5]; // signal for starting get_address fsm
	assign	odd_addr = 					state[7]; // odd address bit
	assign 	even_addr = 				state[6]; // even address bit
	

	get_address getNow(CLK_50M, reset, direction, address, get_new_address, got_new_address); // instaintiating get_address to get address

   
	always_ff @(posedge CLK_50M or posedge reset)
		begin
			if(reset) 
				begin
				 	state <= idle;
				end 
			else
				begin
					case(state)
						idle: 
							begin
								if(go_now & !pause) state <= get_addressfsm_on; // gets address
								else state <= idle; // waits until we get a start signal from the edge detector
							end
						
						get_addressfsm_on: // wait until we get a ending signal from get_address fsm
							begin
								if(got_new_address)
							    	state <= get_addressfsm_off;
								else
									state <= wait_state; // wait until ending signal
							end

						wait_state: // wait until ending signal and switch off start signal for get_address fsm
							begin
								if(got_new_address) 
									state <= clock_Wait;
								else 
									state <= wait_state;
							end

						// wait for CLK_22K to go to one to, sync it with 50M clock
						clock_Wait:
							begin
								if(!CLK_22K) 
									state <= clock_Wait2;
								else 
									state <= clock_Wait;
							end

						clock_Wait2: 
							begin 
								if(CLK_22K) 
									state <= get_addressfsm_off;
								else
									state <= clock_Wait2;
							end

						get_addressfsm_off: // wait to get a read valid from the flash memory
							begin
								if(mem_data_valid & !pause) 
									state <= even_or_odd; 
							    else 
							    	state <= get_addressfsm_off;
							end

						even_or_odd: // check if the address is even or odd, and based on that assign even and odd
							begin
								if(even_addr)
									state <= odd_address; 
								else
									state <= even_address;

							end

						odd_address: // if odd address
							begin
								state <= idle;
							end
 
						even_addr: // if even address
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

		always_ff @(posedge even_addr or posedge odd_addr) // at posedge of even or odd, check if the address is even or add and assign values to data_out accordingly
			begin
				if(even_addr) 
					data_out = data_in[15:0];
				else
					data_out = data_in[31:16];
				
			end
		



endmodule

module testing_bench();
	logic [31:0] data_in;
	logic mem_data_valid, CLK_50M, reset, go_now, CLK_22K, pause, direction;
	wire [22:0] address;
	wire start_read_memory;
	wire [3:0] byteenable;
	wire [15:0] data_out;

	fsm_flash why_is_this(CLK_50M, CLK_22K, data_in, mem_data_valid, address, start_read_memory, byteenable, reset, pause, direction, data_out, go_now);

	initial begin
		CLK_50M = 1'b0;
		reset = 1'b1;
		data_in = 32'b1;
		mem_data_valid = 1'b0;
		pause = 1'b0;
		direction = 1'b1;
		go_now = 1'b1;
		#5
		CLK_50M = 1'b1;
		#5
		CLK_50M = 1'b0;
		reset = 1'b0;
		#5
		CLK_50M = 1'b1;
		go_now = 1'b1;
		#5;
		CLK_50M = 1'b0;
		go_now = 1'b0;
		#5
		CLK_50M = 1'b1;
		CLK_22K = 1'b0;
		#5
		CLK_50M = 1'b0;
		#5
		CLK_50M = 1'b1;
		CLK_22K = 1'b0;
		#5
		CLK_50M = 1'b0;
		#5
		CLK_50M = 1'b1;
		#5
		CLK_50M = 1'b0;
		#5
		
		CLK_50M = 1'b1;
		#5
		CLK_50M = 1'b0;
		#5
		
		CLK_50M = 1'b1;

		#5
		CLK_50M = 1'b0;
		#5
		CLK_50M = 1'b1;
		mem_data_valid = 1'b1;
		CLK_22K = 1'b1;
		
		#5
		CLK_50M = 1'b0;
		#5
		CLK_50M = 1'b1;
		CLK_22K = 1'b0;
		#5
		CLK_50M = 1'b0;
		#5
		CLK_50M = 1'b1;
		#5
		CLK_50M = 1'b0;
		#5;


	end

endmodule