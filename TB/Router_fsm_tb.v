module router_fsm_tb;

// Inputs
reg clk, resetn, packet_valid;
reg [1:0] data_in;
reg fifo_full, fifo_empty_0, fifo_empty_1, fifo_empty_2;
reg soft_reset_0, soft_reset_1, soft_reset_2;
reg parity_done, low_packet_valid;


// Outputs
wire write_enb_reg, detect_add, ld_state, laf_state, lfd_state, full_state, rst_int_reg, busy;
wire [3:0] present_state;
wire [3:0] next_state;
// Parameters
parameter cycle = 10;

// DUT instantiation
router_fsm DUT (
    .clk(clk),
    .resetn(resetn),
    .packet_valid(packet_valid),
    .data_in(data_in),
    .fifo_full(fifo_full),
    .fifo_empty_0(fifo_empty_0),
    .fifo_empty_1(fifo_empty_1),
    .fifo_empty_2(fifo_empty_2),
    .soft_reset_0(soft_reset_0),
    .soft_reset_1(soft_reset_1),
    .soft_reset_2(soft_reset_2),
    .parity_done(parity_done),
    .low_packet_valid(low_packet_valid),
    .write_enb_reg(write_enb_reg),
    .detect_add(detect_add),
    .ld_state(ld_state),
    .laf_state(laf_state),
    .lfd_state(lfd_state),
    .full_state(full_state),
    .rst_int_reg(rst_int_reg),
    .busy(busy),
	 .present_state(present_state),
	 .next_state( next_state)
);

// Clock generation
always begin
    #(cycle / 2) clk = ~clk;
end

// Task to initialize inputs
task initialize();
    begin
        clk = 0;
        resetn = 0;
        packet_valid = 0;
        data_in = 2'b00;
        fifo_full = 0;
        fifo_empty_0 = 0;
        fifo_empty_1 = 0;
        fifo_empty_2 = 0;
        soft_reset_0 = 0;
        soft_reset_1 = 0;
        soft_reset_2 = 0;
        parity_done = 0;
        low_packet_valid = 0;
    end
endtask

// Task for delay
task delay(input integer cycles);
    begin
        repeat(cycles) @(negedge clk);
    end
endtask

// Task t1: Payload length < 14
task t1();
    begin
        @(negedge clk)
        packet_valid = 1'b1;
        data_in = 2'b01;
        fifo_empty_1 = 1'b1;
        @(negedge clk)
        @(negedge clk)
        fifo_full = 1'b0;
        packet_valid = 1'b0;
        @(negedge clk)
		  @(negedge clk)
        fifo_full = 1'b0;
    end
endtask

// Task t2: Payload length = 15
task t2();
    begin
        @(negedge clk)
        packet_valid = 1'b1;
        data_in = 2'b10;
        fifo_empty_2 = 1'b1;
        @(negedge clk)//load data
        @(negedge clk)//fifo_full_state
        fifo_full = 1'b0;
		  @(negedge clk)//laf
        parity_done = 1'b0;
		  low_packet_valid=1'b1;
        @(negedge clk)
		  @(negedge clk)
        fifo_full = 1'b0;
    end
endtask

// Task t3: Payload length > 15
task t3();
    begin
        @(negedge clk)
        packet_valid = 1'b1;
        data_in = 2'b00;
        fifo_empty_0 = 1'b1;//load data
        @(negedge clk)//ffs
        @(negedge clk)
        fifo_full = 1'b0;//laf
		  @(negedge clk)
        parity_done = 1'b0;
		  low_packet_valid=1'b0;
        @(negedge clk)//ld
		  fifo_full = 1'b0;
        packet_valid = 1'b0;//lp
		  @(negedge clk)//cpe
		  @(negedge clk)//da
		  fifo_full = 1'b0;
    end
endtask

// Task t4: Payload length = 14
task t4();
    begin
        @(negedge clk)
        packet_valid = 1'b1;
        data_in = 2'b01;
        fifo_empty_1 = 1'b1;//lfd
        @(negedge clk)//ld
		  @(negedge clk)
        fifo_full = 1'b0;
        packet_valid = 1'b0;//lp
        @(negedge clk)//cpe
		  @(negedge clk)
        fifo_full = 1'b1;//ffs
		  @(negedge clk)
		  fifo_full = 1'b0;//laf
		  @(negedge clk)
		  parity_done = 1'b1;
    end
endtask

// Testbench logic
initial begin
    // Initialize signals
    initialize();

    // Apply reset
    @(negedge clk);
    resetn = 1;

    // Run tasks
    t1();
    t2();
    t3();
    t4();

    // End simulation
    $finish;
end
initial begin
    $monitor("Time: %0t | Present State: %b | Next State: %b", $time, DUT.present_state, DUT.next_state);
end

endmodule

