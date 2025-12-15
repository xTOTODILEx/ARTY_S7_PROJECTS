`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 01:55:23 AM
// Design Name: 
// Module Name: advanced_fifo_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module advanced_fifo_test;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;  // Using power of 2 for proper FIFO depth

    // Signals
    logic rst, wr_clk, rd_clk;
    logic rd_en, wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;
    logic fifo_full, fifo_empty;
    
    // For checking
    // Dynamic Queue to store expected values
    logic [DATA_WIDTH-1:0] exp_q[$];
    integer write_count, read_count;
    
    logic Data_match, error_count;
    localparam MAX_RD_TXNS = 200, MAX_WR_TXNS = 200;
    localparam L_MAX_RD = $clog2(MAX_RD_TXNS);
    localparam L_MAX_WR = $clog2(MAX_WR_TXNS); 
    logic [L_MAX_WR-1:0] wr_txns;
    logic [L_MAX_RD-1:0] rd_txns;
    
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

    initial begin
        wr_clk = 0;
        rd_clk = 0;
    end

    // Clock generation
    always #5  wr_clk = ~wr_clk;  // 100MHz
    always #10 rd_clk = ~rd_clk;  // 50MHz

    //Task that writes until full
//    task wr_until_full;
        
//    endtask
    
    //Task that reads until full
//    task rd_until_full;
        
//    endtask
   
    
    //Task that writes only once
    task write_data;
        logic [DATA_WIDTH-1:0] rand_val;
        rand_val = $urandom(); // truncated to DATA_WIDTH bits automatically
    
        wait(!fifo_full);
        //@(posedge(wr_clk));
        @(posedge(wr_clk));
        wr_en   = !fifo_full;
        wr_data = rand_val;
        exp_q.push_back(rand_val);
        @(posedge(wr_clk));
        wr_en   = 1'b0;

    endtask
    
    //Task that reads only once
    task read_data;
        logic [DATA_WIDTH-1:0] actual_value;
        
        wait(!fifo_empty);
        //@(posedge(rd_clk));
        @(posedge(rd_clk));
        rd_en = !fifo_empty;

        @(posedge(rd_clk));
        rd_en = 1'b0;
        actual_value = exp_q.pop_front();        
        
        if(rd_data == actual_value)
            Data_match = 1'b1;
                    
        if (rd_data !== actual_value)
             $error("Mismatch: got=%0h expected=%0h at t=%0t", rd_data, actual_value, $time);
    
    endtask
    
    //Main testbench body
    initial begin
        Data_match = 0;
        rst     = 1;
        wr_en   = 0;
        rd_en   = 0;
        rd_txns = 0;
        wr_txns = 0;
        error_count = 0;
        
        #40
        rst = 0;
        
        // Most or typical FIFO designs consists 
        // of only DEPTH-1 actual writable addresses
        fork
            begin : write_process
                while (wr_txns < MAX_WR_TXNS) begin
                    #( $urandom_range(0,40));   // 0-40ns
                    
                    // 50% attempt to write
                    if( $urandom_range(0,1)) begin
                        write_data;
                        wr_txns++;
                    end
                end
            end
            begin : read_process
                while (rd_txns < MAX_RD_TXNS) begin
                    #( $urandom_range(0,60));    // 0-60ns
                    
                    // 50% chance to attempt a read
                    if ( $urandom_range(0,1)) begin
                        read_data;
                        rd_txns++;
                    end
                end
            end
        join
        
        if (error_count > 0) $display("TEST FAILED: Data Mismatch");
        else $display("TEST PASSED: Data Mismatch");
        
        #400
        $finish;
    end
    
    initial begin        
        $dumpvars(0, advanced_fifo_test);        // dump everything under testbench scope
    end

    // Assertions
    A_WR_FULL_CHECK:
    assert property (@(posedge wr_clk) disable iff(rst) wr_en |-> !fifo_full)
        else $error("FIFO Protocol violation: write when FIFO is FULL");
    
    A_RD_EMPTY_CHECK:    
    assert property (@(posedge rd_clk) disable iff(rst) rd_en |-> !fifo_empty)
        else $error("FIFO Protocol violation: read when FIFO is EMPTY");

endmodule
