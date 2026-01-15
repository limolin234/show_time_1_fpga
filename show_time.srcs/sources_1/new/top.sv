`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/14 14:17:30
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input rst,
    input key,
    output reg[5:0] group,
    output reg[7:0] led
    );

    wire a_tick,b_tick,s_tick,m_tick,h_tick;
    wire[7:0] a_counter,b_counter,s_counter,m_counter,h_counter;
    wire ena;

    scaler#(10_000) u_scaler_10_000(clk,rst,a_tick);
    scaler#(50) u_scaler_20(a_tick,rst,b_tick);
    scaler#(100) u_scaler_100(b_tick,rst,s_tick);
    scaler#(60) u_scaler_60_1(s_tick,rst,m_tick);
    scaler#(60) u_scaler_60_2(m_tick,rst,h_tick);

    counter#(.N(42)) u_couner_a(a_tick,rst,a_counter);
    counter#(.N(100)) u_counter_b(b_tick,rst,b_counter);
    counter#(.N(60)) u_counter_s(s_tick,rst,s_counter);
    counter#(.N(60)) u_counter_m(m_tick,rst,m_counter);
    counter#(.N(24)) u_counter_h(h_tick,rst,h_counter);

    display u_display(a_counter,{h_counter,m_counter,s_counter,b_counter},ena,group,led);

    key_detector#(250) u_key_detector(a_tick,rst,key,ena);
endmodule

module scaler#(
    parameter N = 100
)(
    input clk,
    input rst,
    output reg tick
);
    localparam WIDTH = $clog2(N);
    reg[WIDTH-1:0] count;
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            count <= 0;
            tick <= 1'b1;
        end
        else 
            if(count == N/2-1) begin
                count <= 0;
                tick <= ~tick;
            end 
            else begin
                count <= count + 1;
            end
    end
endmodule

module counter#(
    parameter WIDTH = 8,
    parameter N = 100
)(
    input clk,
    input rst,
    output reg [WIDTH-1:0] cnt
);
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            cnt <= 0;
        end
        else 
            if(cnt == N-1) begin
                cnt <= 0;
            end 
            else begin
                cnt <= cnt + 1;
            end
    end
endmodule

module display(
    input[7:0] counter,
    input[31:0] in,
    input en,
    output reg[5:0] group,
    output reg[7:0] led
);
    wire[23:0] tmp;
    assign tmp = en?in[31:8]:in[23:0];

    reg[3:0] num;
    reg[7:0] byte_tmp;
    wire[3:0] counter_div7,counter_mod7;

    assign counter_div7 = counter / 7;
    assign counter_mod7 = counter % 7;
    always@(*)begin
        case(num)
            4'b0000:byte_tmp = 8'b00_111_111;
            4'b0001:byte_tmp = 8'b00_000_110;
            4'b0010:byte_tmp = 8'b01_011_011;
            4'b0011:byte_tmp = 8'b01_001_111;
            4'b0100:byte_tmp = 8'b01_100_110;
            4'b0101:byte_tmp = 8'b01_101_101;
            4'b0110:byte_tmp = 8'b01_111_101;
            4'b0111:byte_tmp = 8'b00_000_111;
            4'b1000:byte_tmp = 8'b01_111_111;
            4'b1001:byte_tmp = 8'b01_101_111;
            default:byte_tmp = 0;
        endcase
        case(counter_div7)
            0:group = 6'b111_110;
            1:group = 6'b111_101;
            2:group = 6'b111_011;
            3:group = 6'b110_111;
            4:group = 6'b101_111;
            5:group = 6'b011_111;
            default:group = 6'b111_111;
        endcase
        case(counter_div7)
            0:num = tmp[23:16]/10;
            1:num = tmp[23:16]%10;
            2:num = tmp[15:8]/10;
            3:num = tmp[15:8]%10;
            4:num = tmp[7:0]/10;
            5:num = tmp[7:0]%10;
            default:num = 10;
        endcase
        case(counter_mod7)
            0:led = byte_tmp & 8'b00_000_001;
            1:led = byte_tmp & 8'b00_000_010;
            2:led = byte_tmp & 8'b00_000_100;
            3:led = byte_tmp & 8'b00_001_000;
            4:led = byte_tmp & 8'b00_010_000;
            5:led = byte_tmp & 8'b00_100_000;
            6:led = byte_tmp & 8'b01_000_000;
            default:led = 0;
        endcase
    end
endmodule

module key_detector#(
    parameter N = 50
)(
    input clk,
    input rst,
    input key,
    output reg ena
);
    localparam WIDTH = $clog2(N);

    reg[N-1:0] counter;
    reg key_sync,key_sync_1;

    always@(posedge clk)begin
        key_sync <= key;
        key_sync_1 <= key_sync;
    end

    always@(posedge clk)begin
        if(!rst)begin
            counter <= 0;
            ena <= 0;
        end
        else begin
            if(counter == 0)begin
                if(key_sync != key_sync_1 && !key_sync)begin
                    counter <= 1;
                    ena <= ~ena;
                end
            end
            else begin
                if(counter == N + 1)begin
                    counter <= 0;
                end
                else begin
                    counter <= counter + 1;
                end
            end
        end
    end
endmodule