module ex2(input v_cc, input async_sig_clk, input out_clk, output out_sync_sig);
	wire clr, first_top_out, bottom_out, second_top_out;
	
	register_async_clr first_top(.async_sig(async_sig_clk), .clr(bottom_out), .in(v_cc), .out(first_top_out));
	register_async_clr second_top(.async_sig(out_clk), .clr(1'b0), .in(first_top_out), .out(second_top_out));
	register_async_clr third_top(.async_sig(out_clk), .clr(1'b0), .in(second_top_out), .out(out_sync_sig));
	register_async_clr bottom(.async_sig(out_clk), .clr(1'b0), .in(out_sync_sig), .out(bottom_out));
	

endmodule


module register_async_clr(input async_sig, input clr, input in, output reg out);
  
 	always @(posedge async_sig or posedge clr) 
 		begin
 			if(clr == 1'b1)
 				out <=0;
 			else
  				out <= in;
  		end
  
endmodule

module ex2_tb;
	reg v_cc, async_sig_clk, out_clk;
	wire out_sync_sig;

	ex2 test_bench(v_cc, async_sig_clk, out_clk, out_sync_sig);

	initial begin
		v_cc = 1'b1; // value of input is 1
		async_sig_clk = 1'b0; // async clock is 0
		out_clk = 1'b0; // clock for all other flipflops is 0 too
		#5
		async_sig_clk = 1'b1; // async clock becomes 1 which is not connected to 3 flipflops out of 4
		#5
		async_sig_clk = 1'b0; 
		out_clk = 1'b1; // sync clock becomes 1 adn the data is copied from async flipflop to a sync flipflop. It is stored here until next sync cycle
		#5
		out_clk = 1'b0; 
		#5
		out_clk = 1'b1; // the value held in the top second flipfop now goes to the third flipflop. That becomes the output now
		#5
		out_clk = 1'b0;
		#5
		async_sig_clk = 1'b1; // async clock becomes 1 again
		v_cc = 1'b0; // the input is now changed to 0, to reset the value from the async flipflop
		out_clk = 1'b1; // sync clock is also set to 1
		#5
		async_sig_clk = 1'b0;
		out_clk = 1'b0;
		#5
		async_sig_clk = 1'b1;
		out_clk = 1'b1;
		#5
		out_clk = 1'b0;
		#5
		out_clk = 1'b1;
		#5;
	end
endmodule