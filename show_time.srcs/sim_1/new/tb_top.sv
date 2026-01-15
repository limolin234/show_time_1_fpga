`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/14 22:45:47
// Design Name: 
// Module Name: tb_top
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


module tb_top(

    );
    reg clk;
    reg rst;
    reg key;
    wire[5:0] group;
    wire[7:0] led;
    top uut(clk,rst,key,group,led);

    initial begin 
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 0;
        key = 1;
        #10
        rst = 1;
        #100000
        key = 0;

    end

endmodule
