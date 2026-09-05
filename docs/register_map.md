# Register Map

The DMA controller is programmed through its AXI4-Lite slave interface.

All registers are 32 bits wide.

## Register Summary

| Offset | Register | Access | Description |
|---:|---|:---:|---|
| `0x00` | CONTROL | W | DMA control |
| `0x04` | STATUS | R | DMA status |
| `0x08` | SOURCE_ADDR | R/W | Source memory address |
| `0x0C` | DEST_ADDR | R/W | Destination memory address |
| `0x10` | LENGTH | R/W | Transfer length in bytes |
| `0x14` | TRANSFER_COUNT | R | Number of transferred words |
| `0x18` | ERROR | R | DMA error status |

## 0x00 — CONTROL

Controls the start of a DMA transfer.

| Bit | Name | Description |
|---:|---|---|
| 0 | `START` | Starts a DMA transfer |
| 31:1 | Reserved | Reserved |

`START` is treated as a one-cycle start pulse by the register/control logic.

## 0x04 — STATUS

Reports the current DMA state.

```text
31:3  Reserved
  2   dma_error
  1   done
  0   busy
```

| Bit | Name | Description |
|---:|---|---|
| 0 | `BUSY` | DMA transfer is active |
| 1 | `DONE` | DMA transfer has completed |
| 2 | `DMA_ERROR` | DMA encountered an error |
| 31:3 | Reserved | Reserved |

## 0x08 — SOURCE_ADDR

Stores the starting source memory address.

```text
31:0  SOURCE_ADDR
```

The DMA uses this address to generate AXI4 read transactions.

During a transfer, the active source address advances by 4 bytes after each successfully transferred 32-bit word.

## 0x0C — DEST_ADDR

Stores the starting destination memory address.

```text
31:0  DEST_ADDR
```

The DMA uses this address to generate AXI4 write transactions.

During a transfer, the active destination address advances by 4 bytes after each successfully transferred 32-bit word.

## 0x10 — LENGTH

Specifies the transfer length in bytes.

```text
31:0  LENGTH
```

Because the current DMA operates on 32-bit words, transfers are performed in 4-byte word increments.

For example:

```text
LENGTH = 16 bytes
```

results in:

```text
16 / 4 = 4 words
```

## 0x14 — TRANSFER_COUNT

Reports the number of successfully transferred words.

```text
31:0  TRANSFER_COUNT
```

The count increments as individual word transfers complete.

## 0x18 — ERROR

Reports DMA error status.

```text
31:1  Reserved
  0   DMA_ERROR
```

| Bit | Name | Description |
|---:|---|---|
| 0 | `DMA_ERROR` | Indicates a DMA error |
| 31:1 | Reserved | Reserved |

## Example Configuration

For a 16-byte transfer from `0x1000` to `0x2000`:

```text
SOURCE_ADDR = 0x1000
DEST_ADDR   = 0x2000
LENGTH      = 16
CONTROL     = START
```

The DMA performs four 32-bit word transfers:

```text
0x1000 -> 0x2000
0x1004 -> 0x2004
0x1008 -> 0x2008
0x100C -> 0x200C
```
