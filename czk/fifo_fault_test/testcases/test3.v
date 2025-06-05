      $display("Reset...");
      Reset_ = 1'b0;
      ReadEn = 1'b0;
      WriteEn = 1'b0;
      #220
      Reset_ = 1'b1;

      // Reset flags check
      CheckFlags(.Empty(1'b0), .HalfFull(1'b1), .Full(1'b1));

      @(negedge Clock);

      // Write FIFO until full

      FifoTransfer(.Write(1'b1), .WData(8'h80), .Read(1'b0));
      // Empty flag check
      CheckFlags(.Empty(1'b1), .HalfFull(1'b1), .Full(1'b1));

      FifoTransfer(.Write(1'b1), .WData(8'h41), .Read(1'b0));
      CheckFlags(.Empty(1'b1), .HalfFull(1'b1), .Full(1'b1));

      FifoTransfer(.Write(1'b1), .WData(8'h22), .Read(1'b0));
      CheckFlags(.Empty(1'b1), .HalfFull(1'b1), .Full(1'b1));

      FifoTransfer(.Write(1'b1), .WData(8'h3), .Read(1'b0));
      // HalfFull flag check
      CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b1));

      FifoTransfer(.Write(1'b1), .WData(8'hf4), .Read(1'b0));
      CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b1));

      FifoTransfer(.Write(1'b1), .WData(8'h45), .Read(1'b0));
      CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b1));

      FifoTransfer(.Write(1'b1), .WData(8'h26), .Read(1'b0));
      CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b1));

      FifoTransfer(.Write(1'b1), .WData(8'hf7), .Read(1'b0));
      // Full flag
      CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b0));

      // Check FIFO will not write when full
      FifoTransfer(.Write(1'b1), .WData(8'hf8), .Read(1'b0)); 
      CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b0));

      // Read FIFO until empty

      FifoTransfer(.Write(1'b0), .WData(8'hx), .Read(1'b1));
      CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b1));

      FifoTransfer(.Write(1'b0), .WData(8'hx), .Read(1'b1));
      CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b1));

      FifoTransfer(.Write(1'b0), .WData(8'hx), .Read(1'b1));
      CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b1));

      FifoTransfer(.Write(1'b0), .WData(8'hx), .Read(1'b1));
      CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b1));

      FifoTransfer(.Write(1'b0), .WData(8'hx), .Read(1'b1));
      // HalfFull flag check
      CheckFlags(.Empty(1'b1), .HalfFull(1'b1), .Full(1'b1));

      FifoTransfer(.Write(1'b0), .WData(8'hx), .Read(1'b1));
      CheckFlags(.Empty(1'b1), .HalfFull(1'b1), .Full(1'b1));

      FifoTransfer(.Write(1'b0), .WData(8'hx), .Read(1'b1));
      CheckFlags(.Empty(1'b1), .HalfFull(1'b1), .Full(1'b1));

      FifoTransfer(.Write(1'b0), .WData(8'hx), .Read(1'b1));
      // Empty flag check
      CheckFlags(.Empty(1'b0), .HalfFull(1'b1), .Full(1'b1));

         $display("Test done\n");
      $finish;
