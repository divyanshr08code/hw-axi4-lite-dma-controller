`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.08.2026 21:14:33
// Design Name: 
// Module Name: dma_registers
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


module dma_registers (
    input  logic        clk,
    input  logic        rst,

    // Register write interface
    input  logic        write_en,
    input  logic [31:0] write_addr,
    input  logic [31:0] write_data,
    input  logic [3:0]  write_strb,

    // Register read interface
    input  logic [31:0] read_addr,
    output logic [31:0] read_data,

    // DMA control outputs
    output logic        start,
    output logic [31:0] source_addr,
    output logic [31:0] dest_addr,
    output logic [31:0] length,

    // DMA status inputs
    input  logic        busy,
    input  logic        done,
    input  logic        dma_error,
    input  logic [31:0] transfer_count
);

    localparam logic [31:0] ADDR_CONTROL        = 32'h0000_0000;
    localparam logic [31:0] ADDR_STATUS         = 32'h0000_0004;
    localparam logic [31:0] ADDR_SOURCE_ADDR    = 32'h0000_0008;
    localparam logic [31:0] ADDR_DEST_ADDR      = 32'h0000_000C;
    localparam logic [31:0] ADDR_LENGTH         = 32'h0000_0010;
    localparam logic [31:0] ADDR_TRANSFER_COUNT = 32'h0000_0014;
    localparam logic [31:0] ADDR_ERROR          = 32'h0000_0018;


    // Writeable configuration registers
    always_ff @(posedge clk) begin

        if (rst) begin

            source_addr <= 32'd0;
            dest_addr   <= 32'd0;
            length      <= 32'd0;
            start       <= 1'b0;

        end

        else begin

            // START is a one-cycle pulse
            start <= 1'b0;

            if (write_en) begin

                case (write_addr)

                    ADDR_CONTROL: begin

                        if (write_strb[0] && write_data[0])
                            start <= 1'b1;

                    end


                    ADDR_SOURCE_ADDR: begin

                        if (write_strb[0])
                            source_addr[7:0] <= write_data[7:0];

                        if (write_strb[1])
                            source_addr[15:8] <= write_data[15:8];

                        if (write_strb[2])
                            source_addr[23:16] <= write_data[23:16];

                        if (write_strb[3])
                            source_addr[31:24] <= write_data[31:24];

                    end


                    ADDR_DEST_ADDR: begin

                        if (write_strb[0])
                            dest_addr[7:0] <= write_data[7:0];

                        if (write_strb[1])
                            dest_addr[15:8] <= write_data[15:8];

                        if (write_strb[2])
                            dest_addr[23:16] <= write_data[23:16];

                        if (write_strb[3])
                            dest_addr[31:24] <= write_data[31:24];

                    end


                    ADDR_LENGTH: begin

                        if (write_strb[0])
                            length[7:0] <= write_data[7:0];

                        if (write_strb[1])
                            length[15:8] <= write_data[15:8];

                        if (write_strb[2])
                            length[23:16] <= write_data[23:16];

                        if (write_strb[3])
                            length[31:24] <= write_data[31:24];

                    end

                    default: begin
                    end

                endcase

            end

        end

    end


    // Register read multiplexer
    always_comb begin

        read_data = 32'd0;

        case (read_addr)

            ADDR_CONTROL:
                read_data = 32'd0;

            ADDR_STATUS:
                read_data = {
                    29'd0,
                    dma_error,
                    done,
                    busy
                };

            ADDR_SOURCE_ADDR:
                read_data = source_addr;

            ADDR_DEST_ADDR:
                read_data = dest_addr;

            ADDR_LENGTH:
                read_data = length;

            ADDR_TRANSFER_COUNT:
                read_data = transfer_count;

            ADDR_ERROR:
                read_data = {31'd0, dma_error};

            default:
                read_data = 32'd0;

        endcase

    end

endmodule
