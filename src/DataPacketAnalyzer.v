module DataPacketAnalyzer(
input clk,
input resetn,
input validIn,
input [31:0] dataIn,
input lastIn,
output reg validOut,
output reg [31:0] dataOut,
output reg lastOut
);

// State encoding
localparam IDLE     = 2'b00; //for IDLE State
localparam HEADER   = 2'b01; //for HEADER State
localparam PAYLOAD  = 2'b10; //for PAYLOAD State
localparam FOOTER   = 2'b11; //for Footer State
localparam max_payload_length = 16'h0064; // Defining the Maximum Payload Length


reg [1:0] current_state, next_state;      // Registers for Current State and Next State Logic
reg [15:0] sequence_number;    // Register for Counting the Sequence of Payloads
reg [6:0] payload_counter;    // Counting the Incoming Payload Data
reg [6:0] payload_counter1;   // Will be used for Crafting the Output Packet
reg [31:0] data_buffer [0:max_payload_length-1];

// Output registers
reg [31:0] header_reg;                 // Header Register, will be used to frame the Header
reg [31:0] footer_reg = 32'hFFFFFFFF;  // Footer Register, will be used to frame the Footer
 

// State transition
always @(posedge clk or negedge resetn) begin  
	if(!resetn) begin                           // Defining Asynchronus Reset
		current_state <= IDLE;              // If Reset Occurs then FSM will be come to IDLE State
	end else begin
		current_state <= next_state;        // If Reset is Released then State Transition will start
	end
end
 

// Next state logic
always @(*) begin
	next_state = IDLE;
	case (current_state)
		IDLE: begin                                     // State IDLE Logic
			if(validIn && lastIn) begin             // If Valid Data has started arriving and Last Data has 
				next_state = HEADER;            // arrived, then move to HEADER State
			end else if(validIn && !lastIn) begin   // Otherwise, be in IDLE State
				next_state = IDLE;
			end
		end
 
		HEADER: begin                                   // State Header Logic
		       next_state = PAYLOAD;                    // Move to PAYLOAD State
		end
 
		PAYLOAD: begin                                  // State PAYLOAD
			if(payload_counter != 0) begin          // Be in PAYLOAD State to integrate the captured Payload Data 
				next_state = PAYLOAD;           // in frame for the Output
			end else begin
				next_state = FOOTER;            // If all Payload Data is integrated, then jump to FOOTER 
			end
		end
 
		FOOTER: begin
			next_state = IDLE;                      // If FOOTER is integrated with Frame jump to IDLE State
		end
 
		default: next_state = IDLE;                     // By Default, be in IDLE State 
	endcase
end


// Output logic and payload counter
always @(posedge clk or negedge resetn) begin
	if(!resetn) begin                                       // If Reset is ocuuring 
		validOut <= 1'b0;                               // Reset the validOut Pin
		dataOut <= 32'h00000000;                        // Reset the Output Data
		lastOut <= 1'b0;                                // Reset the lastOut Pin
		payload_counter <= 7'b0000000;                    // Reset the payload_counter
		payload_counter1 <= 7'b0000000;                   // Reset the payload_counter1
		header_reg <= 32'h00000000;                     // Reset the Header Register
		footer_reg <= 32'hFFFFFFFF;                     // Reset the Footer Register to Default Value
		sequence_number <= 16'h0001;
	end else begin
		case (current_state)                            // If Reset is released then Current State Logics
			IDLE:begin                              // If Current State = IDLE
				payload_counter <= 7'b0000001;    // Set the payload_counter to zero
				payload_counter1 <= 7'b0000001;	// Set the payload_counter1 to zero
				validOut <= 1'b0;               // Set the validOut Pin to zero
				dataOut <= 32'h00000000;        // Set the Output Data to zero
				lastOut <= 1'b0;                // Set the lastOut Pin to zero
				if (validIn && !lastIn) begin                       // If Last data has not arrived then keep
				        payload_counter <= payload_counter + 1;     // on icreasing the payload counter to
					data_buffer[payload_counter] <= dataIn;     // count the data and store it temperoary 
				end                                                 // Data Buffer
				else if (validIn && lastIn) begin                   // If Last Data has arrived then count 
					payload_counter <= payload_counter + 1;     // this data also and store it to 
                                        data_buffer[payload_counter] <= dataIn;     // temperoray Data Buffer
				end
				header_reg <= {sequence_number, {9'b0, payload_counter}};
			end
			
			HEADER: begin                                           // If Current State = HEADER   
				dataOut <= header_reg;
				validOut <= 1'b1;                               // Put validOut as 1
				lastOut <= 1'b0;                                // This is not the Last Output Data
			end
			
			PAYLOAD: begin                                                     // If Current State = PAYLOAD
				if (payload_counter != 7'b0) begin                     // If Data Counter is having some
					if(payload_counter1<payload_counter) begin         // set of the data then it'll be
						validOut <= 1'b1;                          // greater than 0. This logic is
						dataOut <= data_buffer[payload_counter1];  // used to print all Input Data
						lastOut <= lastIn;
						payload_counter1 <= payload_counter1 + 7'b0000001;
					end
					else if (payload_counter1==payload_counter) begin  // If all the Data got printed
						payload_counter <= 0;                      // then, Set both the counters to
						payload_counter1 <= 0;   		   // zero value
					end
				end
			end
			
			FOOTER: begin                                             // If Current State = FOOTER
				validOut <= 1'b1;                                 // Set the validOut Pin 
				dataOut <= footer_reg;                            // Put the Footer Value
				lastOut <= 1'b1;                                  // Set the lastOut Pini
				sequence_number <= sequence_number + 16'h0001;
			end
			
			default: begin
				validOut <= 1'b0;                                 // Set the validOut Pin to zero
				dataOut <= 32'h00000000;                          // Set the Output Data to zero
				lastOut <= 1'b0;                                  // Set the lastOut Pin to zero
			end
		endcase
	end
end
endmodule
