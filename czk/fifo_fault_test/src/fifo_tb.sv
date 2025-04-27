//testbench for fifo
`timescale 1ns/1ns

module test;

    parameter                           FIFO_DEPTH                 = 128   ;
    parameter                           DATA_WIDTH                 = 64    ; 
    parameter                           PARITY_WIDTH               = 7     ;
    parameter                           ECC_WIDTH                  = DATA_WIDTH + PARITY_WIDTH; //71 = 64 + 7

    reg                                 Clock                       ;
    reg                                 Reset_                      ;
    reg                                 WriteEn                     ;
    reg                                 ReadEn                      ;
    reg                [DATA_WIDTH-1: 0]        DataIn                      ;
    wire               [DATA_WIDTH-1: 0]        DataOut                     ;
    wire                                FifoEmpty                   ;
    wire                                FifoHalfFull                ;
    wire                                FifoFull                    ;
    wire                                Error                       ;
    wire                                error_sm                    ;

    wire                                error_fifo                  ;
    wire               [PARITY_WIDTH-1: 0]        is_parity_diff              ;
    wire                                correct                     ;

    reg       [DATA_WIDTH-1: 0]            golden_data[$];                           //queue
    reg       [DATA_WIDTH-1: 0]            temp_data;

    wire               [DATA_WIDTH+DATA_WIDTH/8*4-1: 0]        DataInEnc                   ;
    wire               [DATA_WIDTH+DATA_WIDTH/8*4-1: 0]        DataOutEnc=0                ;
  
    reg     err_in_test;
    
    assign    Error   = error_fifo | error_sm;

    `include "strobe.sv"

    FIFO #(.FIFO_DEPTH(FIFO_DEPTH), .DATA_WIDTH(DATA_WIDTH)) DUT
    (
        .Reset_                             (Reset_                    ),
        .ReadClk                            (Clock                     ),
        .WriteClk                           (Clock                     ),
        .WriteEn                            (WriteEn                   ),
        .DataIn                             (DataIn                    ),
        .ReadEn                             (ReadEn                    ),
        .DataOut                            (DataOut                   ),
        .Empty_                             (FifoEmpty                 ),
        .HalfFull_                          (FifoHalfFull              ),
        .Full_                              (FifoFull                  ),
        .error_flag                         (error_fifo                ),
        .is_parity_diff                     (is_parity_diff            ),
        .correct                            (correct                   ) 
    );

    //sm check flag
    FIFO_SM #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH($clog2(FIFO_DEPTH))) DUT_SM
    (
        .Reset_                             (Reset_                    ),
        .Clock                              (Clock                     ),
        .in_signals                         ({WriteEn,ReadEn,FifoEmpty,FifoHalfFull,FifoFull,DataIn,DataOutEnc}),// input the signals you need to observe
        .detected_error                     (error_sm                  ) // output Error signal when SM detect a fault
    );

    integer      i   ;

    initial begin
        // Initialize Memory
        for (int i=0; i < FIFO_DEPTH; i++) begin
            #1 test.DUT.sdpram_i1.sdpram_i1.mem_array[i] <= {DATA_WIDTH {1'h0}};
        end
        err_in_test=0;

        if($test$plusargs("test1"))
        begin
            $display("Using test1");
            `include "./test1.v"
        end
        if($test$plusargs("test2"))
        begin
            $display("Using test2");
            `include "./test2.v"
        end
        if($test$plusargs("test3"))
        begin
            $display("Using test3");
            `include "./test3.v"
        end
        $display("Calling finish");
        #10 $finish;
    end

    initial begin
        $fsdbDumpfile("fifo.fsdb");
        $fsdbDumpvars(0,test);
    end

endmodule
