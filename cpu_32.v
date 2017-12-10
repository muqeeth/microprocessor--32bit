`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:39:45 10/31/2017 
// Design Name: 
// Module Name:    cpu_32 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module cpu_32(clk);
input clk;
reg [31:0] PC;
reg [31:0] IR,A,B,IMM;
reg [2:0] TYPE;
reg [31:0] ALUOUT;
reg COND;
reg HALTED;
reg [31:0] REG[0:31];//internal registers
reg [31:0] MEM[0:1023];//main memory
parameter ADD=6'b000000,SUB=6'b000001,AND=6'b000010,OR=6'b000011,LST=6'b000100,RST=6'b000101,LW=6'b000110,ST=6'b000111,
			 ADDI=6'b001000,SUBI=6'b001001,BEQZ=6'b001010,BNEQZ=6'b001011,HLT=6'b111111;//opcodes 
parameter RR_ALU=3'b000,RM_ALU=3'b001,LOAD=3'b010,STORE=3'b011,BRANCH=3'b100,HALT=3'b101;//type of instructions RR_ALU:register register 													operation,RM_ALU:register memory operation	
reg [2:0]state;	//state 

////////////////////////////////////////////////////////////////////////////////////////////////////////////
					
always@(posedge clk) //INSTRUCTION FETCH STAGE	//enter only for posedge of clk
begin
case(state)
3'b000:		//start from state =0
if (HALTED==0)	//check if halt signal is high
begin			//if not begin
IR = MEM[PC];		//load machine instruction into instruction register(IR)
if(IR[25:21]==5'b00000)  A=0;	
else A =  REG[IR[25:21]];	// load into A value of reg [IR[25:21]] to use as predefined registers
if(IR[20:16]==5'b00000)  B=0;	// load into B value of reg [IR[20:16]] to use as predefined registers
else B = REG[IR[20:16]];
IMM = {{16{IR[15]}},{IR[15:0]}};	//load into IMM immediate value given with sign extension to 32 bit
case (IR[31:26])
 ADD,SUB,AND,OR,LST,RST:TYPE = RR_ALU;	//depending on opcode assign types to  instructions
 ADDI,SUBI:TYPE = RM_ALU;
  LW:TYPE = LOAD;
  ST:TYPE = STORE;
  BEQZ,BNEQZ:TYPE =  BRANCH;
  HLT:TYPE = HALT;
  default:TYPE = HALT;
endcase
state = 3'b001;	//change state to 1
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
3'b001 :	//execution stage
if( HALTED == 0)	
begin
case (TYPE)		//depending on type of instruction calculate ALUOUT
 RR_ALU: begin
     case (IR[31:26])
	    ADD: ALUOUT =  A + B;
		SUB: ALUOUT = A - B;
		AND:ALUOUT= A &B;
		OR: ALUOUT= A | B;
		LST: ALUOUT=A << B;
		RST: ALUOUT =  A >> B;
		endcase
		end
 RM_ALU: begin
      case (IR[31:26])
		  ADDI: ALUOUT =  A + IMM;
		  SUBI: ALUOUT =  A - IMM;
      endcase
  end
 LOAD,STORE: begin
  ALUOUT =  A + IMM;
  end
 BRANCH: begin
   ALUOUT = PC + IMM;	//for branch load aluout to program counter + immediate value
	COND =  (A==0);	//check condition if A = 0 for branching
	end
  endcase
if (((IR[31:26]== BEQZ)&& (COND == 1))|| ((IR[31:26]==BNEQZ)&&(COND==0)))
 begin
 PC =  ALUOUT;	//load pc to aluout
 end
else	begin
PC = PC + 1;	//else pc is just incremented and points to next instruction
	end
state = 3'b010;	//change state to 2
end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
3'b010:
if(HALTED==0) //memory operations
 begin 	
  case (TYPE)

	RR_ALU: REG[IR[15:11]] = ALUOUT;	
		
	RM_ALU: REG[IR[20:16]] = ALUOUT;	
		
	LOAD:    REG[IR[20:16]] = MEM[ALUOUT];
	STORE:
      	MEM[ALUOUT]= B;
	HALT : HALTED =  1'b1;	//if instruction is halt raise halted signal and next instruction is not executed
	BRANCH : COND=1'b0;	//for branch once pc has value to go . reset condition register
	endcase
state = 3'b000;	//go to state 0 and repeat
end
endcase
end	
endmodule

