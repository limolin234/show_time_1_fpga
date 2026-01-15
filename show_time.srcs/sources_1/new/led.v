`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/13 21:46:30
// Design Name: 
// Module Name: led
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


module led(
    input clk,
    input rst,
    output reg[3:0] led
    );
    reg[31:0] cnt;
    reg[1:0] state;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt <= 32'b0;
            state <= 2'b0;
        end
        else begin
            if (cnt == 32'd50_000_000-1) begin
                cnt <= 32'b0;
                state <= state + 1;
            end
            else begin
                cnt<=cnt+1;
            end
        end
    end
    
    always @(*)begin
        case (state)
            2'b00: led = ~4'b0001;
            2'b01: led = ~4'b0010;
            2'b10: led = ~4'b0100;
            2'b11: led = ~4'b1000;
            default:led = ~4'b1111;
        endcase         
    end



endmodule
