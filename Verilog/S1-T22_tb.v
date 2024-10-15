module DigitalFuelGauge_tb;

    // Inputs for the DigitalFuelGauge
    reg clk;                     // Clock signal 
    reg reset;                   // Reset signal
    reg [4:0] input_fuel;        // Input fuel quantity 
    reg [3:0] distance;          // Distance covered 
    reg [1:0] vehicle_quality;   // Vehicle quality
    reg [1:0] road_quality;      // Road quality 
    reg driver_quality;          // Driver quality

    // Outputs to monitor from the DigitalFuelGauge
    wire LED1;                   // Threshold fuel LED1
    wire LED2;                   // Min threshold fuel LED2
    wire [4:0] remaining_fuel;   // Remaining fuel register 
    wire [7:0] mileage;          // Mileage calculation register 
    wire [4:0] fuel_headlights;  // Fuel consumed by headlights (1L)
    wire [4:0] total_fuel_consumed; // Total fuel consumption register

    // Instantiate the DigitalFuelGauge for testing
    DigitalFuelGauge uut (
        .clk(clk),
        .reset(reset),
        .input_fuel(input_fuel),
        .distance(distance),
        .vehicle_quality(vehicle_quality),
        .road_quality(road_quality),
        .driver_quality(driver_quality),
        .LED1(LED1),
        .LED2(LED2),
        .remaining_fuel(remaining_fuel),
        .mileage(mileage),
        .fuel_headlights(fuel_headlights),
        .total_fuel_consumed(total_fuel_consumed)
    );

    // Clock generation process to show clock behavior
    initial begin
        clk = 0; // Initial state of the clock
        forever #5 clk = ~clk; // Toggle the clock every 5 time units to simulate clock cycles
    end

    // Test scenarios setup to validate the module behavior over multiple cycles
    integer cycle; // Declare cycle counter
    reg [15:0] max_range; // Register to hold the maximum range

    initial begin
        // Start with a reset to initialize the system state and registers
        reset = 1; 
        #10; // Wait for 10 time units to allow reset
        reset = 0; // Release the reset

        // Set the initial input fuel
        input_fuel = 15; // Starting value for input fuel in liters
        distance = 0; // Initial distance is set to 0 km
        vehicle_quality = 2'b00; // Initial value for vehicle quality (best condition)
        road_quality = 2'b00; // Initial value for road quality (best condition)
        driver_quality = 1'b0; // Initial value for driver quality (efficient driver)

        // Header for the test output to be printed to the console
        $display("Cycle       | Input Fuel (L) | Distance (km) | Vehicle Quality | Road Quality  | Driver Quality | Mileage (km/L)   | Fuel Headlights (L)   | Total Fuel Consumed (L) | Remaining Fuel (L) | Max Range (km)    | LED1 | LED2");
        $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");


        // Initialize the cycle counter
        cycle = 0;

        // Initial wait period before starting the test iterations
        #20; 

        // Loop until the input fuel is less than the minimum threshold
        while (input_fuel >= 2) begin
            cycle = cycle + 1; // Increment cycle counter for each iteration

            // Set distance based on mileage to ensure distance/mileage ratio is an integer
            if (mileage > 0) begin
                distance = mileage * (cycle % 4 + 1); // Adjust distance for the cycle
            end else begin
                distance = 0; // Ensure distance is zero if mileage is not defined
            end
            
            // Cycle through different values for vehicle, road, and driver qualities
            vehicle_quality = (cycle % 4); // Cycle through possible values for vehicle quality
            road_quality = (cycle % 4); // Cycle through possible values for road quality
            driver_quality = (cycle % 2); // Alternate between efficient and inefficient driver qualities
            
            #10; // Wait for a clock cycle to allow new inputs to be processed
            
            // Calculate maximum range based on input fuel and mileage
            max_range = input_fuel * mileage;

            // Display results for the current test cycle in a formatted way
            $display("%3d    | %3d           | %d             | %b              | %b            | %b              | %d              | %d                    | %d                      | %d                 | %d             | %b   | %b",
                     cycle, input_fuel, distance, vehicle_quality, road_quality, driver_quality, mileage, fuel_headlights, total_fuel_consumed, remaining_fuel, max_range, LED1, LED2);
            
            // Set input fuel for the next cycle to be the remaining fuel from the previous cycle
            input_fuel = remaining_fuel;
        end

        // Stop the simulation when input fuel falls below the minimum threshold
        $stop; // Halt the testbench operation
    end

endmodule