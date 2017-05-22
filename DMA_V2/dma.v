module dma(
  input clk_h,
  input rst_n,
  input rw, //0 sdram->memeory  memory->sdram
  input dma_enable,
  input [7:0]latch_sdram_addr_src,
  input [7:0]latch_sdram_addr_dst,
  input [5:0]latch_mem1_addr,
  input [5:0]latch_mem2_addr,
  //from memory
  input memory1_ready, //1:ready; 0：busy
  input memory2_ready, //1:ready; 0：busy
  input [255:0] mem_data_in,
  
  //from sdram
  input [63:0] sdram_data_in,
  input sdram_ready,
  
  output [255:0]data_mem_out,
  output [63:0] data_sdram_out,
  //output [2:0] data_type, //000:disable 001:input 010:point_even 011:point_odd 100：v_ram 101:z_ram 110: bias_ram
  output mem_selecter,   // 0:memory 1; 1:memory 2;
  output [1:0] sdram_enable,  //00:disable 01:read enable 10；write enable
  output [1:0] mem_enable,    //00:disable 01:read enable 10；write enable
  output [5:0] mem1_addr_out, //5
  output [5:0] mem2_addr_out,
  output [7:0] sdram_addr_out
  
  );
  
  //wire rw;
  //wire dma_enable;
  wire empty_buffer;
  //wire latch_sdram_addr_src[7:0];
  //wire latch_sdram_addr_dst[7:0];
  //wire latch_mem1_addr[5:0];
 // wire latch_mem2_addr[5:0];
  //from memory
 // wire memory1_ready; //1:ready; 0：busy
 // wire memory2_ready; //1:ready; 0：busy
  //wire [255:0] mem_data_in;
  
  //from sdram
 // wire [63:0] sdram_data_in;
 // wire sdram_ready;
  wire [1:0]pointer_delta;
  
  reg [255:0]data_mem_out_reg;
  reg [63:0] data_sdram_out_reg;
  reg  mem_selecter_reg;
  reg [1:0] sdram_enable_reg;
  reg [1:0] mem_enable_reg;
  reg [5:0] mem_addr_out[0:1];//5
  //reg [4:0] mem2_addr_out;
  reg [7:0] sdram_addr_out_reg;
  reg [63:0] buffer [0:3];
  reg [1:0] reg_pointer_beg;// 00 01 10 11
  reg [1:0] reg_pointer_curr;// 00 01 10 11
  reg finish; //0:strart 1:finish
  reg [3:0] curr_state;
  reg [3:0] next_state;
  reg [3:0] curr_state2;
  reg [3:0] next_state2;
  
  
  parameter s0=0,s1=1,s2=2,s3=3;//s4=4,s5=5,s6=6,s7=7,s8=8;
  assign pointer_delta=reg_pointer_curr-reg_pointer_beg;
  assign empty_buffer=memory1_ready||memory2_ready;
  assign mem1_addr_out=mem_addr_out[0];
  assign mem2_addr_out=mem_addr_out[1];
  assign data_mem_out=data_mem_out_reg;
  assign data_sdram_out=data_sdram_out_reg;
  assign mem_selecter=mem_selecter_reg;
  assign sdram_enable=sdram_enable_reg;
  assign mem_enable=mem_enable_reg;
  assign sdram_addr_out=sdram_addr_out_reg;
  
  
   always@(posedge clk_h)
 begin
  if (rst_n == 1'b0) begin
    curr_state<=s0;
	 curr_state2<=s0;
  end
  else begin
    curr_state<=next_state;
	 curr_state2<=next_state2;
	end
end

always@(posedge clk_h)
begin
  case(curr_state) 

	s0:begin //clear all
	data_sdram_out_reg<=64'b0;
	sdram_addr_out_reg<=8'b0;
	buffer[0]<=64'b0;
	buffer[1]<=64'b0;
	buffer[2]<=64'b0;
	buffer[3]<=64'b0;
	reg_pointer_curr<=2'b0;
	reg_pointer_beg<=2'b0;
	finish<=1;
	if(dma_enable==1)
	next_state=s1;
	else
	next_state=s0;
	end
	
	s1:begin //rw judement
	sdram_addr_out_reg<=latch_sdram_addr_src;
	//mem1_addr_out<=latch_mem1_addr;
	//mem2_addr_out<latch_mem2_addr;
	finish<=0;
		if (rw==0 && sdram_ready==1)
		begin
		//sdram_enable_reg<=2'b01;
		next_state=s2;//sdram->mem
		end
	/*else
	next_state<=s7;//mem->sdram*/
	end
	
	s2:begin //read data from sdram
		
		if(finish==0)begin
			if (sdram_enable_reg==2'b01)
			begin
			buffer[reg_pointer_curr]=sdram_data_in;
			reg_pointer_curr<=reg_pointer_curr+2'b01;
			sdram_addr_out_reg<=sdram_addr_out_reg+8'b1;//看一下sdram的地址是怎么变化的
			end
		next_state=s2;
		end
		else
		next_state=s0;
	
	if((sdram_addr_out_reg-8'b1)==latch_sdram_addr_dst && mem_enable_reg==2'b00)
	finish<=1;
	else
	finish<=0;
	end
	
  endcase
end
 
always@(posedge clk_h)
begin
 case(curr_state2) 
	s0:begin
	data_mem_out_reg<=256'b0;
   sdram_enable_reg<=2'b0;
	mem_enable_reg<=2'b0;
	mem_addr_out[0]<=6'b0;
	mem_addr_out[1]<=6'b0;
	//mem_enable_reg<=1;
		if(dma_enable==1)
		next_state2=s1;
		else
		next_state2=s0;
		
	end
	
	s1:begin
		if (rw==0) begin
		 mem_addr_out[0]<=latch_mem1_addr;
		 mem_addr_out[1]<=latch_mem2_addr;
		 sdram_enable_reg<=2'b01;
		 next_state2=s2;
		end
		else begin//if(rw==0 && mem_enable_reg==2'b00) begin
		 next_state2=s1;
		 sdram_enable_reg<=2'b10;
		end
	end
	
	s2:begin
	
	 if(pointer_delta==2'b11)
	 begin
	 mem_enable_reg<=2'b10;
		if(empty_buffer==1) begin
		data_mem_out_reg[63:0]<=buffer[reg_pointer_beg];
		data_mem_out_reg[127:64]<=buffer[reg_pointer_beg+2'b01];
		data_mem_out_reg[191:128]<=buffer[reg_pointer_beg+2'b10];
		data_mem_out_reg[255:192]<=buffer[reg_pointer_beg+2'b11];
		//reg_pointer_beg<=reg_pointer_beg+2'b01;
		sdram_enable_reg<=2'b01; //read from sdram enable
		mem_addr_out[mem_selecter_reg]<=mem_addr_out[mem_selecter_reg]+6'b010000;
		end
		else begin
		sdram_enable_reg<=2'b00;  //sdram block
		end
		//mem_enable_reg<=2'b10;
		//next_state2=s3;
	 end
	 else begin
	 mem_enable_reg<=2'b00;
	 sdram_enable_reg<=2'b01;
	 //next_state2=s2;
	 end
	 
	 if (finish ==0)
	 next_state2=s2;
	 else 
	 next_state2=s0;
	end
	/*
	s3:begin	
		if(empty_buffer==1) begin
		data_mem_out_reg[63:0]<=buffer[reg_pointer_beg];
		data_mem_out_reg[127:64]<=buffer[reg_pointer_beg+2'b01];
		data_mem_out_reg[191:128]<=buffer[reg_pointer_beg+2'b10];
		data_mem_out_reg[255:192]<=buffer[reg_pointer_beg+2'b11];
		//reg_pointer_beg<=reg_pointer_beg+2'b01;
		sdram_enable_reg<=2'b01; //read from sdram enable
		mem_addr_out[mem_selecter_reg]<=mem_addr_out[mem_selecter_reg]+1;
		end
		else begin
		sdram_enable_reg<=2'b00;  //sdram block
		end
	 
	 if (finish ==0)
	 next_state2=s2;
	 else 
	 next_state2=s0;
	 
	end*/
	
 endcase
 /*if (memory1_ready==0)
 mem_addr_out[0]<=latch_mem1_addr;
 
 if(memory2_ready==0)
 mem_addr_out[1]<=latch_mem2_addr;
 */
end

always@(posedge clk_h)
begin
	if(memory1_ready==1)
	mem_selecter_reg<=0;
	else if(memory2_ready==1)
	mem_selecter_reg<=1;
	else
	mem_selecter_reg<=0;
	
	

end
  endmodule
  