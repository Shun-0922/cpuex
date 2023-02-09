`timescale 100ps/1ps
`default_nettype none

module test_all #(CLK_PER_HALF_BIT = 434) ();
  reg clk;
  reg rstn1;
  reg rstn2;
  wire core_to_comp;
  wire comp_to_core;
  wire [15:0] led;
  /************dram*************
  wire [12:0] ddr2_addr;
  wire [2:0] ddr2_ba;
  wire ddr2_cas_n;
  wire [0:0] ddr2_ck_n;
  wire [0:0] ddr2_ck_p;
  wire [0:0] ddr2_cke;
  wire ddr2_ras_n;
  wire ddr2_we_n;
  wire [15:0] ddr2_dq;
  wire [1:0] ddr2_dqs_n;
  wire [1:0] ddr2_dqs_p;
  wire [0:0] ddr2_cs_n;
  wire [1:0] ddr2_dm;
  wire [0:0] ddr2_odt;
  /******************************/

  io_computer_side _io_computer_side(core_to_comp,comp_to_core,clk,rstn1);
  core_wrapper _core_wrapper
    (
      clk,rstn2,comp_to_core,core_to_comp,led/**,
      ddr2_addr,ddr2_ba,ddr2_cas_n,ddr2_ck_n,ddr2_ck_p,ddr2_cke,ddr2_ras_n,ddr2_we_n,ddr2_dq,ddr2_dqs_n,ddr2_dqs_p,ddr2_cs_n,ddr2_dm,ddr2_odt/**/
    );

  initial begin
    clk = 1'b0;
    rstn1 = 1'b0;
    rstn2 = 1'b0;
    # 25
      rstn1 = 1'b1;
    # 30
      rstn2 = 1'b1;
    # 10000000
      $finish;
  end

  always begin
    # 5
      clk <= ~clk;
  end
endmodule


module test_top ();
  wire [12:0] ddr2_addr;
  wire [2:0] ddr2_ba;
  wire ddr2_cas_n;
  wire [0:0] ddr2_ck_n;
  wire [0:0] ddr2_ck_p;
  wire [0:0] ddr2_cke;
  wire ddr2_ras_n;
  wire ddr2_we_n;
  wire [15:0] ddr2_dq;
  wire [1:0] ddr2_dqs_n;
  wire [1:0] ddr2_dqs_p;
  wire [0:0] ddr2_cs_n;
  wire [1:0] ddr2_dm;
  wire [0:0] ddr2_odt;
  reg  sys_clk;
  reg  mem_clk;
  reg  rst;
  reg  [26:0] addr_dram;
  reg  [31:0] din_dram;
  reg  rw_dram;
  reg  valid_dram;
  wire [31:0] dout_dram;
  wire ready_dram;
  wire led_memory;

  top _top(
    ddr2_addr,ddr2_ba,ddr2_cas_n,ddr2_ck_n,ddr2_ck_p,ddr2_cke,ddr2_ras_n,ddr2_we_n,ddr2_dq,ddr2_dqs_n,ddr2_dqs_p,ddr2_cs_n,ddr2_dm,ddr2_odt,
    sys_clk,mem_clk,rst,addr_dram,din_dram,rw_dram,valid_dram,dout_dram,ready_dram,led_memory
  );

  initial begin
    sys_clk = 1'b1;
    mem_clk = 1'b1;
    rst = 1'b0;
    rw_dram = 1'b0;
    valid_dram = 1'b0;
    addr_dram = 27'h0000000;
    din_dram = 32'h00000000;
    # 100
    rst = 1'b1;
    # 2000
    rw_dram = 1'b1;
    din_dram = 32'h33333333;
    valid_dram = 1'b1;
    addr_dram = 27'h2aaaaaa;
    # 100
    rw_dram = 1'b0;
    din_dram = 32'h33333333;
    valid_dram = 1'b1;
    addr_dram = 27'h2aaaaaa;
    
    # 1000000
      $finish;
  end



  always begin
    # 25
      mem_clk <= ~mem_clk;
  end

  always begin
    # 50
      sys_clk <= ~sys_clk;
  end

endmodule

