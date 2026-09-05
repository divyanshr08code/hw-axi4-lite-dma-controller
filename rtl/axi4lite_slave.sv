
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.08.2026 22:00:50
// Design Name: 
// Module Name: axi4lite_slave
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


`timescale 1ns / 1ps

module axi4lite_slave (

    input  logic        clk,
    input  logic        rst,

    //============================================================
    // AXI4-Lite Write Address Channel
    //============================================================

    input  logic [31:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,

    //============================================================
    // AXI4-Lite Write Data Channel
    //============================================================

    input  logic [31:0] s_axi_wdata,
    input  logic [3:0]  s_axi_wstrb,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,

    //============================================================
    // AXI4-Lite Write Response Channel
    //============================================================

    output logic [1:0]  s_axi_bresp,
    output logic        s_axi_bvalid,
    input  logic        s_axi_bready,

    //============================================================
    // AXI4-Lite Read Address Channel
    //============================================================

    input  logic [31:0] s_axi_araddr,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,

    //============================================================
    // AXI4-Lite Read Data Channel
    //============================================================

    output logic [31:0] s_axi_rdata,
    output logic [1:0]  s_axi_rresp,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready,

    //============================================================
    // Register Interface
    //============================================================

    output logic        reg_write_en,
    output logic [31:0] reg_write_addr,
    output logic [31:0] reg_write_data,
    output logic [3:0]  reg_write_strb,

    output logic [31:0] reg_read_addr,
    input  logic [31:0] reg_read_data

);


    //============================================================
    // Write-side storage
    //============================================================

    logic        aw_received;
    logic        w_received;

    logic [31:0] awaddr_reg;
    logic [31:0] wdata_reg;
    logic [3:0]  wstrb_reg;


    //============================================================
    // Write FSM
    //============================================================

    typedef enum logic [1:0] {

        WRITE_IDLE,
        WRITE_COMMIT,
        WRITE_RESPONSE

    } write_state_t;

    write_state_t write_state;


    //============================================================
    // Read-side storage
    //============================================================

    logic [31:0] read_addr_reg;


    //============================================================
    // Read FSM
    //============================================================

    typedef enum logic {

        READ_IDLE,
        READ_RESPONSE

    } read_state_t;

    read_state_t read_state;


    //============================================================
    // Combinational AXI outputs
    //============================================================

    always_comb begin

        //--------------------------------------------------------
        // Default values
        //--------------------------------------------------------

        s_axi_awready = 1'b0;
        s_axi_wready  = 1'b0;
        s_axi_arready = 1'b0;

        reg_write_en   = 1'b0;
        reg_write_addr = awaddr_reg;
        reg_write_data = wdata_reg;
        reg_write_strb = wstrb_reg;

        reg_read_addr  = read_addr_reg;


        //--------------------------------------------------------
        // Accept write address
        //--------------------------------------------------------

        if ((write_state == WRITE_IDLE) &&
            !aw_received) begin

            s_axi_awready = 1'b1;

        end


        //--------------------------------------------------------
        // Accept write data
        //--------------------------------------------------------

        if ((write_state == WRITE_IDLE) &&
            !w_received) begin

            s_axi_wready = 1'b1;

        end


        //--------------------------------------------------------
        // Commit register write
        //--------------------------------------------------------

        if (write_state == WRITE_COMMIT) begin

            reg_write_en = 1'b1;

        end


        //--------------------------------------------------------
        // Accept read address
        //--------------------------------------------------------

        if (read_state == READ_IDLE) begin

            s_axi_arready = 1'b1;

        end

    end


    //============================================================
    // Sequential AXI control
    //============================================================

    always_ff @(posedge clk) begin

        if (rst) begin

            //====================================================
            // Write reset
            //====================================================

            aw_received <= 1'b0;
            w_received  <= 1'b0;

            awaddr_reg <= 32'd0;
            wdata_reg  <= 32'd0;
            wstrb_reg  <= 4'd0;

            write_state <= WRITE_IDLE;

            s_axi_bvalid <= 1'b0;
            s_axi_bresp  <= 2'b00;


            //====================================================
            // Read reset
            //====================================================

            read_addr_reg <= 32'd0;

            read_state <= READ_IDLE;

            s_axi_rdata  <= 32'd0;
            s_axi_rresp  <= 2'b00;
            s_axi_rvalid <= 1'b0;

        end

        else begin

            //====================================================
            // WRITE ADDRESS CHANNEL
            //====================================================

            if (s_axi_awvalid && s_axi_awready) begin

                awaddr_reg  <= s_axi_awaddr;
                aw_received <= 1'b1;

            end


            //====================================================
            // WRITE DATA CHANNEL
            //====================================================

            if (s_axi_wvalid && s_axi_wready) begin

                wdata_reg  <= s_axi_wdata;
                wstrb_reg  <= s_axi_wstrb;
                w_received <= 1'b1;

            end


            //====================================================
            // WRITE FSM
            //====================================================

            case (write_state)

                //------------------------------------------------
                // Wait for both AW and W
                //------------------------------------------------

                WRITE_IDLE: begin

                    if (aw_received && w_received) begin

                        write_state <= WRITE_COMMIT;

                    end

                end


                //------------------------------------------------
                // Generate register write pulse
                //------------------------------------------------

                WRITE_COMMIT: begin

                    write_state <= WRITE_RESPONSE;

                end


                //------------------------------------------------
                // Hold write response until accepted
                //------------------------------------------------

                WRITE_RESPONSE: begin

                    s_axi_bvalid <= 1'b1;
                    s_axi_bresp  <= 2'b00;

                    if (s_axi_bvalid && s_axi_bready) begin

                        s_axi_bvalid <= 1'b0;

                        aw_received <= 1'b0;
                        w_received  <= 1'b0;

                        write_state <= WRITE_IDLE;

                    end

                end


                default: begin

                    write_state <= WRITE_IDLE;

                    aw_received <= 1'b0;
                    w_received  <= 1'b0;

                end

            endcase


            //====================================================
            // READ ADDRESS CHANNEL
            //====================================================

            if (s_axi_arvalid && s_axi_arready) begin

                read_addr_reg <= s_axi_araddr;

                read_state <= READ_RESPONSE;

            end


            //====================================================
            // READ RESPONSE
            //====================================================

            if (read_state == READ_RESPONSE) begin

                s_axi_rdata  <= reg_read_data;
                s_axi_rresp  <= 2'b00;
                s_axi_rvalid <= 1'b1;

                if (s_axi_rvalid && s_axi_rready) begin

                    s_axi_rvalid <= 1'b0;

                    read_state <= READ_IDLE;

                end

            end

        end

    end

endmodule
