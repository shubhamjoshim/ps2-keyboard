## PS/2 Communication Theory
- Follows serial protocol
- Uses 2 pins to communicate information
- Data pin is bi-directional

### Output Sequence:
- Databit goes low
- Clock goes low
- Data kept low 
- Clock goes high
- 8 data bits clocked out
- Parity data bit kept high
- 1 clock cycle
- Stop data bit kept high 
- 1 clock cycle

### Pinouts:
1 - Data
2 - Not implemented
3 - Ground
4 - Vcc 
5 - Clock
6 - Not implemented

## PS/2 Output Theory
Computers have no idea what each key press means so we have to encode each key into a binary number. These encoded numbers are called scan codes. All keys have a scan code and some special keys have a dual / longer scan code.
The main letters and numbers are all 8 bit codes.

### Sending data to the Keyboard:
Another function of the PS/2 protocol is that you can send data back to the keyboard to tell it to do things like turn on the capslock led, or to reset. This process uses virtually the same method to send data as we saw above of receiving data, but for simplicity sake, we focus on receiving data from a keyboard.

# Implementation 
PS/2 port has 2 wires used for communication:
- A clock line ps2_clk
- A data line ps2_data

Data is communicated in an 11-bit packet

When no data is being transmitted, ps2_data and ps2_clk are held high. When ps2c goes low for the start bit, the sampling of the packet begins.  

Eight data bits, one parity bit and one stop bit are then sampled on the falling edge of ps2_clk.

The receiver operates using a 4 state FSM.

The four states for the receiver are IDLE, DATA, PARITY and STOP. In idle state, if a negative edge is detected for ps2_clk, the start bit of a packet has been sent, if the receiver is also enabled, we go to the rx state, if a negative edge for ps2c is detected, we sample ps2_data by right shifting in the bit to the register and then incrementing. When bit_count is equal to 7 we have sampled the 8 data, 1 parity and 1 stop bits and are done, so we assert a one clock cycle done tick and go back to the idle state.

### Explanation:
By waiting for a negative edge on ps2_clk while in idle, the state machine is specifically hunting for our start bit. Once this is detected it confirms that a transmission has begun and transitions to the DATA state.

Because the start bit was just consumed to wake up the receiver and trigger the state change, there are exactly 10 bits remaining in the frame. Setting the counter to track 8 bits ensures the machine stays in DATA state for the duration of this packet.

Because keyboards are physical mechanical devices, the clock signal can bounce and create false edges on the wire. To prevent the state machine from reading garbage data, the design includes a 2 stage synchronizer (meta and sync flip flops). It samples the clock line continuously and only registers a valid high or low state when passed through both stages, ensuring the receiver only triggers on true clock pulses.

For the next 8 clock cycles the statemachine waits for the negative edge of the ps2_clk and samples ps2_data
We must right shift the data into the external shift register because the PS/2 protocol transmits data LSB first. By shifting right the first bit received gets pushed down to the lowest position of the register by the time the 8th data bit arrives for perfect order.

When the counter reaches its limit, the 8 data bits are fully captured, and the machine steps through the PARITY and STOP states to validate the remaining frame bits. The register now contains jsut the pure scan node, completely separated from the parity and stop bits. Asserting a one clock cycle valid tick (scan_valid) acts a flag to the rest of our system signaling that a complete, error checked keystroke has been received. The machine then resets to idle to catch the next keystroke.


