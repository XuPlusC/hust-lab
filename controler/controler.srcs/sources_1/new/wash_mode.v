`timescale 1ns / 1ps

module wash_mode
#(parameter WIDTH = 32, CLK_CH = 25)
(
    input wash_start, input start, input power, input [31:0]clk, //input wash_control,
    input [2:0]weight,
    output reg wash_end_sign, 
    //light
    output reg water_in_light, output reg washing_light,
    output [2:0]water_level, output reg [31:0]wash_count,
    output reg [1:0]state
    );
    // FIXED ME: there's 3 state, but state and nextState only can hold 1 bit.
    reg [1:0]nextstate;
    wire [31:0]washing_count;
    wire water_in_end_sign, water_out_end_sign, wash_end_sign_mode;
    reg water_in_start, washing_start;
    parameter water_in_state = 0, washing_state = 1, wash_end_state = 2;
    
    initial begin
        state = water_in_state;
        nextstate = water_in_state;
//        water_in_end_sign = 0;
//        spangle_start = 0;
        water_in_light = 1'b0;
        washing_light = 1'b0;
        wash_count = 1'b0;
    end
    
     water_let_mode #(WIDTH, CLK_CH) WATER_IN_MODE (.water_in_end_sign(water_in_end_sign),
                                  .water_in_start(water_in_start),
                                  .water_out_start(1'b0),
                                  .water_out_end_sign(water_out_end_sign),
                                  .clk(clk),
                                  .power(power),
                                  .max_water_level(weight),
                                  .start(start),
                                  .water_level(water_level)
     );
     
     timer #(WIDTH, CLK_CH) TIMER_WASH (.clk_src(clk),
                       .switch_power(power),
                       .switch_en(start),
                       .sum_count({{29{1'b0}}, weight} * 3),
                       .count_start_flag(washing_start),
                       .count_end_flag(wash_end_sign_mode),
                       .count(washing_count)
     );
    
    // FIXED ME: edge detective(posedge) can't be mix up with level detective(power).
    always @(posedge clk[0])
    begin
    if(wash_start & power) state = nextstate;
    else begin
//        wash_end_sign_mode = 0;
        state = water_in_state;
    end
    end
    
    //spangle light
    always @(posedge clk[CLK_CH])
    if(wash_start & power)
    begin
        case(state)
            water_in_state: begin water_in_light = ~water_in_light; end
            washing_state: begin water_in_light = 1'b0; washing_light = ~washing_light; end
            wash_end_state: begin washing_light = 1'b0; end
        endcase
    end
    else begin
        water_in_light = 1'b0; washing_light = 1'b0;
    end
    
    //count time
    always @(posedge clk[0])
    begin
    if(wash_start & power) begin
        case(state)
            water_in_state: begin wash_count = {{29{1'b0}},weight} * 4 - {{29{1'b0}},water_level}; wash_end_sign = 1'b0; end
            washing_state: begin wash_count = washing_count; end
            wash_end_state: begin wash_count = 0; wash_end_sign = 1'b1; end
        endcase
    end
    else begin
        wash_count = 0; wash_end_sign = 1'b0;
    end
    end
    
    always @(state or start or power or wash_start)
    if(wash_start & power) begin
        case(state)
            water_in_state: begin water_in_start = 1'b1; end
            washing_state: begin water_in_start = 1'b0; washing_start = 1'b1; end
            wash_end_state: begin  washing_start = 1'b0; end
        endcase
    end
    else begin
        water_in_start = 1'b0; washing_start = 1'b0;
    end
    
    always @(water_in_end_sign or wash_end_sign_mode or wash_start or power or start)
    if(power & wash_start) begin
    if(start)
    begin
        case(state)
            water_in_state:
                if(water_in_end_sign)
                    nextstate = washing_state;
                else nextstate = water_in_state;
            washing_state:
                if(wash_end_sign_mode)
                    nextstate = wash_end_state;
                else nextstate = washing_state;
            wash_end_state:
                nextstate = wash_end_state;
        endcase
    end
    end else begin
        nextstate = water_in_state;
    end
endmodule
