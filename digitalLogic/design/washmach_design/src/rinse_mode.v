`timescale 1ns / 1ps

module rinse_mode
#(parameter WIDTH = 32, CLK_CH = 25, TIME_SCORE = 2)
(
    input rinse_start, input start, input power, input [31:0]clk, input [2:0]weight,
    output reg rinse_end_sign, 
    //light
    output reg water_in_light, output reg rinsing_light,output reg water_out_light,
    output [2:0]water_level, output reg dewatering_light, output reg [31:0]rinse_count,
    output reg [2:0]state
    );
    
    reg [2:0]nextstate;
    reg water_in_start, water_out_start, dewatering_start, rinsing_start; // submodules' start sign
    wire [31:0]dewatering_count, rinsing_count, water_out_count, water_in_count; // count time
    wire [2:0]water_level_rinse; // water level
    wire water_in_end_sign, water_out_end_sign, dewatering_end_sign, rinsing_end_sign; // submodules' start sign
    parameter water_out_state = 0, dewatering_state = 1, water_in_state = 2, rinsing_state = 3, rinse_end_state = 4;
    
    
    initial begin
        state = water_out_state;
        nextstate = water_out_state;
        water_out_light = 1'b0;
        dewatering_light = 1'b0;
        water_in_light = 1'b0;
        rinsing_light = 1'b1; // light on when module start
        water_in_start = 1'b0;
        water_out_start = 1'b0;
        dewatering_start = 1'b0;
        rinsing_start = 1'b0;
    end
        
    assign water_level = (state == rinsing_state) ? weight : water_level_rinse;
         
    // water_let mode run when start sign nd power are both true
    water_let_mode #(WIDTH, CLK_CH, TIME_SCORE) WATER_IN_MODE (.water_in_end_sign(water_in_end_sign),
                                 .water_in_start(water_in_start), // control water out
                                 .water_out_start(water_out_start), // comtrol water in
                                 .water_out_end_sign(water_out_end_sign),
                                 .clk(clk),
                                 .power(power),
                                 .max_water_level(weight),
                                 .start(start),
                                 .water_level(water_level_rinse)
    );
          
    //count dewater time
    timer #(WIDTH, CLK_CH, TIME_SCORE) DEWATERIGN_TIMER (.clk_src(clk),
                             .switch_power(power),
                             .switch_en(start),
                             .sum_count({{29{1'b0}},weight}),
                             .count_start_flag(dewatering_start),
                             .count_end_flag(dewatering_end_sign),
                             .count(dewatering_count)
    );
          
    //count rinse time
    timer #(WIDTH, CLK_CH, TIME_SCORE) RINSING_TIMER (
                            .clk_src(clk),
                            .switch_power(power),
                            .switch_en(start),
                            .sum_count({{29{1'b0}},weight} * 2),
                            .count_start_flag(rinsing_start),
                            .count_end_flag(rinsing_end_sign),
                            .count(rinsing_count)
    );
          
    // change state
    always @(posedge clk[0])
    begin
    if(rinse_start & power & start) state = nextstate;
    else if(!(rinse_start & power)) state = water_out_state;
    end 
   
    // control light
    always @(posedge clk[CLK_CH])
    if(rinse_start & power)
    begin
        case(state)
           water_out_state: begin water_out_light = ~water_out_light; rinsing_light = 1'b1; end
           dewatering_state: begin water_out_light = 1'b0; dewatering_light = ~dewatering_light; end
           water_in_state: begin dewatering_light = 1'b0; water_in_light = ~water_in_light; end
           rinsing_state: begin water_in_light = 1'b0; rinsing_light = ~rinsing_light; end
           rinse_end_state: begin rinsing_light = 1'b0; end
        endcase
    end
    else begin
        water_out_light = 1'b0; dewatering_light = 1'b0; water_in_light = 1'b0; rinsing_light = 1'b1;
    end
        
    //control time and end sign
    always @(posedge clk[0])
    begin
    if(rinse_start & power) begin
        case(state)
            water_out_state: begin rinse_count = {{29{1'b0}},weight} * 4 + {{29{1'b0}},water_level}; rinse_end_sign = 1'b0; end
            dewatering_state: rinse_count = {{29{1'b0}},weight} * 3 + dewatering_count;
            water_in_state: rinse_count = {{29{1'b0}},weight} * 3 - {{29{1'b0}},water_level};
            rinsing_state: rinse_count = rinsing_count;
            rinse_end_state: begin rinse_count = 0; rinse_end_sign = 1'b1; end
        endcase
    end
    else begin
        rinse_count = 0; rinse_end_sign = 1'b0;
    end
    end
   
    // control submodules' start
    always @(state or rinse_start or power or start)
    if(rinse_start & power & start) begin
        case(state)
            water_out_state: begin water_out_start = 1'b1; water_in_start = 1'b0; dewatering_start = 1'b0; rinsing_start = 1'b0; end
            dewatering_state: begin dewatering_start = 1'b1; water_out_start = 1'b0; water_in_start = 1'b0; rinsing_start = 1'b0; end
            water_in_state: begin dewatering_start = 1'b0; water_in_start = 1'b1; water_out_start = 1'b0; rinsing_start = 1'b0; end
            rinsing_state: begin water_in_start = 1'b0; rinsing_start = 1'b1; dewatering_start = 1'b0; water_out_start = 1'b0; end
            rinse_end_state: begin water_in_start = 1'b0; rinsing_start = 1'b0; dewatering_start = 1'b0; water_out_start = 1'b0; end
        endcase
    end
    else if(!(rinse_start & power)) begin
        water_out_start = 1'b0; dewatering_start = 1'b0; water_in_start = 1'b0; rinsing_start = 1'b0;
    end
    
    // change nextstate when sign come
    always @(water_in_end_sign or water_out_end_sign or dewatering_end_sign or rinsing_end_sign or rinse_start or power)
    if(power & rinse_start)
    begin
        case(state)
            water_out_state: begin
                    if(water_out_end_sign)
                        nextstate = dewatering_state;
                    else nextstate = water_out_state;
                end
           dewatering_state: begin 
                    if(dewatering_end_sign)
                        nextstate = water_in_state;
                    else nextstate = dewatering_state;
                end
           water_in_state: begin
                    if(water_in_end_sign) nextstate = rinsing_state;
                    else nextstate = water_in_state;
                end
           rinsing_state: begin
                    if(rinsing_end_sign) nextstate = rinse_end_state;
                    else nextstate = rinsing_state;
                end
           rinse_end_state: begin
                    nextstate = rinse_end_state;
                end
        endcase
    end else nextstate = water_out_state;
endmodule
