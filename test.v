`timescale 100ps/1ps
`default_nettype none

module test_io #(CLK_PER_HALF_BIT = 217) ();
  reg clk;
  reg rstn_uart;
  wire line;
  wire txd;
  wire [15:0] debug;

  io_test_2 _io_test_2(line, txd, debug, clk, rstn_uart);
  io_test_server _io_test_server(line, clk, rstn_uart);
  initial begin
    clk = 1'b0;
    rstn_uart = 1'b0;
    # 20
      rstn_uart = 1'b1;
    # 10000000
      $finish;
  end


  always begin
    # 5
      clk <= ~clk;
  end
endmodule

module test_dual_port_ram();
  reg clk;
  reg rstn;
  reg wr_en;
  reg [31:0] data_in;
  reg [31:0] addr_in_0;
  reg [31:0] addr_in_1;
  reg port_en_0;
  reg port_en_1;
  wire [31:0] data_out_0;
  wire [31:0] data_out_1;

  dual_port_ram _dual_port_ram(clk,rstn,wr_en,data_in,addr_in_0,addr_in_1,port_en_0,port_en_1,data_out_0,data_out_1);
  
  initial begin
    clk = 1'b0;
    rstn = 1'b0;
    wr_en = 1'b0;
    data_in = 32'b0;
    addr_in_0 = 32'b0;
    addr_in_1 = 32'b0;
    port_en_0 = 1'b0;
    port_en_1 = 1'b0;
    # 15
    clk = 1'b0;
    rstn = 1'b1;
    wr_en = 1'b0;
    data_in = 32'b0;
    addr_in_0 = 32'b0;
    addr_in_1 = 32'b0;
    port_en_0 = 1'b0;
    port_en_1 = 1'b0;
    # 10
    wr_en = 1'b0;
    data_in = 32'd0;
    addr_in_0 = 32'b0;
    addr_in_1 = 32'b1;
    port_en_0 = 1'b1;
    port_en_1 = 1'b1;
    # 10
    wr_en = 1'b1;
    data_in = 32'd100;
    addr_in_0 = 32'd0;
    addr_in_1 = 32'd1;
    port_en_0 = 1'b1;
    port_en_1 = 1'b1;
    # 10
    wr_en = 1'b1;
    data_in = 32'd200;
    addr_in_0 = 32'd1;
    addr_in_1 = 32'd0;
    port_en_0 = 1'b1;
    port_en_1 = 1'b1;
    # 10
    wr_en = 1'b1;
    data_in = 32'd300;
    addr_in_0 = 32'd2;
    addr_in_1 = 32'd1;
    port_en_0 = 1'b1;
    port_en_1 = 1'b1;
    # 10
    wr_en = 1'b0;
    data_in = 32'd0;
    addr_in_0 = 32'd3;
    addr_in_1 = 32'd2;
    port_en_0 = 1'b1;
    port_en_1 = 1'b1;
    # 10000000
      $finish;
  end

  always begin
    # 5
      clk <= ~clk;
  end
endmodule

module test_core();
  reg clk;
  reg rstn;
  wire [31:0] output_register;

  core _core(clk,rstn,output_register);
  initial begin
    clk = 1'b0;
    rstn = 1'b0;
    # 15
      rstn = 1'b1;
    # 10000000
      $finish;
  end

  always begin
    # 5
      clk <= ~clk;
  end
  
endmodule

