module ALSU (A, B, opcode, cin, serial_in, direction, red_op_A, red_op_B, bypass_A, bypass_B, clk, rst, out, leds);
input  cin, serial_in, direction, red_op_A, red_op_B, bypass_A, bypass_B, clk, rst;
input  [2:0] A,B,opcode;
output reg [15:0] leds;
output reg [5:0] out;
parameter INPUT_PRIORITY ="A";
parameter FULL_ADDER = "ON";
reg [2: 0] A_FF, B_FF, opcode_FF;
reg cin_FF, serial_in_FF, red_op_A_FF, red_op_B_FF, bypass_A_FF, bypass_B_FF, direction_FF;
wire invalid_opcode ,invalid_red_op_A,invalid_red_op_B , invalid_case;     //invalid cases//
assign invalid_opcode = opcode[2]&opcode[1] ;
assign invalid_red_op_A = red_op_A & (opcode[2]|opcode[1]);
assign invalid_red_op_B = red_op_B & (opcode[2]|opcode[1]);
assign invalid_case = invalid_opcode|invalid_red_op_A|invalid_red_op_B;

always @(posedge clk or posedge rst) begin         //rst or entering inputs //
	if (rst) begin
		A_FF<=0; B_FF<=0; opcode_FF<=0; cin_FF<=0; serial_in_FF<=0; direction_FF<=0; red_op_A_FF<=0; red_op_B_FF<=0;
		bypass_A_FF<=0; bypass_B_FF<=0; 	
	end
	begin
	A_FF<=A; B_FF<=B; opcode_FF<=opcode; serial_in_FF<=serial_in; direction_FF<=direction;
	red_op_A_FF<=red_op_A; red_op_B_FF<=red_op_B; bypass_A_FF<=bypass_A; bypass_B_FF<=bypass_B;	
	end
end

always @(posedge clk or posedge rst) begin    //for leds//
	if (rst) begin
		leds<=0;	
	end
	else if (invalid_case) begin
		leds<=~leds;
	end
end

always @(posedge clk or posedge rst) begin     //for out//
	if (rst||invalid_case) begin
		out<=0;
	end
	
	else begin
	if (bypass_A && bypass_B) begin
		if (INPUT_PRIORITY=="A") begin
		out<=A_FF;
		end
		else begin
		out<=B_FF;
		end
	end
	else if (bypass_A) 
		out<=A_FF;
	else if (bypass_B) 
		out<=B_FF;
	
	end
	begin
		case (opcode_FF)
		0:
		if (red_op_A_FF && red_op_B_FF)
		if (INPUT_PRIORITY=="A") begin
		out <=  &A_FF;
		end
		else
		out <=  &B_FF ;
		else if (red_op_A_FF)
		out <= &A_FF;
		else if (red_op_B_FF)
		out <= &B_FF;
		else
		out <= A_FF & B_FF;

		1:
		if (red_op_A_FF && red_op_B_FF)
		if (INPUT_PRIORITY=="A") begin
		out <=  ^A_FF;
		end
		else
		out <=  ^B_FF ;
		else if (red_op_A_FF)
		out <= ^A_FF;
		else if (red_op_B_FF)
		out <= ^B_FF;
		else
		out <= A_FF ^ B_FF;

		2:
		if (FULL_ADDER == "ON")
		out <= A_FF + B_FF + cin_FF;
		else
		out <= A_FF + B_FF;
		
		
		3:
		out <= A_FF * B_FF;
		
		4:
		if (direction_FF)
		out <= {out[4: 0], serial_in_FF};
		else
		out <= {serial_in_FF, out[5: 1]};

		5:
		if (direction_FF)
		out <= {out[4: 0], out[5]};
		else
		out <= {out[0], out[5: 1]};

		endcase
	end
end
endmodule
