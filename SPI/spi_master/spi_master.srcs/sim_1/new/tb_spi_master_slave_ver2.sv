module tb_spi_master_slave_ver2;

	// Parameters
    localparam CLK_PERIOD = 10; // 100 MHz system clock

    // Testbench signals
    logic clk;
    logic reset;
    logic slave_rx_start;
    logic slave_tx_start;
    logic [31:0] mosi_reg_data;
    logic miso;
    logic cs_bar;
    logic sclk;
    logic mosi;
    logic [31:0] miso_reg_data;
    logic rx_valid;
    logic tx_done;

    // Instantiate the SPI master module
    spi_master_slave_ver2 uut (
        .clk(clk),
        .reset(reset),
		.slave_rx_start(slave_rx_start),
		.slave_tx_start(slave_tx_start),
		.mosi_reg_data(mosi_reg_data),
		.miso(miso),
        .cs_bar(cs_bar),
        .sclk(sclk),
        .mosi(mosi),
        .miso_reg_data(miso_reg_data),
        .rx_valid(rx_valid),
        .tx_done(tx_done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test miso_reg_data and control signals
    logic [31:0] test_data [0:15];
    integer i;

    initial begin
        // Initialize test miso_reg_data (e.g., 16 frames with varying channel_id)
        for (i = 0; i <=15; i++) begin
            test_data[i] = {28'd0, i[3:0]}; // Channel ID is i, output_reg_data is 0xABC
        end

        // Initialize signals
        reset = 1;
        slave_rx_start = 0;
        slave_tx_start = 0;
        miso = 0;
        mosi_reg_data = 0;

        // Wait for reset
        #200;
		reset = 0;

        // Simulate sending 16 frames of 16-bit miso_reg_data
        for (i = 0; i <=15; i++) begin

			if (i==0) begin
				mosi_reg_data = 8'h11; // Example 16-bit miso_reg_data value
				slave_tx_start = 1;
			end
			else begin
				mosi_reg_data = 0;
				slave_tx_start = 0;
			end
		
            // Load the next frame to be transmitted
            @(posedge clk);
			slave_rx_start = 1;
			
            @(posedge clk);
            slave_rx_start = 0;
            

            // Simulate MISO miso_reg_data from the ADC
            repeat (32) begin
                @(posedge sclk); // Wait for falling edge of sclk
                miso = test_data[i][31]; // Send MSB first
                test_data[i] = test_data[i] << 1; // Shift to next bit
            end

            // Wait for miso_reg_data to be received
            @(posedge clk);
            while (!rx_valid) @(posedge clk);
			// mosi_reg_data = 0;

            // // Check received miso_reg_data
            // if (channel_id != (15-i) || miso_reg_data != 12'hABC) begin
                // $error("Test failed for frame %0d: channel_id = %0d, output_reg_data = %0h", i, channel_id, output_reg_data);
            // end else begin
                // $display("Frame %0d received correctly: channel_id = %0d, output_reg_data = %0h", i, channel_id, output_reg_data);
            // end

			if (i==0) begin
				slave_tx_start = 0;
				#2000;
			end
			else begin
				miso = 0;
				#2000; // Delay between frames
			end
		end

        // // Finish the simulation
        // $finish;
    end
	
	// initial begin
	
		// // Initialize signals
        // slave_tx_start = 0;
        // mosi_reg_data = 0;
		
		// #200;
		
		// @(posedge clk);
		// slave_tx_start = 1;
		// @(posedge clk);
		// slave_tx_start = 0;
		// mosi_reg_data = 16'hABCD; // Example 16-bit miso_reg_data value
		
		// wait(tx_done)
	// end
	
endmodule
