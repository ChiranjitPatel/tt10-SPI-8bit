`timescale 1ns/1ps
module tb_tt_um_spi;

    // Parameters
    localparam CLK_PERIOD = 10; // 100 MHz clock

    // Testbench signals
    logic clk;
    logic rst_n;
    logic [7:0] ui_in;
    logic [7:0] uo_out;
    logic [7:0] uio_in;
    logic [7:0] uio_out;
    logic [7:0] uio_oe;

    // Instantiate the SPI module
    tt_um_spi uut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(1'b1),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Reset generation
    // initial begin
        // rst_n = 1;
        // #200; // Assert reset for 100 ns
        // rst_n = 0;
    // end

    // Test data
    logic [7:0] test_data [0:7];
    integer i;

    // initial begin
        // // Initialize signals
        // ui_in = 8'b00000000;
        // uio_in = 8'b0;
        // // test_data = 8'hA5; // Example test data for SPI transmission
		// for (i = 0; i <=7; i++) begin
            // test_data[i] = {5'd0, i[2:0]}; // Channel ID is i, output_reg_data is 0xABC
        // end
        // // @(negedge rst_n);
        // // @(posedge clk);

        // $display("Starting SPI transaction...");

        // // Simulate SPI communication
        // // ui_in[0] = 1; // Assert slave_rx_start
        // // ui_in[1] = 1; // Assert slave_tx_start
        // // ui_in[2] = 0; // MISO initial value

        // // for (i = 0; i < 8; i++) begin
            // // // @(posedge clk);
            // // ui_in[2] = test_data[i]; // Load bits into MISO line for transmission
			// // #250;
        // // end

		// #1000;
		// @(posedge clk);
			// ui_in[1] = 1; //  slave_tx_start
			// ui_in[0] = 1; //  slave_rx_start
		// @(posedge clk);
			// ui_in[0] = 0; //  slave_rx_start
		
		// repeat (8) begin
            // @(posedge uo_out[1]); // sclk
            // ui_in[2] = test_data[i][7]; // dout_miso = test_data
			// test_data[i] = test_data[i] << 1; // Shift to next bit
			// // #200;
        // end
		
		// #3000;
		// ui_in[1] = 0; // slave_tx_start
        // // ui_in[1] = 1; // De-assert slave_tx_start

        // // Wait for rx_valid signal
        // @(posedge clk);
        // while (!uo_out[3]) @(posedge clk);
        // $display("SPI transaction complete, rx_valid asserted.");

        // // Check tx_done signal
        // @(posedge clk);
        // if (uo_out[4]) begin
            // $display("SPI transmission successful.");
        // end else begin
            // $error("SPI transmission failed.");
        // end

        // // $finish;
    // end




	initial begin
        // Initialize test output_reg_data (e.g., 16 frames with varying channel_id)
        for (i = 0; i <=15; i++) begin
            test_data[i] = {5'd0, i[2:0]}; // Channel ID is i, output_reg_data is 0xABC
        end

        // Initialize signals
        rst_n = 1;
        ui_in[0] = 0;
        ui_in[1] = 0;
        ui_in[2] = 0;
        // input_reg_data = 0;

        // Wait for rst_n
        #200;
		rst_n = 0;

        // Simulate sending 16 frames of 16-bit output_reg_data
        for (i = 0; i <=15; i++) begin

			// if (i==0) begin
				// // input_reg_data = 8'hAA; // Example 16-bit output_reg_data value
				// ui_in[1] = 1;
			// end
			// else begin
				// // input_reg_data = 0;
				// ui_in[1] = 0;
			// end
		
            // Load the next frame to be transmitted
            @(posedge clk);
			ui_in[0] = 1;
			ui_in[1] = 1;
			
            @(posedge clk);
            ui_in[0] = 0;
			ui_in[1] = 0;
            

            // Simulate MISO output_reg_data from the ADC
            repeat (8) begin
                @(posedge uo_out[1]); // Wait for falling edge of uo_out[1]
                ui_in[2] = test_data[i][7]; // Send MSB first
                test_data[i] = test_data[i] << 1; // Shift to next bit
            end

            // Wait for output_reg_data to be received
            @(posedge clk);
            while (!uo_out[3]) @(posedge clk);

			if (i==0) begin
				ui_in[1] = 0;
				#2000;
			end
			else begin
				ui_in[2] = 0;
				#2000; // Delay between frames
			end
		end

    end






endmodule
