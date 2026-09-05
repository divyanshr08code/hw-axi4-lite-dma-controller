`timescale 1ns / 1ps

module dma_tb;

    //============================================================
    // CLOCK AND RESET
    //============================================================

    logic clk;
    logic rst;

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    //============================================================
    // AXI4-LITE SLAVE INTERFACE
    //============================================================

    logic [31:0] s_axi_awaddr;
    logic        s_axi_awvalid;
    logic        s_axi_awready;

    logic [31:0] s_axi_wdata;
    logic [3:0]  s_axi_wstrb;
    logic        s_axi_wvalid;
    logic        s_axi_wready;

    logic [1:0]  s_axi_bresp;
    logic        s_axi_bvalid;
    logic        s_axi_bready;

    logic [31:0] s_axi_araddr;
    logic        s_axi_arvalid;
    logic        s_axi_arready;

    logic [31:0] s_axi_rdata;
    logic [1:0]  s_axi_rresp;
    logic        s_axi_rvalid;
    logic        s_axi_rready;


    //============================================================
    // AXI4 MASTER INTERFACE
    //============================================================

    logic [31:0] m_axi_araddr;
    logic [7:0]  m_axi_arlen;
    logic [2:0]  m_axi_arsize;
    logic [1:0]  m_axi_arburst;
    logic        m_axi_arvalid;
    logic        m_axi_arready;

    logic [31:0] m_axi_rdata;
    logic [1:0]  m_axi_rresp;
    logic        m_axi_rvalid;
    logic        m_axi_rlast;
    logic        m_axi_rready;

    logic [31:0] m_axi_awaddr;
    logic [7:0]  m_axi_awlen;
    logic [2:0]  m_axi_awsize;
    logic [1:0]  m_axi_awburst;
    logic        m_axi_awvalid;
    logic        m_axi_awready;

    logic [31:0] m_axi_wdata;
    logic [3:0]  m_axi_wstrb;
    logic        m_axi_wlast;
    logic        m_axi_wvalid;
    logic        m_axi_wready;

    logic [1:0]  m_axi_bresp;
    logic        m_axi_bvalid;
    logic        m_axi_bready;


    //============================================================
    // DUT
    //============================================================

    dma_top dut (

        .clk(clk),
        .rst(rst),

        // AXI4-Lite
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),

        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),

        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),

        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),

        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),

        // AXI4 Master
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),

        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rready(m_axi_rready),

        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),

        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),

        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready)

    );


    //============================================================
    // SVA
    //============================================================

    dma_sva sva (

        .clk(clk),
        .rst(rst),

        .start(dut.start),
        .busy(dut.busy),
        .done(dut.done),
        .dma_error(dut.dma_error),

        .m_axi_araddr(m_axi_araddr),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),

        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),

        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),

        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),

        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready)

    );


    //============================================================
    // MEMORY MODEL
    //============================================================

    logic [31:0] memory [0:4095];


    //============================================================
    // WRITE TRANSACTION STORAGE
    //============================================================

    logic        write_addr_received;
    logic [31:0] write_addr_reg;


    //============================================================
    // MEMORY INITIALIZATION
    //============================================================

    initial begin : memory_init

        integer i;

        for (i = 0; i < 4096; i = i + 1)
            memory[i] = 32'd0;

    end


    //============================================================
    // AXI4 READY SIGNALS
    //
    // These are continuously driven.
    // They are NOT assigned anywhere else.
    //============================================================

    assign m_axi_arready = !m_axi_rvalid;

    assign m_axi_awready = !write_addr_received;

    assign m_axi_wready  = !m_axi_bvalid;


    //============================================================
    // AXI4 READ RESPONSE MODEL
    //
    // ONLY this always_ff drives:
    //   m_axi_rvalid
    //   m_axi_rdata
    //   m_axi_rresp
    //   m_axi_rlast
    //============================================================

    always_ff @(posedge clk) begin

        if (rst) begin

            m_axi_rvalid <= 1'b0;
            m_axi_rdata  <= 32'd0;
            m_axi_rresp  <= 2'b00;
            m_axi_rlast  <= 1'b1;

        end

        else begin

            //----------------------------------------------------
            // Accept read address
            //----------------------------------------------------

            if (m_axi_arvalid && m_axi_arready) begin

                m_axi_rdata <= memory[m_axi_araddr >> 2];
                m_axi_rresp <= 2'b00;
                m_axi_rlast <= 1'b1;

                m_axi_rvalid <= 1'b1;

            end

            //----------------------------------------------------
            // Accept read data
            //----------------------------------------------------

            else if (m_axi_rvalid && m_axi_rready) begin

                m_axi_rvalid <= 1'b0;

            end

        end

    end


    //============================================================
    // AXI4 WRITE RESPONSE MODEL
    //
    // ONLY this always_ff drives:
    //   write_addr_received
    //   write_addr_reg
    //   m_axi_bvalid
    //   m_axi_bresp
    //============================================================

    always_ff @(posedge clk) begin

        if (rst) begin

            write_addr_received <= 1'b0;
            write_addr_reg      <= 32'd0;

            m_axi_bvalid <= 1'b0;
            m_axi_bresp  <= 2'b00;

        end

        else begin

            //----------------------------------------------------
            // Accept write address
            //----------------------------------------------------

            if (m_axi_awvalid && m_axi_awready) begin

                write_addr_reg      <= m_axi_awaddr;
                write_addr_received <= 1'b1;

            end


            //----------------------------------------------------
            // Accept write data
            //----------------------------------------------------

            if (m_axi_wvalid && m_axi_wready) begin

                if (write_addr_received) begin

                    memory[write_addr_reg >> 2] <= m_axi_wdata;

                    m_axi_bresp  <= 2'b00;
                    m_axi_bvalid <= 1'b1;

                    write_addr_received <= 1'b0;

                end

            end


            //----------------------------------------------------
            // Accept write response
            //----------------------------------------------------

            if (m_axi_bvalid && m_axi_bready) begin

                m_axi_bvalid <= 1'b0;

            end

        end

    end


    //============================================================
    // AXI4-LITE DEFAULT INPUTS
    //
    // These signals are TB-driven and have only one driver.
    //============================================================

    initial begin : axi_lite_defaults

        s_axi_awaddr  = 32'd0;
        s_axi_awvalid = 1'b0;

        s_axi_wdata   = 32'd0;
        s_axi_wstrb   = 4'b1111;
        s_axi_wvalid  = 1'b0;

        s_axi_bready  = 1'b1;

        s_axi_araddr  = 32'd0;
        s_axi_arvalid = 1'b0;

        s_axi_rready  = 1'b1;

    end


    //============================================================
    // RESET TASK
    //============================================================

    task automatic reset_dut;

        begin

            rst = 1'b1;

            repeat (5)
                @(posedge clk);

            rst = 1'b0;

            @(posedge clk);

        end

    endtask


    //============================================================
    // AXI4-LITE WRITE TASK
    //============================================================

    task axi_write (
    input logic [31:0] address,
    input logic [31:0] data
);

    begin

        @(posedge clk);

        s_axi_awaddr  <= address;
        s_axi_awvalid <= 1'b1;

        s_axi_wdata   <= data;
        s_axi_wstrb   <= 4'b1111;
        s_axi_wvalid  <= 1'b1;

        $display("WRITE: AWVALID/WVALID asserted");

        wait (s_axi_awready && s_axi_awvalid);

        $display("WRITE: AW handshake");

        @(posedge clk);
        s_axi_awvalid <= 1'b0;

        wait (s_axi_wready && s_axi_wvalid);

        $display("WRITE: W handshake");

        @(posedge clk);
        s_axi_wvalid <= 1'b0;

        wait (s_axi_bvalid);

        $display("WRITE: BVALID received");

        @(posedge clk);

        s_axi_bready <= 1'b1;

        wait (!s_axi_bvalid);

        $display("WRITE: Complete");

    end

endtask


    //============================================================
    // AXI4-LITE READ TASK
    //============================================================

    task automatic axi_read (

        input  logic [31:0] address,
        output logic [31:0] data

    );

        begin

            //----------------------------------------------------
            // Drive read address
            //----------------------------------------------------

            @(negedge clk);

            s_axi_araddr  = address;
            s_axi_arvalid = 1'b1;


            //----------------------------------------------------
            // Wait for address handshake
            //----------------------------------------------------

            @(posedge clk);

            while (!s_axi_arready) begin
                @(posedge clk);
            end

            @(negedge clk);

            s_axi_arvalid = 1'b0;


            //----------------------------------------------------
            // Wait for read response
            //----------------------------------------------------

            @(posedge clk);

            while (!s_axi_rvalid) begin
                @(posedge clk);
            end

            data = s_axi_rdata;

            @(negedge clk);

            s_axi_rready = 1'b1;

            @(posedge clk);

        end

    endtask


    //============================================================
    // MAIN TEST
    //============================================================

    initial begin : main_test

        logic [31:0] read_value;

        //--------------------------------------------------------
        // Initial reset
        //--------------------------------------------------------

        rst = 1'b0;

        reset_dut();


        //========================================================
        // INITIALIZE SOURCE MEMORY
        //========================================================

        memory[32'h1000 >> 2] = 32'hAAAA_AAAA;
        memory[32'h1004 >> 2] = 32'hBBBB_BBBB;
        memory[32'h1008 >> 2] = 32'hCCCC_CCCC;
        memory[32'h100C >> 2] = 32'hDDDD_DDDD;


        $display("");
        $display("==============================================");
        $display("       DMA VERIFICATION TEST STARTED");
        $display("==============================================");


        //========================================================
        // TEST AXI4-LITE REGISTER WRITES
        //========================================================

        $display("Writing SOURCE_ADDR...");

        axi_write(
            32'h0000_0008,
            32'h0000_1000
        );


        $display("Writing DEST_ADDR...");

        axi_write(
            32'h0000_000C,
            32'h0000_2000
        );


        $display("Writing LENGTH...");

        axi_write(
            32'h0000_0010,
            32'd16
        );


        //========================================================
        // VERIFY REGISTER VALUES
        //========================================================

        $display("Checking SOURCE_ADDR...");

        axi_read(
            32'h0000_0008,
            read_value
        );

        if (read_value !== 32'h0000_1000) begin

            $error(
                "FAIL: SOURCE_ADDR = %h, expected 00001000",
                read_value
            );

        end
        else begin

            $display("SOURCE_ADDR CHECK PASSED");

        end


        $display("Checking DEST_ADDR...");

        axi_read(
            32'h0000_000C,
            read_value
        );

        if (read_value !== 32'h0000_2000) begin

            $error(
                "FAIL: DEST_ADDR = %h, expected 00002000",
                read_value
            );

        end
        else begin

            $display("DEST_ADDR CHECK PASSED");

        end


        $display("Checking LENGTH...");

        axi_read(
            32'h0000_0010,
            read_value
        );

        if (read_value !== 32'd16) begin

            $error(
                "FAIL: LENGTH = %h, expected 00000010",
                read_value
            );

        end
        else begin

            $display("LENGTH CHECK PASSED");

        end


        //========================================================
        // START DMA
        //========================================================

        $display("");
        $display("Starting DMA...");

        axi_write(
            32'h0000_0000,
            32'h0000_0001
        );


        //========================================================
        // WAIT FOR COMPLETION
        //========================================================

        wait (dut.done);

        $display("DMA completed.");


        //========================================================
        // CHECK DESTINATION MEMORY
        //========================================================

        $display("");
        $display("Checking destination memory...");


        if (memory[32'h2000 >> 2] !== 32'hAAAA_AAAA) begin

            $error(
                "FAIL: destination word 0 = %h",
                memory[32'h2000 >> 2]
            );

        end
        else begin

            $display("DESTINATION WORD 0 PASSED");

        end


        if (memory[32'h2004 >> 2] !== 32'hBBBB_BBBB) begin

            $error(
                "FAIL: destination word 1 = %h",
                memory[32'h2004 >> 2]
            );

        end
        else begin

            $display("DESTINATION WORD 1 PASSED");

        end


        if (memory[32'h2008 >> 2] !== 32'hCCCC_CCCC) begin

            $error(
                "FAIL: destination word 2 = %h",
                memory[32'h2008 >> 2]
            );

        end
        else begin

            $display("DESTINATION WORD 2 PASSED");

        end


        if (memory[32'h200C >> 2] !== 32'hDDDD_DDDD) begin

            $error(
                "FAIL: destination word 3 = %h",
                memory[32'h200C >> 2]
            );

        end
        else begin

            $display("DESTINATION WORD 3 PASSED");

        end


        //========================================================
        // FINAL RESULT
        //========================================================

        if ((memory[32'h2000 >> 2] === 32'hAAAA_AAAA) &&
            (memory[32'h2004 >> 2] === 32'hBBBB_BBBB) &&
            (memory[32'h2008 >> 2] === 32'hCCCC_CCCC) &&
            (memory[32'h200C >> 2] === 32'hDDDD_DDDD)) begin

            $display("");
            $display("==============================================");
            $display("          DMA VERIFICATION PASSED");
            $display("==============================================");
            $display("");

        end

        else begin

            $display("");
            $display("==============================================");
            $display("          DMA VERIFICATION FAILED");
            $display("==============================================");
            $display("");

        end


        #100;

        $finish;

    end

endmodule