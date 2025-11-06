<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
In Wireless Communication (e.g., Wi-Fi, Bluetooth), Data is often transmitted in bursts or Frames. The FlexiPacketEngine IC can be used to structure the transmitted frames and include metadata about the length, sequence, and other characteristics of each frame. Below is the representation of the crafted output Packet.
![Data Packet](https://github.com/user-attachments/assets/e2c27d65-5360-4cc5-89e1-700cac182c06)


The Sequence Number can help detect packet loss due to interference or signal degradation, enabling retransmission if needed.

Example Flow in a Wi-Fi Transmission:
* Data arrives at the MAC layer for transmission.
* The circuit encapsulates the data by adding a header (sequence number and payload length) and a footer (static value).
* The frame is then transmitted over the air.
* At the receiver, the frame is decoded, and the Sequence Number, Payload Length and Footer is used to maintain the Data Integrity.
* If any frames are missing or corrupted, the receiver can request retransmission of those specific frames.
 


## How to test
The Testbench is attached in the src folder. Run the testbench using iverilog and generate the .vcd file. Dump the .vcd file and it'll work as expected.

Limitation: The IC is working on 100MHz frequency and allows max Payload of 100 Data Packets, so next set of the Data Packets should come certain time. Let's call it Incoming Data Frequency.  
Details of Clock Cycle required for every steps:
* x Data Payloads  --> x Clock Cycles
* Header           --> 1 Clock Cycle
* Output Payloads  --> x+2 Clock Cycles
* Footer           --> 1 Clock Cycle
* Total Ticks = 2x+4
Total Clock Cycles required for max 100 Payloads will be 204 (~205) Clock Cycles. The Next Data Payload should come atleast 2050ns(205*10ns). 



## Rendering GDS
The GDS is conerted to .stl using gdsiistl (https://github.com/mbalestrini/gdsiistl) script. Imported all the .stl in Blender and stacked according to SkyWater PDK Stack Architecture. Below is the beautiful rendering of IC (more in rendering folder):
![untitled1](https://github.com/user-attachments/assets/4b86a903-75b1-4a7e-b340-b1446a949404)


