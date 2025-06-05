/*
ecc size: data 64bits + parity 7bits = 71 bits
module 1 : ecc_d64b_p7_enc;
module 2 : ecc_d64b_p7_dec;
reference: ecc.xlsx
*/
`timescale 1ns/1ns

module ecc_d64b_p7_enc (
    input [63:0] data_in,
    output [6:0] parity_out
    // output [70:0] ecc_out
);
    wire [64:1] d;
    assign d[64:1] = data_in[63:0];

    //p1..p7 
    assign parity_out[0] = d[1]^d[2]^d[4]^d[5]^d[7]^d[9]^d[11]^d[12]^d[14]^d[16]^d[18]^d[20]^d[22]^d[24]^d[26]^d[27]^d[29]^d[31]^d[33]^d[35]^d[37]^d[39]^d[41]^d[43]^d[45]^d[47]^d[49]^d[51]^d[53]^d[55]^d[57]^d[58]^d[60]^d[62]^d[64];
    assign parity_out[1] = d[1]^d[3]^d[4]^d[6]^d[7]^d[10]^d[11]^d[13]^d[14]^d[17]^d[18]^d[21]^d[22]^d[25]^d[26]^d[28]^d[29]^d[32]^d[33]^d[36]^d[37]^d[40]^d[41]^d[44]^d[45]^d[48]^d[49]^d[52]^d[53]^d[56]^d[57]^d[59]^d[60]^d[63]^d[64];
    assign parity_out[2] = d[2]^d[3]^d[4]^d[8]^d[9]^d[10]^d[11]^d[15]^d[16]^d[17]^d[18]^d[23]^d[24]^d[25]^d[26]^d[30]^d[31]^d[32]^d[33]^d[38]^d[39]^d[40]^d[41]^d[46]^d[47]^d[48]^d[49]^d[54]^d[55]^d[56]^d[57]^d[61]^d[62]^d[63]^d[64];   
    assign parity_out[3] = d[5]^d[6]^d[7]^d[8]^d[9]^d[10]^d[11]^d[19]^d[20]^d[21]^d[22]^d[23]^d[24]^d[25]^d[26]^d[34]^d[35]^d[36]^d[37]^d[38]^d[39]^d[40]^d[41]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
    assign parity_out[4] = d[12]^d[13]^d[14]^d[15]^d[16]^d[17]^d[18]^d[19]^d[20]^d[21]^d[22]^d[23]^d[24]^d[25]^d[26]^d[42]^d[43]^d[44]^d[45]^d[46]^d[47]^d[48]^d[49]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
    assign parity_out[5] = d[27]^d[28]^d[29]^d[30]^d[31]^d[32]^d[33]^d[34]^d[35]^d[36]^d[37]^d[38]^d[39]^d[40]^d[41]^d[42]^d[43]^d[44]^d[45]^d[46]^d[47]^d[48]^d[49]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
    assign parity_out[6] = d[58]^d[59]^d[60]^d[61]^d[62]^d[63]^d[64];


endmodule


module ecc_d64b_p7_dec (
    input [63:0] data_in,
    input [6:0] parity_in,
    output error_flag, //error_flag = 1 means error detected
    output [6:0]is_parity_diff,
    output reg [70:0] ecc_corrected, 
    output [63:0] data_corrected, 
    output [6:0] parity_corrected
);

    wire [64:1] d;
    assign d[64:1] = data_in[63:0];

    wire [6:0] parity_local;//p1..p7 
    assign parity_local[0] = d[1]^d[2]^d[4]^d[5]^d[7]^d[9]^d[11]^d[12]^d[14]^d[16]^d[18]^d[20]^d[22]^d[24]^d[26]^d[27]^d[29]^d[31]^d[33]^d[35]^d[37]^d[39]^d[41]^d[43]^d[45]^d[47]^d[49]^d[51]^d[53]^d[55]^d[57]^d[58]^d[60]^d[62]^d[64];
    assign parity_local[1] = d[1]^d[3]^d[4]^d[6]^d[7]^d[10]^d[11]^d[13]^d[14]^d[17]^d[18]^d[21]^d[22]^d[25]^d[26]^d[28]^d[29]^d[32]^d[33]^d[36]^d[37]^d[40]^d[41]^d[44]^d[45]^d[48]^d[49]^d[52]^d[53]^d[56]^d[57]^d[59]^d[60]^d[63]^d[64];
    assign parity_local[2] = d[2]^d[3]^d[4]^d[8]^d[9]^d[10]^d[11]^d[15]^d[16]^d[17]^d[18]^d[23]^d[24]^d[25]^d[26]^d[30]^d[31]^d[32]^d[33]^d[38]^d[39]^d[40]^d[41]^d[46]^d[47]^d[48]^d[49]^d[54]^d[55]^d[56]^d[57]^d[61]^d[62]^d[63]^d[64];   
    assign parity_local[3] = d[5]^d[6]^d[7]^d[8]^d[9]^d[10]^d[11]^d[19]^d[20]^d[21]^d[22]^d[23]^d[24]^d[25]^d[26]^d[34]^d[35]^d[36]^d[37]^d[38]^d[39]^d[40]^d[41]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
    assign parity_local[4] = d[12]^d[13]^d[14]^d[15]^d[16]^d[17]^d[18]^d[19]^d[20]^d[21]^d[22]^d[23]^d[24]^d[25]^d[26]^d[42]^d[43]^d[44]^d[45]^d[46]^d[47]^d[48]^d[49]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
    assign parity_local[5] = d[27]^d[28]^d[29]^d[30]^d[31]^d[32]^d[33]^d[34]^d[35]^d[36]^d[37]^d[38]^d[39]^d[40]^d[41]^d[42]^d[43]^d[44]^d[45]^d[46]^d[47]^d[48]^d[49]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
    assign parity_local[6] = d[58]^d[59]^d[60]^d[61]^d[62]^d[63]^d[64];

    assign is_parity_diff = parity_local ^ parity_in;

    wire [71:1] ecc_in;//!!start from 1 to 71, 0 is not used
    assign {ecc_in[64],ecc_in[32],ecc_in[16],ecc_in[8],ecc_in[4],ecc_in[2],ecc_in[1]} = parity_in[6:0];
    assign {ecc_in[71:65],ecc_in[63:33],ecc_in[31:17],ecc_in[15:9],ecc_in[7:5],ecc_in[3]} = d[64:1];

    assign error_flag = |is_parity_diff ;// is_parity_diff[0] | is_parity_diff[1] | is_parity_diff[2] | is_parity_diff[3] | is_parity_diff[4] | is_parity_diff[5] | is_parity_diff[6];

    //correct
    always @(*)  begin
        if(is_parity_diff == 0) begin
            ecc_corrected = ecc_in;
        end else begin
            ecc_corrected = ecc_in ^ (1 << (is_parity_diff[6:0]-1));
        end
    end   

    assign data_corrected[63:0] = {ecc_corrected[70:64],ecc_corrected[62-:31],ecc_corrected[30-:15],ecc_corrected[14-:7],ecc_corrected[6-:3],ecc_corrected[2]};
    assign parity_corrected[6:0] = {ecc_corrected[63],ecc_corrected[31],ecc_corrected[15],ecc_corrected[7],ecc_corrected[3],ecc_corrected[1],ecc_corrected[0]};

endmodule