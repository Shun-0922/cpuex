

module instruction_ram 
  (
    input wire clk,
    input wire rstn,
    input wire wr_en_instr,
    input wire [31:0] data_in_instr,
    input wire [31:0] addr_in_instr,
    input wire [31:0] pc_if,
    input wire port_en_1_instr,
    output wire [31:0] instruction_if,
    output wire [31:0] output_instruction_ram
  );

  wire clka;
  assign clka = clk;

  wire ena;
  assign ena = 1'b1;

  wire wea;
  assign wea = wr_en_instr;

  wire [13:0] addra;
  assign addra = (wr_en_instr == 1'b1) ? addr_in_instr[15:2] : pc_if[15:2];

  wire [31:0] dina;
  assign dina = data_in_instr;

  wire [31:0] douta;
  assign instruction_if = douta;

  blk_mem_gen_0 blk_mem_gen_instruction (
    .clka(clka),    // input wire clka
    .ena(ena),      // input wire ena
    .wea(wea),      // input wire [0 : 0] wea
    .addra(addra),  // input wire [13 : 0] addra
    .dina(dina),    // input wire [31 : 0] dina
    .douta(douta)  // output wire [31 : 0] douta
  );

  assign output_instruction_ram = douta;

endmodule


module data_ram
  (
    input wire clk,
    input wire rstn,
    input wire alu_ready,
    input wire memwrite_mem,
    input wire memwrite_io,
    input wire [31:0] write_data_memory_mem,
    input wire [31:0] write_data_io,
    input wire [31:0] alu_result_mem,
    input wire [31:0] addr_io,
    input wire memread_mem,
    input wire memread_io,
    input wire core_start,
    input wire core_end,
    input wire [31:0] dout_dram,
    input wire ready_dram,
    output wire [31:0] data_from_memory_mem,
    output wire [31:0] data_from_memory_io,
    output wire data_ready_mem,
    output wire data_ready_io,
    output wire [26:0] addr_dram,
    output wire [31:0] din_dram,
    output wire rw_dram,
    output wire valid_dram
  );

  wire clka;
  wire ena;
  wire wea;
  wire [16:0] addra;
  wire [31:0] dina;
  wire [31:0] douta;
  wire ready;
  /******************************bram******************************/
  reg [1:0] ready_reg;
  assign ready = (ready_reg == 2'b10) ? 1'b1 : 1'b0;
  /****************************************************************/
  /*******************************dram*****************************
  assign ready = ready_dram;
  assign douta = dout_dram;
  /****************************************************************/

  assign clka = clk;
  assign ena = 1'b1;
  assign wea = memwrite_mem || memwrite_io;
  assign addra = (core_start && ~core_end) ? alu_result_mem[18:2] : addr_io[18:2];
  assign dina = (memwrite_mem) ? write_data_memory_mem : ((memwrite_io) ? write_data_io : 32'b0);
  assign data_from_memory_mem = douta;
  assign data_from_memory_io = douta;

  assign addr_dram = (core_start && ~core_end) ? alu_result_mem[26:0] : addr_io[26:0];
  assign din_dram = (memwrite_mem) ? write_data_memory_mem : ((memwrite_io) ? write_data_io : 32'b0);
  assign rw_dram = memwrite_mem || memwrite_io;


  
 
  

  wire valid;

  wire [2:0] status1_mem;
  wire [2:0] status1_io;

  reg [1:0] status2_mem;
  reg [1:0] status2_io;

  always @(posedge clk) begin
    if (~rstn) begin
      status2_mem <= 2'b00;
      status2_io <= 2'b00;
    end else begin
      if (memread_mem && status2_mem == 2'b00) begin
        status2_mem <= 2'b01;
      end else if (status2_mem == 2'b01 && ready && ~alu_ready) begin
        status2_mem <= 2'b10;
      end else if (status2_mem == 2'b01 && ready && alu_ready) begin
        status2_mem <= 2'b00;
      end else if (status2_mem == 2'b10 && alu_ready) begin
        status2_mem <= 2'b00;
      end
      if (memread_io && status2_io == 2'b00) begin
        status2_io <= 2'b01;
      end else if (status2_io == 2'b01 && ready && ~alu_ready) begin
        status2_io <= 2'b10;
      end else if (status2_io == 2'b01 && ready && alu_ready) begin
        status2_io <= 2'b00;
      end else if (status2_io == 2'b10 && alu_ready) begin
        status2_io <= 2'b00;
      end
    end
  end

  assign status1_mem =
    (~memread_mem) ? 3'b000 :
    (ready) ? 3'b011 :
    (status2_mem == 2'b10) ? 3'b100 :
    (status2_mem == 2'b01) ? 3'b010 : 3'b001;
  assign status1_io =
    (~memread_io) ? 3'b000 :
    (ready) ? 3'b011 :
    (status2_io == 2'b10) ? 3'b100 :
    (status2_io == 2'b01) ? 3'b010 : 3'b001;

  assign data_ready_io = (status1_io == 3'b000) || (status1_io == 3'b011 || status1_io == 3'b100);
  assign data_ready_mem = (status1_mem == 3'b000) || (status1_mem == 3'b011 || status1_mem == 3'b100);
  assign valid = (status1_io == 3'b001 || status1_mem == 3'b001 || memwrite_io || memwrite_mem || status1_io == 3'b010 || status1_mem == 3'b010);
  assign valid_dram = valid;


  /*********************************bram**************************************/
  blk_mem_gen_1 blk_mem_gen_data (
    .clka(clka),    // input wire clka
    .ena(ena),      // input wire ena
    .wea(wea),      // input wire [0 : 0] wea
    .addra(addra),  // input wire [13 : 0] addra
    .dina(dina),    // input wire [31 : 0] dina
    .douta(douta)  // output wire [31 : 0] douta
  );

  always @(posedge clk) begin
    if (~rstn) begin
      ready_reg <= 2'b00;
    end else begin
      if (status1_io == 3'b001 || status1_mem == 3'b001) begin
        ready_reg <= 2'b01;
      end else if (ready_reg == 2'b01) begin
        ready_reg <= 2'b10;
      end else if (ready_reg == 2'b10) begin
        ready_reg <= 2'b00;
      end 
    end
  end
  /****************************************************************************/



endmodule

