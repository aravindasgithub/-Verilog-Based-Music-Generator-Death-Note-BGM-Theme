`timescale 1ns / 1ps

module main(
    input clk,          // FPGA clock input (50 MHz)
    output reg speaker  // Speaker output
);

    reg [31:0] counter;
    reg [31:0] note_counter;
    reg [3:0] note_index;
    reg playing;
    
    // Define note frequencies (50MHz / (2 * Frequency))
    parameter G5 = 6378;  // 784 Hz
    parameter E5 = 7584;  // 659 Hz
    parameter A5 = 5682;  // 880 Hz
    parameter F5S = 6757; // F#5 (740 Hz)
    parameter B5 = 5062;  // 988 Hz
    parameter D5 = 8513;  // 587 Hz
    
    reg [31:0] melody [0:12];  // Reduced to 13 notes (Removed last E5)
    initial begin
        melody[0] = G5;
        melody[1] = E5;
        melody[2] = A5;
        melody[3] = E5;
        melody[4] = F5S;
        melody[5] = G5;
        melody[6] = E5;
        melody[7] = B5;
        melody[8] = A5;
        melody[9] = G5;
        melody[10] = F5S;
        melody[11] = E5;
        melody[12] = D5;
    end

    initial begin
        playing = 1; // Start playing immediately
        note_index = 0;
        note_counter = 0;
    end
    
    always @(posedge clk) begin
        if (playing) begin
            counter <= counter + 1;
            if (counter >= melody[note_index]) begin
                counter <= 0;
                speaker <= ~speaker;  // Toggle speaker output
            end
        end else begin
            speaker <= 0; // Silence during break
        end
    end
    
    // Handle note timing and breaks
    always @(posedge clk) begin
        note_counter <= note_counter + 1;
        if (note_counter >= 2500000) begin  // 0.05s (50ms) assuming 50MHz clock
            playing <= 0;  // Stop playing for the break
            if (note_counter >= 2900000) begin // 0.008s (8ms) break
                playing <= 1;  // Resume playing
                note_counter <= 0;
                note_index <= note_index + 1;
                if (note_index == 13) note_index <= 0; // Loop melody
            end
        end
    end
    
endmodule
