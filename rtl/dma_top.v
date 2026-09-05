`timescale 1ns / 1ps

module dma_top (

    input  logic clk,
    input  logic rst,


    //============================================================
    // AXI4-Lite Slave Interface
    //============================================================

    input  logic [31:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,

    input  logic [31:0] s_axi_wdata,
    input  logic [3:0]  s_axi_wstrb,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,

    output logic [1:0]  s_axi_bresp,
    output logic        s_axi_bvalid,
    input  logic        s_axi_bready,

    input  logic [31:0] s_axi_araddr,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,

    output logic [31:0] s_axi_rdata,
    output logic [1:0]  s_axi_rresp,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready,


    //============================================================
    // AXI4 Master Interface
    //============================================================

    output logic [31:0] m_axi_araddr,
    output logic [7:0]  m_axi_arlen,
    output logic [2:0]  m_axi_arsize,
    output logic [1:0]  m_axi_arburst,
    output logic        m_axi_arvalid,
    input  logic        m_axi_arready,

    input  logic [31:0] m_axi_rdata,
    input  logic [1:0]  m_axi_rresp,
    input  logic        m_axi_rvalid,
    input  logic        m_axi_rlast,
    output logic        m_axi_rready,

    output logic [31:0] m_axi_awaddr,
    output logic [7:0]  m_axi_awlen,
    output logic [2:0]  m_axi_awsize,
    output logic [1:0]  m_axi_awburst,
    output logic        m_axi_awvalid,
    input  logic        m_axi_awready,

    output logic [31:0] m_axi_wdata,
    output logic [3:0]  m_axi_wstrb,
    output logic        m_axi_wlast,
    output logic        m_axi_wvalid,
    input  logic        m_axi_wready,

    input  logic [1:0]  m_axi_bresp,
    input  logic        m_axi_bvalid,
    output logic        m_axi_bready

);


    //============================================================
    // AXI4-Lite ? Register Bank
    //============================================================

    logic        reg_write_en;
    logic [31:0] reg_write_addr;
    logic [31:0] reg_write_data;
    logic [3:0]  reg_write_strb;

    logic [31:0] reg_read_addr;
    logic [31:0] reg_read_data;


    //============================================================
    // DMA Configuration
    //============================================================

    logic        start;
    logic [31:0] source_addr;
    logic [31:0] dest_addr;
    logic [31:0] length;


    //============================================================
    // DMA Status
    //============================================================

    logic        busy;
    logic        done;
    logic        dma_error;
    logic [31:0] transfer_count;


    //============================================================
    // Controller ? Read Engine
    //============================================================

    logic        read_start;
    logic [31:0] read_address;

    logic        read_busy;
    logic        read_done;
    logic        read_error;


    //============================================================
    // Controller ? Write Engine
    //============================================================

    logic        write_start;
    logic [31:0] write_address;

    logic        write_busy;
    logic        write_done;
    logic        write_error;


    //============================================================
    // Read Engine ? Buffer
    //============================================================

    logic [31:0] read_data;
    logic        read_data_valid;
    logic        read_data_ready;


    //============================================================
    // Buffer ? Write Engine
    //============================================================

    logic [31:0] buffer_data;
    logic        buffer_valid;
    logic        buffer_ready;


    //============================================================
    // AXI4-Lite Slave
    //============================================================

    axi4lite_slave axi_slave (

        .clk            (clk),
        .rst            (rst),

        .s_axi_awaddr   (s_axi_awaddr),
        .s_axi_awvalid  (s_axi_awvalid),
        .s_axi_awready  (s_axi_awready),

        .s_axi_wdata    (s_axi_wdata),
        .s_axi_wstrb    (s_axi_wstrb),
        .s_axi_wvalid   (s_axi_wvalid),
        .s_axi_wready   (s_axi_wready),

        .s_axi_bresp    (s_axi_bresp),
        .s_axi_bvalid   (s_axi_bvalid),
        .s_axi_bready   (s_axi_bready),

        .s_axi_araddr   (s_axi_araddr),
        .s_axi_arvalid  (s_axi_arvalid),
        .s_axi_arready  (s_axi_arready),

        .s_axi_rdata    (s_axi_rdata),
        .s_axi_rresp   (s_axi_rresp),
        .s_axi_rvalid  (s_axi_rvalid),
        .s_axi_rready  (s_axi_rready),

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
    // DMA Controller
    //============================================================

    dma_controller controller (

        .clk            (clk),
        .rst            (rst),

        .start          (start),
        .source_addr    (source_addr),
        .dest_addr      (dest_addr),
        .length         (length),

        .busy           (busy),
        .done           (done),
        .dma_error      (dma_error),
        .transfer_count (transfer_count),

        .read_start     (read_start),
        .read_address   (read_address),
        .read_busy      (read_busy),
        .read_done      (read_done),
        .read_error     (read_error),

        .write_start    (write_start),
        .write_address  (write_address),
        .write_busy     (write_busy),
        .write_done     (write_done),
        .write_error    (write_error),

        .buffer_data    (buffer_data),
        .buffer_valid   (buffer_valid),
        .buffer_ready   (buffer_ready)

    );


    //============================================================
    // DMA Read Engine
    //============================================================

    dma_read_engine read_engine (

        .clk            (clk),
        .rst            (rst),

        .start          (read_start),
        .address        (read_address),

        .busy           (read_busy),
        .done           (read_done),
        .error          (read_error),

        .data_out       (read_data),
        .data_valid     (read_data_valid),
        .data_ready     (read_data_ready),

        .m_axi_araddr   (m_axi_araddr),
        .m_axi_arlen    (m_axi_arlen),
        .m_axi_arsize   (m_axi_arsize),
        .m_axi_arburst  (m_axi_arburst),
        .m_axi_arvalid  (m_axi_arvalid),
        .m_axi_arready  (m_axi_arready),

        .m_axi_rdata    (m_axi_rdata),
        .m_axi_rresp    (m_axi_rresp),
        .m_axi_rvalid   (m_axi_rvalid),
        .m_axi_rlast    (m_axi_rlast),
        .m_axi_rready   (m_axi_rready)

    );


    //============================================================
    // DMA Buffer
    //============================================================

    dma_buffer buffer (

        .clk            (clk),
        .rst            (rst),

        .write_data     (read_data),
        .write_valid    (read_data_valid),
        .write_ready    (read_data_ready),

        .read_data      (buffer_data),
        .read_valid     (buffer_valid),
        .read_ready     (buffer_ready)

    );


    //============================================================
    // DMA Write Engine
    //============================================================

    dma_write_engine write_engine (

        .clk            (clk),
        .rst            (rst),

        .start          (write_start),
        .address        (write_address),

        .busy           (write_busy),
        .done           (write_done),
        .error          (write_error),

        .data_in        (buffer_data),
        .data_valid     (buffer_valid),
        .data_ready     (buffer_ready),

        .m_axi_awaddr   (m_axi_awaddr),
        .m_axi_awlen    (m_axi_awlen),
        .m_axi_awsize   (m_axi_awsize),
        .m_axi_awburst  (m_axi_awburst),
        .m_axi_awvalid  (m_axi_awvalid),
        .m_axi_awready  (m_axi_awready),

        .m_axi_wdata    (m_axi_wdata),
        .m_axi_wstrb    (m_axi_wstrb),
        .m_axi_wlast    (m_axi_wlast),
        .m_axi_wvalid   (m_axi_wvalid),
        .m_axi_wready   (m_axi_wready),

        .m_axi_bresp    (m_axi_bresp),
        .m_axi_bvalid   (m_axi_bvalid),
        .m_axi_bready   (m_axi_bready)

    );

endmodule