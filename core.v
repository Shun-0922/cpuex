module core(
    input wire [1023:0] i_memory_input,
    input wire clk,
    input wire rstn,
    output wire [31:0] output_register
);


wire alusrc_id;
wire alusrc_ex;
wire branch_id;
wire branch_ex;
wire branchtrue;
wire if_flush;
wire ifidwrite;
wire memread_id;
wire memread_ex;
wire memread_mem;
wire memtoreg_id;
wire memtoreg_ex;
wire memtoreg_mem;
wire memtoreg_wb;
wire memwrite_id;
wire memwrite_ex;
wire memwrite_mem;
wire nop_insert;
wire regwrite_id;
wire regwrite_ex;
wire regwrite_mem;
wire regwrite_wb;
wire pcwrite;
wire zero;

wire [1:0] alu_op_id;
wire [1:0] alu_op_ex;
wire [1:0] forward_a;
wire [1:0] forward_b;

wire [2:0] funct3_id;
wire [2:0] funct3_ex;

wire [3:0] alu_control;

wire [4:0] rd_id;
wire [4:0] rd_ex;
wire [4:0] rd_mem;
wire [4:0] rd_wb;
wire [4:0] rs1_id;
wire [4:0] rs1_ex;
wire [4:0] rs2_id;
wire [4:0] rs2_ex;

wire [6:0] funct7_id;
wire [6:0] funct7_ex;
wire [6:0] opcode;

wire [7:0] controlunit_out;
wire [7:0] control_signal;

wire [31:0] alu_result_ex;
wire [31:0] alu_result_mem;
wire [31:0] alu_result_wb;
wire [31:0] data_from_memory_mem;
wire [31:0] data_from_memory_wb;
wire [31:0] imm_id;
wire [31:0] imm_ex;
wire [31:0] instruction_if;
wire [31:0] instruction_id;
wire [31:0] pc_if;
wire [31:0] pc_id;
wire [31:0] pc_ex;
wire [31:0] read_data1_id;
wire [31:0] read_data1_ex;
wire [31:0] read_data2_id;
wire [31:0] read_data2_ex;
wire [31:0] src_a;
wire [31:0] src_b;
wire [31:0] write_data_memory_ex;
wire [31:0] write_data_memory_mem;
wire [31:0] write_data_register_wb;

assign write_data_register_wb = (memtoreg_wb == 1'b1) ? data_from_memory_wb : alu_result_wb;
assign branchtrue = branch_ex & zero;
assign src_b = (alusrc_ex == 1'b1) ? imm_ex : write_data_memory_ex;
assign write_data_memory_ex = (forward_b == 2'b00) ? read_data2_ex :
                              (forward_b == 2'b10) ? alu_result_mem : write_data_register_wb;
assign src_a = (forward_a == 2'b00) ? read_data1_ex :
               (forward_a == 2'b10) ? alu_result_mem : write_data_register_wb;
assign control_signal = (nop_insert == 1'b1) ? 8'b0 : controlunit_out;

alu _alu
  (
    .src_a(src_a),
    .src_b(src_b),
    .alu_control(alu_control),
    .zero(zero),
    .alu_result_ex(alu_result_ex)
  );

alu_controller _alu_controller
  (
    .funct3_ex(funct3_ex),
    .funct7_ex(funct7_ex),
    .alu_op_ex(alu_op_ex),
    .alu_control(alu_control)
  );

controlunit _controlunit
  (
    .opcode(opcode),
    .controlunit_out(controlunit_out)
  );

controldecoder _controldecoder
  (
    .control_signal(control_signal),
    .branch_id(branch_id),
    .memread_id(memread_id),
    .memtoreg_id(memtoreg_id),
    .alu_op_id(alu_op_id),
    .memwrite_id(memwrite_id),
    .alusrc_id(alusrc_id),
    .regwrite_id(regwrite_id)
  );

decoder _decoder
  (
    .instruction_id(instruction_id),
    .opcode(opcode),
    .rs1_id(rs1_id),
    .rs2_id(rs2_id),
    .rd_id(rd_id),
    .funct3_id(funct3_id),
    .funct7_id(funct7_id)
  );

instruction_memory _instruction_memory
  (
    .i_memory_input(i_memory_input),
    .clk(clk),
    .rstn(rstn),
    .pc_if(pc_if),
    .instruction_if(instruction_if)
  );

data_memory _data_memory
  (
    .clk(clk),
    .rstn(rstn),
    .alu_result_mem(alu_result_mem),
    .write_data_memory_mem(write_data_memory_mem),
    .memwrite_mem(memwrite_mem),
    .memread_mem(memread_mem),
    .data_from_memory_mem(data_from_memory_mem)
  );

programcounter _programcounter
  (
    .clk(clk),
    .rstn(rstn),
    .imm_ex(imm_ex),
    .branchtrue(branchtrue),
    .pc_ex(pc_ex),
    .pcwrite(pcwrite),
    .pc_if(pc_if)
  );

immediate_generator _immediate_generator
  (
    .instruction_id(instruction_id),
    .imm_id(imm_id)
  );

ifid _ifid
  (
    .clk(clk),
    .rstn(rstn),
    .pc_if(pc_if),
    .instruction_if(instruction_if),
    .if_flush(if_flush),
    .ifidwrite(ifidwrite),
    .pc_id(pc_id),
    .instruction_id(instruction_id)
  );

idex _idex
  (
    .clk(clk),
    .rstn(rstn),
    .branch_id(branch_id),
    .memread_id(memread_id),
    .memtoreg_id(memtoreg_id),
    .alu_op_id(alu_op_id),
    .memwrite_id(memwrite_id),
    .alusrc_id(alusrc_id),
    .regwrite_id(regwrite_id),
    .pc_id(pc_id),
    .read_data1_id(read_data1_id),
    .read_data2_id(read_data2_id),
    .imm_id(imm_id),
    .rs1_id(rs1_id),
    .rs2_id(rs2_id),
    .funct3_id(funct3_id),
    .funct7_id(funct7_id),
    .rd_id(rd_id),
    .branch_ex(branch_ex),
    .memread_ex(memread_ex),
    .memtoreg_ex(memtoreg_ex),
    .alu_op_ex(alu_op_ex),
    .memwrite_ex(memwrite_ex),
    .alusrc_ex(alusrc_ex),
    .regwrite_ex(regwrite_ex),
    .pc_ex(pc_ex),
    .read_data1_ex(read_data1_ex),
    .read_data2_ex(read_data2_ex),
    .imm_ex(imm_ex),
    .rs1_ex(rs1_ex),
    .rs2_ex(rs2_ex),
    .funct3_ex(funct3_ex),
    .funct7_ex(funct7_ex),
    .rd_ex(rd_ex)
  );

exmem _exmem
  (
    .clk(clk),
    .rstn(rstn),
    .regwrite_ex(regwrite_ex),
    .memtoreg_ex(memtoreg_ex),
    .memwrite_ex(memwrite_ex),
    .memread_ex(memread_ex),
    .alu_result_ex(alu_result_ex),
    .write_data_memory_ex(write_data_memory_ex),
    .rd_ex(rd_ex),
    .regwrite_mem(regwrite_mem),
    .memtoreg_mem(memtoreg_mem),
    .memwrite_mem(memwrite_mem),
    .memread_mem(memread_mem),
    .alu_result_mem(alu_result_mem),
    .write_data_memory_mem(write_data_memory_mem),
    .rd_mem(rd_mem)
  );

memwb _memwb
  (
    .clk(clk),
    .rstn(rstn),
    .regwrite_mem(regwrite_mem),
    .memtoreg_mem(memtoreg_mem),
    .data_from_memory_mem(data_from_memory_mem),
    .alu_result_mem(alu_result_mem),
    .rd_mem(rd_mem),
    .regwrite_wb(regwrite_wb),
    .memtoreg_wb(memtoreg_wb),
    .data_from_memory_wb(data_from_memory_wb),
    .alu_result_wb(alu_result_wb),
    .rd_wb(rd_wb)
  );

forwarding_unit _forwarding_unit
  (
    .rd_wb(rd_wb),
    .rd_mem(rd_mem),
    .rs1_ex(rs1_ex),
    .rs2_ex(rs2_ex),
    .regwrite_wb(regwrite_wb),
    .regwrite_mem(regwrite_mem),
    .forward_a(forward_a),
    .forward_b(forward_b)
  );

hazard_detection_unit _hazard_detection_unit 
  (
    .rd_ex(rd_ex),
    .rs1_id(rs1_id),
    .rs2_id(rs2_id),
    .branchtrue(branchtrue),
    .memread_ex(memread_ex),
    .pcwrite(pcwrite),
    .if_flush(if_flush),
    .ifidwrite(ifidwrite),
    .nop_insert(nop_insert)
  );

registerfile _registerfile
  (
    .rs1_id(rs1_id),
    .rs2_id(rs2_id),
    .rd_wb(rd_wb),
    .write_data_register_wb(write_data_register_wb),
    .regwrite_wb(regwrite_wb),
    .clk(clk),
    .rstn(rstn),
    .read_data1_id(read_data1_id),
    .read_data2_id(read_data2_id),
    .output_register(output_register)
  );


endmodule


module instruction_out
  (
    output wire [1023:0] i_memory_out,
    output wire rstn
  );
  assign rstn = 1'b1;
  wire [31:0]  i_memory_input1;
  wire [31:0]  i_memory_input2;
  wire [31:0]  i_memory_input3;
  wire [31:0]  i_memory_input4;
  wire [31:0]  i_memory_input5;
  wire [31:0]  i_memory_input6;
  wire [31:0]  i_memory_input7;
  wire [31:0]  i_memory_input8;
  wire [31:0]  i_memory_input9;
  wire [31:0]  i_memory_input10;
  wire [31:0]  i_memory_input11;
  wire [31:0]  i_memory_input12;
  wire [31:0]  i_memory_input13;
  wire [31:0]  i_memory_input14;
  wire [31:0]  i_memory_input15;
  wire [31:0]  i_memory_input16;
  wire [31:0]  i_memory_input17;
  wire [31:0]  i_memory_input18;
  wire [31:0]  i_memory_input19;                  
  wire [31:0]  i_memory_input20;
  wire [31:0]  i_memory_input21;
  wire [31:0]  i_memory_input22;
  wire [31:0]  i_memory_input23;
  wire [31:0]  i_memory_input24;
  wire [31:0]  i_memory_input25;
  wire [31:0]  i_memory_input26;
  wire [31:0]  i_memory_input27;
  wire [31:0]  i_memory_input28;
  wire [31:0]  i_memory_input29;
  wire [31:0]  i_memory_input30;
  wire [31:0]  i_memory_input31;
  wire [31:0]  i_memory_input32;
  assign i_memory_out = 
  {i_memory_input32,
  i_memory_input31,
  i_memory_input30,
  i_memory_input29,
  i_memory_input28,
  i_memory_input27,
  i_memory_input26,
  i_memory_input25,
  i_memory_input24,
  i_memory_input23,
  i_memory_input22,
  i_memory_input21,
  i_memory_input20,
  i_memory_input19,
  i_memory_input18,
  i_memory_input17,
  i_memory_input16,
  i_memory_input15,
  i_memory_input14,
  i_memory_input13,
  i_memory_input12,
  i_memory_input11,
  i_memory_input10,
  i_memory_input9,
  i_memory_input8,
  i_memory_input7,
  i_memory_input6,
  i_memory_input5,
  i_memory_input4,
  i_memory_input3,
  i_memory_input2,
  i_memory_input1};
  assign i_memory_input1 =  32'b0000000_00001_00000_000_00001_0010011;
  assign i_memory_input2 =  32'b0000000_00001_00000_000_00010_0010011;
  assign i_memory_input3 =  32'b0000000_00010_00000_000_00100_0010011;
  assign i_memory_input4 =  32'b0000000_01010_00000_000_00101_0010011;
  assign i_memory_input5 =  32'b0000000_00000_00000_000_00111_0010011;
  assign i_memory_input6 =  32'b0000000_00001_00111_010_00000_0100011;
  assign i_memory_input7 =  32'b0000000_00100_00111_000_00111_0010011;
  assign i_memory_input8 =  32'b0000000_00010_00111_010_00000_0100011;
  assign i_memory_input9 =  32'b0000000_00100_00111_000_00111_0010011;
  assign i_memory_input10 = 32'b0000000_00010_00001_000_00011_0110011;
  assign i_memory_input11 = 32'b0000000_00011_00111_010_00000_0100011;
  assign i_memory_input12 = 32'b0000000_00000_00010_000_00001_0010011;
  assign i_memory_input13 = 32'b0000000_00000_00011_000_00010_0010011;
  assign i_memory_input14 = 32'b0000000_00001_00100_000_00100_0010011;
  assign i_memory_input15 = 32'b0000000_00101_00100_000_01000_1100011;
  assign i_memory_input16 = 32'b1111111_00000_00000_000_00101_1100011;
  assign i_memory_input17 = 32'b0000000_00000_00111_010_00110_0000011;
  assign i_memory_input18 = 32'b0000000_00001_00100_000_00100_0010011;
  assign i_memory_input19 = 32'b1111111_00000_00000_000_11101_1100011;
  assign i_memory_input20 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input21 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input22 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input23 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input24 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input25 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input26 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input27 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input28 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input29 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input30 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input31 = 32'b0000000_00000_00000_000_00000_0000000;
  assign i_memory_input32 = 32'b0000000_00000_00000_000_00000_0000000;
   

endmodule