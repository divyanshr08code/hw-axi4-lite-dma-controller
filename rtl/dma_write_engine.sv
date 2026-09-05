`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2026 19:03:49
// Design Name: 
// Module Name: dma_write_engine
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


module dma_write_engine (

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
    // Data interface from DMA Buffer
    //============================================================

    input  logic [31:0] data_in,
    input  logic        data_valid,
    output logic        data_ready,

    //============================================================
    // AXI4 Write Address Channel
    //============================================================

    output logic [31:0] m_axi_awaddr,
    output logic [7:0]  m_axi_awlen,
    output logic [2:0]  m_axi_awsize,
    output logic [1:0]  m_axi_awburst,
    output logic        m_axi_awvalid,
    input  logic        m_axi_awready,

    //============================================================
    // AXI4 Write Data Channel
    //============================================================

    output logic [31:0] m_axi_wdata,
    output logic [3:0]  m_axi_wstrb,
    output logic        m_axi_wlast,
    output logic        m_axi_wvalid,
    input  logic        m_axi_wready,

    //============================================================
    // AXI4 Write Response Channel
    //============================================================

    input  logic [1:0]  m_axi_bresp,
    input  logic        m_axi_bvalid,
    output logic        m_axi_bready

);


    //============================================================
    // State machine
    //============================================================

    typedef enum logic [1:0] {

        IDLE,
        WRITE_ADDRESS,
        WRITE_DATA,
        WRITE_RESPONSE

    } state_t;

    state_t state;


    //============================================================
    // Internal registers
    //============================================================

    logic [31:0] address_reg;
    logic [31:0] data_reg;


    //============================================================
    // Combinational outputs
    //============================================================

    always_comb begin

        //--------------------------------------------------------
        // Defaults
        //--------------------------------------------------------

        m_axi_awaddr  = address_reg;

        // One AXI beat
        m_axi_awlen   = 8'd0;

        // 4-byte transfer
        m_axi_awsize  = 3'd2;

        // INCR burst
        m_axi_awburst = 2'b01;

        m_axi_awvalid = 1'b0;


        m_axi_wdata   = data_reg;
        m_axi_wstrb   = 4'b1111;
        m_axi_wlast   = 1'b1;
        m_axi_wvalid  = 1'b0;


        m_axi_bready  = 1'b0;


        //--------------------------------------------------------
        // We can accept buffer data when starting a transaction
        //--------------------------------------------------------

        data_ready = (state == IDLE) && start;


        busy = 1'b0;


        //--------------------------------------------------------
        // State-dependent outputs
        //--------------------------------------------------------

        case (state)

            WRITE_ADDRESS: begin

                m_axi_awvalid = 1'b1;

                busy = 1'b1;

            end


            WRITE_DATA: begin

                m_axi_wvalid = 1'b1;

                busy = 1'b1;

            end


            WRITE_RESPONSE: begin

                m_axi_bready = 1'b1;

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

            state <= IDLE;

            address_reg <= 32'd0;
            data_reg    <= 32'd0;

            done  <= 1'b0;
            error <= 1'b0;

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

                    //------------------------------------------------
                    // Command and buffer data arrive together
                    //------------------------------------------------

                    if (start && data_valid) begin

                        address_reg <= address;

                        data_reg <= data_in;

                        error <= 1'b0;

                        state <= WRITE_ADDRESS;

                    end

                end


                //================================================
                // WRITE ADDRESS
                //================================================

                WRITE_ADDRESS: begin

                    if (m_axi_awvalid && m_axi_awready) begin

                        state <= WRITE_DATA;

                    end

                end


                //================================================
                // WRITE DATA
                //================================================

                WRITE_DATA: begin

                    if (m_axi_wvalid && m_axi_wready) begin

                        state <= WRITE_RESPONSE;

                    end

                end


                //================================================
                // WRITE RESPONSE
                //================================================

                WRITE_RESPONSE: begin

                    if (m_axi_bvalid && m_axi_bready) begin

                        if (m_axi_bresp != 2'b00) begin

                            error <= 1'b1;

                        end

                        else begin

                            done <= 1'b1;

                        end

                        state <= IDLE;

                    end

                end


                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule