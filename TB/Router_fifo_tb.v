module Router_FIFO_tb;

  reg clk;
  reg resetn;
  reg write_enb;
  reg read_enb;
  reg soft_reset;
  reg [7:0] data_in;
  reg lfd_state;
  wire empty;
  wire full;
  wire [7:0] data_out;
  

  parameter cycle = 10;

  Router_FIFO DUT (
      .clk(clk),
      .resetn(resetn),
      .write_enb(write_enb),
      .read_enb(read_enb),
      .soft_reset(soft_reset),
      .data_in(data_in),
      .lfd_state(lfd_state),
      .empty(empty),
      .full(full),
      .data_out(data_out)
  );

  // Clock generation
  always begin
   #(cycle/2) clk = ~clk;
   end

  // Tasks
  task initialize();
      begin
		    clk=1'b0;
          resetn = 1'b0;
          write_enb = 1'b0;
          read_enb = 1'b0;
          soft_reset = 1'b0;
          data_in = 8'b0;
          lfd_state = 1'b0;
			 
          @(negedge clk);
          resetn = 1'b1;
      end
  endtask

  task rst_dut();
      begin
          @(negedge clk);
          resetn = 1'b0; // Assert reset
          @(negedge clk);
          resetn = 1'b1; // Deassert reset
      end
  endtask

  task soft_rst();
      begin
          @(negedge clk);
          soft_reset = 1'b1;
          @(negedge clk);
          soft_reset = 1'b0;
      end
  endtask

  task write_fifo();
      reg [7:0] payload_data, parity, header;
      reg [5:0] payload_len;
      reg [1:0] addr;
      integer k;
      begin
          @(negedge clk);
          payload_len = 6'd12;
          addr = 2'b01;
          header = {payload_len, addr};
          data_in = header;
          lfd_state = 1'b1;
          write_enb = 1'b1;

          for (k = 0; k < payload_len; k = k + 1) begin
              @(negedge clk);
              lfd_state = 1'b0;
              payload_data = ($random) % 256;
              data_in = payload_data;
          end

          @(negedge clk);
          parity = ($random) % 256;
          data_in = parity;
          @(negedge clk);
          write_enb = 1'b0;
      end
  endtask

  task read_fifo();
    begin
        @(negedge clk);
        read_enb = 1'b0; // Ensure read_enb is low initially
        while (!empty) begin
            @(negedge clk);
            read_enb = 1'b1; // Read if FIFO is not empty
        end
        @(negedge clk);
        read_enb = 1'b0; // Stop reading when FIFO becomes empty
    end
endtask


  // Testbench sequence
  initial begin
      initialize();
      rst_dut();
      soft_rst();
      write_fifo();
      read_fifo();
      $stop;
  end

endmodule

