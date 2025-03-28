`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/14 08:13:34
// Design Name: 
// Module Name: SigGen_TB
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


module SigGen_TB(

    );
        // Defining Signals
    reg CLK = 0;                 
    reg RESET = 1;                
    reg [15:0] CONFIG_COLOURS = 16'hE003;  // Foreground = Red (E0), Background = Blue (03)
    reg VGA_DATA = 0;             

    wire DPR_CLK;                  
    wire [14:0] VGA_ADDR;          
    wire VGA_HS, VGA_VS;           
    wire [7:0] VGA_COLOUR;         

    // Instantiate VGA_Sig_Gen
    VGA_Sig_Gen uut (
        .CLK(CLK),
        .RESET(RESET),
        .CONFIG_COLOURS(CONFIG_COLOURS),
        .DPR_CLK(DPR_CLK),
        .VGA_ADDR(VGA_ADDR),
        .VGA_DATA(VGA_DATA),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_COLOUR(VGA_COLOUR)
    );

    // Generate 100MHz clock
    always #5 CLK = ~CLK;  // 100MHz clock, period 10ns10ns

    
    initial begin
        $display("\n=== VGA_Sig_Gen Testbench Start ===");

        // Reset test
        #500;  
        RESET = 0;  
        #1000;
        $display("Time %0t: Reset complete, VGA_HS = %b, VGA_VS = %b (expect: 0, 0)", $time, VGA_HS, VGA_VS);

        // VGA_COLOUR must be black during RESET test
        #1000000;  
        $display("Time %0t: Reset period£¬VGA_COLOUR = %h (expect: 00)", $time, VGA_COLOUR);

        // Color switching test
        VGA_DATA = 0; CONFIG_COLOURS = 16'h03E0;  // Background = blue, foreground = red
        #500;
        $display("Time %0t: VGA_DATA = 0, CONFIG_COLOURS = 03E0, VGA_COLOUR = %h (expect: E0)", $time, VGA_COLOUR);

        VGA_DATA = 1; CONFIG_COLOURS = 16'hE003;  // Background = red, foreground = blue
        #500;
        $display("Time %0t: VGA_DATA = 1, CONFIG_COLOURS = E003, VGA_COLOUR = %h (expect: 03)", $time, VGA_COLOUR);

        // VGA address increment test
        #5000;
        $display("Time %0t: VGA_ADDR = %d (expect: Increase )", $time, VGA_ADDR);

        // VGA_HS
        #10000;
        $display("Time %0t: VGA_HS = %b ", $time, VGA_HS);

        // VGA_VS
        #20000;
        $display("Time %0t: VGA_VS = %b ", $time, VGA_VS);

       
        $display("\n=== VGA_Sig_Gen Testbench END ===");
        $stop;
    end

        
endmodule
