module freq_divider(CLK_50M, div_by, clk_out, rst);
	input CLK_50M, rst;
	input [31:0] div_by;
	output reg clk_out;
	reg [31:0] count_16;

	always @(posedge CLK_50M) 
		begin 
			if (count_16 < div_by)
				count_16 <= count_16 + 1;
			else
				begin
					count_16 <= 0;
					clk_out <= ~clk_out;
				end
		end

endmodule