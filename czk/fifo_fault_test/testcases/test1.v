    $display("Reset");
    Reset_ = 1'b0;
    ReadEn = 1'b0;
    WriteEn = 1'b0;
    #220
    Reset_ = 1'b1;

    // Reset flags check
    CheckFlags(.Empty(1'b0), .HalfFull(1'b1), .Full(1'b1));

    @(negedge Clock);
    // Write to Half full
    repeat(FIFO_DEPTH/2) begin
        FifoTransfer(.Write(1'b1), .WData(RandomData()), .Read(1'b0));
    end

    // HalfFull flag check
    CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b1));
    

    repeat(FIFO_DEPTH/2) begin
        FifoTransfer(.Write(1'b1), .WData(RandomData()), .Read(1'b0));
    end

    // Full flag
    CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b0));

    // Check FIFO will not write when full
    FifoTransfer(.Write(1'b1), .WData(RandomData()), .Read(1'b0)); 
    CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b0));

    repeat(FIFO_DEPTH/2) begin
        FifoTransfer(.Write(1'b0), .WData(8'hx), .Read(1'b1));
    end

    // HalfFull flag check
    CheckFlags(.Empty(1'b1), .HalfFull(1'b0), .Full(1'b1));

    repeat(FIFO_DEPTH/2) begin
        FifoTransfer(.Write(1'b0), .WData(8'hx), .Read(1'b1));
    end

    // Empty flag check
    CheckFlags(.Empty(1'b0), .HalfFull(1'b1), .Full(1'b1));

    // Check FIFO will not read when empty
    FifoTransfer(.Write(1'b0), .WData(8'hx), .Read(1'b1));
    CheckFlags(.Empty(1'b0), .HalfFull(1'b1), .Full(1'b1));

    //random write/read
    // repeat(FIFO_DEPTH) begin
    //     FifoTransfer(.Write($random()%2), .WData(RandomData()), .Read($random()%2));
    // end

    $display("err_in_test = %d" , err_in_test);
    if (err_in_test == 0) begin
        $display("!0:passed");
    end else begin
        $display("!1:failed");
    end
    $display("Test done");
    $finish;
