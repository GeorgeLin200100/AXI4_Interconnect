`timescale 1ns/1ns

module FIFO #( 
  parameter FIFO_DEPTH = 128, 
  parameter DATA_WIDTH = 64 , 
  parameter PARITY_WIDTH = 7)
  (  
    input                   Reset_,
    input                   WriteEn,
    input                   WriteClk,
    input  [DATA_WIDTH-1:0] DataIn,
    input                   ReadEn,
    input                   ReadClk,
    output [DATA_WIDTH-1:0] DataOut,
    output                  Empty_,
    output                  HalfFull_,
    output                  Full_,
    output                  error_flag,
    output [PARITY_WIDTH-1:0]              is_parity_diff,
    output                  correct
  ); 


  parameter ADDR_WIDTH = $clog2(FIFO_DEPTH);//7bit addr 2^7=128
  parameter ECC_WIDTH = DATA_WIDTH + PARITY_WIDTH; //71 = 64 + 7

  wire [ADDR_WIDTH-1:0] ReadPtr ;
  wire [ADDR_WIDTH-1:0] WritePtr;
  wire [PARITY_WIDTH-1:0] parity_enc;
  wire [ECC_WIDTH-1:0] ecc_in_fifo;
  wire [ECC_WIDTH-1:0] ecc_out_fifo;
  wire [PARITY_WIDTH-1:0] parity_out_fifo;
  wire [DATA_WIDTH-1:0] data_out_fifo;

  assign DoRead = ReadEn & Empty_;
  assign DoWrite = WriteEn & Full_;

  assign IClock = ReadClk | WriteClk;

  assign ecc_in_fifo = {parity_enc, DataIn};
  assign {parity_out_fifo, data_out_fifo} = ecc_out_fifo;
  assign correct = error_flag & (ecc_in_fifo != ecc_out_fifo) ;

  FLAGS #(.ADDR_WIDTH(ADDR_WIDTH)) FL_IF ( Reset_, IClock, DoRead, DoWrite, Empty_, HalfFull_, Full_ );
  COUNTER #(.ADDR_WIDTH(ADDR_WIDTH)) RP_IF ( Reset_, DoRead, ReadClk, ReadPtr );
  COUNTER #(.ADDR_WIDTH(ADDR_WIDTH)) WP_IF ( Reset_, DoWrite, WriteClk, WritePtr );

  ecc_d64b_p7_enc ECC_Enc (
    .data_in(DataIn)                   , // data input bus
    .parity_out(parity_enc)             // ECC data protected input bus
  );

  ecc_d64b_p7_dec ECC_Dec (
    .data_in(data_out_fifo)               , // ECC data protected output bus
    .parity_in(parity_out_fifo)               , // data input bus
    .error_flag(error_flag)               , // data output bus
    .is_parity_diff(is_parity_diff)                   , // data output bus
    .ecc_corrected(),         // data output bus
    .data_corrected(DataOut)            , // data output bus
    .parity_corrected()                  // data output bus
  );


  SDPRAM_TOP #( .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(ECC_WIDTH)) sdpram_i1
  ( 
    // Left port
    .L_Clock(WriteClk)                ,
    .L_Address(WritePtr)              , // address bus
    .L_DataIn(ecc_in_fifo)                 , // data input bus
    .L_DataOut()                      , // data output bus
    .L_ReadEn(1'b0)                   , // Active high read  enable
    .L_WriteEn(DoWrite)               , // Active high write enable
    // Right port
    .R_Clock(ReadClk)                 , // Clock
    .R_Address(ReadPtr)               , // address bus
    .R_DataIn({ECC_WIDTH {1'b0}})    , // data input bus
    .R_DataOut(ecc_out_fifo)               , // data output bus
    .R_ReadEn(DoRead)                 , // Active high read  enable
    .R_WriteEn(1'b0)
  ) ;

endmodule

module FLAGS ( Reset_, Clock, Read, Write, Empty_, HalfFull_, Full_ );

  parameter ADDR_WIDTH = 4;

  input   Reset_;
  input   Clock;
  input   Read;
  input   Write;
  output  Empty_;
  output  HalfFull_;
  output  Full_;

  reg [ADDR_WIDTH:0] Count;

  assign Empty_ = |Count;
  assign HalfFull_ = ~(Count[ADDR_WIDTH] | Count[ADDR_WIDTH-1]);
  assign Full_ = ~Count[ADDR_WIDTH];

  always @(posedge Clock or negedge Reset_)
    if (!Reset_)
      Count <= {ADDR_WIDTH {1'b0}};
    else
      if (Read & ~Write)
        Count <= Count - 1'b1;
      else if (~Read & Write)
        Count <= Count + 1'b1;

endmodule

module COUNTER ( Reset_, Enable, Clock, Count );

  parameter ADDR_WIDTH = 4;

  input                       Reset_;
  input                       Enable;
  input                       Clock;
  output reg [ADDR_WIDTH-1:0] Count;

  always @(posedge Clock or negedge Reset_)
    if (!Reset_)
      Count <= {ADDR_WIDTH {1'b0}};
    else if (Enable)
      Count <= Count + 1'b1;

endmodule
