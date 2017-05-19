module dma_tb;

  reg clk_h;
  reg rst_n;
  reg rw;
  reg dma_enable;
  reg [7:0]latch_sdram_addr_src;
  reg [7:0]latch_sdram_addr_dst;
  reg [5:0]latch_mem1_addr;
  reg [5:0]latch_mem2_addr;
  reg memory1_ready; //1:ready; 0：busy
  reg memory2_ready; //1:ready; 0：busy
  reg [255:0] mem_data_in;
  reg [63:0] sdram_data_in;
  reg sdram_ready;
  reg [63:0]temp_sdram_data;
  
  wire [255:0]data_mem_out;
  wire [63:0] data_sdram_out;
  wire mem_selecter;
  wire [1:0] sdram_enable;  //00:disable 01:read enable 10；write enable
  wire [1:0] mem_enable;    //00:disable 01:read enable 10；write enable
  wire [4:0] mem1_addr_out;
  wire [4:0] mem2_addr_out;
  wire [7:0] sdram_addr_out;
  
  //wire data_output;
  //wire select_mem1;
  //wire select_mem2;
  
  reg [63:0]data_sdram[0:63];
  reg [1:0] count;
  
  //assign select_mem1=mem_selecter^~0;
  //assign select_mem2=mem_selecter^~1;
  
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
  .mem_selecter(mem_selecter),
  .sdram_enable(sdram_enable),
  .mem_enable(mem_enable),
  .mem1_addr_out(mem1_addr_out),
  .mem2_addr_out(mem2_addr_out),
  .sdram_addr_out(sdram_addr_out)
  );
  /*
  ram ram_inst1(
  .address(mem1_addr_out),
  .clock(clk_h),
  .data(data_mem_out),
  .rden(select_mem1),
  .wren(mem_enable),
  .q(data_output)
  );
  
  ram ram_inst2(
  .address(mem2_addr_out),
  .clock(clk_h),
  .data(data_mem_out),
  .rden(select_mem2),
  .wren(mem_enable),
  .q(data_output)
  );*/
  
  initial 
   begin	
	  clk_h = 1;
	  rst_n = 0;
		#20 rst_n = 1;
	end
	
always #20 clk_h = ~clk_h;

initial begin
   
	$readmemb("D:/project/DMA/data.txt",data_sdram);
end

always @(posedge clk_h or negedge rst_n)                                                               
begin 
if(rst_n==0)
   begin
    rw<=0;
	 dma_enable<=1;
	latch_mem1_addr<=6'b0;
	latch_mem2_addr<=6'b0;
	latch_sdram_addr_src<=8'b0;
	latch_sdram_addr_dst<=8'b01000000;
	sdram_ready<=1;
	memory1_ready<=1;
	memory2_ready<=1;
	count=2'b0;
	//
   end
 else begin
	if (sdram_enable==2'b01 && sdram_ready==1) begin
	 if (data_sdram[sdram_addr_out]==temp_sdram_data)
	 sdram_data_in=data_sdram[sdram_addr_out+1];
	 else
	 sdram_data_in=data_sdram[sdram_addr_out];
	end
	temp_sdram_data=sdram_data_in;
   //data_show0<=data_sdram[0];
	if(mem_enable==2'b10)begin
		
		if (count==2'b11) begin
			case (mem_selecter)
			0:begin
			memory1_ready<=0;
			memory2_ready<=1;
			end
			1:begin
			memory1_ready<=1;
			memory2_ready<=0;
			end
			endcase
		count<=0;
		end
		count<=count+1;
	end
 end
 
 end
  endmodule
  