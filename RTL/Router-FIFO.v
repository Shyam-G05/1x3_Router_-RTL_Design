module Router_FIFO(
    input clk,
    input resetn,
    input write_enb,
    input read_enb,
    input soft_reset,
    input [7:0] data_in,
    input lfd_state,
    output empty,
    output full,
    output reg [7:0] data_out
);

    parameter depth = 16;
    parameter width = 9;
    reg lfd_out;
    reg [width-1:0] fifo [depth-1:0];
    reg [3:0] write_ptr;
    reg [3:0] read_ptr;
    reg [4:0] count;
    reg [6:0] counter;
    integer i;

    // LFD state latch
    always @(posedge clk) begin
        lfd_out <= lfd_state;
    end

    // Internal counter of FIFO
    always @(posedge clk ) begin
        if (!resetn) begin
            counter <= 7'b0;
        end else if (soft_reset) begin
            counter <= 7'b0;
        end else if (read_enb && ~empty) begin
            if (fifo[read_ptr][8] == 1'b1) begin
                counter <= fifo[read_ptr][7:2] + 7'b1;
            end else if (counter != 7'b0) begin
                counter <= counter - 1;
            end
        end
    end

    // Write/Read Logic for Count
    always @(posedge clk ) begin
        if (!resetn) begin
            count <= 0;
            write_ptr <= 0;
            read_ptr <= 0;
            for (i = 0; i < depth; i = i + 1)
                fifo[i] <= 0;
        end else if (soft_reset) begin
            count <= 0;
            write_ptr <= 0;
            read_ptr <= 0;
            for (i = 0; i < depth; i = i + 1)
                fifo[i] <= 0;
        end else begin
            // Write operation
            if (write_enb && !full) begin
                fifo[write_ptr] <= {lfd_out, data_in};
                write_ptr <= write_ptr + 1'b1;
                count <= count + 1;
            end

            // Read operation
            if (read_enb && !empty) begin
                data_out <= fifo[read_ptr][7:0];
                read_ptr <= read_ptr + 1'b1;
                count <= count - 1;
            end
        end
    end

    // Data Output Logic
    always @(posedge clk ) begin
        if (!resetn || soft_reset) begin
            data_out <= 8'b0;
        end else if (count == 0) begin
            data_out <= 8'bz;
        end
    end

    assign empty = (count == 0);
    assign full = (count == depth);

endmodule
