`timescale 1ns / 1ps

module fifo_test;
    
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;  // Using power of 2 for proper FIFO depth

    // Signals
    reg rst, wr_clk, rd_clk;
    reg rd_en, wr_en;
    reg [DATA_WIDTH-1:0] wr_data;
    wire [DATA_WIDTH-1:0] rd_data;
    wire fifo_full, fifo_empty;
    
    // For checking
    reg [DATA_WIDTH-1:0] expected_data;
    integer write_count, read_count;
    
    // DUT instantiation
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) DUT (
        .rst(rst),
        .wr_clk(wr_clk),
        .wr_data(wr_data),
        .wr_en(wr_en),
        .wr_full(fifo_full),
        .rd_clk(rd_clk),
        .rd_data(rd_data),
        .rd_en(rd_en),
        .rd_empty(fifo_empty)
    );

    // Clock generation
    always #5  wr_clk = ~wr_clk;  // 100MHz
    always #10 rd_clk = ~rd_clk;  // 50MHz
    
    // Task for writing data
    task write_data;
        input [DATA_WIDTH-1:0] data;
        begin
            @(posedge wr_clk);
            while (fifo_full) @(posedge wr_clk);  // Wait if full
            wr_en   = 1'b1;
            wr_data = data;
            @(posedge wr_clk);
            wr_en   = 1'b0;
            $display("Time=%0t: Written data = %h", $time, data);
        end
    endtask
    
    // Task for reading data
    task read_check;
        input [DATA_WIDTH-1:0] expected;
        begin
            @(posedge rd_clk);
            while (fifo_empty) @(posedge rd_clk);  // Wait if empty
            rd_en = 1'b1;
            @(posedge rd_clk);
            if (rd_data !== expected)
                $display("Error @ %0t: Expected = %h, Got = %h", $time, expected, rd_data);
            else
                $display("Time=%0t: Read data = %h (correct)", $time, rd_data);
            rd_en = 1'b0;
        end
    endtask
    
    // Initialize
    initial begin
        // Initialize signals
        rst     = 1'b1;
        wr_clk  = 1'b0;
        rd_clk  = 1'b0;
        wr_en   = 1'b0;
        rd_en   = 1'b0;
        wr_data = {DATA_WIDTH{1'b0}};
        
        write_count = 0;
        read_count  = 0;
        
        // Reset sequence
        #100;
        rst = 1'b0;
        #10;
        
        // Test 1: Write until full
        $display("Test 1: Writing until full");
        repeat(DEPTH) begin
            write_data(write_count);
            write_count = write_count + 1;
        end
        
        // Test 2: Try writing when full (should block)
        $display("Test 2: Testing full condition");
        write_data(8'hFF);  // Should wait
        
        // Test 3: Read until empty
        $display("Test 3: Reading until empty");
        repeat(DEPTH) begin
            read_check(read_count);
            read_count = read_count + 1;
        end
        
        // Test 4: Try reading when empty
        $display("Test 4: Testing empty condition");
        @(posedge rd_clk);
        rd_en = 1'b1;
        #2;
        if (!fifo_empty)
            $display("Error: FIFO should be empty!");
        rd_en = 1'b0;
        
        // Test 5: Alternating read/write
        $display("Test 5: Alternating read/write");
        repeat(4) begin
            write_data(write_count);
            write_count = write_count + 1;
            read_check(read_count);
            read_count = read_count + 1;
        end
        
        #100;
        $display("Tests completed");
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #10000 
        $display("Error: Simulation timeout");
        $finish;
    end
    
    // Monitor full/empty conditions
    always @(fifo_full)
        $display("Time=%0t: FIFO full = %b", $time, fifo_full);
        
    always @(fifo_empty)
        $display("Time=%0t: FIFO empty = %b", $time, fifo_empty);

    // Generate VCD waveform file
    initial begin
        $dumpfile("fifo_test.vcd");     // Create VCD file
        $dumpvars(0, fifo_test);        // Dump all variables
        $timeformat(-9, 1, " ns", 10);  // Format time display
    end

endmodule
