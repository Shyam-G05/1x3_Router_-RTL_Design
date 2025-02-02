

module router_top_tb;

  // Inputs
  reg clk, resetn, packet_valid, read_enb_0, read_enb_1, read_enb_2;
  reg [7:0] data_in;

  // Outputs
  wire vldout_0, vldout_1, vldout_2, err, busy;
  wire [7:0] data_out_0, data_out_1, data_out_2;

  // Instantiate the router_top module
  router_top DUT (
    .clk(clk),
    .resetn(resetn),
    .packet_valid(packet_valid),
    .read_enb_0(read_enb_0),
    .read_enb_1(read_enb_1),
    .read_enb_2(read_enb_2),
    .data_in(data_in),
    .vldout_0(vldout_0),
    .vldout_1(vldout_1),
    .vldout_2(vldout_2),
    .err(err),
    .busy(busy),
    .data_out_0(data_out_0),
    .data_out_1(data_out_1),
    .data_out_2(data_out_2)
  );

  // Clock generation
  parameter cycle = 10;
  always begin
    #(cycle / 2) clk = ~clk;
  end

  // Task: Initialize
  task initialize();
    begin
      clk = 0;
      resetn = 0;
      packet_valid = 0;
      read_enb_0 = 0;
      read_enb_1 = 0;
      read_enb_2 = 0;
      data_in = 0;
    end
  endtask

  // Task: Reset
  task rst();
    begin
      @(negedge clk)
      resetn = 1;
      @(negedge clk)
      resetn = 0;
      @(negedge clk)
      resetn = 1;
    end
  endtask

  // Task: Packet generation 
  task pkt_gen_l4_l();
    reg [7:0] payload_data, parity, header;
    reg [5:0] payload_len;
    reg [1:0] addr;
    integer i;
    begin
      @(negedge clk);
      wait(~busy);

      @(negedge clk);
      payload_len = 6'd14;
      addr = 2'b01;
      header = {payload_len, addr};
      parity = 8'b0;
      data_in = header;
      packet_valid = 1'b1;
      parity = parity ^ header;

      @(negedge clk);
      wait(~busy);
      for (i = 0; i < payload_len; i = i + 1) begin
        @(negedge clk);
        wait(~busy);
        payload_data = {$random} % 256;
        data_in = payload_data;
        parity = parity ^ payload_data;
      end

      @(negedge clk);
      wait(~busy);
      packet_valid = 1'b0;
      data_in = parity;
      @(negedge clk);
    end
  endtask

  // Testbench logic
  initial begin
    initialize;
    rst;

    // Task 1 → Output Channel 0
    pkt_gen_l4_l();
    @(negedge clk);
    read_enb_1 = 1;
    while (vldout_1 || busy) @(negedge clk);
    read_enb_1 = 0;

    @(negedge clk);
    $finish;
  end
endmodule




