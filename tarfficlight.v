// create module
	module blink (
    input wire clk,             // Clock signal
    input wire reset,           // Reset signal
    input wire adc_data_valid,  // ADC data valid signal
    input wire [11:0] adc_data, // ADC data (12-bit)
    output wire led              // LED output
	);

// Define parameters
parameter THRESHOLD = 8'b011111111111; // Set your threshold value here
parameter BLINK_RATE = 24'b000000000000000001111111; // Set your blink rate here

// Registers
reg [11:0] sensor_value;
reg led_state;
reg [23:0] counter;

// FSM states
parameter IDLE = 2'b00;
parameter BLINK_ON = 2'b01;
parameter BLINK_OFF = 2'b10;

// State register
reg [1:0] state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        counter <= 0;
        led_state <= 0;
    end else begin
        case (state)
            IDLE:
                if (adc_data_valid && (adc_data > THRESHOLD)) begin
                    state <= BLINK_ON;
                    counter <= 0;
                end
            BLINK_ON:
                if (counter >= BLINK_RATE) begin
                    state <= BLINK_OFF;
                    counter <= 0;
                end
            BLINK_OFF:
                if (counter >= BLINK_RATE) begin
                    state <= BLINK_ON;
                    counter <= 0;
                end
        endcase
    end
end

always @(posedge clk) begin
    // Read the sensor value when ADC data is valid
    if (adc_data_valid) begin
        sensor_value <= adc_data;
    end
end

assign led = (state == BLINK_ON);

endmodule
