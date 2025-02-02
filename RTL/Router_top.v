
module router_top(
    input clk, resetn, packet_valid, read_enb_0, read_enb_1, read_enb_2,
    input [7:0] data_in, 
    output vldout_0, vldout_1, vldout_2, err, busy,
    output [7:0] data_out_0, data_out_1, data_out_2
);

    // Internal wires
    wire [2:0] write_enb;
    wire [7:0] dout;
    wire [7:0] fifo_data_out_0, fifo_data_out_1, fifo_data_out_2;
    wire fifo_empty_0, fifo_empty_1, fifo_empty_2;
    wire fifo_full_0, fifo_full_1, fifo_full_2;
    wire soft_reset_0, soft_reset_1, soft_reset_2;
    wire parity_done, low_packet_valid;
    wire detect_add, ld_state, laf_state, lfd_state, full_state, rst_int_reg;

    // FSM Instance
    router_fsm fsm1(
        .clk(clk),
        .resetn(resetn),
        .packet_valid(packet_valid),
        .data_in(data_in[1:0]),
        .fifo_full(fifo_full ),
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
        .busy(busy)
    );

    // Register Instance
    router_reg reg1(
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

    // Synchronizer Instance
    Router_Synchronizer syn1(
        .detect_add(detect_add),
        .data_in(data_in[1:0]),
        .clk(clk),
        .resetn(resetn),
        .empty_0(fifo_empty_0),
        .empty_1(fifo_empty_1),
        .empty_2(fifo_empty_2),
        .read_enb_0(read_enb_0),
        .read_enb_1(read_enb_1),
        .read_enb_2(read_enb_2),
        .write_enb_reg(write_enb_reg),
        .full_0(fifo_full_0),
        .full_1(fifo_full_1),
        .full_2(fifo_full_2),
        .write_enb(write_enb),
        .fifo_full(fifo_full),
        .vld_out_0(vldout_0),
        .vld_out_1(vldout_1),
        .vld_out_2(vldout_2),
        .soft_reset_0(soft_reset_0),
        .soft_reset_1(soft_reset_1),
        .soft_reset_2(soft_reset_2)
    );

    // FIFO Instances
    Router_FIFO fifo_0(
        .clk(clk),
        .resetn(resetn),
        .write_enb(write_enb[0]),
        .read_enb(read_enb_0),
        .soft_reset(soft_reset_0),
        .data_in(dout),
        .lfd_state(lfd_state),
        .empty(fifo_empty_0),
        .full(fifo_full_0),
        .data_out(data_out_0)
    );

    Router_FIFO fifo_1(
        .clk(clk),
        .resetn(resetn),
        .write_enb(write_enb[1]),
        .read_enb(read_enb_1),
        .soft_reset(soft_reset_1),
        .data_in(dout),
        .lfd_state(lfd_state),
        .empty(fifo_empty_1),
        .full(fifo_full_1),
        .data_out(data_out_1)
        
    );

    Router_FIFO fifo_2(
        .clk(clk),
        .resetn(resetn),
        .write_enb(write_enb[2]),
        .read_enb(read_enb_2),
        .soft_reset(soft_reset_2),
        .data_in(dout),
        .lfd_state(lfd_state),
        .empty(fifo_empty_2),
        .full(fifo_full_2),
        .data_out(data_out_2)
        
    );

endmodule