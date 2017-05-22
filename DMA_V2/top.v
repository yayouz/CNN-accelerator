module top(clk_h,rst_n,rw,dma_enable,
			latch_sdram_addr_src,latch_sdram_addr_dst,latch_mem1_addr,latch_mem2_addr,
			mem_data_in,sdram_data_in,sdram_ready,
			data_sdram_out,sdram_enable,sdram_addr_out,
			dataRam1,ram_addr_out1,ram_selecter1,to_ram_ready1,
			dataRam2,ram_addr_out2,ram_selecter2,to_ram_ready2);
  
  parameter DD_WIDTH = 16;
  parameter BUFFER_SIZE= 16;
  //parameter AD_WIDTH = 4;
  parameter RAM_ADDR_WIDTH = 4;
  parameter MEM_ADDR_WIDTH = 6;
  input clk_h;
  input rst_n;
  input rw; //0 sdram->memeory  memory->sdram
  input dma_enable;
  input [7:0]latch_sdram_addr_src;
  input [7:0]latch_sdram_addr_dst;
  input [5:0]latch_mem1_addr;
  input [5:0]latch_mem2_addr;
  input [255:0] mem_data_in;
  input [63:0] sdram_data_in;
  input sdram_ready;
  output [63:0] data_sdram_out;
  output [1:0] sdram_enable;
  output [7:0] sdram_addr_out;
  
  output [DD_WIDTH-1:0] dataRam1;//store data to ram
  output [RAM_ADDR_WIDTH-1:0] ram_addr_out1;
  output [2:0]ram_selecter1;   // 000:disable 001:input 010:point_even 011:point_odd 100：v_ram 101:z_ram 110: bias_ram
  output to_ram_ready1;
  output [DD_WIDTH-1:0] dataRam2;//store data to ram
  output [RAM_ADDR_WIDTH-1:0] ram_addr_out2;
  output [2:0]ram_selecter2;   // 000:disable 001:input 010:point_even 011:point_odd 100：v_ram 101:z_ram 110: bias_ram
  output to_ram_ready2;
  
  wire dma_selecter;
  wire [255:0]data_mem_out;
  wire [1:0] mem_enable;
  wire [5:0] mem1_addr_out;
  wire [5:0] mem2_addr_out;
  wire memory1_ready;
  wire memory2_ready;
  wire buffer_selecter;
  reg [1:0] count;
  reg data_type;
  assign buffer_selecter=dma_selecter?1'b0:1'b1;
  
  dma dma_inst(
  .clk_h(clk_h),
  .rst_n(rst_n),
  .rw(rw),
  .dma_enable(dma_enable),
  .latch_sdram_addr_src(latch_sdram_addr_src),
  .latch_sdram_addr_dst(latch_sdram_addr_dst),
  .latch_mem1_addr(latch_mem1_addr),
  .latch_mem2_addr(latch_mem2_addr),
  .memory1_ready(memory1_ready),
  .memory2_ready(memory2_ready),
  .mem_data_in(mem_data_in),
  .sdram_data_in(sdram_data_in),
  .sdram_ready(sdram_ready),
  .data_mem_out(data_mem_out),
  .data_sdram_out(data_sdram_out),
  //.data_type(data_type),
  .mem_selecter(dma_selecter),
  .sdram_enable(sdram_enable),
  .mem_enable(mem_enable),
  .mem1_addr_out(mem1_addr_out),
  .mem2_addr_out(mem2_addr_out),
  .sdram_addr_out(sdram_addr_out)
  );
  
  buffer buffer_inst1(
  .clk_h(clk_h),
  .rst_n(rst_n),
  .buffer_addr_in(mem1_addr_out),
  .buffer_data_in(data_mem_out),
  .buffer_enable(mem_enable),
  .data_type(data_type),
  .buffer_selecter(buffer_selecter),
  .dataRam(dataRam1),
  .ram_addr_out(ram_addr_out1),
  .ram_selecter(ram_selecter1),
  .buffer_ready(memory1_ready),
  .to_ram_ready(to_ram_ready1)
  );
  
  buffer buffer_inst2(
  .clk_h(clk_h),
  .rst_n(rst_n),
  .buffer_addr_in(mem2_addr_out),
  .buffer_data_in(data_mem_out),
  .buffer_enable(mem_enable),
  .data_type(data_type),
  .buffer_selecter(buffer_selecter),
  .dataRam(dataRam2),
  .ram_addr_out(ram_addr_out2),
  .ram_selecter(ram_selecter2),
  .buffer_ready(memory2_ready),
  .to_ram_ready(to_ram_ready2)
  );
  
  always @(posedge clk_h or negedge rst_n)                                                               
begin 
   if(rst_n==0)
   begin
	data_type<= 3'b001;
	count<=0;
	//
   end
   else if(mem_enable==2'b10)begin
		
		if (count==2'b11 && data_type!=3'b110) 
		begin
		data_type<=data_type+3'b001;
		count<=0;
		end
		else if (count==2'b11 && data_type==3'b110)
		begin
		data_type<=3'b001;
		count<=0;
		end
		count<=count+1;
	end
end
  endmodule
  
  