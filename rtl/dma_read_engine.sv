`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2026 19:03:49
// Design Name: 
// Module Name: dma_read_engine
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


module dma_read_engine (

    input  logic        clk,
    input  logic        rst,

    //============================================================
    // Command interface
    //============================================================

    input  logic        start,
    input  logic [31:0] address,

    output logic        busy,
    output logic        done,
    output logic        error,

    //============================================================
    // Data interface to DMA Buffer
    //============================================================

    output logic [31:0] data_out,
    output logic        data_valid,
    input  logic        data_ready,

    //============================================================
    // AXI4 Read Address Channel
    //============================================================

    output logic [31:0] m_axi_araddr,
    output logic [7:0]  m_axi_arlen,
    output logic [2:0]  m_axi_arsize,
    output logic [1:0]  m_axi_arburst,
    output logic        m_axi_arvalid,
    input  logic        m_axi_arready,

    //============================================================
    // AXI4 Read Data Channel
    //============================================================

    input  logic [31:0] m_axi_rdata,
    input  logic [1:0]  m_axi_rresp,
    input  logic        m_axi_rvalid,
    input  logic        m_axi_rlast,
    output logic        m_axi_rready

);


    //============================================================
    // State machine
    //============================================================

    typedef enum logic [1:0] {

        IDLE,
        READ_ADDRESS,
        READ_DATA

    } state_t;

    state_t state;


    //============================================================
    // Saved address
    //============================================================

    logic [31:0] address_reg;


    //============================================================
    // Combinational outputs
    //============================================================

    always_comb begin

        //--------------------------------------------------------
        // Defaults
        //--------------------------------------------------------

        m_axi_araddr  = address_reg;

        // One AXI beat
        m_axi_arlen   = 8'd0;

        // 2^2 = 4 bytes
        m_axi_arsize  = 3'd2;

        // INCR burst type
        m_axi_arburst = 2'b01;

        m_axi_arvalid = 1'b0;

        m_axi_rready  = 1'b0;


        data_out      = m_axi_rdata;
        data_valid    = 1'b0;

        busy          = 1'b0;


        //--------------------------------------------------------
        // State-dependent outputs
        //--------------------------------------------------------

        case (state)

            READ_ADDRESS: begin

                m_axi_arvalid = 1'b1;

                busy = 1'b1;

            end


            READ_DATA: begin

                // Only accept data when the buffer can accept it
                m_axi_rready = data_ready;

                // Present valid data to the buffer
                data_valid = m_axi_rvalid && m_axi_rlast;

                busy = 1'b1;

            end


            default: begin

            end

        endcase

    end


    //============================================================
    // Sequential logic
    //============================================================

    always_ff @(posedge clk) begin

        if (rst) begin

            state       <= IDLE;

            address_reg <= 32'd0;

            done        <= 1'b0;
            error       <= 1'b0;

        end

        else begin

            //----------------------------------------------------
            // done is a one-cycle pulse
            //----------------------------------------------------

            done <= 1'b0;


            case (state)

                //================================================
                // IDLE
                //================================================

                IDLE: begin

                    if (start) begin

                        address_reg <= address;

                        error <= 1'b0;

                        state <= READ_ADDRESS;

                    end

                end


                //================================================
                // READ ADDRESS
                //================================================

                READ_ADDRESS: begin

                    if (m_axi_arvalid && m_axi_arready) begin

                        state <= READ_DATA;

                    end

                end


                //================================================
                // READ DATA
                //================================================

                READ_DATA: begin

                    if (m_axi_rvalid && m_axi_rready) begin

                        //------------------------------------------------
                        // AXI response error
                        //------------------------------------------------

                        if (m_axi_rresp != 2'b00) begin

                            error <= 1'b1;

                            state <= IDLE;

                        end


                        //------------------------------------------------
                        // Single-beat transaction must terminate
                        //------------------------------------------------

                        else if (!m_axi_rlast) begin

                            error <= 1'b1;

                            state <= IDLE;

                        end


                        //------------------------------------------------
                        // Successful read
                        //------------------------------------------------

                        else begin

                            done <= 1'b1;

                            state <= IDLE;

                        end

                    end

                end


                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule
