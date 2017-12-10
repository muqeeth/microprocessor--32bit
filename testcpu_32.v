`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:16:15 11/01/2017
// Design Name:   cpu_32
// Module Name:   C:/Users/Muqeeth/verilog/cpu_32/testcpu_32.v
// Project Name:  cpu_32
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu_32
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testcpu_32;

	// Inputs
	reg clk;
	integer k;
	reg [31:0]captured;
	integer datafile;
	integer scanfile;
	integer i;
	//integer i;
	//reg [31:0]regtest[5:0];
	// Instantiate the Unit Under Test (UUT)
	cpu_32 uut (
		.clk(clk)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		forever
		begin
			#2 clk= 1; #2 clk=0;	//clk for the system
		end
	end
	initial begin
	for(k=0;k<31;k=k+1)
	uut.REG[k]=k;		//assining registers to have default values
	uut.PC = 0;		//begin from program counter =0
	uut.HALTED =0;		//halt signal is not high, if it is high then stop .
	uut.state = 3'b000;	//starting from state =0
	uut.MEM[8] =32'h00000004;
	//uut.MEM[6]=32'h00000008;

	//uut.MEM[2]=32'h28000000;//beqz ro,1
	//uut.MEM[2]=32'h2c200001;//bneqz r1,1
	//uut.MEM[2]=32'h2021FFFF;//ADD R1,R2,R4
	//uut.MEM[0]=32'h00222000;//ADD R1,R2,R4	//directly giving machine instructions into memory
	//uut.MEM[2]=32'h00000000;//ADD R0,R0,R0
	//uut.MEM[3]=32'h00000000;//ADD R0,R0,R0
	//uut.MEM[3]=32'h00000000;//ADD R0,R0,R0
	//uut.MEM[1]=32'h04413800;//SUB R2,R1,R7
	//uut.MEM[2]=32'h1CA20002;//store r2,2(r5)
	//uut.MEM[1]=32'h2021FFFF;//ADDI r1,r1,-1
	//uut.MEM[3]=32'h19020000;//load r2,r8,0
	//uut.MEM[4]=32'hfc000000;//HALT	
	#3000	
	for(k=0;k<10;k=k+1)
	begin
	$display ("R%1d - %2d ",k,uut.REG[k]);	
	//display value of registers and memory from 30 t0 60 after 3000ns
	$display("mem[%2d]=%2d",k+30,uut.MEM[k+30]);
	end	
	end
initial begin
	
    datafile= $fopen("firsttest.hex","r");	//open in readmode  file "firsttest.hex" which has machine instructions
	i =0;
    if(datafile==0) begin
        $display("Input program not available!");	//if none display "Input program not available!"
        $finish;
    end
    else begin							
        while(!$feof(datafile)) begin			//not reached to end of file
            scanfile= $fscanf(datafile,"%b\n",captured);//capture data into register captured
		uut.MEM[i] = captured;		//copy that captured data into memory
		$display("%b",uut.MEM[i]);	//display machine instructions on to terminal
            i=i+1;
        end
    end
    $fclose(datafile);	//close file
end		
	initial 
	begin
	$dumpfile("uut.vcd");	//dump file is uut.vcd
	$dumpvars(0,testcpu_32);	//dump all variables
	#3000 $finish;
	end		
endmodule
