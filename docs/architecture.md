# Architecture

## 1. Overview

The AXI4-Lite Controlled DMA Controller is a programmable memory-to-memory DMA engine implemented in SystemVerilog.

The design separates the system into two interfaces:

- **AXI4-Lite slave interface** — used to configure and control the DMA.
- **AXI4 master interface** — used by the DMA to read source memory and write destination memory.

### High-Level Architecture

```text
                 AXI4-Lite
              Control Interface
                     |
                     v
             +---------------+
             | AXI4-Lite     |
             | Slave         |
             +---------------+
                     |
                     v
             +---------------+
             | DMA Registers |
             +---------------+
                     |
                     v
             +---------------+
             | DMA Controller|
             +---------------+
                /          \
               /            \
              v              v
       +-------------+  +-------------+
       | AXI4 Read   |  | AXI4 Write  |
       | Engine      |  | Engine      |
       +-------------+  +-------------+
              |              ^
              v              |
       +------------------------+
       |      Data Buffer       |
       |    1-word storage      |
       +------------------------+
```

## 2. Major Components

### AXI4-Lite Slave

**File:** `rtl/axi4lite_slave.sv`

Provides the control-plane interface. It handles AXI4-Lite write-address, write-data, write-response, read-address, and read-data channels.

The write address and write data channels are captured independently before a register write is committed.

### DMA Register Bank

**File:** `rtl/dma_registers.sv`

Stores DMA configuration and exposes status information.

The programmable configuration includes:

- Source address
- Destination address
- Transfer length
- Start control

The status information includes:

- Busy
- Done
- Error
- Transfer count

### DMA Controller

**File:** `rtl/dma_controller.sv`

Acts as the central control FSM. It coordinates the read, buffering, and write phases of a DMA transfer.

A transfer consists of:

1. Starting the DMA operation
2. Issuing a memory read
3. Receiving read data
4. Storing the data in the buffer
5. Issuing a memory write
6. Waiting for the write response
7. Updating addresses and transfer count
8. Repeating until the requested transfer completes

### AXI4 Read Engine

**File:** `rtl/dma_read_engine.sv`

Generates AXI4 read transactions using the current source address.

Current transaction configuration:

- Data width: 32 bits
- Single-beat transaction
- `ARLEN = 0`
- `ARSIZE = 3'b010`
- Incrementing burst type

### Data Buffer

**File:** `rtl/dma_buffer.sv`

Provides one word of storage between the read and write engines.

The buffer uses a ready/valid-style interface and temporarily holds the data returned from source memory before it is consumed by the write engine.

### AXI4 Write Engine

**File:** `rtl/dma_write_engine.sv`

Generates AXI4 write transactions using the current destination address and data supplied by the buffer.

Current transaction configuration:

- Data width: 32 bits
- Single-beat transaction
- `AWLEN = 0`
- `AWSIZE = 3'b010`
- Incrementing burst type
- Full-word write strobes

## 3. DMA Data Flow

For each transferred word:

```text
Source Address
      |
      v
AXI4 Read Address
      |
      v
Source Memory
      |
      v
AXI4 Read Data
      |
      v
Data Buffer
      |
      v
AXI4 Write Data
      |
      v
Destination Memory
```

After a successful word transfer, the controller advances the source and destination addresses by four bytes and increments the transfer count.

## 4. Transfer Granularity

The current implementation operates on 32-bit words:

```text
DATA_WIDTH = 32 bits
WORD_SIZE  = 4 bytes
```

For example, a 16-byte transfer consists of four 32-bit word transfers.

## 5. Control Flow

A typical transfer follows this sequence:

```text
IDLE
 |
 | start
 v
READ
 |
 | read response
 v
BUFFER
 |
 | data available
 v
WRITE
 |
 | write response
 v
NEXT WORD
 |
 +---- more data ----> READ
 |
 +---- complete -----> DONE
```

## 6. AXI Handshake Model

AXI channel transfers occur when:

```text
VALID && READY
```

is true at a rising clock edge.

When an AXI source asserts `VALID` while `READY` is low, the source must maintain `VALID` and keep the associated transaction information stable until the handshake occurs.

The project includes SystemVerilog Assertions for important AXI stability requirements.

## 7. Design Philosophy

The architecture intentionally prioritizes simplicity, modularity, and verifiability over maximum throughput.

The current design uses:

- One DMA controller
- One read engine
- One write engine
- One-word internal buffer
- Single-beat AXI transactions
- No multiple outstanding transactions

This provides a simple foundation for future extensions such as AXI burst transfers, deeper buffering, and higher-throughput data movement.
