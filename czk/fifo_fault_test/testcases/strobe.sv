
  initial
    begin
      Clock = 1'b0;
      forever
        #50 Clock = ~Clock;
   end

  integer wn=0;
  integer rn=0;

  task FifoTransfer; //read write check
    input                  Write;
    input [DATA_WIDTH-1:0] WData;
    input                  Read;
    begin
      WriteEn <= Write;
      ReadEn  <= Read;
      DataIn  <= WData;
      @(posedge Clock);
      if (Write && FifoFull) begin
        golden_data.push_back(WData);
        wn=wn+1;
        $display("Write%d %h @%d",wn, WData,$time);
      end
      if (Read && FifoEmpty) begin
        temp_data = golden_data.pop_front();
        if (DataOut !== temp_data) begin
          err_in_test = 1;
          if (Error == 1'b1)
            $display($time,": DD: failure on Data value detected, got %h, was expecting %h\n", DataOut, temp_data);
          else
            $display($time,": FAIL: got %h, was expecting %h\n", DataOut, temp_data);
        end else begin
          if (Error == 1'b1)
            $display("Read & correct %h @%d", DataOut,$time);
          else begin
            rn=rn+1;
            $display("Read_%d %h @%d", rn, DataOut,$time);
          end
        end
      end
      @(negedge Clock);
      WriteEn <= 1'b0;
      ReadEn  <= 1'b0;
    end
  endtask

  task CheckFlags; // Active-Low signal
    input Empty;
    input HalfFull;
    input Full;
    begin
      $display("Check Flags:");
      if (FifoEmpty !== Empty) begin
        if (Error == 1'b1)
          $display($time,": DD: 'Empty' flag value detected, got %h, was expecting %h", FifoEmpty, Empty);
        else
          $display($time,": FAIL: wrong 'Empty' flag value, got %h, was expecting %h", FifoEmpty, Empty);
      end
      if (FifoHalfFull !== HalfFull) begin
        if (Error == 1'b1)
          $display($time,": DD: 'HalfFull' flag value detected, got %h, was expecting %h", FifoHalfFull, HalfFull);
        else
          $display($time,": FAIL: wrong 'HalfFull' flag value, got %h, was expecting %h", FifoHalfFull, HalfFull);
      end
      if (FifoFull !== Full) begin
        if (Error == 1'b1)
          $display($time,": DD: 'Full' flag value detected, got %h, was expecting %h", FifoFull, Full);
        else
          $display($time,": FAIL: wrong 'Full' flag value, got %h, was expecting %h", FifoFull, Full);
      end
      if((FifoEmpty == Empty) && (FifoHalfFull == HalfFull) && (FifoFull == Full)) begin
        $display($time,": PASS Empty=%d HalfFull=%d Full=%d", FifoEmpty, FifoHalfFull, FifoFull);
      end      
    end
  endtask

  function [DATA_WIDTH-1:0] RandomData;
    begin
      RandomData = {$random(),$random()};
    end
  endfunction

