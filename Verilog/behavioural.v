
//Behavioral Level Implementation
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
