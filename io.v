`default_nettype none



module io_test_2 #(CLK_PER_HALF_BIT = 217) 
  (
    input wire rxd,
    output wire txd,
    output wire [15:0] debug,
    input wire clk,
    input wire rstn_uart
  );

  reg [7:0] sdata;
  wire [7:0] rdata;
  reg tx_start;
  wire rx_ready;
  wire tx_busy;
  wire ferr;


  reg [15:0] status;
  

  wire [7:0] large_p;       assign large_p = 8'h50;
  wire [7:0] number_0;      assign number_0 = 8'h30;
  wire [7:0] space;         assign space = 8'h20;
  wire [7:0] newline;       assign newline = 8'h0a;
  
  wire [31:0] program_words;

  reg [31:0] counter;
  reg [31:0] program_bytes;
  reg [31:0] input_program;

  assign debug = program_words[15:0];
  assign program_words = {2'b00,program_bytes[31:2]};

  uart_tx #(CLK_PER_HALF_BIT) u1(sdata, tx_start, tx_busy, txd, clk, rstn_uart);
  uart_rx #(CLK_PER_HALF_BIT) u2(rdata, rx_ready, ferr, rxd, clk, rstn_uart);


  always @(posedge clk) begin
    if (~rstn_uart) begin
      sdata <= 8'h00;
      tx_start <= 1'b0;
      status <= 16'd0;
      counter <= 32'b0;
      program_bytes <= 32'b0;
      input_program <= 32'b0;
    end else begin
      if (status == 16'd0) begin
        sdata <= 8'h99; status <= status + 16'd1;
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
      end else if (status == 16'd16)  begin if (rx_ready) begin program_bytes[7:0]                 <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd32)  begin if (rx_ready) begin program_bytes[15:8]                <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd48)  begin if (rx_ready) begin program_bytes[23:16]               <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd64)  begin if (rx_ready) begin program_bytes[31:24]               <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd80)  begin if (rx_ready) begin input_program[7:0]                 <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd96)  begin if (rx_ready) begin input_program[15:8]                <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd112) begin if (rx_ready) begin input_program[23:16]               <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd128) begin if (rx_ready) begin input_program[31:24]               <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd144) begin 
        if (counter != program_words - 32'd1) begin
          counter <= counter + 32'd1;
          status <= status - 32'd64;
        end else begin
          counter <= 0;
          status <= 16'd4000;
        end
      end else if (status == 16'd4000) begin sdata <= 8'haa;           status <= status + 16'd1;
      end else if (status == 16'd4016) begin sdata <= large_p;         status <= status + 16'd1;
      end else if (status == 16'd4032) begin sdata <= number_0 + 8'd3; status <= status + 16'd1;
      end else if (status == 16'd4048) begin sdata <= newline;         status <= status + 16'd1;
      end else if (status == 16'd4064) begin sdata <= number_0 + 8'd1; status <= status + 16'd1;
      end else if (status == 16'd4080) begin sdata <= number_0 + 8'd2; status <= status + 16'd1;
      end else if (status == 16'd4096) begin sdata <= number_0 + 8'd8; status <= status + 16'd1;
      end else if (status == 16'd4112) begin sdata <= space;           status <= status + 16'd1;
      end else if (status == 16'd4128) begin sdata <= number_0 + 8'd1; status <= status + 16'd1;
      end else if (status == 16'd4144) begin sdata <= number_0 + 8'd2; status <= status + 16'd1;
      end else if (status == 16'd4160) begin sdata <= number_0 + 8'd8; status <= status + 16'd1;
      end else if (status == 16'd4176) begin sdata <= space;           status <= status + 16'd1;
      end else if (status == 16'd4192) begin sdata <= number_0 + 8'd2; status <= status + 16'd1;
      end else if (status == 16'd4208) begin sdata <= number_0 + 8'd5; status <= status + 16'd1;
      end else if (status == 16'd4224) begin sdata <= number_0 + 8'd5; status <= status + 16'd1;
      end else if (status == 16'd4240) begin sdata <= newline;         status <= status + 16'd1;
      end else if (status == 16'd4256) begin sdata <= number_0 + 8'd0; status <= status + 16'd1;
      end else if (status == 16'd4272) begin sdata <= number_0 + 8'd2; status <= status + 16'd1;
      end else if (status == 16'd4288) begin sdata <= number_0 + 8'd8; status <= status + 16'd1;
      end else if (status == 16'd4304) begin sdata <= space;           status <= status + 16'd1;
      end else if (status == 16'd4320) begin sdata <= number_0 + 8'd0; status <= status + 16'd1;
      end else if (status == 16'd4336) begin sdata <= number_0 + 8'd2; status <= status + 16'd1;
      end else if (status == 16'd4352) begin sdata <= number_0 + 8'd8; status <= status + 16'd1;
      end else if (status == 16'd4368) begin sdata <= space;           status <= status + 16'd1;
      end else if (status == 16'd4384) begin sdata <= number_0 + 8'd2; status <= status + 16'd1;
      end else if (status == 16'd4400) begin sdata <= number_0 + 8'd5; status <= status + 16'd1;
      end else if (status == 16'd4416) begin sdata <= number_0 + 8'd5; status <= status + 16'd1;
      end else if (status == 16'd4432) begin sdata <= newline;         status <= status + 16'd1;
      end else if (status == 16'd4448) begin
        if (counter != 32'd16384) begin
          counter <= counter + 32'd1;
          status <= status - 16'd192;
        end
      end 
    end
  end
endmodule


module io_test_server #(CLK_PER_HALF_BIT = 217) 
  (
    output wire txd,
    input wire clk,
    input wire rstn_uart
  );

  reg [7:0] sdata;
  reg tx_start;
  wire tx_busy;
  reg [15:0] status;
  wire [7:0] large_p;       assign large_p = 8'h50;
  wire [7:0] number_0;      assign number_0 = 8'h30;
  wire [7:0] space;         assign space = 8'h20;
  wire [7:0] newline;       assign newline = 8'h0a;

  uart_tx #(CLK_PER_HALF_BIT) u1(sdata, tx_start, tx_busy, txd, clk, rstn_uart);


  always @(posedge clk) begin
    if (~rstn_uart) begin
      sdata <= 8'h00;
      tx_start <= 1'b0;
      status <= 16'd0;
    end else begin
      if (status == 16'd0) begin
        sdata <= 8'h57; status <= status + 16'd1;
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
      end else if (status == 16'd16)  begin sdata <= 8'h36;           status <= status + 16'd1;
      end 
    end
  end

endmodule


module io_test_client #(CLK_PER_HALF_BIT = 217) 
  (
    input wire rxd,
    output wire [15:0] debug,
    input wire clk,
    input wire rstn_uart
  );

  
  wire [7:0] rdata;
  wire rx_ready;
  wire ferr;
  reg [15:0] status;
  reg [7:0] buf1;
  reg [7:0] buf2;
  assign debug = {buf1,buf2};

  uart_rx #(CLK_PER_HALF_BIT) u2(rdata, rx_ready, ferr, rxd, clk, rstn_uart);


  always @(posedge clk) begin
    if (~rstn_uart) begin
      status <= 16'd0;
    end else begin
      if (status[3:0] == 4'd4) begin
        if (~rx_ready) begin
          status <= status + 16'd12;
        end
      end else if (status == 16'd0)   begin if (rx_ready) begin buf1         <= rdata; status <= status + 16'd4; end 
      end else if (status == 16'd16)  begin if (rx_ready) begin buf2         <= rdata; status <= status + 16'd4; end 
      end 
    end
  end
endmodule

`default_nettype wire