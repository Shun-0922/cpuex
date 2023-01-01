

module instruction_ram 
  (
    input wire clk,
    input wire rstn,
    input wire wr_en_instr,
    input wire [31:0] data_in_instr,
    input wire [31:0] addr_in_instr,
    input wire [31:0] pc_if,
    input wire port_en_1_instr,
    output wire [31:0] instruction_if
  );
  parameter WIDTH = 32,LOGWIDTH = 5;

  reg [31:0] ram [0:WIDTH - 1];

  integer i;

  always @(posedge clk) begin
    if (~rstn) begin
      /*for (i = 0; i < WIDTH; i = i + 1) begin
        ram[i] <= 32'b0;
      end*/
      ram[0] <=  32'b0000000_00001_00000_000_00001_0010011;  //  00100093     addi x1,   zero, 1
      ram[1] <=  32'b0000000_00001_00000_000_00010_0010011;  //  00100113     addi x2,   zero, 1
      ram[2] <=  32'b0000000_00010_00000_000_00100_0010011;  //  00200223     addi x4,   zero, 2
      ram[3] <=  32'b0000000_01010_00000_000_00101_0010011;  //  00a00293     addi x5,   zero, 10
      ram[4] <=  32'b0000000_00000_00000_000_00111_0010011;  //  00000393     addi x7,   zero, 0
      ram[5] <=  32'b0000000_00001_00111_010_00000_0100011;  //  0070a023     sw   x1,   0(x7)
      ram[6] <=  32'b0000000_00100_00111_000_00111_0010011;  //  00438393     addi x7,   x7,   4
      ram[7] <=  32'b0000000_00010_00111_010_00000_0100011;  //  00712023     sw   x2,   0(x7)
      ram[8] <=  32'b0000000_00100_00111_000_00111_0010011;  //  00438393     addi x7,   x7,   4                LABEL2
      ram[9] <=  32'b0000000_00010_00001_000_00011_0110011;  //  002081b3     add  x3,   x1,   x2
      ram[10] <= 32'b0000000_00011_00111_010_00000_0100011;  //  0071a023     sw   x3,   0(x7)
      ram[11] <= 32'b0000000_00000_00010_000_00001_0010011;  //  00010093     addi x1,   x2,   0
      ram[12] <= 32'b0000000_00000_00011_000_00010_0010011;  //  00018113     addi x2,   x3,   0
      ram[13] <= 32'b0000000_00001_00100_000_00100_0010011;  //  00120213     addi x4,   x4,   1
      ram[14] <= 32'b0000000_00101_00100_000_01000_1100011;  //  00520263     beq  x4,   x5,   LABEL1 (= 64 (+ 8))
      ram[15] <= 32'b1111111_00000_00000_000_00101_1100011;  //  fe0002e3     beq  zero, zero, LABEL2 (= 32 (- 28))
      ram[16] <= 32'b0000000_00000_00111_010_00110_0000011;  //  0003a303     lw   x6,   0(x7)                  LABEL1
      ram[17] <= 32'b0000000_00001_00100_000_00100_0010011;  //  00120213     addi x4,   x4,   1                LABEL3
      ram[18] <= 32'b1111111_00000_00000_000_11101_1100011;  //  fe000ee3     beq  zero, zero, LABEL3 (= 68 (- 4))                    
      ram[19] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[20] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[21] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[22] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[23] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[24] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[25] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[26] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[27] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[28] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[29] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[30] <= 32'b0000000_00000_00000_000_00000_0000000;
      ram[31] <= 32'b0000000_00000_00000_000_00000_0000000;
    end else if (wr_en_instr == 1'b1) begin
      ram[addr_in_instr[LOGWIDTH + 1:2]] <= data_in_instr;
    end
  end

  assign instruction_if = port_en_1_instr ? ram[pc_if[LOGWIDTH + 1:2]] : 32'b0;

endmodule




module data_ram 
  (
    input wire clk,
    input wire rstn,
    input wire memwrite_mem,
    input wire [31:0] write_data_memory_mem,
    input wire [31:0] alu_result_mem,
    input wire memread_mem,
    output wire [31:0] data_from_memory_mem
  );
  
  parameter WIDTH = 32,LOGWIDTH = 5;
  reg [31:0] ram [0:WIDTH - 1];

  integer i;

  always @(posedge clk) begin
    if (~rstn) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        ram[i] <= 32'b0;
      end
    end else if (memwrite_mem == 1'b1) begin
      ram[alu_result_mem[LOGWIDTH + 1:2]] <= write_data_memory_mem;
    end
  end

  assign data_from_memory_mem = memread_mem ? ram[alu_result_mem[LOGWIDTH + 1:2]] : 32'b0;

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










