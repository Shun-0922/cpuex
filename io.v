`default_nettype none



module io #(CLK_PER_HALF_BIT = 100) 
  (
    input wire rxd,
    output wire txd,
    input wire clk,
    input wire rstn,
    input wire data_ready_io,
    input wire [31:0] data_from_memory_io,  
    input wire core_end,                    
    output wire wr_en_instr,                
    output wire [31:0] data_in_instr,       
    output wire [31:0] addr_in_instr,       
    output wire [31:0] addr_io,             
    output wire [31:0] write_data_io,       
    output wire memread_io,                 
    output wire memwrite_io,                
    output wire core_start,                 
    output wire [31:0] output_io
  );

  //UART
  reg [7:0] sdata;
  wire [7:0] rdata;
  reg tx_start;
  wire rx_ready;
  wire tx_busy;
  wire ferr;

  //registers for output
  reg memread_io_reg;
  reg wr_en_instr_reg;
  reg core_start_reg;
  assign wr_en_instr = wr_en_instr_reg;
  assign core_start = core_start_reg;
  assign memread_io = memread_io_reg;


  reg [15:0] status;         //status of finite state machine
  reg [31:0] counter;

  
  wire [31:0] program_words; //= program_bytes/4
  reg [31:0] program_bytes;  //first four words of input
  reg [31:0] input_program;  //buffer for input program

  
  reg [31:0] output_io_reg;
  assign output_io = output_io_reg;

  reg [31:0] count_program_words;
  reg [31:0] addr_in_instr_reg;
  reg [31:0] addr_io_reg;
  reg [31:0] write_data_io_reg;
  reg memwrite_io_reg;
  reg count_1;
 

  assign program_words = {2'b00,program_bytes[31:2]};                      
  assign addr_in_instr = {addr_in_instr_reg[29:0],2'b00};                    
  assign data_in_instr = input_program;                                    
  assign addr_io = {addr_io_reg[29:0],2'b00};                   
  assign memwrite_io = memwrite_io_reg;
  assign write_data_io = write_data_io_reg;
  

  uart_tx #(CLK_PER_HALF_BIT) u1(sdata, tx_start, tx_busy, txd, clk, rstn);
  uart_rx #(CLK_PER_HALF_BIT) u2(rdata, rx_ready, ferr, rxd, clk, rstn);

  

  


  always @(posedge clk) begin
    if (~rstn) begin
      sdata <= 8'h00;
      tx_start <= 1'b0;
      status <= 16'd0;
      counter <= 32'b0;
      program_bytes <= 32'b0;
      input_program <= 32'b0;
      wr_en_instr_reg <= 1'b0;
      core_start_reg <= 1'b0;
      output_io_reg <= 32'b0;
      memread_io_reg <= 1'b0;
      addr_in_instr_reg <= 32'b0;
      addr_io_reg <= 32'b0;
      write_data_io_reg <= 32'b0;
      memwrite_io_reg <= 1'b0;
      count_program_words <= 32'b0;
      count_1 <= 1'b0;
    end else begin
      if (status == 16'd0) begin  //send "99"                    
        output_io_reg <= 32'hffff8000;                                                             
        sdata <= 8'h99; status <= status + 16'd1;
      end else if (status[3:0] == 4'd1) begin  //start sending data
        output_io_reg <= 32'hffff4000;
        tx_start <= 1'b1;
        status <= status + 16'd1;
      end else if (status[3:0] == 4'd2) begin  //check tx_busy
        if (tx_busy) begin
          output_io_reg <= 32'hffff2000;
          status <= status + 16'd1;
          tx_start <= 1'b0;
        end
      end else if (status[3:0] == 4'd3) begin  //check that sending has completed
        if (~tx_busy) begin
          output_io_reg <= 32'hffff1000;
          status <= status + 16'd13;
        end
      end else if (status[3:0] == 4'd4) begin  //check that recieving has completed
        if (~rx_ready) begin
          status <= status + 16'd12;
        end

      //recieve program
      end else if (status == 16'd16)  begin if (rx_ready) begin program_bytes[7:0]    <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd32)  begin if (rx_ready) begin program_bytes[15:8]   <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd48)  begin if (rx_ready) begin program_bytes[23:16]  <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd64)  begin if (rx_ready) begin program_bytes[31:24]  <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd80)  begin if (rx_ready) begin input_program[7:0]    <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd96)  begin if (rx_ready) begin input_program[15:8]   <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd112) begin if (rx_ready) begin input_program[23:16]  <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd128) begin if (rx_ready) begin input_program[31:24]  <= rdata; status <= status + 16'd4; count_program_words <= count_program_words + 32'd1; end 
      end else if (status == 16'd144) begin 
        if (input_program == 32'hffffffff) begin
          status <= status + 16'd48;
        end else begin
          status <= status + 16'd16;
        end
      end else if (status == 16'd160) begin wr_en_instr_reg <= 1'b1; status <= status + 16'd16;
      end else if (status == 16'd176) begin wr_en_instr_reg <= 1'b0; status <= status - 16'd96; addr_in_instr_reg <= addr_in_instr_reg + 32'd1;
      end else if (status == 16'd192) begin if (rx_ready) begin write_data_io_reg[7:0]   <= rdata; status <= status + 16'd4; end
      end else if (status == 16'd208) begin if (rx_ready) begin write_data_io_reg[15:8]  <= rdata; status <= status + 16'd4; end
      end else if (status == 16'd224) begin if (rx_ready) begin write_data_io_reg[23:16] <= rdata; status <= status + 16'd4; end
      end else if (status == 16'd240) begin if (rx_ready) begin write_data_io_reg[31:24] <= rdata; status <= status + 16'd4;count_program_words <= count_program_words + 32'd1; end
      end else if (status == 16'd256) begin memwrite_io_reg <= 1'b1; status <= status + 16'd16;
      end else if (status == 16'd272) begin memwrite_io_reg <= 1'b0; status <= status + 16'd16; addr_io_reg <= addr_io_reg + 32'd1;
      end else if (status == 16'd288) begin
        if (count_program_words == program_words) begin
          status <= status + 16'd1712;
        end else begin
          status <= status - 16'd96;
        end
      end else if (status == 16'd2000) begin sdata <= 8'haa; status <= status + 16'd1;  addr_io_reg <= 32'd2048;                         //  where to put sld data (words)
      end else if (status == 16'd2016) begin if (rx_ready) begin write_data_io_reg[7:0]   <= rdata; status <= status + 16'd4; end
      end else if (status == 16'd2032) begin if (rx_ready) begin write_data_io_reg[15:8]  <= rdata; status <= status + 16'd4; end
      end else if (status == 16'd2048) begin if (rx_ready) begin write_data_io_reg[23:16] <= rdata; status <= status + 16'd4; end
      end else if (status == 16'd2064) begin if (rx_ready) begin write_data_io_reg[31:24] <= rdata; status <= status + 16'd4; end
      end else if (status == 16'd2080) begin memwrite_io_reg <= 1'b1; status <= status + 16'd16;
      end else if (status == 16'd2096) begin memwrite_io_reg <= 1'b0; status <= status + 16'd16; addr_io_reg <= addr_io_reg + 32'd1;
      end else if (status == 16'd2112) begin 
        if (write_data_io_reg == 32'hffffffff) begin
          status <= status + 16'd16;
        end else begin
          status <= status - 16'd96;
        end
      end else if (status == 16'd2128) begin if (rx_ready) begin write_data_io_reg[7:0]   <= rdata; status <= status + 16'd4; end
      end else if (status == 16'd2144) begin if (rx_ready) begin write_data_io_reg[15:8]  <= rdata; status <= status + 16'd4; end
      end else if (status == 16'd2160) begin if (rx_ready) begin write_data_io_reg[23:16] <= rdata; status <= status + 16'd4; end
      end else if (status == 16'd2176) begin if (rx_ready) begin write_data_io_reg[31:24] <= rdata; status <= status + 16'd4; end
      end else if (status == 16'd2192) begin memwrite_io_reg <= 1'b1; status <= status + 16'd16;
      end else if (status == 16'd2208) begin memwrite_io_reg <= 1'b0; status <= status + 16'd16; addr_io_reg <= addr_io_reg + 32'd1;
      end else if (status == 16'd2224) begin
        if (write_data_io_reg == 32'hffffffff && count_1 == 1'b0) begin
          count_1 <= 1'b1;
          status <= status - 16'd208;
        end else if (write_data_io_reg == 32'hffffffff && count_1 == 1'b1) begin
          status <= status + 16'd16;
        end else begin
          status <= status - 16'd208;
        end 
      end else if (status == 16'd2240) begin core_start_reg <= 1'b1; status <= status + 16'd1760;
      end else if (status == 16'd4000) begin
        if (core_end) begin
          status <= status + 16'd16;
        end 
        addr_io_reg <= 32'd4096;              //where the output is (words)
      end else if (status == 16'd4016) begin memread_io_reg <= 1'b1; status <= status + 16'd16;
      end else if (status == 16'd4032) begin
        if (data_ready_io) begin
          memread_io_reg <= 1'b0;
          addr_io_reg <= addr_io_reg + 32'd1;
          sdata <= data_from_memory_io[7:0];
          status <= status + 16'd1;
        end 
      end else if (status == 16'd4048) begin 
        if (addr_io_reg < 32'd65536) begin
          status <= status - 16'd32;
        end else begin
          status <= status + 16'd16;
        end
      end
    end
  end
endmodule





//module to simulate io
module io_computer_side #(CLK_PER_HALF_BIT = 200) 
  (
    input wire rxd,
    output wire txd,
    input wire clk,
    input wire rstn
  );

  reg [7:0] sdata;
  wire [7:0] rdata;
  reg tx_start;
  wire rx_ready;
  wire tx_busy;
  wire ferr;

  wire [31:0] program_bytes;
  assign program_bytes = 32'd8;

  reg [31:0] ram [0:1/**/];
  reg [31:0] sld [0:511];


  reg [15:0] status;
  

  reg [31:0] counter;

  uart_tx #(CLK_PER_HALF_BIT) u1(sdata, tx_start, tx_busy, txd, clk, rstn);
  uart_rx #(CLK_PER_HALF_BIT) u2(rdata, rx_ready, ferr, rxd, clk, rstn);

  reg [7:0] first_number;
  reg [31:0] program_buffer;

  initial begin
    $readmemb("increment.mem", ram);
    $readmemb("sld_res.mem",sld);
  end

  always @(posedge clk) begin
    if (~rstn) begin
      sdata <= 8'h00;
      tx_start <= 1'b0;
      status <= 16'd0;
      counter <= 32'b0;
      first_number <= 8'b0;
      program_buffer <= 32'b0;
    end else begin
      if (status == 16'd0) begin if (rx_ready) begin first_number                 <= rdata; status <= status + 16'd4; end 
      end else if (status[3:0] == 4'd1) begin
        tx_start <= 1'b1;
        status <= status + 16'd1;
      end else if (status[3:0] == 4'd2) begin
        if (tx_busy) begin
          status <= status + 16'd1;
          tx_start <= 1'b0;
        end
      end else if (status[3:0] == 4'd3) begin
        if (~tx_busy) begin
          status <= status + 16'd13;
        end
      end else if (status[3:0] == 4'd4) begin
        if (~rx_ready) begin
          status <= status + 16'd12;
        end
      end else if (status == 16'd16) begin
        if (first_number == 8'h99) begin
          status <= 16'd32;
        end else begin
          status <= 16'd2000;
        end
      end else if (status == 16'd32) begin sdata <= program_bytes[7:0];             status <= status + 16'd1;
      end else if (status == 16'd48) begin sdata <= program_bytes[15:8];            status <= status + 16'd1;
      end else if (status == 16'd64) begin sdata <= program_bytes[23:16];           status <= status + 16'd1;
      end else if (status == 16'd80) begin sdata <= program_bytes[31:24];           status <= status + 16'd1;
      end else if (status == 16'd96) begin status <= 16'd112;
      end else if (status == 16'd112) begin
        program_buffer <= ram[counter[0]];
        status <= 16'd128;
      end else if (status == 16'd128) begin sdata <= program_buffer[7:0];           status <= status + 16'd1;
      end else if (status == 16'd144) begin sdata <= program_buffer[15:8];          status <= status + 16'd1;
      end else if (status == 16'd160) begin sdata <= program_buffer[23:16];         status <= status + 16'd1;
      end else if (status == 16'd176) begin sdata <= program_buffer[31:24];         status <= status + 16'd1;
      end else if (status == 16'd192) begin
        if (counter[0] != 1'b1) begin
          counter <= counter + 32'b1;
          status <= status - 16'd80;
        end else begin
          counter <= 32'b0;
          status <= 16'd1984;
        end
      end else if (status == 16'd1984) begin if (rx_ready) begin first_number                 <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd2000) begin 
        program_buffer <= sld[counter[8:0]];
        status <= status + 16'd16;
      end else if (status == 16'd2016) begin sdata <= program_buffer[7:0];           status <= status + 16'd1;
      end else if (status == 16'd2032) begin sdata <= program_buffer[15:8];          status <= status + 16'd1;
      end else if (status == 16'd2048) begin sdata <= program_buffer[23:16];         status <= status + 16'd1;
      end else if (status == 16'd2064) begin sdata <= program_buffer[31:24];         status <= status + 16'd1;
      end else if (status == 16'd2080) begin
        counter <= counter + 32'b1;
        status <= status - 16'd80;
      end
    end
  end
endmodule

`default_nettype wire