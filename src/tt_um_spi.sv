/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

// `default_nettype none

module tt_um_spi (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

spi_master_slave spi_module (
    .clk(clk),           
    .reset(rst_n),
	.slave_rx_start(ui_in[0]),
	.slave_tx_start(ui_in[1]),
	// .input_reg_data(ui_in),
    .dout_miso(ui_in[2]), 	
    .cs_bar(uo_out[0]),       
    .sclk(uo_out[1]),
	.din_mosi(uo_out[2]),	
    // .output_reg_data(uo_out),
    .rx_valid(uo_out[3]),
	.tx_done(uo_out[4])
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out[7:4] = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:5], 1'b0};

endmodule
