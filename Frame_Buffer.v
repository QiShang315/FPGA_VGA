`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/05 15:59:43
// Design Name: 
// Module Name: Frame_Buffer
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

// Frame_Buffer Dual-port memory that allows the CPU/FPGA to write pixels while VGA reads them
module Frame_Buffer(
// Port A - Read/Write 
    input  wire         clk_A,            // Write clock 
    input  wire [14:0]  addr_A,           // 15-bit address (8 bits X + 7 bits Y, 8+7=15) 
    input  wire         data_in_A,        // Pixel Data In 1-bit pixel value written (0 = background color, 1 = foreground color)
    input  wire         we_A,             // Write Enable (1 = write data, 0 = read only) 
    output reg          data_out_A,       // Pixel Data Out 

    // Port B - Read Only connect VGA_Sig_Gen moulde
    input wire         clk_B,             // Read clock 
    input wire [14:0]  addr_B,           // Pixel read address
    output reg         data_out_B        // Pixel Data Out for VGA, Pixel data read by the VGA port
);

    // Memory definition (256¡Á128 1-bit storage)  
    // A 256 x 128 1-bit memory to hold frame data
    reg  Total_Pixels [0:32767]; // 256*128 = 32768, 1-bit per pixel, total 32768 pixels
    
     // Define GRID_SIZE as a global parameter
    parameter GRID_SIZE = 0;   // It determines which bit of X and Y is used when XOR is calculated.
       
    integer i;                 // Loop index variable
    reg [7:0] X;              // 8-bit X coordinate
    reg [6:0] Y;              // 7-bit Y coordinate
    initial begin
        for (i = 0; i < 32768; i = i + 1) begin
            
            X = i[7:0];     // Lower 8 bits represent the X coordinate, its value ranges from 0 to 255
            Y = i[14:8];    // Upper 7 bits represent the Y coordinate, its value ranges from 0 to 127
            Total_Pixels[i] = (X[GRID_SIZE] ^ Y[GRID_SIZE]); // XOR
        end
    end
    
    // Port A: Read/write access (write data) 
    always @(posedge clk_A) begin               // Execute at the rising edge of A_CLK 
        if (we_A) begin                        // If we_A = 1, data is written 
            Total_Pixels[addr_A] <= data_in_A;  // Write data_in_A into Total_Pixels at address addr_A (external write)
        end
        data_out_A <= Total_Pixels[addr_A];    // Read from Total_Pixels at addr_A and output to data_out_A
    end

    //  Read-only access (for VGA_Sig_Gen reading)
    always @(posedge clk_B) begin             // Execute at the rising edge of clk_B
        data_out_B <= Total_Pixels[addr_B];  // Read from Total_Pixels at addr_B and output to data_out_B (for VGA_Sig_Gen)
    end
    
endmodule
