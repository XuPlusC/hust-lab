`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/05/23 21:33:25
// Design Name: 
// Module Name: bcd_to_7segment_decoder
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


module bcd_to_7segment_decoder(input [3:0] x, output [3:0] an, output [6:0] seg);
	assign an = 4'b0001;
	assign  seg[0] = (~x[0] & ~x[1] & x[2]) | (x[0] & ~x[1] & ~x[2] & ~x[3]); // a
	assign  seg[1] = (x[0] ^ x[1]) & x[2]; // b
	assign  seg[2] = ~x[0] & x[1] & ~x[2]; // c
	assign  seg[3] = (~x[0] & ~x[1] & x[2]) | (x[0] & ~x[1] & ~x[2] & ~x[3]) | (x[0] & x[1] & x[2]); // d
	assign  seg[4] = (x[0] ) | (~x[0] & ~x[1] & x[2]); // e
	assign  seg[5] = (x[0] & x[1]) | (x[1] & ~x[2]) | (x[0] & ~x[2] & ~x[3]); // f
	assign  seg[6] = (x[0] & x[1] & x[2]) | (~x[1] & ~x[2] & ~x[3]); // g
endmodule

