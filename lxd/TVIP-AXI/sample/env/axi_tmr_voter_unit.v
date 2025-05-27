module axi_tmr_voter_unit(
    input  wire  d0,
    input  wire  d1,
    input  wire  d2,
    output wire  d_out,
    output wire  err_flag,
    output wire  err_d0,
    output wire  err_d1,
    output wire  err_d2
);
    wire cmp_d0_d1;
    wire cmp_d1_d2;
    wire cmp_d2_d0;
    reg  d_select;
    reg [2:0] err_d_reg;

    assign cmp_d0_d1 = (d0 == d1);
    assign cmp_d1_d2 = (d1 == d2);
    assign cmp_d2_d0 = (d2 == d0);
    assign err_flag = ~cmp_d0_d1 | ~cmp_d1_d2 | ~cmp_d2_d0;
    assign d_out = d_select;
    assign {err_d2, err_d1, err_d0} = err_d_reg;

    always @(*) begin
        if(err_flag) begin
            if (cmp_d0_d1) begin//d2 wrong
                d_select = d0;
                err_d_reg = 3'b100;
            end else if (cmp_d1_d2) begin//d0 wrong
                d_select = d1;
                err_d_reg = 3'b001;
            end else if (cmp_d2_d0) begin//d1 wrong
                d_select = d2;
                err_d_reg = 3'b010;
            end else begin
                d_select = 1'bx; 
                err_d_reg = 3'b111;
            end
        end else begin
            d_select = d0; 
            err_d_reg = 3'b000;
        end
    end

endmodule