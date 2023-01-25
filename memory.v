

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
  parameter WIDTH = 32,LOGWIDTH = 5;

  reg [31:0] ram [0:WIDTH - 1];
  assign output_instruction_ram = ram[0];

  integer i;

  always @(posedge clk) begin
    if (~rstn) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        ram[i] <= 32'b0;
      end
    end else if (wr_en_instr == 1'b1) begin
      ram[addr_in_instr[LOGWIDTH + 1:2]] <= data_in_instr;
    end
  end

  assign instruction_if = port_en_1_instr ? ram[pc_if[LOGWIDTH + 1:2]] : 32'b0;

endmodule


module data_ram_wrap
  (
    input wire clk,
    input wire rstn,
    input wire memwrite_mem,
    input wire memwrite_io,
    input wire [31:0] write_data_memory_mem,
    input wire [31:0] write_data_io,
    input wire [31:0] alu_result_mem,
    input wire [31:0] addr_io,
    input wire memread_mem,
    input wire memread_io,
    output wire [31:0] data_from_memory_mem,
    output wire [31:0] data_from_memory_io
  );
  wire memwrite;
  wire [31:0] write_data_memory;
  wire [31:0] addr_in;
  wire memread;
  wire [31:0] data_from_memory;
  data_ram _data_ram
  (
    .clk(clk),
    .rstn(rstn),
    .memwrite(memwrite),
    .write_data_memory(write_data_memory),
    .addr_in(addr_in),
    .memread(memread),
    .data_from_memory(data_from_memory)
  );
  assign memwrite = memwrite_mem || memwrite_io;
  assign write_data_memory = memwrite_mem == 1'b1 ? write_data_memory_mem : write_data_io;
  assign addr_in = (memwrite_mem == 1'b1 || memread_mem == 1'b1) ? alu_result_mem : addr_io;
  assign memread = memread_mem || memread_io;
  assign data_from_memory_mem = data_from_memory;
  assign data_from_memory_io = data_from_memory;

endmodule

module data_ram 
  (
    input wire clk,
    input wire rstn,
    input wire memwrite,
    input wire [31:0] write_data_memory,
    input wire [31:0] addr_in,
    input wire memread,
    output wire [31:0] data_from_memory
  );
  
  parameter WIDTH = 256,LOGWIDTH = 8;
  reg [31:0] ram [0:WIDTH - 1];

  integer i;

  always @(posedge clk) begin
    if (~rstn) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        ram[i] <= 32'b0;
      end
    end else if (memwrite == 1'b1) begin
      ram[addr_in[LOGWIDTH + 1:2]] <= write_data_memory;
    end
  end

  assign data_from_memory = memread ? ram[addr_in[LOGWIDTH + 1:2]] : 32'b0;

endmodule


module dual_port_ram 
 #(
    WIDTH = 32,
    LOGWIDTH = 5
  )
  (
    input wire clk,
    input wire rstn,
    input wire wr_en,
    input wire [31:0] data_in,
    input wire [31:0] addr_in_0,
    input wire [31:0] addr_in_1,
    input wire port_en_0,
    input wire port_en_1,
    output wire [31:0] data_out_0,
    output wire [31:0] data_out_1
  );
  
  reg [31:0] ram [0:WIDTH - 1];

  integer i;

  always @(posedge clk) begin
    if (~rstn) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        ram[i] <= 32'b0;
      end
    end else if (port_en_0 == 1'b1 && wr_en == 1'b1) begin
      ram[addr_in_0[LOGWIDTH - 1:0]] <= data_in;
    end
  end

  assign data_out_0 = port_en_0 ? ram[addr_in_0[LOGWIDTH - 1:0]] : 32'b0;
  assign data_out_1 = port_en_1 ? ram[addr_in_1[LOGWIDTH - 1:0]] : 32'b0;

endmodule










