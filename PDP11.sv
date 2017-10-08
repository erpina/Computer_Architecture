`define MEMFILE "Register.ascii"
//`HALT 16'b0000_0000_0000_0000

module memory();
parameter MemSize = 64 ;
parameter HALT = 16'b0000_0000_0000_0000;
parameter StartAdd = 0;
//logic [23:0] PDP_11_Memory_buf[0:MemSize*1024];
logic signed [7:0] PDP_11_Memory[0:(MemSize*1024)-1];
logic [23:0] mem_buf;

string strings11[0:MemSize*1024];
int FLAG;
integer i,j,k,fp,condFlagFile, traceFile;
reg eof;
string changeAddress,loadValue,startAddress;
logic [15:0]PC, tempPC;
logic [15:0] IR;
logic [15:0] SP;
logic signed [15:0]Register[0:7];
logic [2:0] srcRegister;
logic [2:0] dstRegister;
logic [15:0] srcEffAddress;
logic [15:0] dstEffAddress;
logic [15:0] tempAddress;
logic byteSelect;
logic N,Z,C,V,T;
logic [4:0] d; 
logic signed [7:0] offset;

//logic [16:0]loopVariable;
//logic [15:0]PC;
//logic [7:0]PDP_11_Memory[0:64*1024];

int PC_Flag;
int m;


initial 
  begin 
  Z=0; V=0; N=0; C=0; T=0;
  readmemory;  
  //loopVariable = 0;
  //PC = Register[7];
  SP = Register[6];
   condFlagFile = $fopen("output.txt","w");
   traceFile = $fopen("trace.txt");

do
begin
tempPC  = Register[7];
IR = {PDP_11_Memory[Register[7]+1],PDP_11_Memory[Register[7]]};
byteSelect = IR[15];
   $fwrite(traceFile,"2 %o\n",Register[7]);

  Register[7] += 2;
if( IR[14:12] >= 3'b001 && IR[14:12] <= 3'b110 )
	begin 
	//$display("Double Operand");
		doubleoperands(IR);
	end
else if ((IR[14:9]==6'b000_101)||(IR[14:9]==6'b000_110))
	begin
		//$display("Single Operands");
		singleoperands(IR);
		
	end 
else if ((IR[15:9]==7'b0000100))
	begin 
		//$display("subroutine calls");
		subroutinecalls(IR);
	end 
else if(((IR[14:9]==6'b000001)||(IR[14:9]==6'b000010)||(IR[14:9]==6'b000011))&&((IR[8:6]==3'b100)||(IR[8:6]==3'b000)))
	begin
		//$display("Conditional Branches");
		conditionalbranches(IR);
	end 
else if(((IR[14:9]==6'b000000)&&(IR[8:6]==6'b100))||(IR[15:6]==10'b1000000000))
	begin
		//$display("Special Conditional Branches");
		specialconditionalbranches(IR);
	end
else if ((IR[15:3]==13'b0000000010000))
	begin
		//$display("subroutine returns");
		subroutinereturns(IR);
	end
else if (( IR[14:9]==6'b000000) && ((IR[8:6]==3'b001) || (IR[8:6]==3'b011) ))
	begin
		//$display("Special single operands");
		specialsingleoperands(IR);
	end
else 
	begin
		//$display("special instructions");
		specialinstructions(IR);
	end
$display("IR=%o R0=%o R1=%o R2=%o  R3=%o  R4=%o  R5=%o  R6=%o  R7=%o  N=%b Z=%b C=%b V=%b ",IR,Register[0],Register[1],Register[2],Register[3],Register[4],Register[5],Register[6],Register[7],N,Z,C,V); 
$fwrite(condFlagFile,"IR=%o R0=%o R1=%o R2=%o  R3=%o  R4=%o  R5=%o  R6=%o  R7=%d  N=%b Z=%b C=%b V=%b \n",IR,Register[0],Register[1],Register[2],Register[3],Register[4],Register[5],Register[6],tempPC,N,Z,C,V);                     
   end while(IR != HALT);
 end
/*  initial
    begin 
	 $monitor("PDP 64 %o    PDP_70 %o  ",PDP_11_Memory[64],PDP_11_Memory[70]);
	//$monitor("PC %o IR  %b r0 %o r1 %o r2 %o r3 %o  r4 %o  r5 %o   r6 %o  r7 %o ", PC,IR,Register[0],Register[1],Register[2],Register[3],Register[4],Register[5],Register[6],Register[7] );
	end */
// assign PC = Register[7];
// assign IR = {PDP_11_Memory[PC+1],PDP_11_Memory[PC]};//{PDP_11_Memory[PC]}};
 //assign byteSelect = IR[15];

 
 
/*  //Instruction Decode
always_comb
begin

$fwrite(traceFile,"0 %o\n",Register[7]);
$fwrite(condFlagFile,"IR=%o R0=%o R1=%o R2=%o  R3=%o  R4=%o  R5=%o  R6=%o  R7=%d  N=%b Z=%b C=%b V=%b \n",IR,Register[0],Register[1],Register[2],Register[3],Register[4],Register[5],Register[6],Register[7],N,Z,C,V);                  
  Register[7] += 2;
if( IR[14:12] >= 3'b001 && IR[14:12] <= 3'b110 )
	begin 
	$display("Double Operand");
		doubleoperands(IR);
	end
else if ((IR[14:9]==6'b000_101)||(IR[14:9]==6'b000_110))
	begin
		$display("Single Operands");
		singleoperands(IR);
		
	end 
else if ((IR[15:9]==7'b0000100))
	begin 
		$display("subroutine calls");
		subroutinecalls(IR);
	end 
else if(((IR[14:9]==6'b000001)||(IR[14:9]==6'b000010)||(IR[14:9]==6'b000011))&&((IR[8:6]==3'b100)||(IR[8:6]==3'b000)))
	begin
		$display("Conditional Branches");
		conditionalbranches(IR);
	end 
else if(((IR[14:9]==6'b000000)&&(IR[8:6]==6'b100))||(IR[15:6]==10'b1000000000))
	begin
		$display("Special Conditional Branches");
		specialconditionalbranches(IR);
	end
else if ((IR[15:3]==13'b0000000010000))
	begin
		$display("subroutine returns");
		subroutinereturns(IR);
	end
else if (( IR[14:9]==6'b000000) && ((IR[8:6]==3'b001) || (IR[8:6]==3'b011) ))
	begin
		$display("Special single operands");
		specialsingleoperands(IR);
	end
else 
	begin
		$display("special instructions");
		specialinstructions(IR);
	end
$display("IR=%o R0=%o R1=%o R2=%o  R3=%o  R4=%o  R5=%o  R6=%o  R7=%o  N=%b Z=%b C=%b V=%b ",IR,Register[0],Register[1],Register[2],Register[3],Register[4],Register[5],Register[6],Register[7],N,Z,C,V); 
//$fwrite(condFlagFile,"IR=%o R0=%o R1=%o R2=%o  R3=%o  R4=%o  R5=%o  R6=%o  R7=%o  N=%b Z=%b C=%b V=%b ",IR,Register[0],Register[1],Register[2],Register[3],Register[4],Register[5],Register[6],Register[7],N,Z,C,V); 
//if(loopVariable <= k)
	//loopVariable = loopVariable + 1;
end
 */
 
 task readmemory;
 
     j=0;k=0;
	 changeAddress="@";
	 loadValue="-";
	 startAddress="*";
	 //logic [15:0]tempAddress;	// Temporary value to store input data from input file
	 k = 0;	//Loop counter to input file
	 
	 PDP_11_Memory[0:MemSize*1024-1]='{default:'d0};   
   	 fp = $fopen(`MEMFILE,"r");
	    if (fp == 0)
	        $display("file doesn't exist");
	    else
	    begin
	     $display("file  exist");
	  	    while(!$feof(fp))
	       begin
	         FLAG = $fgets(strings11[j],fp);
			 j++;
	       end
		end 
	    foreach(strings11[i])
		   begin
				
		         if(!strings11[i].substr(0,0).icompare(changeAddress))
		            begin
				      tempAddress = strings11[i].substr(1,7).atooct();
					  k = tempAddress;
				    end
		         else if(!strings11[i].substr(0,0).icompare(loadValue))
		             begin  
				         //PDP_11_Memory[k] = strings11[i].substr(1,7).atooct();
			             //k++; 
						 tempAddress = strings11[i].substr(1,7).atooct();
						 { PDP_11_Memory[k+1] , PDP_11_Memory[k] } =  { tempAddress[15:8] , tempAddress[7:0] }; 
						 k = k + 2;
			         end
		         else if(!strings11[i].substr(0,0).icompare(startAddress))
		             begin
					    Register[7] = strings11[i].substr(1,7).atooct();
						PC_Flag = 1;
						k = k + 2; 
					 end   
				 else
						PDP_11_Memory[k] = 0;
	           $display(" %d :   %o    %o", i,PDP_11_Memory[i-1],Register[7]);
			   
        end

            if(!PC_Flag)
			begin
			i= $value$plusargs("Register[7]=%o",Register[7] );
			$display("loaded %d",Register[7]);
			end
		
 endtask
 
 
 //double operands
task doubleoperands(input logic [15:0]IR);
logic [2:0]operand1;
logic [2:0]operand2;
logic [2:0]mode1;
logic [2:0]mode2;
logic signed [15:0]source;	//srcData	
logic signed [15:0]destination;	//dstData
logic signed [16:0]tempResult; //Temp variable to hold intermediate values
logic [15:0]address;
T = 0;
mode1=IR[11:9];	//srcMode
operand2=IR[2:0];	//dstOperand
operand1=IR[8:6];	//srcOperand
mode2=IR[5:3];		//dstMode
srcRegister = operand1;
dstRegister = operand2;


		if(mode1 > 0)
		begin
			effective_address(operand1, mode1, srcEffAddress, byteSelect);
			$fwrite(traceFile,"0 %o\n",srcEffAddress);                
		end
		if(mode2 > 0)
		begin
			effective_address(operand2, mode2, dstEffAddress, byteSelect);
			               
		end
		//Calculate Source Data
		if(byteSelect == 1)
		begin
			if(mode1 == 0) 
				source = Register[operand1][7:0];
			else
				get_val(srcEffAddress, source, byteSelect);
		end
		else
		begin
			if(mode1 == 0) 
				source = Register[operand1];
			else
				get_val(srcEffAddress, source, byteSelect);
		end
		
		//Calculate Destination data
		if(byteSelect == 1)
		begin
			if(mode2 == 0) 
				destination = Register[operand2][7:0] ;
			else
				get_val(dstEffAddress, source, byteSelect);
		end
		else
		begin
			if(mode2 == 0) 
				destination = Register[operand2];
			else
				get_val(dstEffAddress, destination, byteSelect);
		end

if( T != 1 )
begin

case(IR[15:12])

4'b0_001: 
	begin 
		$display("PC before MOVE  %o  ",Register[7]);			
		$display("MOV");
		
		V = 0;	//Cleared by Default
		//Zero Flag
		if(source == 0)	//PSW Update
			Z = 1;
		else
			Z = 0;
		//Negative Flag
		if(byteSelect == 1)
		begin
		if(source[7] == 1)
			N = 1; 
		else
			N = 0;
		end
		else
		begin
			if (source[15] == 1)
				N = 1;
			else
				N = 0;
		end
		
//Operation
		$display("PC in MOV  %o  ",Register[7]);
		if(byteSelect == 1)	//MOVB
		begin
			if(mode2 == 0) 
				begin
				Register[dstRegister] = source[7:0];
				end 
				if(source[7] == 1)	//Sign Extend
				begin
					Register[dstRegister][15:8] = 8'b1111_1111;
				end
			else
				put_val( dstEffAddress , source[7:0] , byteSelect);
			//PDP_11_Memory[dstEffAddress] = source[7:0];//####################################################################################################################################
		end
		
		else	//MOV
		begin
			if(mode2 == 0)
				Register[dstRegister] = source;
			else
			begin
			
				//PDP_11_Memory[dstEffAddress] = source[7:0];	//######################################################################################################################################################
				//PDP_11_Memory[dstEffAddress+1] = source[15:7];//######################################################################################################################################################
				put_val( dstEffAddress , source[15:0] , byteSelect);
			end
			$display("Source Address %d  Source Value %o Destination Address %d PDP_11_Memory(dest) = %o ",srcEffAddress, source,dstEffAddress, {PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress] });
		end
		
	end
4'b0_010:  
	begin 
	$display("CMP");
	
		if(byteSelect == 1)	//CMPB
		begin
		tempResult = source[7:0] - destination[7:0];
		
		if( tempResult[8] == 1)
		begin
			C = 0;	//cleared if there was a carry from the most significant bit of the result; set otherwise
		end
		else
		begin
			C = 1;
		end
		if( source[7] != destination[7] )
		begin
			if( tempResult[7] == destination[7] )
				V = 1;	//Set if operands were of opposite signs and the sign of the destination was the same as the sign of the result; cleared otherwise
		end
		else
			V = 0;
			
		if( tempResult == 0 )
			Z = 1;
		else
			Z = 0;
		
		if(tempResult[7] == 1)
			N = 1;
		else
			N = 0;
		end
		
		else	//CMP
		begin
		tempResult = source - destination;
		
		if( tempResult[16] == 1)
		begin
			C = 1;
		end
		else
			C = 0;
		if( source[15] != destination[15] )	
		begin
			if( tempResult[15] == destination[15] )
				V = 1;
		end
		else
			V = 0;
		if( tempResult == 0 )
			Z = 1;
		else
			Z = 0;
		
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		end
		
			
	end
4'b0_011:
	begin 
		$display("BIT");
				
		V = 0;	//V cleared by Default
		tempResult = source & destination;
		if(byteSelect == 1)	//BITB
		begin
			if( tempResult[7] == 1)
				N = 1;
			else
				N = 0;
			if( tempResult[7:0] == 0)
				Z = 1;
			else
				Z = 0;
		end
		else	//BIT
		begin
			if( tempResult[15] == 1)
				N = 1;
			else
				N = 0;
			if( tempResult[15:0] == 0)
				Z = 1;
			else
				Z = 0;
		end
	end
4'b0_100: 
	begin 
		$display("BIC");
					
		V = 0;	//V cleared by Default	
		tempResult = (~source) & destination;	
		
		if( byteSelect == 1)	//BICB
		begin
			if( tempResult[7] == 1)
				N = 1;
			else
				N = 0;
			if( tempResult[7:0] == 0)
				Z = 0;
			else
				Z = 1;
		end
		else
		begin	//BIC
			if( tempResult[15] == 1)
				N = 1;
			else
				N = 0;
			if( tempResult[15:0] == 0)
				Z = 0;
			else
				Z = 1;
		end
		
		if(byteSelect == 1)
		begin
			if(mode2 == 0)
				Register[dstRegister] = tempResult[7:0];	//#####################################################################################################################################################
			else
				put_val( dstEffAddress , tempResult[7:0] , byteSelect);
			//PDP_11_Memory[dstEffAddress] = tempResult[7:0];	//#######################################################################################################################################################
		end	
		else
		begin
			if(mode2 == 0)
				Register[dstRegister] = tempResult[15:0];
			else
			begin
				put_val( dstEffAddress , tempResult[15:0] , byteSelect);
				//PDP_11_Memory[dstEffAddress] = tempResult[7:0];	//#####################################################################################################################################################
				//PDP_11_Memory[dstEffAddress+1] = tempResult[15:7];	//#######################################################################################################################################################
			end
		end
			
		
	end
4'b0_101:
	begin 
		$display("BIS");
		
		
		V = 0;	//V cleared by Default	
		tempResult = source | destination;	
		
		if( byteSelect == 1)	//BISB
		begin
			if( tempResult[7] == 1)
				N = 1;
			else
				N = 0;
			if( tempResult[7:0] == 0)
				Z = 0;
			else
				Z = 1;
		end
		else
		begin	//BIS
			if( tempResult[15] == 1)
				N = 1;
			else
				N = 0;
			if( tempResult[15:0] == 0)
				Z = 0;
			else
				Z = 1;
		end
		
		if(byteSelect == 1)
		begin
			if(mode2 == 0)
				Register[dstRegister] = tempResult[7:0];
			else
				put_val( dstEffAddress , tempResult[7:0] , byteSelect);
			//PDP_11_Memory[dstEffAddress] = tempResult[7:0];//	###############################################################################################################################################################
		end
		else
		begin
			if(mode2 == 0)
				Register[dstRegister] = tempResult[15:0];
			else
			begin
				put_val( dstEffAddress , tempResult[15:0] , byteSelect);
				//PDP_11_Memory[dstEffAddress] = tempResult[7:0];	//##########################################################################################################################################################
				//PDP_11_Memory[dstEffAddress+1] = tempResult[15:7];//	###############################################################################################################################################
			end
		end	
		
	end
4'b0_110:
	begin 
		$display("ADD");
		
		tempResult = source + destination;
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if(tempResult[16] == 1)
			C = 1;
		else
			C = 0;
		if( (source[15] == destination[15]) && (tempResult[15] != destination[15]) )
			V = 1;
		else
			V = 0;
		if(tempResult[15:0] == 0)
			Z = 1;	
		else
			Z = 0;
		destination=tempResult;
		
		if(mode2 == 0)
			Register[dstRegister] = destination;
		else
			put_val( dstEffAddress , destination[15:0] , 1'b0);
			//PDP_11_Memory[dstEffAddress] = destination;	//##################################################################################################################################################################
	
	end
4'b1_110:
	begin 
		$display("SUB");
		

		tempResult = source - destination;
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if(tempResult[16] == 1)
			C = 0;
		else
			C = 1;
		if( (source[15] != destination[15]) && (tempResult[15] == source[15]) )
			V = 1;
		else
			V = 0;
		if(tempResult[15:0] == 0)
			Z = 1;	
		else
			Z = 0;
		destination=tempResult;
		
		if(mode2 == 0)
			Register[dstRegister] = destination;
		else
			put_val( dstEffAddress , destination[15:0] , 1'b0);
			//PDP_11_Memory[dstEffAddress] = destination;
	end 

default:
	begin 
		$display("MIGHT BE NO-OP");
	end
endcase
end

else
begin

	$display("Encountered TRAP, Executing NO-OP");
	end
	
endtask

//single operands
task singleoperands(input logic [15:0]IR);
logic [2:0]dstRegister;
logic [2:0]mode;		
logic signed [15:0]destination;//dstData
logic signed [16:0]tempResult; //Temp variable to hold intermediate values
logic [15:0]address;
T = 0;
mode=IR[5:3];	//srcMode
dstRegister=IR[2:0];	//dstOperand

	if(mode > 0)
		effective_address(dstRegister, mode, dstEffAddress, byteSelect);	
	//Calculate Destination data
		if(byteSelect == 1)
		begin
			if(mode == 0) 
				destination = Register[dstRegister][7:0] ;
			else
				get_val(dstEffAddress, destination, byteSelect);
		end
		else
		begin
			if(mode == 0) 
				destination = Register[dstRegister];
			else
				get_val(dstEffAddress, destination, byteSelect);
		end	

	
if( T != 1 )
begin

case(IR[15:6])
10'b0_000_101_000: 
	begin
		$display("CLR");
//zero flag 
		Z = 1;	V = 0;	C = 0;	N = 0;	
		if(byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister][7:0] = 8'b0000_0000;
				else
					put_val( dstEffAddress , 8'b0 , byteSelect );
					//PDP_11_Memory[dstEffAddress] =8'b0000_0000;	//#########################################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= 16'b0000_0000_0000_0000;
				else
					put_val( dstEffAddress , 16'b0 , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} =16'b0000_0000_0000_0000;	//#############################################################################################################
			end

	end
10'b0_000_101_001:
	begin
		$display("COM");
		//zero flag 
		tempResult[15:0] = ~destination;
		C = 1;	//Set Carry Flag
		V = 0;
		if( byteSelect == 0 )
		begin
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000)
			Z = 1;
		else
			Z = 0;
		end
		else 
		begin
		if( tempResult[7] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[7:0] == 8'b0000_0000)
			Z = 1;
		else
			Z = 0;
		end

		if(byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister][7:0] = tempResult[7:0];
				else
					put_val( dstEffAddress , tempResult[7:0] , byteSelect );
					//PDP_11_Memory[dstEffAddress] =tempResult[7:0];	//#####################################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= tempResult[15:0];
				else
					put_val( dstEffAddress , tempResult[15:0] , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} =tempResult[15:0];	//######################################################################################################################
			end	
		
	end
10'b0_000_101_010:
	begin 
		$display("INC");
		if(destination[15] == 1)
			tempResult[15:0] = destination  + 1;

		if( byteSelect == 0 )
		begin
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000 )
			Z = 1;
		else
			Z = 0;
		if( destination[15:0] == 16'o077777 )
			V = 1;
		else
			V = 0;
		end
		else
		begin
		if( tempResult[7] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[7:0] == 8'b0000_0000 )
			Z = 1;
		else
			Z = 0;
		if( destination[7:0] == 8'o177 )
			V = 1;
		else
			V = 0;
		end
		
		if(byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister][7:0] = tempResult[7:0];
				else
					put_val( dstEffAddress , tempResult[7:0] , byteSelect );
					//PDP_11_Memory[dstEffAddress] =tempResult[7:0];	//#####################################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= tempResult[15:0];
				else
					put_val( dstEffAddress , tempResult[15:0] , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} = tempResult[15:0];//
			end	
	end
10'b0_000_101_011: 
	begin 
		$display("DEC");
		tempResult[15:0] = destination - 1;
		
		if( byteSelect == 0 )
		begin
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000 )
			Z = 1;
		else
			Z = 0;
		if( destination[15:0] == 16'o100000 )
			V = 1;
		else
			V = 0;
		end
		else
		begin
		if( tempResult[7] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[7:0] == 8'b0000_0000 )
			Z = 1;
		else
			Z = 0;
		if( destination[7:0] == 8'b1000_0000 )
			V = 1;
		else
			V = 0;
		end	
			
		if(byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister][7:0] = tempResult[7:0];
				else
					put_val( dstEffAddress , tempResult[7:0] , byteSelect );
					//PDP_11_Memory[dstEffAddress] =tempResult[7:0];	//##################################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= tempResult[15:0];
				else
					put_val( dstEffAddress , tempResult[15:0] , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} = tempResult[15:0];	//######################################################################################################################
			end
	end
10'b0_000_101_100:
	begin 
		$display("NEG");
		
		if( byteSelect == 0 )
	begin
		tempResult[15:0] = ~destination + 1;
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000 )
			Z = 1;
		else
			Z = 0;
	
		if( tempResult[15:0] == 16'o100000 )
			V = 1;
		else
			V = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000 )	
			C = 0;
		else
			C = 1;	
		end
		
		
		else
		begin
		if( tempResult[7] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[7:0] == 8'b0000_0000 )
			Z = 1;
		else
			Z = 0;
		if( tempResult[7:0] == 8'b1000_0000 )
			V = 1;
		else
			V = 0;
		if( tempResult[7:0] == 8'b0000_0000 )	
			C = 0;
		else
			C = 1;	
		end
	
		if( byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister][7:0] = tempResult[7:0];
				else
					put_val( dstEffAddress , tempResult[7:0] , byteSelect );
					//PDP_11_Memory[dstEffAddress] =tempResult[7:0];	//###################################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= tempResult[15:0];
				else
					put_val( dstEffAddress , tempResult[15:0] , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} = tempResult[15:0];//#########################################################################################################################
			end	
		
	end
10'b0_000_101_101:
	begin 
		$display("ADC");
		tempResult[15:0] = destination + C;
		
		if( byteSelect == 0 )	//WORD
		begin
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000 )
			Z = 1;
		else
			Z = 0;
		
		if( destination[15:0] == 16'o077777 && C == 1 )
			V = 1;
		else
			V = 0;
		if( destination[15:0] == 16'o177777 && C == 1 )	
			C = 1;
		else
			C = 0;	
		end
		else	//Byte
		begin
		if( tempResult[7] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[7:0] == 8'b0000_0000 )
			Z = 1;
		else
			Z = 0;
		if( tempResult[7:0] == 8'b0111_1111 && C == 1 )
			V = 1;
		else
			V = 0;
		if( tempResult[7:0] == 8'b1111_1111 && C == 1 )	
			C = 1;
		else
			C = 0;	
		end
		
		if(byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister][7:0] = tempResult[7:0];
				else
					put_val( dstEffAddress , tempResult[7:0] , byteSelect );
					//PDP_11_Memory[dstEffAddress] =tempResult[7:0];//##############################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= tempResult[15:0];
				else
					put_val( dstEffAddress , tempResult[15:0] , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} = tempResult[15:0];//##################################################################################################################
			end	
	end
10'b0_000_101_110:
	begin 
		$display("SBC");
		tempResult[15:0] = destination - C;
		
		if( byteSelect == 0 )	//WORD
		begin
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000 )
			Z = 1;
		else
			Z = 0;
	
		if( destination[15:0] == 16'o100000  )
			V = 1;
		else
			V = 0;
		if( destination[15:0] == 16'o000000 && C == 1 )	
			C = 0;
		else
			C = 1;
		end
		
		else	//BYTE
		begin
		if( tempResult[7] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[7:0] == 8'b0000_0000 )
			Z = 1;
		else
			Z = 0;
		
		if( destination[7:0] == 8'b1000_0000  )
			V = 1;
		else
			V = 0;
		if( destination[7:0] == 8'b0000_0000 && C == 1 )	
			C = 0;
		else
			C = 1;
		end
		
		if(byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister][7:0] = tempResult[7:0];
				else
					put_val( dstEffAddress , tempResult[7:0] , byteSelect );
					//PDP_11_Memory[dstEffAddress] =tempResult[7:0];	//################################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= tempResult[15:0];
				else
					put_val( dstEffAddress , tempResult[15:0] , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} = tempResult[15:0];	//###################################################################################################################
			end	
	end
10'b0_000_101_111:
	begin 
		$display("TST");
		V = 0; C = 0;
		tempResult[15:0] = destination;
		
		if( byteSelect == 0 )	//WORD
		begin
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000 )
			Z = 1;
		else
			Z = 0;
		end
		
		else	//BYTE
		begin
		if( tempResult[7] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[7:0] == 8'b0000_0000 )
			Z = 1;
		else
			Z = 0;
		end
		
		if(byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister][7:0] = tempResult[7:0];
				else
					put_val( dstEffAddress , tempResult[7:0] , byteSelect );
					//PDP_11_Memory[dstEffAddress] =tempResult[7:0];	//#########################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= tempResult[15:0];
				else
					put_val( dstEffAddress , tempResult[15:0] , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} = tempResult[15:0];	//#############################################################################################################
			end	
	end
10'b0_000_110_000:
	begin 
		$display("ROR");
		
						
		if( byteSelect == 0 )	//WORD
		begin
		tempResult[15:0] = { C,destination[15:1] };
		C = destination[0];
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000 )
			Z = 1;
		else
			Z = 0;
		
		V = N ^ C;
		
		end
		
		else	//BYTE
		begin
		tempResult[7:0] = { C,destination[7:1] };
		tempResult[15:8] = { C,destination[15:9] } ;       
		C = destination[0];
		
		if( tempResult[7] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[7:0] == 8'b0000_0000 )
			Z = 1;
		else
			Z = 0;
		
		V = N ^ C;
		end
		
		if(byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister] = tempResult[7:0];
				else
					put_val( dstEffAddress , tempResult[7:0] , byteSelect );
					//PDP_11_Memory[dstEffAddress] = tempResult[7:0];	//##################################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= tempResult[15:0];
				else
					put_val( dstEffAddress , tempResult[15:0] , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} = tempResult[15:0];	//#####################################################################################################################
			end	
	end
10'b0_000_110_001:
	begin 
		$display("ROL");
		
						
		if( byteSelect == 0 )	//WORD
		begin
		tempResult[15:0] = { destination[14:0] , C };
		C = destination[15];
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000 )
			Z = 1;
		else
			Z = 0;
		
		V = N ^ C;
		
		end
		
		else	//BYTE
		begin
		tempResult[7:0] = { destination[6:0] , C };
		tempResult[15:8] = { destination[14:0] , C };
		C = destination[7];
		if( tempResult[7] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[7:0] == 8'b0000_0000 )
			Z = 1;
		else
			Z = 0;
		
		V = N ^ C;
		end
		
		if(byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister] = tempResult[7:0];
				else
					put_val( dstEffAddress , tempResult[7:0] , byteSelect );
					//PDP_11_Memory[dstEffAddress] = tempResult[7:0];	//#################################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= tempResult[15:0];
				else
					put_val( dstEffAddress , tempResult[15:0] , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} = tempResult[15:0];	//####################################################################################################################
			end	
		
	end
10'b0_000_110_010:
	begin 
		$display("ASR");
		
				
		if( byteSelect == 0 )	//WORD
		begin
		tempResult[15:0] = { destination[15],destination[15:1] };
		C = destination[0];
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000 )
			Z = 1;
		else
			Z = 0;
		
		V = N ^ C;
		
		end
		
		else	//BYTE
		begin
		tempResult[7:0] = { destination[7],destination[7:1] };
		tempResult[15:8] = { destination[15],destination[15:9] };
		C = destination[0];
		if( tempResult[7] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[7:0] == 8'b0000_0000 )
			Z = 1;
		else
			Z = 0;
		
		V = N ^ C;
		end
		
		if(byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister] = tempResult[7:0];
				else
					put_val( dstEffAddress , tempResult[7:0] , byteSelect );
					//PDP_11_Memory[dstEffAddress] = tempResult[7:0];	//##################################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= tempResult[15:0];
				else
					put_val( dstEffAddress , tempResult[15:0] , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} = tempResult[15:0];	////#####################################################################################################################
			end	
	end
10'b0_000_110_011:
	begin 
		$display("ASL");
		
		if( byteSelect == 0 )	//WORD
		begin
		tempResult[15:0] = { destination[14:0],1'b0 };
		C = destination[15];
		if( tempResult[15] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[15:0] == 16'b0000_0000_0000_0000 )
			Z = 1;
		else
			Z = 0;
		
		V = N ^ C;
		
		end
		
		else	//BYTE
		begin
		tempResult[7:0] = { destination[6:0],1'b0};
		tempResult[15:8] = { destination[14:8],1'b0 };
		C = destination[7];
		if( tempResult[7] == 1 )
			N = 1;
		else
			N = 0;
		if( tempResult[7:0] == 8'b0000_0000 )
			Z = 1;
		else
			Z = 0;
		
		V = N ^ C;
		end
		
		if(byteSelect == 1)
			begin
				if(mode == 0) 
					Register[dstRegister] = tempResult[7:0];
				else
					put_val( dstEffAddress , tempResult[7:0] , byteSelect );
					//PDP_11_Memory[dstEffAddress] = tempResult[7:0];////##################################################################################################################################################
			end
		else
			begin
				if(mode == 0) 
					Register[dstRegister]= tempResult[15:0];
				else
					put_val( dstEffAddress , tempResult[15:0] , byteSelect );
					//{PDP_11_Memory[dstEffAddress+1],PDP_11_Memory[dstEffAddress]} = tempResult[15:0];	////###########################################################################################################################################
			end	
		
	end
default:
	begin 
		$display("MIGHT BE BYTE IN SINGLE OPERANDS");
	end
endcase

end

else	//TRAP Encountered
begin
	$display("Encountered TRAP in Single Operand Instruction: %o\n",IR[15:0]);
	end

endtask
// subroutinecalls
task subroutinecalls(input logic [15:0]IR);
logic [15:0] address;
T = 0;
effective_address(IR[2:0] , IR[5:3], address, 1'b0);

if( T != 1 )
begin
case(IR[15:9])
7'b0_000_100: 
	begin 
		$display("JSR");
		push(Register[ IR[8:6] ]);
		Register[ IR[8:6] ] = Register[7];
		Register[7] = address;
	end
default:
	begin 
		$display("MIGHT BE SOMEOTHER FORMAT IN SUBROUTINE CALLS");
	end
endcase
end

else	//TRAP Encountered
begin
	$display("Encountered TRAP in Sub-Routine Instruction: %o\n",IR[15:0]);
	end
endtask

//Conditional Branches***************************************************************************************************************************************************************************
task conditionalbranches(input logic [15:0]IR);

offset = IR[7:0];

case(IR[15:6])
10'b0_000_001_000: 
	begin 
		$display("BNE");
		if(Z == 0) begin
			Branch_Taken(offset, Register[7]);
		end
				
	end
10'b0_000_001_100:
	begin
		$display("BEQ");
		if(Z == 1) begin
			Branch_Taken(offset, Register[7]);
		end
	end
10'b0_000_010_000:
	begin 
		$display("BGE");
		if( (N ^ V) == 0 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
10'b0_000_010_100: 
	begin 
		$display("BLT");
		if( (N ^ V) == 1 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
10'b0_000_011_000:
	begin 
		$display("BGT");
		if( (Z | (N ^ V)) == 0 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
10'b0_000_011_100:
	begin 
		$display("BLE");
		if( (Z | (N ^ V)) == 1 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
10'b1_000_001_000:
	begin 
		$display("BHI");
		if( C  == 0 && Z == 0 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
10'b1_000_001_100:
	begin 
		$display("BLOS");
		if( C  == 1 || Z == 1 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
10'b1_000_010_000:
	begin 
		$display("BVC");
		if( V == 0 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
10'b1_000_010_100:
	begin 
		$display("BVS");
		if( V == 1 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
10'b1_000_011_000:
	begin 
		$display("BCC OR BHIS");
		if( C == 0 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
10'b1_000_011_100:
	begin 
		$display("BCS OR BLO");
		if( C == 1 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
default:
	begin 
		$display("MIGHT BE SOMEOTHER INSTRUCTION IN BRANCH");
	end
endcase


endtask

//Special Conditional Branches
task specialconditionalbranches(input logic [15:0]IR);

offset = IR[7:0];

begin
case(IR[15:6])
10'b0_000_000_100: 
	begin 
		$display("BR");
		Branch_Taken(offset, Register[7]);
	end
10'b1_000_000_000:
	begin
		$display("BPL");
		if( N == 0 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
10'b1_000_000_100:
	begin 
		$display("BMI");
		if( N == 1 ) begin
			Branch_Taken(offset, Register[7]);
		end
	end
default:
	begin 
		$display("MIGHT BE SOMEOTHER INSTRUCTION IN SPECIAL CONDITION BRANCHES");
	end
endcase
end


endtask

//subroutine returns
task subroutinereturns(input logic [15:0]IR);

logic signed [15:0] returnvalue;
//$display("%b",IR);

case(IR[15:3])
13'b0_000_000_010_000: 
	begin 
		$display("RTS");
		Register[7] = Register[ IR[2:0] ];
		if(Register[7] == 1)
		 pop(returnvalue);
		 Register[ IR[2:0] ] = returnvalue;
	end
default:
	begin 
		$display("MIGHT BE SOMEOTHER SUB-ROUTINE RETURN INSTRUCTION");
	end
endcase
endtask

//Special single operands
task automatic specialsingleoperands(input logic [15:0]IR);
logic[2:0] destinationMode = IR[5:3];
logic[2:0] destinationOperand = IR[2:0];
logic [15:0] address;
logic [15:0] value;
T = 0;
case(IR[15:6])
10'b0_000_000_001: 
	begin 
		$display("JMP");
		if( IR[5:3] != 3'b000)
		begin
			effective_address(destinationOperand , destinationMode , address , 0);    ////// modified 
			if( T != 1 )
				Register[7] = address;
			else
				$display("Encountered TRAP executing JMP instruction: %o\n",IR[15:0]);
		end
		else
		begin
			$display("ERROR: Register Mode:0 encountered for JMP Instruction.");//*********************************************************************************************
		end
	end
10'b0_000_000_011:
	begin
		
		if( destinationMode == 0 )
		begin
			address = Register[destinationOperand];
			
		end
		else
			effective_address(destinationOperand , destinationMode , address , 0);

		if(address[0] == 1)
				T = 1;
		$display("SWAB");
		if( T != 1 )
			begin
			get_val(address , value, 1'b0);
			value = {value[7:0] , value[15:8]};
			put_val( address , value , 1'b0 );
			end 
			//PDP_11_Memory[address] = { PDP_11_Memory[address] , PDP_11_Memory[address + 1]};	////#########################################################################################################################################
		else
			$display("Encountered TRAP executing  instruction: %o, \n",IR[15:0]);
		
		V = 0;
		C = 0;
		if( PDP_11_Memory[address][7] == 1 )
			N = 1;
		else
			N = 0;
		if( PDP_11_Memory[address][7:0] == 8'b0 )
			Z = 1;
		else
			Z = 0;
		
	
		end
default:
	begin 
		$display("Special SWAB instruction: %o, Executing NO_OP\n",IR[15:0]);
	end
endcase
endtask

//special instructions
task specialinstructions(input logic [15:0]IR);
$display("%b",IR);
case(IR[15:0])
16'b0_000_000_000_000_000: 
	begin 
		$display("HALT");
	end
16'b0_000_000_000_000_001:
	begin
		$display("WAIT");
	end
16'b0_000_000_000_000_010:
	begin 
		$display("RTI");
	end
16'b0_000_000_000_000_100: 
	begin 
		$display("IOT");
	end
16'b0_000_000_000_000_101: 
	begin 
		$display("RESET");
	end
default:
	begin 
		$display("Special instruction: %o, Executing NO_OP\n",IR[15:0]);
	end
endcase
endtask

task effective_address(input logic[2:0]operand,input logic[2:0]mode,output logic[15:0]address,input logic byteselect);
logic signed [15:0] X;
logic signed [15:0] value_at_address;
logic[15:0] tempAddress;
logic signed [15:0]tempReg;
logic signed [15:0] returnValue;
X=16'b0;
tempReg = 0;
case(mode)
3'b001:		//Register	Data = Rn
	begin
	address=Register[operand];
	if( (address[0] == 1 && byteselect == 0) || (Register[7][0] == 1) ) 
	begin	
		T = 1;
		//updatePC( Register[7] , mode );
	end
		
	end
3'b010:	begin		//Autoincrement Data = (Rn) Rn++
	address = Register[operand];
	
	if( (address[0] == 1 && byteselect == 0) || (Register[7][0] == 1) )
	begin
		T = 1;
		
	end
	
	if( T != 1)
	begin
	if(byteselect==1'b1 && operand < 6 )	//Byte op and Not R6 and R7
		begin
			Register[operand]=Register[operand] + 1;
		end
	else
		begin
			if( operand == 6 )
				pop(returnValue);
			else
				Register[operand]=Register[operand] + 2;
		end
	end
	else
		updatePC( Register[7] , mode );
	//$display("operand %b address %d Register[operand] %d PDP_11_Memory[Address]  %o ",operand,address,Register[operand],PDP_11_Memory[address]);
	end
3'b011:		//	Autoincrement Deferred	Data =((Rn)) Rn++
	begin
	get_val(Register[operand],value_at_address,0);
	address=value_at_address;
	if( (address[0] == 1 && byteselect == 0) || (Register[7][0] == 1) )
		T = 1;
	
	if( T != 1 )
	begin
		if( operand == 6 )
			pop(returnValue);
		else
			Register[operand]=Register[operand] + 2;	//The increment/decrement is always 2 bytes for modes 3 and 5, or if the register being used is R6 
	end
	else
		updatePC(Register[7] , mode);
	//$display("operand %b address %d Register[operand] %d ",operand,address,Register[operand]);
	end
	
3'b100:	begin		//Autodecrement	Rn–	Data = (Rn)

	$display("operand %b address %d  %d ",operand,address,Register[operand]);
	
	
	if(byteselect==1'b1)
		begin
			if( operand < 6 )
				tempReg=Register[operand] - 1;	//Byte ops decrement register by 1
			
		end
	else
		begin
			if( operand != 7 )
				tempReg=Register[operand] - 2;	//SP or Word operation always decrements by 2
			
		end
	address = tempReg;
	if( (address[0] == 1 && byteselect == 0) || (Register[7][0] == 1 || operand == 7) )
	begin
		T = 1;
		updatePC( Register[7] , mode );
	end
	else
		Register[operand] = tempReg;	//*****************************************************************************************************************************Check Stack Overflow
	//$display("operand %b address %d  %d ",operand,address,Register[operand]);
	end
3'b101:	begin		//	Autodecrement Deferred	Rn–	Data =((Rn))
	
	if(operand != 7)
	begin
		tempReg=Register[operand] - 2;	//The increment/decrement is always 2 bytes for modes 3 and 5, or if the register being used is R6 
		get_val(tempReg,value_at_address,0);
		address=value_at_address;
	end
	
	if( (address[0] == 1 && byteselect == 0) || (Register[7][0] == 1  || operand == 7) )
	begin
		T = 1;
		updatePC( Register[7] , mode );
	end
	else
	begin
		Register[operand] = tempReg;		//*****************************************************************************************************************************Check Stack Overflow
	end
	end
	
3'b110:	begin		//X(Rn)	Index

	
			//display("PC is  %o  ",Register[7]);
			
			//X = { PDP_11_Memory[Register[7]+1] , PDP_11_Memory[Register[7]] };	//#######################################################################################################################################
			get_val(Register[7] , value_at_address , 1'b0);
			X = value_at_address;
			Register[7] = Register[7] + 2;			//**************************************************************************************************Check for PC overflow
			address = Register[operand] + X;	
			$display("Reg 7 %o X %o Mod 6 Address %o ",Register[7],X, address);
		
	
	if( (address[0] == 1 && byteselect == 0) || (Register[7][0] == 1)  )
	begin
		T = 1;
		updatePC(Register[7] , mode);
	end
	
	end
3'b111:	begin		//@X(Rn)	Index Deferred
$display("PC %d  ",PC);
	//PC=PC+2;
	
	
			

		//X = { PDP_11_Memory[Register[7]+1] , PDP_11_Memory[Register[7]] };	//###########################################################################################################################################
		get_val(Register[7] , value_at_address , 1'b0);
		X = value_at_address;
		Register[7] = Register[7] + 2;		//**************************************************************************************************Check for PC overflow
		address = Register[operand] + X;	
			
		get_val( address , value_at_address , 1'b0 );
		address = value_at_address;
		//address = { PDP_11_Memory[address + 1] , PDP_11_Memory[address] };	##############################################################################################################################################
	
		if( (Register[7][0] == 1) || (address[0] == 1 && byteselect == 0) )
		begin
			T = 1;
			updatePC( Register[7] , mode );
		end			
		
	end	
endcase
endtask

 task get_val(input logic[15:0] address,output logic [15:0] value_at_address, input logic byteselect);
begin

if( byteselect == 0 )
begin
	if( address[0] != 1 )
	begin
		value_at_address = { PDP_11_Memory[address + 1] , PDP_11_Memory[address]};
		$fwrite(traceFile,"0 %o\n",address); 
	end
	else
	begin
		T = 1;	//Set A "boundary error" trap condition will result when attempts to reference instructions or word operands at odd addresses. 
		//value_at_address = 'b0;//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	end
end
else
begin
value_at_address = PDP_11_Memory[address];
$fwrite(traceFile,"0 %o\n",address);
end
$display("value   %b PDP_11_Memory[address] %b at address %b  ",value_at_address,PDP_11_Memory[address],address);

end
endtask

task put_val(input logic[15:0] address,input logic [15:0] value_at_address , input logic ByteSelect );
begin

if( ByteSelect == 0 && address[0] == 1 )
	begin
	T = 1;
	end
 
 else
 begin
 if( ByteSelect == 1 )
	PDP_11_Memory[address] = value_at_address[7:0] ;
 else
	{PDP_11_Memory[address+1],PDP_11_Memory[address]} = value_at_address[15:0];
$fwrite(traceFile,"1 %o\n",address); 	//WRITE ADDRESS
end
 

end
endtask

task Branch_Taken(input logic[7:0] offset,input logic [15:0] PC);
begin
 Register[7] = PC + ( offset << 1);
 
end
endtask


task push(input logic [15:0] inputRegister);
begin
//***********************************************************************************************************Check for Stack Overflow
 Register[6] = Register[6] - 2;
 
 //{ PDP_11_Memory[Register[6] + 1] , PDP_11_Memory[Register[6]] }= inputRegister[15:0];	//############################################################################################################################
	put_val( Register[6] , inputRegister , 1'b0);
 
end
endtask


task pop(output logic [15:0] regValue);
begin
//***********************************************************************************************************Check for Stack Overflow
 //regValue = {PDP_11_Memory[Register[6] + 1] , PDP_11_Memory[Register[6]]};	//###############################################################################################################################################
 //{PDP_11_Memory[Register[6] + 1] , PDP_11_Memory[Register[6]]} = 'b0;	//#####################################################################################################################################################
 get_val(Register[6], regValue , 1'b0);
 put_val(Register[6], 16'b0 , 1'b0);
 
 Register[6] = Register[6] + 2;
 
end
endtask

task updatePC(input logic [15:0]programCounter , input logic [3:0] inputMode);
begin
//***********************************************************************************************************Check for Stack Overflow
if(inputMode == 3'b010)	////Autoincrement Data = (Rn) Rn++
	Register[7] = Register[7] + 2;	//Skip the immediate value pointed by PC
else if (inputMode == 3'b011)	////	Autoincrement Deferred	Data =((Rn)) Rn++
	Register[7] = Register[7] + 2;
//else if (mode == 3'b110)		//	X(Rn)	Index
//	Register[7] = Register[7] + 2;
//else if (mode == 3'b111)		//	//@X(Rn)	Index Deferred
//	Register[7] = Register[7] + 2;
else
	Register[7] = Register[7];
end
endtask

 final 
 begin

 $fclose(condFlagFile);
 $fclose(traceFile);
 end
endmodule

