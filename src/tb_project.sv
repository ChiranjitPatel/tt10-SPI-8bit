`timescale 1ns / 1ps
`default_nettype none

module tb_project;

	// Parameters
    localparam CLK_PERIOD = 10; // 100 MHz system clock

    // Testbench signals
    logic clk;
    logic sclk;
    logic rst_n;
    logic [7:0] ui_in;
    logic [7:0] uo_out;
    logic [7:0] uio_in;
    logic [7:0] uio_out;
    logic [7:0] uio_oe;

    // Instantiate the SPI master module
 tt_um_spi uut (
	.clk(clk),
    .rst_n(rst_n),
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(1'b1) // Always enabled
);

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test output_reg_data and control signals
    logic [7:0] test_data [0:15];
    integer i;

    initial begin
        // Initialize test output_reg_data (e.g., 16 frames with varying channel_id)
        for (i = 0; i <=15; i++) begin
            test_data[i] = {5'd0, i[2:0]}; // Channel ID is i, output_reg_data is 0xABC
        end

        // Initialize signals
        rst_n = 1;
        uio_in[0] = 0;
        uio_in[1] = 0;
        uio_in[2] = 0;
		// loopback = 1;
        ui_in = 0;

        // Wait for reset
        #200;
		rst_n = 0;

        // Simulate sending 16 frames of 16-bit output_reg_data
        for (i = 0; i <=15; i++) begin

			if (i==0) begin
				ui_in = 8'hF1; // Example 16-bit output_reg_data value
				uio_in[1] = 1;
			end
			else begin
				ui_in = 0;
				uio_in[1] = 0;
			end
		
            // Load the next frame to be transmitted
            @(posedge clk);
			uio_in[0] = 1;
			
            @(posedge clk);
            uio_in[0] = 0;
            
			// if (cs_bar == 1)
				// assign loopback = 0;
			
            // Simulate MISO output_reg_data from the ADC
            repeat (8) begin
                @(posedge sclk); // Wait for falling edge of sclk
                uio_in[2] = test_data[i][7]; // Send MSB first
                test_data[i] = test_data[i] << 1; // Shift to next bit
            end

            // Wait for output_reg_data to be received
            @(posedge clk);
            while (!uio_out[1]) @(posedge clk);
			// input_reg_data = 0;

            // // Check received output_reg_data
            // if (channel_id != (15-i) || output_reg_data != 12'hABC) begin
                // $error("Test failed for frame %0d: channel_id = %0d, output_reg_data = %0h", i, channel_id, output_reg_data);
            // end else begin
                // $display("Frame %0d received correctly: channel_id = %0d, output_reg_data = %0h", i, channel_id, output_reg_data);
            // end

			if (i==0) begin
				uio_in[1] = 0;
				#2000;
			end
			else begin
				uio_in[2] = 0;
				#2000; // Delay between frames
			end
		end

        // // Finish the simulation
        // $finish;
    end
	
	// initial begin
	
		// // Initialize signals
        // slave_tx_start = 0;
        // input_reg_data = 0;
		
		// #200;
		
		// @(posedge clk);
		// slave_tx_start = 1;
		// @(posedge clk);
		// slave_tx_start = 0;
		// input_reg_data = 16'hABCD; // Example 16-bit output_reg_data value
		
		// wait(tx_done)
	// end
	
endmodule
