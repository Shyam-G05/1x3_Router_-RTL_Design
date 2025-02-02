module Router_Synchronizer (
    input detect_add,
    input [1:0] data_in,
    input clk,
    input resetn,
    input empty_0,
    input empty_1,
    input empty_2,
    input read_enb_0,
    input read_enb_1,
    input read_enb_2,
    input write_enb_reg,
    input full_0,  
    input full_1,  
    input full_2,  
    output reg [2:0] write_enb,
    output reg fifo_full,
    output vld_out_0,
    output vld_out_1,
    output vld_out_2,
    output reg soft_reset_0,
    output reg soft_reset_1,
    output reg soft_reset_2
);

  reg [4:0] counter_0;
  reg [4:0] counter_1;
  reg [4:0] counter_2;
  reg [1:0] temp; // Register to capture address

  // Capturing Address
  always @(posedge clk ) begin
    if (!resetn) begin
      temp <= 2'b11;
    end else if (detect_add) begin
      temp <= data_in;
    end
  end

  // Write Enable Logic
  always @(*) begin
    if (write_enb_reg) begin
      case (temp)
        2'b00: write_enb = 3'b001;
        2'b01: write_enb = 3'b010;
        2'b10: write_enb = 3'b100;
        default: write_enb = 3'b000;
      endcase
    end else begin
      write_enb = 3'b000;
    end
  end

  // FIFO Full Detection
  always @(*) begin
    case (temp)
      2'b00: fifo_full = full_0;
      2'b01: fifo_full = full_1;
      2'b10: fifo_full = full_2;
      default: fifo_full = 1'b0;
    endcase
  end

  // Valid Output Logic
  assign vld_out_0 = ~empty_0;
  assign vld_out_1 = ~empty_1;
  assign vld_out_2 = ~empty_2;

  // Soft Reset Logic
  always @(posedge clk ) begin
    if (!resetn) begin
      soft_reset_0 <= 1'b0;
      soft_reset_1 <= 1'b0;
      soft_reset_2 <= 1'b0;
      counter_0 <= 5'b0;
      counter_1 <= 5'b0;
      counter_2 <= 5'b0;
    end else begin
      // FIFO 0
      if (vld_out_0 && !read_enb_0) begin
        if (counter_0 == 5'd29) begin
          soft_reset_0 <= 1'b1;
          counter_0 <= 5'b0;
        end else begin
          counter_0 <= counter_0 + 1;
          soft_reset_0 <= 1'b0;
        end
      end else begin
        counter_0 <= 5'b0;
        soft_reset_0 <= 1'b0;
      end

      // FIFO 1
      if (vld_out_1 && !read_enb_1) begin
        if (counter_1 == 5'd29) begin
          soft_reset_1 <= 1'b1;
          counter_1 <= 5'b0;
        end else begin
          counter_1 <= counter_1 + 1;
          soft_reset_1 <= 1'b0;
        end
      end else begin
        counter_1 <= 5'b0;
        soft_reset_1 <= 1'b0;
      end

      // FIFO 2
      if (vld_out_2 && !read_enb_2) begin
        if (counter_2 == 5'd29) begin
          soft_reset_2 <= 1'b1;
          counter_2 <= 5'b0;
        end else begin
          counter_2 <= counter_2 + 1;
          soft_reset_2 <= 1'b0;
        end
      end else begin
        counter_2 <= 5'b0;
        soft_reset_2 <= 1'b0;
      end
    end
  end

endmodule

    
     
     
