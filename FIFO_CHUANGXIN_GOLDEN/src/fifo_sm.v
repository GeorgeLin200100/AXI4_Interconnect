module FIFO_SM #( parameter DATA_WIDTH = 8 , parameter ADDR_WIDTH = 8 )
  (
     input                   Reset_,
     input                   Clock,
     input  [5+DATA_WIDTH*2+DATA_WIDTH/8*4-1:0]  in_signals,
     output [DATA_WIDTH*2+DATA_WIDTH/8*4-1:0]  out_signals,
     output detected_error
);
  wire [ADDR_WIDTH-1:0] SM_ReadPtr;
  wire [ADDR_WIDTH-1:0] SM_WritePtr;
  wire [ADDR_WIDTH-1:0] ReadPtr ;
  wire [ADDR_WIDTH-1:0] WritePtr;
  wire FlagError,ReadError,WriteError,EccError_0,EccError_1,EccError_2,EccError_3;
  wire SM_Full_,SM_HalfFull_,SM_Empty_;
  wire [DATA_WIDTH-1:0]   DataIn,DataOut;
  wire [DATA_WIDTH+DATA_WIDTH/8*4-1:0] DataInEnc,DataOutEnc;
  wire                  Empty_;
  wire                  HalfFull_;
  wire                  Full_;
  wire                  ReadEn;
  wire                  WriteEn;

  assign DoRead = ReadEn & Empty_;
  assign DoWrite = WriteEn & Full_;
  
  assign {WriteEn,ReadEn,Empty_,HalfFull_,Full_,DataIn,DataOutEnc} = in_signals;
  assign out_signals = {DataInEnc,DataOut};

  assign detected_error = FlagError | ReadError | WriteError | EccError_0 | EccError_1 | EccError_2 | EccError_3;
  assign WritePtr = test.DUT.WritePtr;
  assign WriteError = |(WritePtr ^ SM_WritePtr);
  COUNTER #(.ADDR_WIDTH(ADDR_WIDTH)) WP_SM ( Reset_, DoWrite, Clock, SM_WritePtr );
  
  assign ReadPtr = test.DUT.ReadPtr;
  assign ReadError = |(ReadPtr ^ SM_ReadPtr);
  COUNTER #(.ADDR_WIDTH(ADDR_WIDTH)) RP_SM ( Reset_, DoRead, Clock, SM_ReadPtr );

  assign FlagError = (Empty_ ^ SM_Empty_) | (HalfFull_ ^ SM_HalfFull_) | (Full_ ^ SM_Full_);
  FLAGS #(.ADDR_WIDTH(ADDR_WIDTH)) FL_SM ( Reset_, Clock, DoRead, DoWrite, SM_Empty_, SM_HalfFull_, SM_Full_ );

  ECC_8BIT_ENC ECC_Enc_0 (
    .DataIn(DataIn[7:0])                   , // data input bus
    .DataEnc(DataInEnc[11:0])               // ECC data protected input bus
  );

  ECC_8BIT_ENC ECC_Enc_1 (
    .DataIn(DataIn[15:8])                   , // data input bus
    .DataEnc(DataInEnc[23:12])               // ECC data protected input bus
  );

  ECC_8BIT_ENC ECC_Enc_2 (
    .DataIn(DataIn[23:16])                   , // data input bus
    .DataEnc(DataInEnc[35:24])               // ECC data protected input bus
  );

  ECC_8BIT_ENC ECC_Enc_3(
    .DataIn(DataIn[31:24])                   , // data input bus
    .DataEnc(DataInEnc[47:36])               // ECC data protected input bus
  );

  ECC_8BIT_DEC ECC_Dec_0 (
    .DataOutEnc(DataOutEnc[11:0])               , // ECC data protected output bus
    .DataOut(DataOut[7:0]),                // data output bus
    .EccError(EccError_0)               // data output bus
  );

  ECC_8BIT_DEC ECC_Dec_1 (
    .DataOutEnc(DataOutEnc[23:12])               , // ECC data protected output bus
    .DataOut(DataOut[15:8]),                // data output bus
    .EccError(EccError_1)               // data output bus
  );

  ECC_8BIT_DEC ECC_Dec_2 (
    .DataOutEnc(DataOutEnc[35:24])               , // ECC data protected output bus
    .DataOut(DataOut[23:16]),                // data output bus
    .EccError(EccError_2)               // data output bus
  );

  ECC_8BIT_DEC ECC_Dec_3 (
    .DataOutEnc(DataOutEnc[47:36])               , // ECC data protected output bus
    .DataOut(DataOut[31:24]),                // data output bus
    .EccError(EccError_3)               // data output bus
  );

endmodule

