# Digital Fuel Gauge with Advanced Monitoring Features
<!-- First Section -->
## Team Details
<details>
  <summary>Detail</summary>

  > Semester: 3rd Sem B. Tech. CSE

  > Section: S1

  > Team ID: S1-T22

  > Member-1: Aaditya Yadav, 231CS102, aadityayadav.231cs102@nitk.edu.in

  > Member-2: Chetan Kumar Sah, 231CS118, chetankumarsah.231cs118@nitk.edu.in

  > Member-3: Girish Sharma, 231CS123, girishsharma.231cs123@nitk.edu.in

</details>

<!-- Second Section -->
## Abstract
<details>
  <summary>Detail</summary>
  
1) Motivation: In today’s world, accurate fuel monitoring is critical for efficient vehicle operation
and cost management. Traditional fuel gauges often lack precision and additional monitoring capabilities,
leading to fuel wastage and unforeseen breakdowns. With the integration of advanced monitoring
systems, users can make informed decisions regarding fuel usage, plan refueling schedules, and reduce
costs. This project aims to explore the design and implementation of a digital fuel gauge that not only
displays the fuel level accurately but also incorporates advanced monitoring features. The motivation
stems from the need for modern solutions to improve energy management and operational efficiency in
vehicles and other machinery dependent on fuel.</br>
2) Problem Statement: Current analog fuel gauges provide only a rough estimation of fuel levels,
which can lead to inaccuracies and potential miscalculations, especially in critical scenarios. Furthermore,
they lack real-time advanced monitoring features such as consumption rate, low-fuel alerts, and predictive
analysis of fuel requirements. This project seeks to develop a digital fuel gauge using a digital IC trainer kit
that offers precise fuel level readings and advanced monitoring features such as low-fuel warnings,
consumption tracking, and predictive alerts. The goal is to bridge the gap between traditional fuel gauges
and modern, data-driven fuel management systems.</br>
3) Features: The system uses a seven-segment display to accurately represent the fuel level in either
percentage or volume. It includes real-time fuel consumption tracking, allowing users to monitor how
quickly the fuel is being used and to estimate remaining travel distance. LED indicators or buzzer sounds
are triggered when the fuel level falls below a predefined threshold, providing timely alerts to the user.
The system detects anomalies or failures in the fuel sensor, alerting the user to any sensor-related issues.
The entire system is controlled using a digital IC trainer kit, providing a flexible environment for building
and testing the design. Additional features such as GPS-based fuel consumption prediction and integration
with mobile devices can be added for real-world applications.</br>

</details>

## Functional Block Diagram
<details>
  <summary>Detail</summary>
  

  > ![Block Diagram](Snapshots/block.drawio.png)


</details>

<!-- Third Section -->
## Working
<details>
  <summary>Detail</summary>

  > Explain how your model works with the help of a functional table (compulsory) followed by the flowchart.
</details>

<!-- Fourth Section -->
## Logisim Circuit Diagram
<details>
  <summary>Detail</summary>

  > Update a neat logisim circuit diagram
</details>

<!-- Fifth Section -->
## Verilog Code
<details>
  <summary>Detail</summary>

  module DigitalFuelGauge(
    input clk,               // Clock Signal
    input reset,             // To reset the system
    input [4:0] input_fuel,   // Input fuel in liters (5-bit wide to accommodate up to 31L)
    input [3:0] distance,     // Distance covered by the vehicle 
    input [1:0] vehicle_quality, // Vehicle quality 
    input [1:0] road_quality,    // Road quality 
    input driver_quality,     // Driver quality
    output reg LED1,          // LED1 indicator for fuel warning when fuel is lower than threshold value
    output reg LED2,          // LED2 indicator for fuel warning when fuel is lower than min threshold value
    output reg [4:0] remaining_fuel, // Output of remaining fuel
    output reg [7:0] mileage,        //  Calculated mileage
    output reg [4:0] fuel_headlights,//  Fuel consumed by headlights
    output reg [4:0] total_fuel_consumed // Total fuel consumed in a cycle
);

    // Constants for mileage calculations
    parameter MIN_THRESHOLD = 2; // Minimum threshold for fuel; below this, system signals low fuel
    parameter FUEL_HEADLIGHTS = 1; // Fuel consumption for headlights

    // Internal variables for mileage calculations
    reg [7:0] mileage1; // Mileage based on road quality 
    reg [7:0] mileage2; // Mileage based on driver quality
    reg [7:0] mileage3; // Mileage based on vehicle quality

    // AlwaysExecuted at every clock cycle or when reset signal is activated
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            remaining_fuel <= 0;        // Reset remaining fuel to zero
            mileage <= 0;               // Reset mileage calculation
            fuel_headlights <= 0;       // Reset fuel consumed by headlights
            total_fuel_consumed <= 0;   // Reset total fuel consumed value
        end else begin
            // Calculate mileage based on road quality
            case (road_quality)
                2'b00: mileage1 = 12;   // Good road quality gives the best mileage
                2'b01: mileage1 = 9;    // Moderate road quality (75% of the best mileage)
                2'b10: mileage1 = 6;    // Poor road quality (half the best mileage)
                2'b11: mileage1 = 3;    // Very poor road quality (quarter of the best mileage)
             
            endcase

            // Calculate mileage based on driver quality
            mileage2 = (driver_quality == 1'b0) ? 12 : 6;

            // Calculate mileage based on vehicle quality using another case statement
            case (vehicle_quality)
                2'b00: mileage3 = 12;   // Best vehicle condition gives maximum mileage
                2'b01: mileage3 = 9;    // Decent vehicle condition (75% of maximum mileage)
                2'b10: mileage3 = 6;    // Average vehicle condition (half of maximum mileage)
                2'b11: mileage3 = 3;    // Poor vehicle condition (quarter of maximum mileage)
          
            endcase

            // Average the three mileage values to get a final mileage estimate
            mileage = (mileage1 + mileage2 + mileage3) / 3;

            // Calculate the total fuel consumption using distance and mileage
            if (mileage > 0) begin
                total_fuel_consumed = (distance / mileage) + FUEL_HEADLIGHTS;
                // Ensure remaining fuel does not go negative
                remaining_fuel = (input_fuel >= total_fuel_consumed) ? (input_fuel - total_fuel_consumed) : 0;
            end else begin
                total_fuel_consumed = 0; // No fuel consumed if mileage is zero
                remaining_fuel = input_fuel; // Retain input fuel if no consumption
            end

            // Fixed fuel consumption by headlights
            fuel_headlights = FUEL_HEADLIGHTS;
        end
    end

    // LED Control Logic
    always @(posedge clk) begin
        if (remaining_fuel <= 5 && remaining_fuel > 2) begin
            LED1 = 1; // Activate LED1 if fuel is low
            LED2 = 0; // Ensure LED2 remains off
        end 
        else if (remaining_fuel < 2) begin
            LED1 = 0; // Deactivate the LED1
            LED2 = 1; // Activate LED2 forlow fuel warning i.e less than min threshold value
        end 
        else begin
            LED1 = 0; // Deactivate both LEDs if fuel levels are safe
            LED2 = 0;
        end
    end

endmodule

/*module DigitalFuelGauge_GateLevel(
    input clk,
    input reset,
    input [4:0] input_fuel,
    input [3:0] distance,
    input [1:0] vehicle_quality,
    input [1:0] road_quality,
    input driver_quality,
    output reg LED1,
    output reg LED2,
    output reg [4:0] remaining_fuel,
    output reg [7:0] mileage,
    output reg [4:0] fuel_headlights,
    output reg [4:0] total_fuel_consumed,
    output reg [15:0] max_range
);

    // Internal signals
    wire [7:0] mileage1;             
    wire [7:0] mileage2;             
    wire [7:0] mileage3;             
    wire [7:0] sum_mileage;          
    wire [7:0] avg_mileage;          
    wire [4:0] fuel_used;            
    wire [4:0] temp_remaining_fuel;  
    wire [4:0] fuel_used_reg;        
    wire reset_n;                    

    // Invert the reset signal
    wire nreset;
    not u_reset_inv(nreset, reset);

    // Road quality multiplexer
    wire [7:0] road_quality_mux_out; 
    mux2x1 road_quality_mux(.sel(road_quality), .in0(8'b00001100), .in1(8'b00001001), .in2(8'b00000110), .in3(8'b00000011), .out(road_quality_mux_out));
    assign mileage1 = road_quality_mux_out;

    // Driver quality mileage calculation
    wire n_driver_quality;
    not u_driver_quality_inv(n_driver_quality, driver_quality);
    and u_driver_quality_out(mileage2[0], n_driver_quality, 8'b00001100);
    and u_driver_quality_out1(mileage2[1], driver_quality, 8'b00000110);
    or u_driver_quality_final(mileage2[7:2], mileage2[0], mileage2[1]);  

    // Vehicle quality multiplexer
    wire [7:0] vehicle_quality_mux_out; 
    mux2x1 vehicle_quality_mux(.sel(vehicle_quality), .in0(8'b00001100), .in1(8'b00001001), .in2(8'b00000110), .in3(8'b00000011), .out(vehicle_quality_mux_out));
    assign mileage3 = vehicle_quality_mux_out;

    // Sum the mileage components
    wire [7:0] temp_sum_mileage;
    four_bit_adder sum_mileage_adder(.a(mileage1[3:0]), .b(mileage2[3:0]), .sum(temp_sum_mileage[3:0]));
    four_bit_adder sum_mileage_adder2(.a(temp_sum_mileage[3:0]), .b(mileage3[3:0]), .sum(sum_mileage[3:0]));

    // Average mileage calculation (sum_mileage / 3)
    wire [7:0] avg_mileage_temp;
    assign avg_mileage_temp = sum_mileage >> 1; 
    assign avg_mileage = avg_mileage_temp >> 1; 

    // Calculate total fuel consumption: distance / avg_mileage
    wire [3:0] distance_temp;
    assign distance_temp = distance; 

    // Creating logic for division
    wire [4:0] temp_fuel_used;
    divide_by_mileage divider(.dividend(distance_temp), .divisor(avg_mileage), .quotient(temp_fuel_used));

    // Calculate remaining fuel
    wire [4:0] temp_remaining_fuel_full;
    remaining_fuel_calculator fuel_calculator(.input_fuel(input_fuel), .fuel_used(temp_fuel_used), .remaining_fuel(temp_remaining_fuel_full));

    // Sequential logic for output registers
    always @(posedge clk or negedge nreset) begin
        if (~nreset) begin
            remaining_fuel <= 0;
            mileage <= 0;
            fuel_headlights <= 0;
            total_fuel_consumed <= 0;
            max_range <= 0;
        end else begin
            remaining_fuel <= temp_remaining_fuel_full;
            total_fuel_consumed <= temp_fuel_used;
            fuel_headlights <= 1; 
            max_range <= input_fuel * avg_mileage; 
        end
    end

    // LED indicators based on remaining fuel
    always @(posedge clk) begin
        if (remaining_fuel <= 5 && remaining_fuel > 2) begin
            LED1 <= 1;
            LED2 <= 0;
        end 
        else if (remaining_fuel < 2) begin
            LED1 <= 0;
            LED2 <= 1;
        end 
        else begin
            LED1 <= 0;
            LED2 <= 0;
        end
    end

endmodule

// Mux definition (2-to-1 multiplexer)
module mux2x1(
    input [1:0] sel,
    input [7:0] in0,
    input [7:0] in1,
    input [7:0] in2,
    input [7:0] in3,
    output reg [7:0] out
);
    always @(*) begin
        case(sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
            default: out = 0;
        endcase
    end
endmodule

// 4-bit Adder using gates
module full_adder (
    input a, 
    input b, 
    input cin, 
    output sum, 
    output cout
);
    assign sum = a ^ b ^ cin; 
    assign cout = (a & b) | (cin & (a ^ b)); 
endmodule

module four_bit_adder (
    input [3:0] a, 
    input [3:0] b, 
    input cin, 
    output [3:0] sum, 
    output cout 
);
    wire c1, c2, c3; 

    full_adder fa0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(c1));
    full_adder fa1 (.a(a[1]), .b(b[1]), .cin(c1), .sum(sum[1]), .cout(c2));
    full_adder fa2 (.a(a[2]), .b(b[2]), .cin(c2), .sum(sum[2]), .cout(c3));
    full_adder fa3 (.a(a[3]), .b(b[3]), .cin(c3), .sum(sum[3]), .cout(cout));
endmodule

// Divider module (simple integer division)
module divide_by_mileage(
    input [3:0] dividend,
    input [7:0] divisor,
    output reg [4:0] quotient
);
    integer i;
    reg [7:0] temp_dividend;

    always @(*) begin
        temp_dividend = {4'b0000, dividend}; 
        quotient = 0;
        for (i = 7; i >= 0; i = i - 1) begin
            temp_dividend = {temp_dividend[6:0], 1'b0}; 
            if (temp_dividend >= divisor) begin
                temp_dividend = temp_dividend - divisor; 
                quotient[i] = 1;
            end
        end
    end
endmodule

// Main Digital Fuel Gauge Module
module DigitalFuelGauge(
    input clk,
    input reset,
    input [4:0] input_fuel,
    input [3:0] distance,
    input [1:0] vehicle_quality,
    input [1:0] road_quality,
    input driver_quality,
    output reg LED1,
    output reg LED2,
    output reg [4:0] remaining_fuel,
    output reg [7:0] mileage,
    output reg [4:0] fuel_headlights,
    output reg [4:0] total_fuel_consumed,
    output reg [15:0] max_range
);

    // Instantiate gate-level design
    DigitalFuelGauge_GateLevel gate_level_design (
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
        .total_fuel_consumed(total_fuel_consumed),
        .max_range(max_range)
    );

endmodule
*/
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
</details>

## References
<details>
  <summary>Detail</summary>
  >https://www.electronicshub.org/different-types-sensors</br>
  >https://youtube.com/watch?v=5g1DzmoN6uo</br>
  >https://www.quora.com/search?q=digital%20fuel%20gauge%20by%20using%20digital%20electronics</br>
  >https://nevonprojects.com/digital-electronics-projects</br>
  >https://instrumentationtools.com/top-100-digital-electronics-project-ideas/</br>
</details>
