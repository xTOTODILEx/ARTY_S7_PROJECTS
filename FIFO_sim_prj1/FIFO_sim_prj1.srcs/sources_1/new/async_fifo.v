`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 04:20:51 AM
// Design Name: 
// Module Name: async_fifo
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


module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 4
)(
    input wire rst,
    // Write side
    input wire wr_clk,
    input wire [DATA_WIDTH-1:0] wr_data,
    input wire wr_en,
    output wire wr_full,
    // Read side
    input wire rd_clk,
    output reg [DATA_WIDTH-1:0] rd_data,
    input wire rd_en,
    output wire rd_empty
);
    
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    localparam ADDR_PTR = $clog2(DEPTH);
    localparam ADDR_PTR_WIDTH = ADDR_PTR+1;

    reg [ADDR_PTR_WIDTH-1:0] wr_ptr_gray_sync_0, rd_ptr_gray_sync_0, 
                       rd_ptr_gray_sync, wr_ptr_gray_sync, wr_ptr_bin, 
                       rd_ptr_bin;
                       
    wire [ADDR_PTR_WIDTH-1:0] wr_ptr_bin_next, wr_ptr_gray, wr_ptr_gray_next, rd_ptr_gray;
    
    // write data into memory at current address when enabled
    always @(posedge(wr_clk) or posedge(rst)) begin
        if(rst) wr_ptr_bin <= {ADDR_PTR_WIDTH{1'b0}};
        else begin
            if(wr_en  && !wr_full) begin
                mem[wr_ptr_bin[ADDR_PTR-1:0]] <= wr_data;
                wr_ptr_bin <= wr_ptr_bin + 1'b1;
            end
        end
    end
    
    // Read data from memory at current address when enabled
    always @(posedge(rd_clk) or posedge(rst)) begin
        if(rst) rd_ptr_bin <= {ADDR_PTR_WIDTH{1'b0}};
        else begin
            if(rd_en && !rd_empty) begin
                rd_data     <= mem[rd_ptr_bin[ADDR_PTR-1:0]];
                rd_ptr_bin  <= rd_ptr_bin + 1'b1;
            end
        end
    end
    

    // -------------------- CDC for wr and rd ptrs ---------------------
    // Bringing rd_ptr_gray to write domain
    always @(posedge(wr_clk) or posedge(rst)) begin
        if(rst) begin
            rd_ptr_gray_sync_0  <= {ADDR_PTR_WIDTH{1'b0}};
            rd_ptr_gray_sync    <= {ADDR_PTR_WIDTH{1'b0}};
        end
        else begin
            rd_ptr_gray_sync_0  <= rd_ptr_gray;
            rd_ptr_gray_sync    <= rd_ptr_gray_sync_0;
        end
    end
    
    // Bringing rd_ptr_gray to write domain
    always @(posedge(rd_clk) or posedge(rst)) begin
        if(rst) begin
            wr_ptr_gray_sync_0  <= {ADDR_PTR_WIDTH{1'b0}};
            wr_ptr_gray_sync    <= {ADDR_PTR_WIDTH{1'b0}};
        end
        else begin
            wr_ptr_gray_sync_0  <= wr_ptr_gray;
            wr_ptr_gray_sync    <= wr_ptr_gray_sync_0;
        end
    end

    // wr_ptr_next
    assign wr_ptr_bin_next = wr_ptr_bin + 1'b1;

    // -------------------- binary to gray conversion ---------------------
    // Write side gray code conversion
    assign wr_ptr_gray = (wr_ptr_bin>>1)^wr_ptr_bin;
    assign wr_ptr_gray_next = (wr_ptr_bin_next>>1)^wr_ptr_bin_next;
    // Read side gray code conversion
    assign rd_ptr_gray = (rd_ptr_bin>>1)^rd_ptr_bin;
    
    // Condition for FIFO FULL
//    assign wr_full = (wr_ptr_gray_next == {~rd_ptr_gray_sync[ADDR_PTR_WIDTH:ADDR_PTR_WIDTH-1],
//                                            rd_ptr_gray_sync[ADDR_PTR_WIDTH-2:0]});

    assign wr_full = (wr_ptr_gray_next == {~rd_ptr_gray_sync[ADDR_PTR:ADDR_PTR-1],
                                            rd_ptr_gray_sync[ADDR_PTR-2:0]});

    // Condition for FIFO EMPTY
    assign rd_empty = (rd_ptr_gray == wr_ptr_gray_sync);
    
endmodule
