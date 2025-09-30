`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2025 02:52:20 PM
// Design Name: 
// Module Name: blinky
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


module blinky(
    input CLK12MHZ,
    output [3:0] led
    );
 
    reg [23:0] count = 0;
    assign led[0] = count[22];
    assign led[3:1] = 3'b000;
    always @ (posedge(CLK12MHZ)) count <= count + 1;
endmodule
