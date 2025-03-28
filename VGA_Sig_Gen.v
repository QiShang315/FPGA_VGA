`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/07 14:42:49
// Design Name: 
// Module Name: VGA_Sig_Gen
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


module VGA_Sig_Gen(
    input wire           CLK,                     // Default 100MHz clock
    input wire           RESET,                  // Reset signal
    input wire [15:0]    CONFIG_COLOURS,         // Colour configuration (foreground/background)

    // Frame Buffer (Dual Port memory) Interface
    output wire           DPR_CLK,                // 25MHz clock
    output wire [14:0]    VGA_ADDR,              // Frame buffer address (for 256x128 resolution)
    input  wire           VGA_DATA,              //  1-bit pixel data output from the frame buffer

    // VGA Output Interface
    output reg            VGA_HS,                  // Horizontal sync signal
    output reg            VGA_VS,                  // Vertical sync signal
    output wire [7:0]      VGA_COLOUR             // VGA colour output (8-bit)
    );
    // Generate 25MHz VGA clock (using a divide-by-4 scheme)
    reg [0:0] counter = 0;             // 1-bit counter, counting 0 and 1 only
    reg CLK_25MHz = 0;                 // 25MHz clock signal
    
    always @(posedge CLK) begin
        if (counter == 1) begin          // When counter reaches 1 (i.e., every 2 cycles)
            CLK_25MHz <= ~CLK_25MHz;    // Toggle the 25MHz clock signal
            counter <= 0;              // Reset counter
        end else begin
            counter <= counter + 1;    // Otherwise, increment counter
        end
    end
    
    assign DPR_CLK = CLK_25MHz;        // Assign the 25MHz clock output for use by other modules
           
      //  VGA 640x480 timing parameters
           parameter HTs = 800;      // Total horizontal time: 800 clock cycles
           parameter HTpw = 96;      // Horizontal sync pulse width: 96 cycles
           parameter HTDisp = 640;  // Horizontal display area: 640 cycles
           parameter Hbp = 48;      // Horizontal back porch: 48 cycles
           parameter Hfp = 16;     // Horizontal front porch: 16 cycles
       
           parameter VTs = 521;     // Total vertical time: 521 lines
           parameter VTpw = 2;      // Vertical sync pulse width: 2 lines
           parameter VTDisp = 480;  // Vertical display area: 480 lines
           parameter Vbp = 29;     //  Vertical back porch: 29 lines
           parameter Vfp = 10;     // Vertical front porch: 10 lines
       
           // Horizontal and Vertical scan counters
           reg [9:0] X_count = 0;    //1024 > 800
           reg [9:0] Y_count = 0;    //1024 > 521
           
            // VGA Sequential control
           always @(posedge DPR_CLK) begin     //Update X_count and Y_count at each rising edge of DPR_CLK (25MHz)
               if (RESET) begin
               // When RESET is active, set both sync signals to 0 and reset counters
               // VGA signal is invalid and the screen will not display images
                       VGA_HS <= 0;
                       VGA_VS <= 0;
                       X_count <= 0;
                       Y_count <= 0;
               end else begin
                  if (X_count < HTs - 1)          // If X_count < HTs-1 , X_count is incremented.
                      X_count <= X_count + 1;
                  else begin                     // If X_count reaches HTs-1, the scanning line is complete and X_count is reset
                      X_count <= 0;
                    if (Y_count < VTs - 1)
                        Y_count <= Y_count + 1;   // Also go to the next line (Y_count +1)
                   else
                        Y_count <= 0;            //If Y_count reaches VTs-1 (that is, the last line of a frame)
                                                 // Then Y_count is reset and a new frame scan is started again.
                  end
                
                   VGA_HS <= (X_count >= (HTpw)) && (X_count < (HTs)); // When X_count between [HTpw, HTs],VGA_HS = 1
                                                                      // otherwise, VGA_HS = 0
                         
                   VGA_VS <= (Y_count >= (VTpw)) && (Y_count < (VTs));// When Y_count between [VTpw, VTs],VGA_VS = 1
                                                                      // otherwise, VGA_VS = 0
              end
           end
           
// Key part: calculate the frame buffer address (for a 256x128 resolution)
         wire [7:0] X_frame = X_count[9:2];  // 640 ¡ú 256,  8 bits
                                             // Convert X coordinate from 640 to 256 pixels by dividing by 4 (taking bits [9:2])
         wire [6:0] Y_frame = Y_count[8:2];  // 480 ¡ú 128,  7 bits
                                            // Convert Y coordinate from 480 to 128 pixels by dividing by 4 (taking bits [8:2])
         
        assign VGA_ADDR = {Y_frame, X_frame}; // Concatenate Y_frame and X_frame to form a 15-bit frame buffer address
        


         assign VGA_COLOUR = ((X_count >= (HTpw + Hbp)) && (X_count < (HTDisp + HTpw + Hbp)) &&
                     (Y_count >= (VTpw + Vbp)) && (Y_count < (VTDisp + VTpw + Vbp))) ?
                     ((VGA_DATA) ? CONFIG_COLOURS[15:8] : CONFIG_COLOURS[7:0]) :
                     8'h00; 
 // When the current pixel is within the display region, X and Y all display
 //If VGA_DATA == 1, select the foreground  colour CONFIG_COLOURS[15:8] as VGA_COLOUR output.
 //If VGA_DATA == 0, select the background  colour CONFIG_COLOURS[7:0] as VGA_COLOUR output.
//VGA_DATA from Frame_Buffer data_out_B
//If the current pixel exceeds the valid display area, black is displayed
          
endmodule