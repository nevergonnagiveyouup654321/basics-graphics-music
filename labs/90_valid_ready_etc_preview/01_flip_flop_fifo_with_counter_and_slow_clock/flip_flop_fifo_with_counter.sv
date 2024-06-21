// Asynchronous reset here is needed for one of FPGA boards we use

`include "config.svh"

module flip_flop_fifo_with_counter
# (
    parameter width = 1, depth = 0
)
(
    input                clk,
    input                rst,
    input                push,
    input                pop,
    input  [width - 1:0] write_data,
    output [width - 1:0] read_data,
    output               empty,
    output               full

    `ifdef SYNTHESIS
    ,
    output [31:0]        debug
    `endif
);

    //------------------------------------------------------------------------

    localparam pointer_width = $clog2 (depth),
               counter_width = $clog2 (depth + 1);

    localparam [counter_width - 1:0] max_ptr = counter_width' (depth - 1);

    //------------------------------------------------------------------------

    logic [pointer_width - 1:0] wr_ptr, rd_ptr;
    logic [counter_width - 1:0] cnt;

    logic [width - 1:0] data [0: depth - 1];

    //------------------------------------------------------------------------

    `ifdef SYNTHESIS
    assign debug [31:16] = 16' (wr_ptr);
    assign debug [15:00] = 16' (rd_ptr);
    `endif

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            wr_ptr <= '0;
        else if (push)
            wr_ptr <= wr_ptr == max_ptr ? '0 : wr_ptr + 1'b1;

    // TODO: Add logic for rd_ptr
    // START_SOLUTION

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            rd_ptr <= '0;
        else if (pop)
            rd_ptr <= rd_ptr == max_ptr ? '0 : rd_ptr + 1'b1;

    // END_SOLUTION

    //------------------------------------------------------------------------

    always_ff @ (posedge clk)
        if (push)
            data [wr_ptr] <= write_data;

    assign read_data = data [rd_ptr];

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            cnt <= '0;
        else if (push & ~ pop)
            cnt <= cnt + 1'b1;
        else if (pop & ~ push)
            cnt <= cnt - 1'b1;

    //------------------------------------------------------------------------

    assign empty = (cnt == '0);  // Same as "~| cnt"

    // TODO: Add logic for full output
    // START_SOLUTION
    assign full = (cnt == depth);
    // END_SOLUTION

endmodule
