module control(
  input clk_h,
  input rst_n,
  input dma_enbale,
  input memory1_ready,
  input memory2_ready,
  
  //from data module
  input [255:0]data_to_memory,
  input [63:0] data_to_sdram,
  input write_ready,
  input read_ready,
  
  //from adresss module
  input [5:0] mem1_addr_out,
  input [5:0] mem2_addr_out,
  input [7:0] sdram_addr_out,
  
  // from top
  input [7:0] latch_sdram_dst,
  input rw, //0 sdram->memeory  memory->sdram
  //input [1:0] reg_pointer_beg;// 00 01 10 11
  //input [1:0] reg_pointer_curr;// 00 01 10 11
  output clear_data,
  output clear_addr,
  output sdram_read,
  output sdram_write,
  output mem1_read,
  output mem1_wirte,
  output mem2_read,
  output mem2_wirte,
  output init_sdram_addr,
  output init_mem1_addr,
  output init_mem2_addr,
  output add_sdram_addr,
  output add_mem1_addr,
  output add_mem2_addr,
  output [255:0] data_memory1,
  output [255:0] data_memory2,
  output mem_enable// ->data modle: empty_buffer
  );
  
  wire dma_enbale;
  wire memory1_ready;
  wire memory2_ready;
  
  //from data module
  wire [255:0]data_to_memory;
  wire [63:0] data_to_sdram;
  wire write_ready;
  wire read_ready;
  
  //from adresss module
  wire [5:0] mem1_addr_out;
  wire [5:0] mem2_addr_out;
  wire [7:0] sdram_addr_out;
  wire [7:0] latch_sdram_dst;
  wire rw;
  
  reg clear_data;
  reg clear_addr;
  reg sdram_read;
  reg sdram_write;
  reg mem1_read;
  reg mem1_wirte;
  reg mem2_read;
  reg mem2_wirte;
  reg init_sdram_addr;
  reg init_mem1_addr;
  reg init_mem2_addr;
  reg add_sdram_addr;
  reg add_mem1_addr;
  reg add_mem2_addr;
  reg [255:0] data_memory1;
  reg [255:0] data_memory2;
  wire mem_enable; //to data module 
  
  reg finish;
  reg [3:0] curr_state;
  reg [3:0] next_state;
  
  parameter s0=0,s1=1,s2=2,s3=3,s4=4,s5=5,s6=6,s7=7,s8=8;
  assign mem_enable=mem1_read||mem2_read;
  
   always@(posedge clk_h)
 begin
  if (rst_n == 1'b0) begin
    curr_state<=s0;
  end
  else
     curr_state<=next_state;
end

always@(posedge clk_h)
 begin
 case(curr_state)
  s0:
  begin
 clear_addr<=1;
 clear_data<=1;
 sdram_read<=0;
 sdram_write<=0;
 mem1_read<=0;
 mem1_wirte<=0;
 mem2_read<=0;
 mem2_wirte<=0;
 init_sdram_addr<=0;
 init_mem1_addr<=0;
 init_mem2_addr<=0;
 add_sdram_addr<=0;
 add_mem1_addr<=0;
 add_mem2_addr<=0;
 finish<=1;
 next_state<=s1;
  end
  
 s1:
  begin
  clear_addr<=0;
 clear_data<=0;
 sdram_read<=0;
 sdram_write<=0;
 mem1_read<=0;
 mem1_wirte<=0;
 mem2_read<=0;
 mem2_wirte<=0;
 init_sdram_addr<=0;
 init_mem1_addr<=0;
 init_mem2_addr<=0;
 add_sdram_addr<=0;
 add_mem1_addr<=0;
 add_mem2_addr<=0;
 finish<=1;
 if(dma_enbale==1)
 next_state<=s2;
 else
 next_state<=s1;
  end
  
  s2:
  begin
  clear_addr<=0;
 clear_data<=0;
 sdram_read<=0;
 sdram_write<=0;
 mem1_read<=0;
 mem1_wirte<=0;
 mem2_read<=0;
 mem2_wirte<=0;
 init_sdram_addr<=0;
 init_mem1_addr<=0;
 init_mem2_addr<=0;
 add_sdram_addr<=0;
 add_mem1_addr<=0;
 add_mem2_addr<=0;
 finish<=0;
 if(rw==0)
 next_state<=s3;
 //else
 //next_state<= jump to the state transfer from memory to sdram
 end
 
 // read data from sdram
   s3:
   begin
 clear_addr<=0;
 clear_data<=0;
 sdram_read<=1;
 sdram_write<=0;
 mem1_read<=0;
 mem1_wirte<=0;
 mem2_read<=0;
 mem2_wirte<=0;
 init_sdram_addr<=1;
 init_mem1_addr<=1;
 init_mem2_addr<=1;
 add_sdram_addr<=0;
 add_mem1_addr<=0;
 add_mem2_addr<=0;
 finish<=0;
 next_state<=s4;
   end
   
   s4:
   begin
 clear_addr<=0;
 clear_data<=0;
 sdram_read<=1;
 sdram_write<=0;
 mem1_read<=0;
 mem1_wirte<=0;
 mem2_read<=0;
 mem2_wirte<=0;
 init_sdram_addr<=0;
 init_mem1_addr<=0;
 init_mem2_addr<=0;
 add_sdram_addr<=1;
 add_mem1_addr<=0;
 add_mem2_addr<=0;
 finish<=0;
 if(read_ready==1&& write_ready==0)
   next_state<=s4;
 else if (read_ready==1 &&write_ready==1)
 next_state<=s5;
 else if(read_ready==0 &&write_ready==1)
 next_state<=s7;
 
   end
   
   s5:
   begin
 clear_addr<=0;
 clear_data<=0;
 sdram_read<=1;
 sdram_write<=0;
 
 if(memory1_ready==1)begin
 mem1_wirte<=1;
 mem2_wirte<=0;
 end
 else if(memory2_ready==1)begin
  mem1_wirte<=0;
  mem2_wirte<=1;
  end
  else begin
  mem1_wirte<=0;
  mem2_wirte<=0;
  end
  mem1_read<=0;
  mem2_read<=0;

 init_sdram_addr<=0;
 init_mem1_addr<=0;
 init_mem2_addr<=0;
 add_sdram_addr<=1;
 add_mem1_addr<=0;
 add_mem2_addr<=0;
 finish<=0; 
 next_state<=s6;
 
 end
 
 s6:
 begin
 if (mem1_wirte==1)
 begin
   data_memory1<=data_to_memory;
   data_memory2<=256'b0;
   add_mem1_addr<=1;
 end
   else if(mem2_wirte==1)
   begin
   data_memory1<=256'b0;
   data_memory2<=data_to_memory;
   add_mem2_addr<=1;
   end
   else
   begin
    data_memory1<=256'b0;
	data_memory2<=256'b0;
	add_mem1_addr<=0;
	add_mem2_addr<=0;
   end
   if(sdram_addr_out==latch_sdram_dst && write_ready==1)
   next_state<=s7;
   else if(sdram_addr_out==latch_sdram_dst && write_ready==0)
   next_state<=s8;
   else if(read_ready==1&& write_ready==0)
   next_state<=s4;
   else if (read_ready==1 &&write_ready==1)
   next_state<=s5;
   else if(read_ready==0 &&write_ready==1)
   next_state<=s7;
 end
    
	s7:
	begin
	clear_addr<=0;
	clear_data<=0;
	sdram_read<=0;
	sdram_write<=0;
	if(memory1_ready==1)begin
    mem1_wirte<=1;
    mem2_wirte<=0;
    end
	else if(memory2_ready==1)begin
	mem1_wirte<=0;
	mem2_wirte<=1;
	end
	else begin
	mem1_wirte<=0;
	mem2_wirte<=0;
	end
	mem1_read<=0;
	mem2_read<=0;
	init_sdram_addr<=0;
	init_mem1_addr<=0;
	init_mem2_addr<=0;
	add_sdram_addr<=0;
	add_mem1_addr<=0;
	add_mem2_addr<=0;
	finish<=0;
	next_state<=s6;
	end
	
	s8:
	begin
	clear_addr<=0;
	clear_data<=0;
	sdram_read<=0;
	sdram_write<=0;
	mem1_read<=0;
	mem1_wirte<=0;
	mem2_read<=0;
	mem2_wirte<=0;
	init_sdram_addr<=0;
	init_mem1_addr<=0;
	init_mem2_addr<=0;
	add_sdram_addr<=0;
	add_mem1_addr<=0;
	add_mem2_addr<=0;
	finish<=1;
	next_state<=s0;
	end
   
 endcase
 end
 
 
  endmodule