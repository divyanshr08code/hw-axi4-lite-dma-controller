`timescale 1ns / 1ps

module dma_sva (

    input logic        clk,
    input logic        rst,

    //============================================================
    // DMA control
    //============================================================

    input logic        start,
    input logic        busy,
    input logic        done,
    input logic        dma_error,

    //============================================================
    // AXI Read Address
    //============================================================

    input logic [31:0] m_axi_araddr,
    input logic        m_axi_arvalid,
    input logic        m_axi_arready,

    //============================================================
    // AXI Read Data
    //============================================================

    input logic [31:0] m_axi_rdata,
    input logic [1:0]  m_axi_rresp,
    input logic        m_axi_rvalid,
    input logic        m_axi_rready,

    //============================================================
    // AXI Write Address
    //============================================================

    input logic [31:0] m_axi_awaddr,
    input logic        m_axi_awvalid,
    input logic        m_axi_awready,

    //============================================================
    // AXI Write Data
    //============================================================

    input logic [31:0] m_axi_wdata,
    input logic [3:0]  m_axi_wstrb,
    input logic        m_axi_wvalid,
    input logic        m_axi_wready,

    //============================================================
    // AXI Write Response
    //============================================================

    input logic [1:0]  m_axi_bresp,
    input logic        m_axi_bvalid,
    input logic        m_axi_bready

);


    //============================================================
    // 1. ARVALID must remain asserted until ARREADY
    //============================================================

    property p_arvalid_stable;

        @(posedge clk)
        disable iff (rst)

        m_axi_arvalid && !m_axi_arready
        |=> m_axi_arvalid;

    endproperty

    assert property (p_arvalid_stable)
        else $error("SVA FAILURE: ARVALID dropped before ARREADY");


    //============================================================
    // 2. ARADDR must remain stable while waiting
    //============================================================

    property p_araddr_stable;

        @(posedge clk)
        disable iff (rst)

        m_axi_arvalid && !m_axi_arready
        |=> m_axi_araddr == $past(m_axi_araddr);

    endproperty

    assert property (p_araddr_stable)
        else $error("SVA FAILURE: ARADDR changed while waiting");


    //============================================================
    // 3. RVALID must remain asserted until RREADY
    //============================================================

    property p_rvalid_stable;

        @(posedge clk)
        disable iff (rst)

        m_axi_rvalid && !m_axi_rready
        |=> m_axi_rvalid;

    endproperty

    assert property (p_rvalid_stable)
        else $error("SVA FAILURE: RVALID dropped before RREADY");


    //============================================================
    // 4. RDATA must remain stable while RVALID waits
    //============================================================

    property p_rdata_stable;

        @(posedge clk)
        disable iff (rst)

        m_axi_rvalid && !m_axi_rready
        |=> m_axi_rdata == $past(m_axi_rdata);

    endproperty

    assert property (p_rdata_stable)
        else $error("SVA FAILURE: RDATA changed while waiting");


    //============================================================
    // 5. AWVALID must remain asserted until AWREADY
    //============================================================

    property p_awvalid_stable;

        @(posedge clk)
        disable iff (rst)

        m_axi_awvalid && !m_axi_awready
        |=> m_axi_awvalid;

    endproperty

    assert property (p_awvalid_stable)
        else $error("SVA FAILURE: AWVALID dropped before AWREADY");


    //============================================================
    // 6. AWADDR must remain stable while waiting
    //============================================================

    property p_awaddr_stable;

        @(posedge clk)
        disable iff (rst)

        m_axi_awvalid && !m_axi_awready
        |=> m_axi_awaddr == $past(m_axi_awaddr);

    endproperty

    assert property (p_awaddr_stable)
        else $error("SVA FAILURE: AWADDR changed while waiting");


    //============================================================
    // 7. WVALID must remain asserted until WREADY
    //============================================================

    property p_wvalid_stable;

        @(posedge clk)
        disable iff (rst)

        m_axi_wvalid && !m_axi_wready
        |=> m_axi_wvalid;

    endproperty

    assert property (p_wvalid_stable)
        else $error("SVA FAILURE: WVALID dropped before WREADY");


    //============================================================
    // 8. WDATA must remain stable while waiting
    //============================================================

    property p_wdata_stable;

        @(posedge clk)
        disable iff (rst)

        m_axi_wvalid && !m_axi_wready
        |=> m_axi_wdata == $past(m_axi_wdata);

    endproperty

    assert property (p_wdata_stable)
        else $error("SVA FAILURE: WDATA changed while waiting");


    //============================================================
    // 9. BVALID must remain asserted until BREADY
    //============================================================

    property p_bvalid_stable;

        @(posedge clk)
        disable iff (rst)

        m_axi_bvalid && !m_axi_bready
        |=> m_axi_bvalid;

    endproperty

    assert property (p_bvalid_stable)
        else $error("SVA FAILURE: BVALID dropped before BREADY");


    //============================================================
    // 10. DMA cannot be DONE and BUSY simultaneously
    //============================================================

    property p_done_not_busy;

        @(posedge clk)
        disable iff (rst)

        done |-> !busy;

    endproperty

    assert property (p_done_not_busy)
        else $error("SVA FAILURE: DONE and BUSY asserted together");


    //============================================================
    // 11. START must be a one-cycle pulse
    //============================================================

    property p_start_one_cycle;

        @(posedge clk)
        disable iff (rst)

        start |=> !start;

    endproperty

    assert property (p_start_one_cycle)
        else $error("SVA FAILURE: START remained asserted");


    //============================================================
    // 12. DMA error must not occur during reset
    //============================================================

    property p_no_error_reset;

        @(posedge clk)

        rst |-> !dma_error;

    endproperty

    assert property (p_no_error_reset)
        else $error("SVA FAILURE: DMA error during reset");


    //============================================================
    // 13. Successful read response should be OKAY
    //============================================================

    property p_read_response_okay;

        @(posedge clk)
        disable iff (rst)

        m_axi_rvalid && m_axi_rready
        |-> (m_axi_rresp == 2'b00);

    endproperty

    assert property (p_read_response_okay)
        else $error("SVA FAILURE: AXI read returned error response");


    //============================================================
    // 14. Successful write response should be OKAY
    //============================================================

    property p_write_response_okay;

        @(posedge clk)
        disable iff (rst)

        m_axi_bvalid && m_axi_bready
        |-> (m_axi_bresp == 2'b00);

    endproperty

    assert property (p_write_response_okay)
        else $error("SVA FAILURE: AXI write returned error response");


endmodule