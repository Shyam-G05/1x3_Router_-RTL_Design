module Router_Synchronizer_tb;

  // Inputs
  reg detect_add;
  reg [1:0] data_in;
  reg clk;
  reg resetn;
  reg empty_0;
  reg empty_1;
  reg empty_2;
  reg read_enb_0;
  reg read_enb_1;
  reg read_enb_2;
  reg write_enb_reg;
  reg full_0;
  reg full_1;
  reg full_2;

  // Outputs
  wire [2:0] write_enb;
  wire fifo_full;
  wire vld_out_0;
  wire vld_out_1;
  wire vld_out_2;
  wire soft_reset_0;
  wire soft_reset_1;
  wire soft_reset_2;
  parameter cycle=10;
  // Instantiate the DUT
  Router_Synchronizer uut (
    .detect_add(detect_add),
    .data_in(data_in),
    .clk(clk),
    .resetn(resetn),
    .empty_0(empty_0),
    .empty_1(empty_1),
    .empty_2(empty_2),
    .read_enb_0(read_enb_0),
    .read_enb_1(read_enb_1),
    .read_enb_2(read_enb_2),
    .write_enb_reg(write_enb_reg),
    .full_0(full_0),
    .full_1(full_1),
    .full_2(full_2),
    .write_enb(write_enb),
    .fifo_full(fifo_full),
    .vld_out_0(vld_out_0),
    .vld_out_1(vld_out_1),
    .vld_out_2(vld_out_2),
    .soft_reset_0(soft_reset_0),
    .soft_reset_1(soft_reset_1),
    .soft_reset_2(soft_reset_2)
  );

  // Clock generation
  always begin
   #(cycle/2) clk = ~clk;
   end

  // Task for initialization
  task initialize;
    begin
      clk = 0;
      resetn = 0;
      detect_add = 0;
      data_in = 2'b00;
      empty_0 = 1;
      empty_1 = 1;
      empty_2 = 1;
      read_enb_0 = 0;
      read_enb_1 = 0;
      read_enb_2 = 0;
      write_enb_reg = 0;
      full_0 = 0;
      full_1 = 0;
      full_2 = 0;
      @(negedge clk) resetn = 1;
    end
  endtask

  // Task to apply delay
  task delay(input integer cycles);
    begin
      repeat(cycles) @(negedge clk);
    end
  endtask

  // Task to set detect address
  task detect_address();
    begin
      @(negedge clk) detect_add = 1'b1;
		
    end
  endtask

  // Task to provide address input
  task address(input [1:0] addr);
    begin
     @(negedge clk)  data_in = addr;
      
    end
  endtask

  // Task to control write signal
  task write_signal(input  enable);
    begin
      @(negedge clk) write_enb_reg = enable;
    end
  endtask

  // Task to set empty status
   
  task empty_status(input [2:0] empty);
    begin
      @(negedge clk)
        empty_0 = empty[0];
        empty_1 = empty[1];
        empty_2 = empty[2];
    end
  endtask

  // Task to control read signal
  task read_signal(input [2:0] read);
    begin
      @(negedge clk)
        read_enb_0 = read[0];
        read_enb_1 = read[1];
        read_enb_2 = read[2];
    end
  endtask


  // Main test logic
  initial begin
    initialize;

    // Test 1: Detect address and write enable
    detect_address();
    address(2'b01);
    write_signal(1);
	 
    // Test 2: Set FIFO empty and check valid outputs
    empty_status(3'b110);
     delay(30);

    // Test 3: Test soft reset logic
    read_signal(3'b000); // Ensure no reads
    empty_status(3'b000); // FIFOs are not empty

    initialize;

    $finish;
  end

endmodule
