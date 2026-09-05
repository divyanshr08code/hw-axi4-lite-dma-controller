`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2026 19:03:49
// Design Name: 
// Module Name: dma_buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dma_buffer (

    input  logic        clk,
    input  logic        rst,

    //============================================================
    // Producer interface
    // Read Engine -> Buffer
    //============================================================

    input  logic [31:0] write_data,
    input  logic        write_valid,
    output logic        write_ready,

    //============================================================
    // Consumer interface
    // Buffer -> Write Engine
    //============================================================

    output logic [31:0] read_data,
    output logic        read_valid,
    input  logic        read_ready

);


    //============================================================
    // Internal storage
    //============================================================

    logic [31:0] data_reg;
    logic        valid_reg;


    //============================================================
    // Ready / Valid
    //============================================================

    always_comb begin

        // Buffer can accept data when it is empty
        write_ready = !valid_reg;

        // Buffer presents data whenever it contains valid data
        read_valid  = valid_reg;

        read_data   = data_reg;

    end


    //============================================================
    // Sequential storage
    //============================================================

    always_ff @(posedge clk) begin

        if (rst) begin

            data_reg  <= 32'd0;
            valid_reg <= 1'b0;

        end

        else begin

            //----------------------------------------------------
            // New data accepted from read engine
            //----------------------------------------------------

            if (write_valid && write_ready) begin

                data_reg  <= write_data;
                valid_reg <= 1'b1;

            end


            //----------------------------------------------------
            // Existing data consumed by write engine
            //----------------------------------------------------

            else if (read_valid && read_ready) begin

                valid_reg <= 1'b0;

            end

        end

    end

endmodule