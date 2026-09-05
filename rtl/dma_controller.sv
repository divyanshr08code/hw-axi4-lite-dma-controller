`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2026 19:03:49
// Design Name: 
// Module Name: dma_controller
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


module dma_controller (

    input  logic        clk,
    input  logic        rst,

    //============================================================
    // DMA Configuration
    //============================================================

    input  logic        start,
    input  logic [31:0] source_addr,
    input  logic [31:0] dest_addr,
    input  logic [31:0] length,

    //============================================================
    // DMA Status
    //============================================================

    output logic        busy,
    output logic        done,
    output logic        dma_error,
    output logic [31:0] transfer_count,

    //============================================================
    // Read Engine Interface
    //============================================================

    output logic        read_start,
    output logic [31:0] read_address,

    input  logic        read_busy,
    input  logic        read_done,
    input  logic        read_error,

    //============================================================
    // Write Engine Interface
    //============================================================

    output logic        write_start,
    output logic [31:0] write_address,

    input  logic        write_busy,
    input  logic        write_done,
    input  logic        write_error,

    //============================================================
    // DMA Buffer Interface
    //============================================================

    input  logic [31:0] buffer_data,
    input  logic        buffer_valid,
    output logic        buffer_ready

);

    //============================================================
    // Constants
    //============================================================

    localparam logic [31:0] BYTES_PER_TRANSFER = 32'd4;


    //============================================================
    // Controller FSM
    //============================================================

    typedef enum logic [2:0] {
        IDLE,
        START_READ,
        WAIT_READ,
        START_WRITE,
        WAIT_WRITE,
        UPDATE,
        DONE,
        ERROR
    } state_t;

    state_t state;


    //============================================================
    // Working Registers
    //============================================================

    logic [31:0] current_src;
    logic [31:0] current_dst;
    logic [31:0] remaining;


    //============================================================
    // Combinational Control Outputs
    //============================================================

    always_comb begin

        // Default values

        read_start    = 1'b0;
        read_address  = current_src;

        write_start   = 1'b0;
        write_address = current_dst;

        buffer_ready  = 1'b0;


        case (state)

            //====================================================
            // Start one read operation
            //====================================================

            START_READ: begin

                read_start = 1'b1;

            end


            //====================================================
            // Start write when buffer contains valid data
            //====================================================

            START_WRITE: begin

                if (buffer_valid) begin

                    write_start  = 1'b1;
                    buffer_ready = 1'b1;

                end

            end


            default: begin

            end

        endcase

    end


    //============================================================
    // Sequential Controller
    //============================================================

    always_ff @(posedge clk) begin

        if (rst) begin

            state <= IDLE;

            current_src <= 32'd0;
            current_dst <= 32'd0;
            remaining   <= 32'd0;

            busy <= 1'b0;
            done <= 1'b0;
            dma_error <= 1'b0;

            transfer_count <= 32'd0;

        end

        else begin

            //====================================================
            // DONE is a one-cycle pulse
            //====================================================

            done <= 1'b0;


            case (state)

                //================================================
                // IDLE
                //================================================

                IDLE: begin

                    busy <= 1'b0;

                    if (start) begin

                        dma_error <= 1'b0;
                        transfer_count <= 32'd0;


                        //================================================
                        // Zero-length transfer
                        //================================================

                        if (length == 32'd0) begin

                            state <= DONE;

                        end


                        //================================================
                        // Alignment check
                        //================================================

                        else if ((source_addr[1:0] != 2'b00) ||
                                 (dest_addr[1:0]   != 2'b00) ||
                                 (length[1:0]      != 2'b00)) begin

                            state <= ERROR;

                        end


                        //================================================
                        // Valid transfer
                        //================================================

                        else begin

                            current_src <= source_addr;
                            current_dst <= dest_addr;
                            remaining   <= length;

                            busy <= 1'b1;

                            state <= START_READ;

                        end

                    end

                end


                //================================================
                // START READ
                //================================================

                START_READ: begin

                    state <= WAIT_READ;

                end


                //================================================
                // WAIT READ
                //================================================

                WAIT_READ: begin

                    if (read_error) begin

                        state <= ERROR;

                    end

                    else if (read_done) begin

                        state <= START_WRITE;

                    end

                end


                //================================================
                // START WRITE
                //================================================

                START_WRITE: begin

                    // Wait here until the read engine has placed
                    // valid data into the buffer.

                    if (buffer_valid) begin

                        state <= WAIT_WRITE;

                    end

                end


                //================================================
                // WAIT WRITE
                //================================================

                WAIT_WRITE: begin

                    if (write_error) begin

                        state <= ERROR;

                    end

                    else if (write_done) begin

                        state <= UPDATE;

                    end

                end


                //================================================
                // UPDATE
                //================================================

                UPDATE: begin

                    // Move to next source/destination word

                    current_src <= current_src + BYTES_PER_TRANSFER;
                    current_dst <= current_dst + BYTES_PER_TRANSFER;


                    // Count completed transfer

                    transfer_count <= transfer_count + 32'd1;


                    // Final transfer?

                    if (remaining == BYTES_PER_TRANSFER) begin

                        remaining <= 32'd0;

                        state <= DONE;

                    end

                    else begin

                        remaining <= remaining - BYTES_PER_TRANSFER;

                        state <= START_READ;

                    end

                end


                //================================================
                // DONE
                //================================================

                DONE: begin

                    busy <= 1'b0;

                    done <= 1'b1;

                    state <= IDLE;

                end


                //================================================
                // ERROR
                //================================================

                ERROR: begin

                    busy <= 1'b0;

                    dma_error <= 1'b1;

                    state <= IDLE;

                end


                default: begin

                    state <= IDLE;

                    busy <= 1'b0;

                    dma_error <= 1'b1;

                end

            endcase

        end

    end

endmodule