`timescale 1ns / 1ps

// @input
// clk_src: clock source
// power: electronic power
// switch_en: pause switch
// sig_up_time: add value of time
// sig_reset: reset pulse
// @output
// count: current count time
// sig_start: signal implicits arriving at 0
// sig_end: signal implicits arriving at RANGE
module timer
#(parameter WIDTH = 32, CLK_CH = 25)
(   input [31:0]clk_src,
    input switch_power,
    input switch_en,
    input [(WIDTH-1):0]sum_count,
    input count_start_flag,
    output reg count_end_flag,
    output reg [(WIDTH-1):0] count
);
    reg init_flag;
    wire real_clk;
    reg [(WIDTH-1):0]reverse_count;
    initial begin
        count_end_flag <= 0;
        init_flag <= 1;
        reverse_count <= 0;
        count  <= 0;
    end
    //information: count has a second delay
    assign real_clk = (switch_power & count_start_flag & !init_flag) ? clk_src[CLK_CH] : clk_src[0];
    always @(posedge real_clk) begin
        if (switch_power & count_start_flag) begin
            if(init_flag) begin reverse_count = 0; count = sum_count; init_flag = 0; end
            else if (switch_en) begin
                if (sum_count >= reverse_count) begin
                    count = sum_count - reverse_count;
                    reverse_count = reverse_count + 1;
                end else begin
                    count_end_flag = 1;
                end
            end
        end else begin
            count_end_flag <= 0;
            reverse_count <= 0;
            count <= 0;
            init_flag <= 1;
        end
    end
endmodule