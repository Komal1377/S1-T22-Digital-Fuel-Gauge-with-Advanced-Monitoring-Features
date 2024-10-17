//Design of Digital Systems Mini Project
//S1_T22
//DIGITAL FUEL GAUGE WITH ADVANCED MONITORING FEATURES
//Semester: 3rd Sem B. Tech. CSE
//Member-1: Aaditya Yadav, 231CS102, aadityayadav.231cs102@nitk.edu.in
//Member-2: Chetan Kumar Sah, 231CS118, chetankumarsah.231cs118@nitk.edu.in
//Member-3: Girish Sharma, 231CS123, girishsharma.231cs123@nitk.edu.in

//Gate level implementation
// Main Module: Digital Fuel Gauge System
module Main_Module(
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
    wire [7:0] mileage1;            // Component for mileage based on road quality
    wire [7:0] mileage2;            // Component for mileage based on driver quality
    wire [7:0] mileage3;            // Component for mileage based on vehicle quality
    wire [7:0] sum_mileage;         // Component for summing mileage
    wire [7:0] avg_mileage;         // Mileage Module: for calculating average mileage
    wire [4:0] fuel_used;           // Component to hold the used fuel amount
    wire [4:0] temp_remaining_fuel; // Component to store temporary remaining fuel
    wire reset_n;                   // Component for active low reset signal

    // Component: Inverting the reset signal
    wire nreset;
    not u_reset_inv(nreset, reset);

    // Gate-Level Implementation of 4x1 Multiplexer for Road Quality
module mux4x1_gate_level (
    input [1:0] sel,
    input [7:0] in0,
    input [7:0] in1,
    input [7:0] in2,
    input [7:0] in3,
    output [7:0] out
);
    wire [7:0] and0, and1, and2, and3;
    wire not_sel0, not_sel1;

    // Generate NOT gates for the select signals
    not g1(not_sel0, sel[0]);
    not g2(not_sel1, sel[1]);

    // AND gates to select the appropriate input based on sel
    and g3[7:0] (and0, in0, {8{not_sel1 & not_sel0}});  // Select in0 if sel = 00
    and g4[7:0] (and1, in1, {8{not_sel1 & sel[0]}});   // Select in1 if sel = 01
    and g5[7:0] (and2, in2, {8{sel[1] & not_sel0}});   // Select in2 if sel = 10
    and g6[7:0] (and3, in3, {8{sel[1] & sel[0]}});     // Select in3 if sel = 11

    // OR gates to combine all possible outputs
    or g7[7:0] (out, and0, and1, and2, and3);
endmodule

    // Initial Module: Driver quality mileage calculation
    wire n_driver_quality;
    not u_driver_quality_inv(n_driver_quality, driver_quality);
    and u_driver_quality_out(mileage2[0], n_driver_quality, 8'b00001100);
    and u_driver_quality_out1(mileage2[1], driver_quality, 8'b00000110);
    or u_driver_quality_final(mileage2[7:2], mileage2[0], mileage2[1]);  

    // Gate-Level Implementation of 4x1 Multiplexer for Vehicle Quality
module mux4x1_gate_level_vehicle (
    input [1:0] sel,
    input [7:0] in0,
    input [7:0] in1,
    input [7:0] in2,
    input [7:0] in3,
    output [7:0] out
);
    wire [7:0] and0, and1, and2, and3;
    wire not_sel0, not_sel1;

    // Generate NOT gates for the select signals
    not g1(not_sel0, sel[0]);
    not g2(not_sel1, sel[1]);

    // AND gates to select the appropriate input based on sel
    and g3[7:0] (and0, in0, {8{not_sel1 & not_sel0}});  // Select in0 if sel = 00
    and g4[7:0] (and1, in1, {8{not_sel1 & sel[0]}});   // Select in1 if sel = 01
    and g5[7:0] (and2, in2, {8{sel[1] & not_sel0}});   // Select in2 if sel = 10
    and g6[7:0] (and3, in3, {8{sel[1] & sel[0]}});     // Select in3 if sel = 11

    // OR gates to combine all possible outputs
    or g7[7:0] (out, and0, and1, and2, and3);
endmodule


    // Component: Sum of mileage components
    wire [7:0] temp_sum_mileage;
    four_bit_adder sum_mileage_adder(.a(mileage1[3:0]), .b(mileage2[3:0]), .sum(temp_sum_mileage[3:0]));
    four_bit_adder sum_mileage_adder2(.a(temp_sum_mileage[3:0]), .b(mileage3[3:0]), .sum(sum_mileage[3:0]));

    module avg_mileage_gate_level (
    input [7:0] sum_mileage,
    output [7:0] avg_mileage
);
    wire [7:0] avg_mileage_temp;

    // First right shift (sum_mileage >> 1)
    and (avg_mileage_temp[0], sum_mileage[1], 1'b1); 
    and (avg_mileage_temp[1], sum_mileage[2], 1'b1); 
    and (avg_mileage_temp[2], sum_mileage[3], 1'b1); 
    and (avg_mileage_temp[3], sum_mileage[4], 1'b1); 
    and (avg_mileage_temp[4], sum_mileage[5], 1'b1); 
    and (avg_mileage_temp[5], sum_mileage[6], 1'b1); 
    and (avg_mileage_temp[6], sum_mileage[7], 1'b1); 
    and (avg_mileage_temp[7], 1'b0, 1'b1);           

    // Second right shift (avg_mileage_temp >> 1)
    and (avg_mileage[0], avg_mileage_temp[1], 1'b1); 
    and (avg_mileage[1], avg_mileage_temp[2], 1'b1); 
    and (avg_mileage[2], avg_mileage_temp[3], 1'b1); 
    and (avg_mileage[3], avg_mileage_temp[4], 1'b1); 
    and (avg_mileage[4], avg_mileage_temp[5], 1'b1); 
    and (avg_mileage[5], avg_mileage_temp[6], 1'b1); 
    and (avg_mileage[6], avg_mileage_temp[7], 1'b1); 
    and (avg_mileage[7], 1'b0, 1'b1);             
endmodule

    // Component: Calculate total fuel consumption: distance / avg_mileage
    module distance_transfer_gate_level (
    input [3:0] distance,
    output [3:0] distance_temp
);

    // Connect each bit of distance directly to distance_temp using AND gates
    and (distance_temp[0], distance[0], 1'b1); 
    and (distance_temp[1], distance[1], 1'b1); 
    and (distance_temp[2], distance[2], 1'b1); 
    and (distance_temp[3], distance[3], 1'b1); 
endmodule
 

    // Component: Logic for division
    wire [4:0] temp_fuel_used;
    divide_by_mileage divider(.dividend(distance_temp), .divisor(avg_mileage), .quotient(temp_fuel_used));

    // Component: Calculate remaining fuel
    wire [4:0] temp_remaining_fuel_full;
    remaining_fuel_calculator fuel_calculator(.input_fuel(input_fuel), .fuel_used(temp_fuel_used), .remaining_fuel(temp_remaining_fuel_full));

    // LED indicators based on remaining fuel
    module LED_Indicator_Gates (
    input [4:0] remaining_fuel,
    output LED1,
    output LED2
);
    wire n_rfuel_4, n_rfuel_3, n_rfuel_2, n_rfuel_1, n_rfuel_0;
    wire comp1, comp2, comp3, comp4, comp5, comp6, comp7;
    wire led1_intermediate, led2_intermediate;

    // Generate NOT gates for each bit of `remaining_fuel`
    not (n_rfuel_4, remaining_fuel[4]);
    not (n_rfuel_3, remaining_fuel[3]);
    not (n_rfuel_2, remaining_fuel[2]);
    not (n_rfuel_1, remaining_fuel[1]);
    not (n_rfuel_0, remaining_fuel[0]);

    // Logic for LED1: Turn ON if 3 <= `remaining_fuel` <= 5
    and (comp1, n_rfuel_4, n_rfuel_3, remaining_fuel[2], remaining_fuel[1], n_rfuel_0); // 3
    and (comp2, n_rfuel_4, n_rfuel_3, remaining_fuel[2], remaining_fuel[1], remaining_fuel[0]); // 4
    and (comp3, n_rfuel_4, remaining_fuel[3], n_rfuel_2, n_rfuel_1, n_rfuel_0); // 5
    or (led1_intermediate, comp1, comp2, comp3);
    buf (LED1, led1_intermediate);

    // Logic for LED2: Turn ON if `remaining_fuel` < 2
    and (comp4, n_rfuel_4, n_rfuel_3, n_rfuel_2, n_rfuel_1, n_rfuel_0); // 0
    and (comp5, n_rfuel_4, n_rfuel_3, n_rfuel_2, n_rfuel_1, remaining_fuel[0]); // 1
    or (led2_intermediate, comp4, comp5);
    buf (LED2, led2_intermediate);
endmodule

// Component: Mux definition (2-to-1 multiplexer)
module mux2x1_gates (
    input [1:0] sel,
    input [7:0] in0,
    input [7:0] in1,
    input [7:0] in2,
    input [7:0] in3,
    output [7:0] out
);
    wire [7:0] sel_00, sel_01, sel_10, sel_11;
    wire n_sel0, n_sel1;

    // NOT gates
    not (n_sel0, sel[0]);
    not (n_sel1, sel[1]);

    // AND gates for each case
    and (sel_00[0], in0[0], n_sel1, n_sel0);
    and (sel_01[0], in1[0], n_sel1, sel[0]);
    and (sel_10[0], in2[0], sel[1], n_sel0);
    and (sel_11[0], in3[0], sel[1], sel[0]);
    or (out[0], sel_00[0], sel_01[0], sel_10[0], sel_11[0]);

    // Repeat for other bits
    genvar i;
    generate
        for (i = 1; i < 8; i = i + 1) begin: mux_gates_loop
            and (sel_00[i], in0[i], n_sel1, n_sel0);
            and (sel_01[i], in1[i], n_sel1, sel[0]);
            and (sel_10[i], in2[i], sel[1], n_sel0);
            and (sel_11[i], in3[i], sel[1], sel[0]);
            or (out[i], sel_00[i], sel_01[i], sel_10[i], sel_11[i]);
        end
    endgenerate
endmodule

// Component: 4-bit Adder using gates
module full_adder_gates (
    input a, 
    input b, 
    input cin, 
    output sum, 
    output cout
);
    wire w1, w2, w3;

    xor (w1, a, b);
    xor (sum, w1, cin);
    and (w2, a, b);
    and (w3, w1, cin);
    or (cout, w2, w3);
endmodule

module four_bit_adder_gates (
    input [3:0] a, 
    input [3:0] b, 
    input cin, 
    output [3:0] sum, 
    output cout
);
    wire c1, c2, c3; 

    full_adder_gates fa0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(c1));
    full_adder_gates fa1 (.a(a[1]), .b(b[1]), .cin(c1), .sum(sum[1]), .cout(c2));
    full_adder_gates fa2 (.a(a[2]), .b(b[2]), .cin(c2), .sum(sum[2]), .cout(c3));
    full_adder_gates fa3 (.a(a[3]), .b(b[3]), .cin(c3), .sum(sum[3]), .cout(cout));
endmodule


// Component: Divider module (simple integer division)
module comparator_gates (
    input [7:0] A, 
    input [7:0] B, 
    output greater_or_equal
);
    wire [7:0] diff;
    wire borrow;
    
    subtractor_8bit_gates sub_comp (.a(A), .b(B), .diff(diff), .borrow(borrow));
    
    // If `borrow` is 0, A >= B, else A < B
    not (greater_or_equal, borrow);
endmodule
module full_subtractor (
    input a, 
    input b, 
    input bin, 
    output diff, 
    output bout
);
    wire w1, w2, w3;
    
    xor (w1, a, b);
    xor (diff, w1, bin);
    and (w2, ~a, b);
    and (w3, ~w1, bin);
    or (bout, w2, w3);
endmodule

module subtractor_8bit_gates (
    input [7:0] a, 
    input [7:0] b, 
    output [7:0] diff, 
    output borrow
);
    wire [7:0] borrows;
    
    full_subtractor fs0 (.a(a[0]), .b(b[0]), .bin(0), .diff(diff[0]), .bout(borrows[0]));
    full_subtractor fs1 (.a(a[1]), .b(b[1]), .bin(borrows[0]), .diff(diff[1]), .bout(borrows[1]));
    full_subtractor fs2 (.a(a[2]), .b(b[2]), .bin(borrows[1]), .diff(diff[2]), .bout(borrows[2]));
    full_subtractor fs3 (.a(a[3]), .b(b[3]), .bin(borrows[2]), .diff(diff[3]), .bout(borrows[3]));
    full_subtractor fs4 (.a(a[4]), .b(b[4]), .bin(borrows[3]), .diff(diff[4]), .bout(borrows[4]));
    full_subtractor fs5 (.a(a[5]), .b(b[5]), .bin(borrows[4]), .diff(diff[5]), .bout(borrows[5]));
    full_subtractor fs6 (.a(a[6]), .b(b[6]), .bin(borrows[5]), .diff(diff[6]), .bout(borrows[6]));
    full_subtractor fs7 (.a(a[7]), .b(b[7]), .bin(borrows[6]), .diff(diff[7]), .bout(borrow));
endmodule
module divide_by_mileage_gates (
    input [3:0] dividend,
    input [7:0] divisor,
    output [4:0] quotient
);
    wire [7:0] temp_dividend;
    wire [7:0] shifted_dividend;
    wire greater_equal, diff_borrow;
    wire [7:0] diff;
    
    // Shift dividend left to match with divisor
    module shift_left_dividend_gate_level (
    input [3:0] dividend,
    output [7:0] temp_dividend
);

    // Set the lower 4 bits of temp_dividend to 0
    and (temp_dividend[0], 1'b0, 1'b0);
    and (temp_dividend[1], 1'b0, 1'b0);
    and (temp_dividend[2], 1'b0, 1'b0);
    and (temp_dividend[3], 1'b0, 1'b0);

    // Pass the 4-bit dividend to the upper 4 bits of temp_dividend
    and (temp_dividend[4], dividend[0], 1'b1);
    and (temp_dividend[5], dividend[1], 1'b1);
    and (temp_dividend[6], dividend[2], 1'b1);
    and (temp_dividend[7], dividend[3], 1'b1);

endmodule

    
    // Compare and subtract if greater or equal
    comparator_gates comp (.A(temp_dividend), .B(divisor), .greater_or_equal(greater_equal));
    subtractor_8bit_gates sub (.a(temp_dividend), .b(divisor), .diff(diff), .borrow(diff_borrow));
    
endmodule
