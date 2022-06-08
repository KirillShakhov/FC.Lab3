
module ex_vadd8(
    input [31:0] a_bi,
    input [31:0] b_bi,
    output wire [31:0] out
    );

    assign out = { a_bi[31:28]+b_bi[31:28],
    a_bi[27:24]+b_bi[27:24],
    a_bi[23:20]+b_bi[23:20],
    a_bi[19:16]+b_bi[19:16],
    a_bi[15:12]+b_bi[15:12],
    a_bi[11:8]+b_bi[11:8],
    a_bi[7:4]+b_bi[7:4],
    a_bi[3:0]+b_bi[3:0]
                };
endmodule
