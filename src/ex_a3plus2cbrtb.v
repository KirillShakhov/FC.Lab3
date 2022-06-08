
module ex_a3plus2cbrtb(
    input clk_i,
    input start_i,
    input [31:0] a_bi,
    input [31:0] b_bi,
    output reg busy_o,
    output wire [31:0] out
    );
    
    reg mult_start;
    wire mult_busy;
    reg [31:0] mult_in;
    wire [31:0] mult_out;
    wire        rst_i;
    
    assign rst_i = !start_i;

    mult mult_calc( 
    .clk_i(clk_i), .rst_i(rst_i), .start_i(mult_start), 
    .a_bi(mult_in), .b_bi(32'h3), .busy_o(mult_busy), .y_bo(mult_out)
    );
    
    reg cbrt_start;
    wire cbrt_busy;
    reg [31:0] cbrt_in;
    wire [31:0] cbrt_out;
    
    cbrt cbrt_calc( 
    .clk_i(clk_i), .rst_i(rst_i), .start_i(cbrt_start), 
    .x_bi(cbrt_in), .busy_o(cbrt_busy), .out(cbrt_out)
    );
    
    reg [31:0] adder_a, adder_b;

    adder adder_calc(.a(adder_a), .b(adder_b), .y(out));
    
    localparam IDLE = 2'h0;
    localparam WORK = 2'h1;
    localparam WAIT = 2'h2;
    
    reg [1:0] state;
    
    // assign busy_o = state > 0;
    
    always @(posedge clk_i or start_i)
        if (start_i) begin
            case (state)
                IDLE:
                    begin
                        if (start_i) begin
                            mult_start <= 0; 
                            cbrt_start <= 0;
                            state <= WORK;
                            busy_o = 1;
                        end
                    end
                WORK:
                    begin
                        mult_start <= 1; 
                        cbrt_start <= 1;
                        mult_in <= a_bi;
                        cbrt_in <= b_bi;
                        state <= WAIT;
                    end
                WAIT:
                    begin
                        mult_start <= 0; 
                        cbrt_start <= 0;
                        if (!(cbrt_busy || mult_busy)) begin
                            adder_a <= cbrt_out << 1;
                            adder_b <= mult_out;
                            state <= IDLE;
                            busy_o = 0;
                        end
                    end
            endcase
        end else begin
            busy_o = 0;
            adder_a <= 0;
            adder_b <= 0;
            mult_start <= 0; 
            cbrt_start <= 0;
            state <= IDLE;
        end
endmodule


module cbrt(
    input clk_i,
    input rst_i,
    input start_i,
    input [31:0] x_bi,
    output wire busy_o,
    output reg [31:0] out
);

localparam IDLE = 2'h0;
localparam WORK = 2'h1;
localparam WORK_IN_WORK = 2'h2;
localparam WAIT_MULT = 2'h3;

reg [31:0] res;
reg [1:0]state;
reg [7:0] m;
reg [7:0] i;
reg [31:0]x_b;
reg [31:0] a;
reg [31:0] b;

 
wire multi_busy;
wire [31:0] mult_out_res;
reg start_mult;
 
 
assign busy_o = state > 0;


mult b_square_calc( 
    .clk_i(clk_i), .rst_i(rst_i), .start_i(start_mult), 
    .a_bi(a), .b_bi(b), .busy_o(multi_busy), .y_bo(mult_out_res)
);


always @(posedge clk_i)
    if (rst_i) begin
        m <= 1;
        res <= 1;
        state <= IDLE;
        out <= 0;
        start_mult <= 1'b0;
    end else begin
        case (state)
            IDLE:
                begin
                start_mult <= 1'b0;
                if (start_i) begin
                    if (x_bi == 0) begin
                        out <= 0;
                    end
                    else if (x_bi == 1) begin
                       out <= 1;
                    end
                    else begin 
                        state <= WORK;
                        x_b <= x_bi;
                        m <= 1;
                        res <= 1;
                    end
                end
                end
            WORK:
                if (res > x_b) 
                begin
                    state <= IDLE;
                    out <= m - 2;
                end 
                else if (res == x_b)
                begin
                    state <= IDLE;
                    out <= m - 1;
                end
                else begin
                    state <= WORK_IN_WORK;
                    res <= m;
                    i <= 1;
                end
            WORK_IN_WORK:
                begin
                    if (i == 3) begin
                        m <= m + 1;
                        state <= WORK; 
                    end else begin
                        state <= WAIT_MULT;
                        start_mult <= 1'b1;
                        a <= m;
                        b <= res;
                        i <= i + 1;
                    end 
                end
            WAIT_MULT:
            begin
               start_mult <= 1'b0;
               if (!multi_busy) begin
                    state <= WORK_IN_WORK;               
                    res <= mult_out_res;
                end
                
            end

        endcase
    end
endmodule


module mult(
    input clk_i,
    input rst_i,
    input start_i,
    input [31:0] a_bi,
    input [31:0] b_bi,
    output wire busy_o,
    output reg [31:0] y_bo
);

localparam IDLE =      1'b0;
localparam WORK =      1'b1;

reg [31:0] a;
reg [31:0] b;
reg [2:0] ctr;
wire [2:0] end_step;
wire [7:0] part_sum;
wire [31:0] shifted_part_sum;
reg [31:0] part_res;

reg state;

assign part_sum = a&{8{b[ctr]}};
assign shifted_part_sum = part_sum << ctr;
assign end_step = (ctr == 3'h7);
assign busy_o = state | start_i;

always @(posedge clk_i)
    if (rst_i) begin
        ctr <= 0;
        part_res <= 0;
        y_bo <= 0;
        state <= IDLE;
    end else begin
        case (state)
            IDLE:
                if (start_i) begin
                    a = a_bi;
                    b = b_bi;
                    ctr = 0;
                    part_res = 0;
                    state = WORK;
                end
            WORK:
                begin
                    if (end_step) begin
                        state <= IDLE;
                        y_bo <= part_res;
                    end
                    part_res <= part_res + shifted_part_sum;
                    ctr <= ctr + 1;
                end
        endcase
    end
endmodule

module adder( 
    input [31:0] a,
    input [31:0] b,
    output [31:0] y
    );

    assign y = a + b;
endmodule

