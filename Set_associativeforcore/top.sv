//clockを生成していろいろな部品につなげる(clock以外はno-touch)

module top (
    // DDR2
    output wire [12:0] ddr2_addr,
    output wire [2:0] ddr2_ba,
    output wire ddr2_cas_n,
    output wire [0:0] ddr2_ck_n,
    output wire [0:0] ddr2_ck_p,
    output wire [0:0] ddr2_cke,
    output wire ddr2_ras_n,
    output wire ddr2_we_n,
    inout  wire [15:0] ddr2_dq,
    inout  wire [1:0] ddr2_dqs_n,
    inout  wire [1:0] ddr2_dqs_p,
    output wire [0:0] ddr2_cs_n,
    output wire [1:0] ddr2_dm,
    output wire [0:0] ddr2_odt,
    // others
    input logic sys_clk,
    input logic mem_clk,
    input logic rst,
    input logic [26:0] addr_dram,
    input logic [31:0] din_dram,
    input logic [ 0:0] rw_dram,
    input logic [ 0:0] valid_dram,
    output logic [31:0] dout_dram,
    output logic [ 0:0] ready_dram,
    output logic led_memory
);

    // interfaces
    master_fifo master_fifo ();
    slave_fifo slave_fifo ();
    
    cpu_req_type cpu_to_cache_request;
    cpu_result_type cpu_res;
    
    assign cpu_to_cache_request.addr = addr_dram;
    assign cpu_to_cache_request.data = din_dram;
    assign cpu_to_cache_request.rw = rw_dram;
    assign cpu_to_cache_request.valid = valid_dram;
    
    assign dout_dram = cpu_res.data;
    assign ready_dram = cpu_res.ready;

    // master（CPU側のFIFO）
    dram_test dram_test (
        .fifo(master_fifo),
        .sys_clk(sys_clk),
        .mem_clk(mem_clk),
        .rst(rst),
        .cpu_to_cache_request(cpu_to_cache_request),
        .cpu_res(cpu_res),
        .led_memory(led_memory)
    );

    // fifoを生成する
    dram_buf dram_buf (
        .master(master_fifo),
        .slave(slave_fifo)
    );

    // slave（DRAM側のFIFO）
    dram_controller dram_controller (
        // DDR2
        .ddr2_addr(ddr2_addr),
        .ddr2_ba(ddr2_ba),
        .ddr2_cas_n(ddr2_cas_n),
        .ddr2_ck_n(ddr2_ck_n),
        .ddr2_ck_p(ddr2_ck_p),
        .ddr2_cke(ddr2_cke),
        .ddr2_ras_n(ddr2_ras_n),
        .ddr2_we_n(ddr2_we_n),
        .ddr2_dq(ddr2_dq),
        .ddr2_dqs_n(ddr2_dqs_n),
        .ddr2_dqs_p(ddr2_dqs_p),
        .ddr2_cs_n(ddr2_cs_n),
        .ddr2_dm(ddr2_dm),
        .ddr2_odt(ddr2_odt),
        // others
        .sys_clk(mem_clk),
        .fifo(slave_fifo)
    );
endmodule
