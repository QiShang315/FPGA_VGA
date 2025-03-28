`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/14 08:42:09
// Design Name: 
// Module Name: VGATOP_TB
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


module VGATOP_TB(

    );
    // Signal definition
        reg CLK = 0;             
        reg RESET = 1;           
        wire VGA_HS, VGA_VS;     
        wire [2:0] VGA_RED, VGA_GREEN;  
        wire [1:0] VGA_BLUE;     
    
        // Instantiate VGA_TOP
        VGA_TOP uut (
            .CLK_100MHz(CLK), 
            .RESET(RESET), 
            .VGA_HS(VGA_HS), 
            .VGA_VS(VGA_VS), 
            .VGA_RED(VGA_RED), 
            .VGA_GREEN(VGA_GREEN), 
            .VGA_BLUE(VGA_BLUE)
        );
    
        // Generate a 100MHz clock
        always #5 CLK = ~CLK;  // 100MHz clock (cycle 10ns)
    
        
        initial begin
            $display("\n=== VGA_TOP Testbench Start ===");
            $monitor("Time=%0t | VGA_HS=%b | VGA_VS=%b | VGA_COLOUR={%b, %b, %b}", 
                     $time, VGA_HS, VGA_VS, VGA_RED, VGA_GREEN, VGA_BLUE);
    
            // RESET test
            #1000; // 1μs, observe the output when RESET = 1 (all black)
            RESET = 0; 
            #50000;   // Wait 50μs to ensure system stability
    
            // **2?? 检查 VGA_HS 和 VGA_VS 是否正确变化**
            #10000;
            $display("Time %0t: VGA_HS = %b, VGA_VS = %b (Should change periodically)", $time, VGA_HS, VGA_VS);
    
            // **3?? 测试颜色切换**
            #1000000;
            $display("Time %0t: Observe VGA color changes and check for red/blue alternations", $time);
 
    
            $display("\n=== VGA_TOP Testbench END ===");
            $stop;  
        end
endmodule
