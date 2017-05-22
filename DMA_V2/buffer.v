module buffer(clk_h,rst_n,buffer_addr_in,buffer_data_in,buffer_enable,data_type,buffer_selecter,dataRam,ram_addr_out,ram_selecter,buffer_ready,to_ram_ready);
  parameter DD_WIDTH = 16;
  parameter BUFFER_SIZE= 16;
  //parameter AD_WIDTH = 4;
  parameter RAM_ADDR_WIDTH = 4;
  parameter MEM_ADDR_WIDTH = 6;
  input clk_h;
  input rst_n;

  input [MEM_ADDR_WIDTH-1:0]  buffer_addr_in;
  input [255:0] buffer_data_in;
  input [1:0] buffer_enable;    //00:disable 01:read enable 10；write enable
  input [2:0] data_type; //000:disable 001:input 010:point_even 011:point_odd 100：v_ram 101:z_ram 110: bias_ram
  input buffer_selecter;
  
  output [DD_WIDTH-1:0] dataRam;//store data to ram
  //output [AD_WIDTH-1:0] addrRam //store address to ram
  output [RAM_ADDR_WIDTH-1:0] ram_addr_out;
  output [2:0]ram_selecter;   // 000:disable 001:input 010:point_even 011:point_odd 100：v_ram 101:z_ram 110: bias_ram
  output buffer_ready; //1:ready; 0：busy
  output to_ram_ready;  // send a w_en signal

  
  
  reg[DD_WIDTH-1:0] RAM_data [2**MEM_ADDR_WIDTH-1:0];
  //reg[AD_WIDTH-1:0] RAM_addr [2**MEM_ADDR_WIDTH-1:0];
  reg[MEM_ADDR_WIDTH-1:0] buffer_addr_reg;
  reg[RAM_ADDR_WIDTH-1:0] ram_addr_reg;
  reg [DD_WIDTH-1:0] data_out_reg;
  reg [2:0] data_type_reg;
  reg [3:0] curr_state;
  reg [3:0] next_state;
  reg buffer_ready_reg; //1:ready; 0：busy
  reg to_ram_ready_reg;  // send a w_en signal
  
  assign ram_selecter=data_type_reg;
  assign ram_addr_out=ram_addr_reg;
  assign dataRam=data_out_reg;
  assign buffer_ready=buffer_ready_reg;
  assign to_ram_ready=to_ram_ready_reg;
  parameter s0=0,s1=1,s2=2,s3=3;
  
 always@(posedge clk_h)
 begin
   if (rst_n == 1'b0) begin
    curr_state<=s0;
   end
   else begin
    curr_state<=next_state;
	end
 end
	
  always @(posedge clk_h)
  begin
  case(curr_state) 
  s0:begin
   buffer_addr_reg<=0;
	ram_addr_reg<=0;
	data_type_reg<=3'b001;
	to_ram_ready_reg<=0;
	buffer_ready_reg<=1;
	if(buffer_enable==2'b10)
	begin
	  buffer_addr_reg <= buffer_addr_in;
	  data_type_reg <=data_type;
	  next_state=s1;
	end
	else
	  next_state=s0;
	end
	
  s1:begin
    if (buffer_selecter==0&& (buffer_addr_reg==BUFFER_SIZE-16))
      begin
        RAM_data[buffer_addr_reg] <= buffer_data_in[15:0];
		  RAM_data[buffer_addr_reg+6'b000001] <= buffer_data_in[31:16];
		  RAM_data[buffer_addr_reg+6'b000010] <= buffer_data_in[47:32];
		  RAM_data[buffer_addr_reg+6'b000011] <= buffer_data_in[63:48];
		  RAM_data[buffer_addr_reg+6'b000100] <= buffer_data_in[79:64];
		  RAM_data[buffer_addr_reg+6'b000101] <= buffer_data_in[95:80];
		  RAM_data[buffer_addr_reg+6'b000110] <= buffer_data_in[111:96];
		  RAM_data[buffer_addr_reg+6'b000111] <= buffer_data_in[127:112];
		  RAM_data[buffer_addr_reg+6'b001000] <= buffer_data_in[143:128];
		  RAM_data[buffer_addr_reg+6'b001001] <= buffer_data_in[159:144];
		  RAM_data[buffer_addr_reg+6'b001010] <= buffer_data_in[175:160];
		  RAM_data[buffer_addr_reg+6'b001011] <= buffer_data_in[191:176];
		  RAM_data[buffer_addr_reg+6'b001100] <= buffer_data_in[207:192];
		  RAM_data[buffer_addr_reg+6'b001101] <= buffer_data_in[223:208];
		  RAM_data[buffer_addr_reg+6'b001110] <= buffer_data_in[239:224];
		  RAM_data[buffer_addr_reg+6'b001111] <= buffer_data_in[255:240];
		  to_ram_ready_reg<=1;
		  buffer_ready_reg<=0;
		  next_state=s2;
		 end
	  else if(buffer_selecter==0&& (buffer_addr_reg!=BUFFER_SIZE-16))
	    begin
		  to_ram_ready_reg<=0;
		  buffer_ready_reg<=1;
		  next_state=s1;
		 end
	  else
	     next_state=s0;
	end
	
  s2:begin
    data_out_reg<=RAM_data[ram_addr_reg];
	 
	 if (ram_addr_reg!=4'b1111)
	    begin
		 ram_addr_reg=ram_addr_reg+4'b0001;
		 next_state=s2;
		 end
	 else
		  next_state=s0;
  end
	
  endcase
end
  
  
  endmodule
  