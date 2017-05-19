module data(
  input clk_h,
  input rst_n,
  input [63:0] sdram_data_in,
  input [255:0] mem_data_in,
  input clear_data,
  input sdram_read_enable,
  input empty_buffer,
  input add_sdram_addr,
  //input [1:0] reg_pointer_beg;// 00 01 10 11
  //input [1:0] reg_pointer_curr;// 00 01 10 11

  output [63:0] sdram_data_out,
  output [255:0] mem_data_out,
  output write_ready,
  output read_ready
  );
  
  reg [2:0] reg_pointer_beg;// 00 01 10 11
  reg [2:0] reg_pointer_curr;// 00 01 10 11
  reg [255:0] data_out;
  reg [63:0] buffer [0:3];
  reg write_ready;
  reg read_ready;
  assign mem_data_out=data_out;
  
 always@(posedge clk_h)
begin
  if (rst_n == 1'b0) begin
    reg_pointer_beg <= 3'b0;
    reg_pointer_curr <= 3'b0;
	data_out <= 256'b0;
	buffer[0] <=64'b0;
	buffer[1] <=64'b0;
	buffer[2] <=64'b0;
	buffer[3] <=64'b0;
	write_ready <=0;
	read_ready<=1;
  end
  
end

always@(posedge clk_h)
begin
if(clear_data==1)
begin
    reg_pointer_beg <= 3'b0;
    reg_pointer_curr <= 3'b0;
	data_out <= 256'b0;
	buffer[0] <=64'b0;
	buffer[1] <=64'b0;
	buffer[2] <=64'b0;
	buffer[3] <=64'b0;
	write_ready <=0;
	read_ready<=1;
end
else begin
    
	if (sdram_read_enable==1 && read_ready==1 && add_sdram_addr==1)
	begin
	
	buffer[reg_pointer_curr % 3'b100]<=sdram_data_in;
	reg_pointer_curr<=(reg_pointer_curr+3'b001)% 3'b100;
	end
	
	if (((reg_pointer_curr-reg_pointer_beg)>3'b000 &&(reg_pointer_curr-reg_pointer_beg)== 3'b011)||
			((reg_pointer_curr-reg_pointer_beg)<3'b000 &&(reg_pointer_curr-reg_pointer_beg+3'b100)== 3'b011)) 
	begin
		if(empty_buffer==1)begin
			write_ready<=1;
			data_out[63:0]<=buffer[reg_pointer_beg]；
			data_out[127:64]<=buffer[(reg_pointer_beg+3'b001)% 3'b100];
			data_out[191:128]<=buffer[(reg_pointer_beg+3'b010)% 3'b100];
			data_out[255:192]<=buffer[(reg_pointer_beg+3'b011)% 3'b100];
			read_ready<=1;
	//reg_pointer_beg<=(reg_pointer_beg+3'b001)% 3'b100;
		end
		else begin
		write_ready<=1;
		read_ready<=0;
		end
	end
	else
	begin
		write_ready<=0;
		read_ready<=1;
	end
end
end

endmodule

