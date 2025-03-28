`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/14 05:29:23
// Design Name: 
// Module Name: FrameBuffer_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FrameBuffer_TB(

    );
     // Defines the signal for port A
       reg         A_CLK = 0;
       reg [14:0]  A_ADDR = 15'h0;
       reg         A_DATA_IN = 0;
       reg         A_WE = 0;
       wire        A_DATA_OUT;
       
       // Define signals on port B (read-only port)
       reg         B_CLK = 0;
       reg [14:0]  B_ADDR = 15'h0;
       wire        B_DATA;
       
       // Instantiate the Frame_Buffer of the module under test
       Frame_Buffer uut(
            .clk_A(A_CLK),
            .addr_A(A_ADDR),
            .data_in_A(A_DATA_IN),
            .we_A(A_WE),
            .data_out_A(A_DATA_OUT),
            .clk_B(B_CLK),
            .addr_B(B_ADDR),
            .data_out_B(B_DATA)
       );
       
       // Clock for generating port A: Cycle 10ns (100MHz)
       always #5 A_CLK = ~A_CLK;
       // Clock for generating port B: period 40ns (25MHz)
       always #20 B_CLK = ~B_CLK;
       
       initial begin
           // Initialize all signals
           A_ADDR     = 15'd0;
           A_DATA_IN  = 0;
           A_WE       = 0;
           B_ADDR     = 15'd0;
           
           // Wait a short time 10ns for all signals to stabilize
           #10;
           
           $display("=== Frame_Buffer Testbench Start ===");
           
           // 1. Test the memory initialization content (WE = 0, read the initialized XOR pattern)
           
           $display("\n--- we_A = 0 ---");
           A_WE = 0;  
           
           // Test a few typical addresses
           // Address 0: X = 0, Y = 0, expected (0 XOR 0) = 0
           A_ADDR = 15'd0;
           #10;  // Wait for a rising edge of A_CLK
           $display("Time %0t: A_ADDR = %d, A_DATA_OUT = %b (expect 0)", $time, A_ADDR, A_DATA_OUT);
           
           // Address 1: X = 1, Y = 0, expected (1 XOR 0) = 1
           A_ADDR = 15'd1;
           #10;
           $display("Time %0t: A_ADDR = %d, A_DATA_OUT = %b (expect 1)", $time, A_ADDR, A_DATA_OUT);
           
           // Address 256: X = 0, Y = 1, expected (0 XOR 1) = 1
           A_ADDR = 15'd256;
           #10;
           $display("Time %0t: A_ADDR = %d, A_DATA_OUT = %b (expect 1)", $time, A_ADDR, A_DATA_OUT);
           
           // Address 257: X = 1, Y = 1, expected (1 XOR 1) = 0
           A_ADDR = 15'd257;
           #10;
           $display("Time %0t: A_ADDR = %d, A_DATA_OUT = %b (expect 0)", $time, A_ADDR, A_DATA_OUT);
           
            // Also test read-only port B
           $display("\n--- Test the initial read of Port B ---");
           B_ADDR = 15'd0;
           #40;  // Wait for a complete B_CLK cycle
           //Since Port B is updated at the rising edge of B_CLK, 
           //if sampled immediately after the B_ADDR switch and not at the rising edge, 
           //the data may not have been updated.
           $display("Time %0t: B_ADDR = %d, B_DATA = %b (expect 0)", $time, B_ADDR, B_DATA);
           
           B_ADDR = 15'd1;
           #40;  // Wait for a complete B_CLK cycle
           $display("Time %0t: B_ADDR = %d, B_DATA = %b (expect 1)", $time, B_ADDR, B_DATA);
           
           // 2. Test write operation (WE = 1)
           $display("\n--- we_A = 1 ---");
           A_WE = 1;  
                   
            // Write operation 1:    Write 1 to address 15
            A_ADDR     = 15'd15;
            A_DATA_IN  = 1;
            @(posedge A_CLK);  // Wait for the rising edge of the clock to complete the writing
            @(posedge A_CLK);  // Wait an extra cycle to ensure data is updated
            $display("Time %0t: Write 1 to A_ADDR = %d, A_DATA_OUT = %b", $time, A_ADDR, A_DATA_OUT);
                   
            // Write operation 2: Write 0 at the same address (overwrite operation 1)
             A_ADDR     = 15'd15;
             A_DATA_IN  = 0;
             @(posedge A_CLK);  // 
             @(posedge A_CLK);  // 
             $display("Time %0t: Write 0 to A_ADDR = %d, A_DATA_OUT = %b", $time, A_ADDR, A_DATA_OUT);
                   
              // Write operation 3£ºWrite 1 to address 5000
              A_ADDR     = 15'd5000;
              A_DATA_IN  = 1;
              @(posedge A_CLK);  
              @(posedge A_CLK);  
              $display("Time %0t: Write 1 to A_ADDR = %d, A_DATA_OUT = %b", $time, A_ADDR, A_DATA_OUT);
              
              $display("\n=== Testbench End ===");
                     #100;
                     $stop;
                 end
    
    
    
    
endmodule
