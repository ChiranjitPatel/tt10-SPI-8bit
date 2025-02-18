module tb_spi_master_slave;

	// Parameters
    localparam CLK_PERIOD = 10; // 100 MHz system clock

    // Testbench signals
    logic clk;
    logic reset;
    logic slave_rx_start;
    logic slave_tx_start;
    logic [7:0] input_reg_data;
    logic dout_miso;
	// logic loopback;    
    // logic din_mosi_ext;
	logic cs_bar;
    logic sclk;
    logic din_mosi;
    logic [7:0] output_reg_data;
    logic rx_valid;
    logic tx_done;

    // Instantiate the SPI master module
    spi_master_slave uut (
        .clk(clk),
        .reset(reset),
		.slave_rx_start(slave_rx_start),
		.slave_tx_start(slave_tx_start),
		.input_reg_data(input_reg_data),
		.dout_miso(dout_miso),
		// .loopback(loopback),
		// .din_mosi_ext(din_mosi_ext),
        .cs_bar(cs_bar),
        .sclk(sclk),
        .din_mosi(din_mosi),
        .output_reg_data(output_reg_data),
        .rx_valid(rx_valid),
        .tx_done(tx_done)
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
        reset = 1;
        slave_rx_start = 0;
        slave_tx_start = 0;
        dout_miso = 0;
		// loopback = 1;
        input_reg_data = 0;

        // Wait for reset
        #200;
		reset = 0;

        // Simulate sending 16 frames of 16-bit output_reg_data
        for (i = 0; i <=15; i++) begin

			if (i==0) begin
				input_reg_data = 8'hF1; // Example 16-bit output_reg_data value
				slave_tx_start = 1;
			end
			else begin
				input_reg_data = 0;
				slave_tx_start = 0;
			end
		
            // Load the next frame to be transmitted
            @(posedge clk);
			slave_rx_start = 1;
			
            @(posedge clk);
            slave_rx_start = 0;
            
			// if (cs_bar == 1)
				// assign loopback = 0;
			
            // Simulate MISO output_reg_data from the ADC
            repeat (8) begin
                @(posedge sclk); // Wait for falling edge of sclk
                dout_miso = test_data[i][7]; // Send MSB first
                test_data[i] = test_data[i] << 1; // Shift to next bit
            end

            // Wait for output_reg_data to be received
            @(posedge clk);
            while (!rx_valid) @(posedge clk);
			// input_reg_data = 0;

            // // Check received output_reg_data
            // if (channel_id != (15-i) || output_reg_data != 12'hABC) begin
                // $error("Test failed for frame %0d: channel_id = %0d, output_reg_data = %0h", i, channel_id, output_reg_data);
            // end else begin
                // $display("Frame %0d received correctly: channel_id = %0d, output_reg_data = %0h", i, channel_id, output_reg_data);
            // end

			if (i==0) begin
				slave_tx_start = 0;
				#2000;
			end
			else begin
				dout_miso = 0;
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
