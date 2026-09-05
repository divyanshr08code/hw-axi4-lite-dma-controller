# Verification

## 1. Verification Strategy

The DMA controller is verified using a normal self-checking SystemVerilog testbench rather than a UVM environment.

The verification environment contains:

- Device Under Test (DUT)
- AXI4-Lite stimulus
- AXI4 memory model
- Directed DMA configuration
- Destination-memory checking
- SystemVerilog Assertions

The goal is to verify the functional data path and important AXI handshake behavior.

## 2. Testbench Structure

```text
                    +-------------------+
                    |    dma_tb.sv      |
                    | Self-checking TB  |
                    +---------+---------+
                              |
                    AXI4-Lite control
                              |
                              v
                    +-------------------+
                    |    DMA DUT        |
                    +-------------------+
                              |
                         AXI4 Master
                              |
                              v
                    +-------------------+
                    |   Memory Model    |
                    +-------------------+
```

## 3. Directed Functional Test

The primary test initializes four source-memory words:

```text
Address     Data
0x1000      0xAAAAAAAA
0x1004      0xBBBBBBBB
0x1008      0xCCCCCCCC
0x100C      0xDDDDDDDD
```

The DMA is configured for:

```text
SOURCE_ADDR = 0x1000
DEST_ADDR   = 0x2000
LENGTH      = 16 bytes
```

The testbench starts the DMA and waits for completion.

After `DONE` is asserted, the destination memory is checked against the expected values.

Expected destination contents:

```text
Address     Data
0x2000      0xAAAAAAAA
0x2004      0xBBBBBBBB
0x2008      0xCCCCCCCC
0x200C      0xDDDDDDDD
```

## 4. Self-Checking

The testbench does not rely only on waveform inspection.

It explicitly compares the destination-memory contents with the expected source data.

A successful run reports:

```text
DESTINATION WORD 0 PASSED
DESTINATION WORD 1 PASSED
DESTINATION WORD 2 PASSED
DESTINATION WORD 3 PASSED

============================================
           DMA VERIFICATION PASSED
============================================
```

## 5. SystemVerilog Assertions

The project includes `sva/dma_sva.sv`.

The assertions check important protocol/design properties including:

- AXI read-address `VALID` stability
- AXI read-address payload stability while stalled
- AXI write-address `VALID` stability
- AXI write-address payload stability while stalled
- AXI write-data `VALID` stability
- AXI write-data payload stability while stalled
- AXI response `READY` behavior where applicable
- Completion/status relationship
- Reset/error behavior

The central AXI rule being checked is that a source must not change a valid transaction's payload while waiting for `READY`.

## 6. Verification Result

The directed functional simulation completed successfully.

The four transferred words were verified at the destination, demonstrating correct basic memory-to-memory operation for the tested configuration.

## 7. Verification Scope

The current verification is intentionally limited to a focused RTL project.

It demonstrates:

- Correct AXI4-Lite programming
- Correct DMA sequencing
- Correct source-memory reads
- Correct data buffering
- Correct destination-memory writes
- Correct transfer completion
- Basic AXI handshake properties

It does not claim exhaustive protocol or functional coverage.

Possible future verification extensions include:

- AXI backpressure/stall testing
- AXI error-response injection
- Additional transfer lengths
- Boundary/address cases
- Constrained-random stimulus
- Functional coverage
- More extensive assertion coverage
