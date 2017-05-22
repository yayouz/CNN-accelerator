module address(
  input clk_h,
  input rst_n,
  input [5:0] latch_mem1_addr,
  input [5:0] latch_mem2_addr,
  input [7:0] latch_sdram_addr,
  input clear_addr,
  input init_sdram_addr,
  input init_mem1_addr,
  input init_mem2_addr,
  input add_sdram_addr,
  input add_mem1_addr,
  input add_mem2_addr,
  
  //input [1:0] reg_pointer_beg;// 00 01 10 11
  //input [1:0] reg_pointer_curr;// 00 01 10 11

  output [5:0] mem1_addr_out,
  output [5:0] mem2_addr_out,
  output [7:0] sdram_addr_out,
  );
  
  reg [5:0] mem1_addr_out,
  reg [5:0] mem2_addr_out,
  reg [7:0] sdram_addr_out,
  
  always@(posedge clk_h)
begin
  if (rst_n == 1'b0) begin
    mem1_addr_out<=6'b0;
	mem2_addr_out<=6'b0;
	sdram_addr_out<=8'b0;
  end
  
end

 always@(posedge clk_h)
begin
	if(clear_addr==1)
	begin
	mem1_addr_out<=6'b0;
	mem2_addr_out<=6'b0;
	sdram_addr_out<=8'b0;
	end
	else
	begin
	if(init_sdram_addr==1)
	sdram_addr_out<=latch_sdram_addr;
	else if(add_sdram_addr==1)
	sdram_addr_out<=sdram_addr_out+8'b00000100;
	else if(init_mem1_addr==1)
	mem1_addr_out<=latch_mem1_addr;
	else if(add_mem1_addr==1)
	mem1_addr_out<=mem1_addr_out+6'b010000;
	else if(init_mem2_addr==1)
	mem2_addr_out<=latch_mem2_addr;
	else if(add_mem2_addr==1)
	mem2_addr_out<=mem2_addr_out+6'b010000;
	end
end

endmodule
