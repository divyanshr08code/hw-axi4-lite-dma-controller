`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.08.2026 22:49:15
// Design Name: 
// Module Name: axi4lite_tb
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


module axi4lite_tb;

    logic clk;
    logic rst;

    // AXI Write Address
    logic [31:0] awaddr;
    logic        awvalid;
    logic        awready;

    // AXI Write Data
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wvalid;
    logic        wready;

    // AXI Write Response
    logic [1:0]  bresp;
    logic        bvalid;
    logic        bready;

    // AXI Read Address
    logic [31:0] araddr;
    logic        arvalid;
    logic        arready;

    // AXI Read Data
    logic [31:0] rdata;
    logic [1:0]  rresp;
    logic        rvalid;
    logic        rready;


    // Register interface
    logic        reg_write_en;
    logic [31:0] reg_write_addr;
    logic [31:0] reg_write_data;
    logic [3:0]  reg_write_strb;

    logic [31:0] reg_read_addr;
    logic [31:0] reg_read_data;


    // DMA status/control
    logic        start;
    logic [31:0] source_addr;
    logic [31:0] dest_addr;
    logic [31:0] length;

    logic        busy;
    logic        done;
    logic        dma_error;
    logic [31:0] transfer_count;


    //============================================================
    // AXI4-Lite Slave
    //============================================================

    axi4lite_slave axi_slave (

        .clk            (clk),
        .rst            (rst),

        .s_axi_awaddr   (awaddr),
        .s_axi_awvalid  (awvalid),
        .s_axi_awready  (awready),

        .s_axi_wdata    (wdata),
        .s_axi_wstrb    (wstrb),
        .s_axi_wvalid   (wvalid),
        .s_axi_wready   (wready),

        .s_axi_bresp    (bresp),
        .s_axi_bvalid   (bvalid),
        .s_axi_bready   (bready),

        .s_axi_araddr   (araddr),
        .s_axi_arvalid  (arvalid),
        .s_axi_arready  (arready),

        .s_axi_rdata    (rdata),
        .s_axi_rresp   (rresp),
        .s_axi_rvalid   (rvalid),
        .s_axi_rready   (rready),

        .reg_write_en   (reg_write_en),
        .reg_write_addr (reg_write_addr),
        .reg_write_data (reg_write_data),
        .reg_write_strb (reg_write_strb),

        .reg_read_addr  (reg_read_addr),
        .reg_read_data  (reg_read_data)
    );


    //============================================================
    // DMA Register Bank
    //============================================================

    dma_registers registers (

        .clk            (clk),
        .rst            (rst),

        .write_en       (reg_write_en),
        .write_addr     (reg_write_addr),
        .write_data     (reg_write_data),
        .write_strb     (reg_write_strb),

        .read_addr      (reg_read_addr),
        .read_data      (reg_read_data),

        .start          (start),
        .source_addr    (source_addr),
        .dest_addr      (dest_addr),
        .length         (length),

        .busy           (busy),
        .done           (done),
        .dma_error      (dma_error),
        .transfer_count (transfer_count)
    );


    //============================================================
    // Clock
    //============================================================

    initial begin
        clk = 1'b0;
    end

    always #5 clk = ~clk;


    //============================================================
    // AXI WRITE: AW FIRST
    //============================================================

    task automatic axi_write_aw_first(
        input logic [31:0] address,
        input logic [31:0] data
    );

        begin

            awaddr  = address;
            awvalid = 1'b1;

            while (!awready)
                @(posedge clk);

            @(posedge clk);

            awvalid = 1'b0;


            wdata  = data;
            wstrb  = 4'b1111;
            wvalid = 1'b1;

            while (!wready)
                @(posedge clk);

            @(posedge clk);

            wvalid = 1'b0;


            bready = 1'b1;

            while (!bvalid)
                @(posedge clk);

            if (bresp !== 2'b00)
                $error("AW-FIRST WRITE FAILED");

            else
                $display("AW-FIRST WRITE PASSED");


            @(posedge clk);

            bready = 1'b0;

        end

    endtask


    //============================================================
    // AXI WRITE: W FIRST
    //============================================================

    task automatic axi_write_w_first(
        input logic [31:0] address,
        input logic [31:0] data
    );

        begin

            wdata  = data;
            wstrb  = 4'b1111;
            wvalid = 1'b1;

            while (!wready)
                @(posedge clk);

            @(posedge clk);

            wvalid = 1'b0;


            awaddr  = address;
            awvalid = 1'b1;

            while (!awready)
                @(posedge clk);

            @(posedge clk);

            awvalid = 1'b0;


            bready = 1'b1;

            while (!bvalid)
                @(posedge clk);

            if (bresp !== 2'b00)
                $error("W-FIRST WRITE FAILED");

            else
                $display("W-FIRST WRITE PASSED");


            @(posedge clk);

            bready = 1'b0;

        end

    endtask


    //============================================================
    // AXI READ
    //============================================================

    task automatic axi_read(
        input logic [31:0] address,
        input logic [31:0] expected
    );

        begin

            araddr  = address;
            arvalid = 1'b1;

            while (!arready)
                @(posedge clk);

            @(posedge clk);

            arvalid = 1'b0;


            rready = 1'b1;

            while (!rvalid)
                @(posedge clk);

            if (rresp !== 2'b00) begin

                $error(
                    "READ RESPONSE ERROR: address=%h",
                    address
                );

            end

            else if (rdata !== expected) begin

                $error(
                    "READ FAILED: address=%h expected=%h actual=%h",
                    address,
                    expected,
                    rdata
                );

            end

            else begin

                $display(
                    "READ PASSED: address=%h data=%h",
                    address,
                    rdata
                );

            end


            @(posedge clk);

            rready = 1'b0;

        end

    endtask


    //============================================================
    // Test Sequence
    //============================================================

    initial begin

        // Initial values
        rst = 1'b1;

        awaddr  = 32'd0;
        awvalid = 1'b0;

        wdata   = 32'd0;
        wstrb   = 4'd0;
        wvalid  = 1'b0;

        bready  = 1'b0;

        araddr  = 32'd0;
        arvalid = 1'b0;

        rready  = 1'b0;


        // Fake DMA status
        busy           = 1'b0;
        done           = 1'b0;
        dma_error      = 1'b0;
        transfer_count = 32'd0;


        // Reset
        repeat (2) @(posedge clk);

        rst = 1'b0;


        //========================================================
        // SOURCE ADDRESS
        //========================================================

        axi_write_aw_first(
            32'h0000_0008,
            32'h0000_1000
        );

        axi_read(
            32'h0000_0008,
            32'h0000_1000
        );


        //========================================================
        // DESTINATION ADDRESS
        //========================================================

        axi_write_w_first(
            32'h0000_000C,
            32'h0000_8000
        );

        axi_read(
            32'h0000_000C,
            32'h0000_8000
        );


        //========================================================
        // LENGTH
        //========================================================

        axi_write_aw_first(
            32'h0000_0010,
            32'h0000_0040
        );

        axi_read(
            32'h0000_0010,
            32'h0000_0040
        );


        //========================================================
        // START
        //========================================================

        axi_write_aw_first(
            32'h0000_0000,
            32'h0000_0001
        );

        @(posedge clk);

        if (start !== 1'b1)
            $error("START PULSE FAILED");

        else
            $display("START PULSE PASSED");


        @(posedge clk);

        if (start !== 1'b0)
            $error("START IS NOT ONE CYCLE");

        else
            $display("START ONE-CYCLE CHECK PASSED");


        //========================================================
        // STATUS
        //========================================================

        axi_read(
            32'h0000_0004,
            32'h0000_0000
        );


        $display("------------------------------------");
        $display("AXI4-LITE TEST COMPLETED");
        $display("------------------------------------");

        $finish;

    end

endmodule
