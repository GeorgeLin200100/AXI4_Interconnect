
  initial
    begin
      Clock = 1'b0;
      forever
        #50 Clock = ~Clock;
   end

  task FifoTransfer;
    input                  Write;
    input [DATA_WIDTH-1:0] WData;
    input                  Read;
    begin
      WriteEn <= Write;
      ReadEn  <= Read;
      DataIn  <= WData;
      @(posedge Clock);
      if (Write && FifoFull)
      begin
        golden_data.push_back(WData);
        $display("Write %h @%d", WData,$time);
      end
      if (Read && FifoEmpty)
        begin
          temp_data = golden_data.pop_front();
          if (DataOut !== temp_data)
            begin
              if (Error == 1'b1)
                $display($time,": DD: failure on Data value detected, got %h, was expecting %h\n", DataOut, temp_data);
              else
                $display($time,": FAIL: got %h, was expecting %h\n", DataOut, temp_data);
              //$finish;
            end
          $display("Read %h @%d", DataOut,$time);
        end
      @(negedge Clock);
      WriteEn <= 1'b0;
      ReadEn  <= 1'b0;
    end
   endtask

  task CheckFlags;
    input Empty;
    input HalfFull;
    input Full;
    begin
      if (FifoEmpty !== Empty)
        begin
          if (Error == 1'b1)
            $display($time,": DD: 'Empty' flag value detected, got %h, was expecting %h\n", FifoEmpty, Empty);
          else
            $display($time,": FAIL: wrong 'Empty' flag value, got %h, was expecting %h\n", FifoEmpty, Empty);
        end
      if (FifoHalfFull !== HalfFull)
        begin
          if (Error == 1'b1)
            $display($time,": DD: 'HalfFull' flag value detected, got %h, was expecting %h\n", FifoEmpty, Empty);
          else
            $display($time,": FAIL: wrong 'HalfFull' flag value, got %h, was expecting %h\n", FifoHalfFull, HalfFull);
        end
      if (FifoFull !== Full)
        begin
          if (Error == 1'b1)
            $display($time,": DD: 'Full' flag value detected, got %h, was expecting %h\n", FifoEmpty, Empty);
          else
            $display($time,": FAIL: wrong 'Full' flag value, got %h, was expecting %h\n", FifoFull, Full);
        end
      $display("Check Flags");
    end
  endtask



