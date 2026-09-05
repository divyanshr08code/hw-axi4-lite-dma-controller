# Design and Verification Challenges

This document records the main engineering challenges encountered while developing and verifying the DMA controller.

## 1. Separating the Control Plane and Data Plane

One of the first architectural challenges was understanding the distinction between the two AXI interfaces.

The design uses:

- **AXI4-Lite** for programming and status
- **AXI4** for actual memory movement

This separation is important because the CPU/host does not directly perform the data transfer. It configures the DMA through registers, after which the DMA becomes the AXI4 master responsible for moving the data.

## 2. AXI4-Lite Write Channels Are Independent

The AXI4-Lite write address and write data channels are independent.

Therefore, the slave cannot assume that the address and data arrive in a fixed order.

The implementation captures:

- `AWADDR` through the write-address handshake
- `WDATA` and `WSTRB` through the write-data handshake

and commits the register write once both pieces have been received.

This was an important practical lesson in AXI protocol implementation.

## 3. AXI VALID/READY Handshake

Another important challenge was understanding the timing semantics of AXI's `VALID`/`READY` handshake.

A transfer occurs only when:

```text
VALID && READY
```

at a rising clock edge.

If `VALID` is asserted while `READY` is low, the source must keep the transaction information stable until the handshake occurs.

This behavior was reflected both in the RTL and in the SystemVerilog Assertions.

## 4. Testbench Multiple Procedural Drivers

During verification, the testbench initially had multiple procedural assignments driving the same AXI memory-model signals.

For example, response signals were assigned from more than one procedural block.

This caused simulator errors related to multiple procedural drivers and `always_ff` restrictions.

The issue was resolved by ensuring that each variable has a single procedural driver.

This reinforced an important SystemVerilog rule:

> A signal modeled as a sequential variable should have one clear procedural owner.

## 5. Understanding AXI Read Data Direction

A useful debugging point was tracing where `RDATA` actually comes from.

For a DMA read:

```text
DMA Read Engine
      |
      | ARADDR
      v
Memory Model
      |
      | RDATA
      v
DMA Read Engine
```

The DMA drives the read request, but the memory/slave model drives the read response.

Understanding this direction was essential for debugging the testbench.

## 6. Simulation Scheduling and Assertions

A reset-related assertion initially exposed a SystemVerilog scheduling issue.

Concurrent assertions sample signals in the preponed region, before sequential logic updates registers at the same clock edge.

Consequently, an assertion checking reset state using an overlapping implication can observe the previous value during the reset transition.

The solution is to formulate reset assertions with the appropriate temporal relationship, such as checking the state on the following clock cycle when appropriate.

## 7. Keeping the Design Scope Controlled

The DMA could be extended significantly with features such as:

- AXI bursts
- Multiple outstanding transactions
- Larger FIFOs
- Scatter-gather descriptors
- Higher-throughput pipelining
- More advanced verification

However, these features were intentionally excluded from the current implementation.

The project therefore focuses on building a correct, modular, understandable single-beat DMA architecture before adding performance-oriented complexity.
