
module router_reg_tb;

    // Inputs
    reg clk;
    reg resetn;
    reg packet_valid;
    reg [7:0] data_in;
    reg fifo_full;
    reg detect_add;
    reg ld_state;
    reg laf_state;
    reg full_state;
    reg lfd_state;
    reg rst_int_reg;

    // Outputs
    wire err;
    wire parity_done;
    wire low_packet_valid;
    wire [7:0] dout;

    // Parameters
    parameter cycle = 10;

    router_reg DUT (
        .clk(clk),
        .resetn(resetn),
        .packet_valid(packet_valid),
        .data_in(data_in),
        .fifo_full(fifo_full),
        .detect_add(detect_add),
        .ld_state(ld_state),
        .laf_state(laf_state),
        .full_state(full_state),
        .lfd_state(lfd_state),
        .rst_int_reg(rst_int_reg),
        .err(err),
        .parity_done(parity_done),
        .low_packet_valid(low_packet_valid),
        .dout(dout)
    );

    // Clock generation
    always begin
        #(cycle/2) clk = ~clk;
    end

    // Task to initialize signals
    task initialize;
        begin
            clk = 0;
            resetn = 0;
            packet_valid = 0;
            data_in = 8'b0;
            fifo_full = 0;
            detect_add = 0;
            ld_state = 0;
            laf_state = 0;
            full_state = 0;
            lfd_state = 0;
            rst_int_reg = 0;
            @(negedge clk) resetn = 1;
        end
    endtask

    // Task to generate a packet
    task packet_generation;
        reg [7:0] payload_data, parity, header;
        reg [5:0] payload_len;
        reg [1:0] addr;
        integer i;
        begin
            @(negedge clk);
            payload_len = 6'd5; // Example payload length
            addr = 2'b10; // Valid address
            packet_valid = 1'b1;
            detect_add = 1'b1;
            header = {payload_len, addr};
            parity = 8'h00 ^ header;
            data_in = header;

            @(negedge clk);
            detect_add = 1'b0;
            lfd_state = 1'b1;

            for (i = 0; i < payload_len; i = i + 1) begin
                @(negedge clk);
                lfd_state = 1'b0;
                ld_state = 1'b1;
                payload_data = {$random} % 256;
                data_in = payload_data;
                parity = parity ^ data_in;
            end

            @(negedge clk);
            packet_valid = 1'b0;
            data_in = parity;

            @(negedge clk);
            ld_state = 1'b0;
        end
    endtask

    // Testbench sequence
    initial begin
        // Initialize inputs
        initialize;

        // Generate a packet
        packet_generation;
        $finish;
    end

endmodule

