module ecc_d64b_p7_func;
// pure combinational
function [70:0] ecc_d64b_p7_enc_func;
    input [63:0] data_in;

    reg [64:1] d;
    reg [6:0] parity_out;

    begin
        d[64:1] = data_in[63:0];

        //p0-p6
        parity_out[0] = d[1]^d[2]^d[4]^d[5]^d[7]^d[9]^d[11]^d[12]^d[14]^d[16]^d[18]^d[20]^d[22]^d[24]^d[26]^d[27]^d[29]^d[31]^d[33]^d[35]^d[37]^d[39]^d[41]^d[43]^d[45]^d[47]^d[49]^d[51]^d[53]^d[55]^d[57]^d[58]^d[60]^d[62]^d[64];
        parity_out[1] = d[1]^d[3]^d[4]^d[6]^d[7]^d[10]^d[11]^d[13]^d[14]^d[17]^d[18]^d[21]^d[22]^d[25]^d[26]^d[28]^d[29]^d[32]^d[33]^d[36]^d[37]^d[40]^d[41]^d[44]^d[45]^d[48]^d[49]^d[52]^d[53]^d[56]^d[57]^d[59]^d[60]^d[63]^d[64];
        parity_out[2] = d[2]^d[3]^d[4]^d[8]^d[9]^d[10]^d[11]^d[15]^d[16]^d[17]^d[18]^d[23]^d[24]^d[25]^d[26]^d[30]^d[31]^d[32]^d[33]^d[38]^d[39]^d[40]^d[41]^d[46]^d[47]^d[48]^d[49]^d[54]^d[55]^d[56]^d[57]^d[61]^d[62]^d[63]^d[64];   
        parity_out[3] = d[5]^d[6]^d[7]^d[8]^d[9]^d[10]^d[11]^d[19]^d[20]^d[21]^d[22]^d[23]^d[24]^d[25]^d[26]^d[34]^d[35]^d[36]^d[37]^d[38]^d[39]^d[40]^d[41]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
        parity_out[4] = d[12]^d[13]^d[14]^d[15]^d[16]^d[17]^d[18]^d[19]^d[20]^d[21]^d[22]^d[23]^d[24]^d[25]^d[26]^d[42]^d[43]^d[44]^d[45]^d[46]^d[47]^d[48]^d[49]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
        parity_out[5] = d[27]^d[28]^d[29]^d[30]^d[31]^d[32]^d[33]^d[34]^d[35]^d[36]^d[37]^d[38]^d[39]^d[40]^d[41]^d[42]^d[43]^d[44]^d[45]^d[46]^d[47]^d[48]^d[49]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
        parity_out[6] = d[58]^d[59]^d[60]^d[61]^d[62]^d[63]^d[64];
        
        ecc_d64b_p7_enc_func = {parity_out, d[64:1]};
    end
endfunction

function [63:0] ecc_d64b_p7_dec_func;
    input [70:0] in;
    reg [63:0] data_in;
    reg [6:0] parity_in;
    reg [64:1] d;
    reg [6:0] parity_local;
    reg [6:0] is_parity_diff;
    reg [71:1] ecc_in;//!!start from 1 to 71, 0 is not used
    reg error_flag;
    reg [70:0] ecc_corrected;
    begin
        data_in[63:0] = in[63:0];
        parity_in[6:0] = in[70:64];
        d[64:1] = data_in[63:0];
        parity_local[0] = d[1]^d[2]^d[4]^d[5]^d[7]^d[9]^d[11]^d[12]^d[14]^d[16]^d[18]^d[20]^d[22]^d[24]^d[26]^d[27]^d[29]^d[31]^d[33]^d[35]^d[37]^d[39]^d[41]^d[43]^d[45]^d[47]^d[49]^d[51]^d[53]^d[55]^d[57]^d[58]^d[60]^d[62]^d[64];
        parity_local[1] = d[1]^d[3]^d[4]^d[6]^d[7]^d[10]^d[11]^d[13]^d[14]^d[17]^d[18]^d[21]^d[22]^d[25]^d[26]^d[28]^d[29]^d[32]^d[33]^d[36]^d[37]^d[40]^d[41]^d[44]^d[45]^d[48]^d[49]^d[52]^d[53]^d[56]^d[57]^d[59]^d[60]^d[63]^d[64];
        parity_local[2] = d[2]^d[3]^d[4]^d[8]^d[9]^d[10]^d[11]^d[15]^d[16]^d[17]^d[18]^d[23]^d[24]^d[25]^d[26]^d[30]^d[31]^d[32]^d[33]^d[38]^d[39]^d[40]^d[41]^d[46]^d[47]^d[48]^d[49]^d[54]^d[55]^d[56]^d[57]^d[61]^d[62]^d[63]^d[64];   
        parity_local[3] = d[5]^d[6]^d[7]^d[8]^d[9]^d[10]^d[11]^d[19]^d[20]^d[21]^d[22]^d[23]^d[24]^d[25]^d[26]^d[34]^d[35]^d[36]^d[37]^d[38]^d[39]^d[40]^d[41]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
        parity_local[4] = d[12]^d[13]^d[14]^d[15]^d[16]^d[17]^d[18]^d[19]^d[20]^d[21]^d[22]^d[23]^d[24]^d[25]^d[26]^d[42]^d[43]^d[44]^d[45]^d[46]^d[47]^d[48]^d[49]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
        parity_local[5] = d[27]^d[28]^d[29]^d[30]^d[31]^d[32]^d[33]^d[34]^d[35]^d[36]^d[37]^d[38]^d[39]^d[40]^d[41]^d[42]^d[43]^d[44]^d[45]^d[46]^d[47]^d[48]^d[49]^d[50]^d[51]^d[52]^d[53]^d[54]^d[55]^d[56]^d[57];
        parity_local[6] = d[58]^d[59]^d[60]^d[61]^d[62]^d[63]^d[64];
        is_parity_diff = parity_local ^ parity_in;
        {ecc_in[64],ecc_in[32],ecc_in[16],ecc_in[8],ecc_in[4],ecc_in[2],ecc_in[1]} = parity_in[6:0];
        {ecc_in[71:65],ecc_in[63:33],ecc_in[31:17],ecc_in[15:9],ecc_in[7:5],ecc_in[3]} = d[64:1];
        error_flag = |is_parity_diff;
        ecc_corrected = (error_flag) ? (ecc_in ^ (1 << (is_parity_diff[6:0]-1))) : ecc_in;
        ecc_d64b_p7_dec_func = {ecc_corrected[70:64],ecc_corrected[62-:31],ecc_corrected[30-:15],ecc_corrected[14-:7],ecc_corrected[6-:3],ecc_corrected[2]};
    end
endfunction
endmodule