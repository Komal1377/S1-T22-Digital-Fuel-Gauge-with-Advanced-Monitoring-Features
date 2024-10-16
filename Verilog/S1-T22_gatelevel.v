//Design of Digital Systems Mini Project
//S1_T22
//DIGITAL FUEL GAUGE WITH ADVANCED MONITORING FEATURES
//Semester: 3rd Sem B. Tech. CSE
//Member-1: Aaditya Yadav, 231CS102, aadityayadav.231cs102@nitk.edu.in
//Member-2: Chetan Kumar Sah, 231CS118, chetankumarsah.231cs118@nitk.edu.in
//Member-3: Girish Sharma, 231CS123, girishsharma.231cs123@nitk.edu.in


//Gate Level Implementation
module DigitalFuelGauge_GateLevel(
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
endmodule
