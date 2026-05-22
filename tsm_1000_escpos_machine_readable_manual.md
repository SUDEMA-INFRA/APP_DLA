# TSM-1000 ESC/POS Command Reference

## Device Information

| Item | Value |
|---|---|
| Model | TSM-1000 |
| Manufacturer | Tanca |
| Protocol | ESC/POS |
| Category | POS Thermal Printer |
| DPI | 200 DPI |
| Interface | ESC/POS Command Set |

---

# Command Structure

Each command contains:

- ASCII
- HEX
- DECIMAL
- PARAMETERS
- DESCRIPTION
- NOTES

---

# BASIC COMMANDS

## HT - Horizontal Tab

### Description
Move current print position to next tab stop.

### Command

| Format | Value |
|---|---|
| ASCII | HT |
| HEX | 09 |
| DECIMAL | 9 |

### Notes

- Requires tab positions configured with `ESC D`
- Default tab size: 8 ASCII chars
- If overflow occurs, printer moves to next line

---

## LF - Line Feed

### Description
Print buffer and move to next line.

| Format | Value |
|---|---|
| ASCII | LF |
| HEX | 0A |
| DECIMAL | 10 |

---

# TEXT FORMATTING

## ESC SP n - Character Right Spacing

### Command

| ASCII | ESC SP n |
| HEX | 1B 20 n |
| DECIMAL | 27 32 n |

### Parameters

| Param | Range |
|---|---|
| n | 0-255 |

### Function
Set character spacing.

---

## ESC ! n - Print Mode

### Command

| ASCII | ESC ! n |
| HEX | 1B 21 n |
| DECIMAL | 27 33 n |

### Bitmask

| Bit | Function |
|---|---|
| 3 | Bold |
| 4 | Double Height |
| 5 | Double Width |
| 7 | Underline |

### Example

```hex
1B 21 38
```

Enables:
- Bold
- Double height
- Double width

---

## ESC E n - Bold Mode

### Command

| ASCII | ESC E n |
| HEX | 1B 45 n |
| DECIMAL | 27 69 n |

### Values

| n | Mode |
|---|---|
| 0 | OFF |
| 1 | ON |

---

## ESC - n - Underline

### Command

| ASCII | ESC - n |
| HEX | 1B 2D n |
| DECIMAL | 27 45 n |

### Values

| n | Function |
|---|---|
| 0 | OFF |
| 1 | 1-dot underline |
| 2 | 2-dot underline |

---

# POSITIONING

## ESC $ nL nH - Absolute Position

### Command

| ASCII | ESC $ nL nH |
| HEX | 1B 24 nL nH |

### Formula

```text
Position = nL + (nH * 256)
```

---

## ESC \\ nL nH - Relative Position

### Command

| ASCII | ESC \\ nL nH |
| HEX | 1B 5C nL nH |

### Formula

```text
RelativePosition = nL + (nH * 256)
```

---

## ESC a n - Alignment

### Command

| ASCII | ESC a n |
| HEX | 1B 61 n |

### Values

| n | Alignment |
|---|---|
| 0 | Left |
| 1 | Center |
| 2 | Right |

---

# LINE SPACING

## ESC 2 - Default Line Height

### Command

| ASCII | ESC 2 |
| HEX | 1B 32 |

### Default
30 dots

---

## ESC 3 n - Custom Line Height

### Command

| ASCII | ESC 3 n |
| HEX | 1B 33 n |

### Parameters

| Param | Range |
|---|---|
| n | 0-255 |

---

# INITIALIZATION

## ESC @ - Initialize Printer

### Command

| ASCII | ESC @ |
| HEX | 1B 40 |

### Function
Reset printer state and clear buffer.

---

# TAB CONFIGURATION

## ESC D n1...nk NUL

### Function
Configure horizontal tabs.

### Command

| ASCII | ESC D |
| HEX | 1B 44 |

### Notes

- Maximum: 32 tabs
- Ends with `00`

---

# CHARACTER SIZE

## GS ! n - Character Scaling

### Command

| ASCII | GS ! n |
| HEX | 1D 21 n |

### Width Scaling

| Hex | Multiplier |
|---|---|
| 00 | 1x |
| 10 | 2x |
| 20 | 3x |
| 30 | 4x |

### Height Scaling

| Hex | Multiplier |
|---|---|
| 00 | 1x |
| 01 | 2x |
| 02 | 3x |
| 03 | 4x |

---

# IMAGE PRINTING

## ESC * m nL nH d1...dk

### Function
Print bit image.

### Modes

| m | Mode |
|---|---|
| 0 | 8-dot single density |
| 1 | 8-dot double density |
| 32 | 24-dot single density |
| 33 | 24-dot double density |

---

## GS v 0

### Function
Print raster bitmap image.

### Command

| ASCII | GS v 0 |
| HEX | 1D 76 30 |

### Modes

| m | Function |
|---|---|
| 0 | Normal |
| 1 | Double Width |
| 2 | Double Height |
| 3 | Double Width + Height |

---

# BARCODE COMMANDS

## GS h n - Barcode Height

| ASCII | GS h n |
| HEX | 1D 68 n |

### Default
162

---

## GS w n - Barcode Width

| ASCII | GS w n |
| HEX | 1D 77 n |

### Range

| n | Width |
|---|---|
| 2 | Narrow |
| 6 | Wide |

---

## GS H n - HRI Position

### Values

| n | Position |
|---|---|
| 0 | None |
| 1 | Above |
| 2 | Below |
| 3 | Both |

---

## GS k - Print Barcode

### Supported Types

| m | Barcode |
|---|---|
| 0 | UPC-A |
| 1 | UPC-E |
| 2 | EAN13 |
| 3 | EAN8 |
| 4 | CODE39 |
| 5 | ITF |
| 6 | CODABAR |
| 72 | CODE93 |
| 73 | CODE128 |

---

# QR CODE

## GS ( k - QR Code Commands

### QR Size

```hex
1D 28 6B 03 00 31 43 n
```

### QR Error Correction

```hex
1D 28 6B 03 00 31 45 n
```

### Levels

| n | Level |
|---|---|
| 48 | L |
| 49 | M |
| 50 | Q |
| 51 | H |

---

## Store QR Data

### Command

```hex
1D 28 6B pL pH 31 50 30 d1...dk
```

---

## Print QR Code

### Command

```hex
1D 28 6B 03 00 31 51 30
```

---

# PRINT AREA

## GS L nL nH - Left Margin

| ASCII | GS L |
| HEX | 1D 4C |

---

## GS W nL nH - Print Width

| ASCII | GS W |
| HEX | 1D 57 |

---

# REVERSE PRINTING

## GS B n

### Command

| ASCII | GS B n |
| HEX | 1D 42 n |

### Values

| n | Mode |
|---|---|
| 0 | OFF |
| 1 | ON |

---

# PAPER FEED

## ESC J n - Feed Dots

| ASCII | ESC J n |
| HEX | 1B 4A n |

---

## ESC d n - Feed Lines

| ASCII | ESC d n |
| HEX | 1B 64 n |

---

# COMMON INITIALIZATION SEQUENCE

## Reset + Align + Bold

```hex
1B 40
1B 61 01
1B 45 01
```

---

# EXAMPLE RECEIPT

```text
ESC @
ESC a 1
ESC E 1
"STORE NAME"
LF
ESC E 0
ESC a 0
"Item 1     10.00"
LF
"Item 2     20.00"
LF
ESC a 2
"TOTAL: 30.00"
LF
GS V
```

---

# QR CODE FULL FLOW

## 1. Set Size

```hex
1D 28 6B 03 00 31 43 04
```

## 2. Set Error Correction

```hex
1D 28 6B 03 00 31 45 31
```

## 3. Store Data

```hex
1D 28 6B pL pH 31 50 30 ...
```

## 4. Print

```hex
1D 28 6B 03 00 31 51 30
```

---

# SUPPORT

| Item | Value |
|---|---|
| Manufacturer | Tanca |
| Support Email | suporte@tanca.com.br |
| Support Portal | http://tancasuporte.mysuite2.com.br |

