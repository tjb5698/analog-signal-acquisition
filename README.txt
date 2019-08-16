Objective
To learn timer module and interrupt based Analog Signal Acquisition programming.

Textbook Reading (for next homework):
MC9S12C Family Data Sheet: Chapters 5, 8, 13, and 15
Instruction
Write a program to aquire analog signal through the HCS12 board and display the analog signal on a PC screen.

The program steps are as follows:

Initialize
Your program starts from ASCII monitor command 'go 3100'
Your program prints the message on the HyperTerminal 'Baud rate changed! Please reopen the HyperTerminal with 115.2Kbaud'
Change the SCI port baud rate from 9600 to 115.2Kbaud.
Wait for the first RETURN key hit on the SCI port
Print the message 'Please connect the audio cable to HCS12 board' on the new HyperTerminal (115.2kbaud) if the RETURN key was hit
Non-RETURN key hits are ignored
Also print the 'Well>' prompt on a new line
Wait for the RETURN key hit again on the SCI port
Non-RETURN key hits are ignored
Start a single Analog-to-Digital Conversion (ADC) of the signal on the AN7 pin and display the 8 bit result on the HyperTerminal if the RETURN key was hit.
You may check the result at this time: if the audio cable is correctly connected, the result display is between 123($7B) to 133($85). If the audio cable is not connected or incorrectly connected, the result display is between 0($00) to 32($20).
Also print the 'Well>' prompt on a new line
Wait for the RETURN key hit again on the SCI port
Non-RETURN key hits are ignored
Start a single Analog-to-Digital conversion of the signal on the AN7 pin and display the 8 bit result on the HyperTerminal if the RETURN key was hit.
Also print the 'Well>' prompt on a new line
The subsequent RETURN key hits, the last two steps are repeated.
If the RETURN key hit (then the ADC result display) was followed by the 'a' key hit, Print the following messages:

'Please disconnect the HyperTerminal'
'Start NCH Tone Generator program'
'Start SB Data Receive program'
'Then press the switch SW1, for 1024 point analog to digital conversions'

Wait for the Switch SW1 pressing
Start the Timer Module Channel 2 Output Compare interrupt generation at every 125usec (8KHz rate). Each time the Output Compare interrupt occurs, carry out the following tasks:

Service the Output Compare (OC) register (update the counter compare number) for the next interrupt. Also clear the OC interrupt flag (if you selected the Fast Flag Clear option, updating the timer OC register for the next interrupt will also clear the interrupt flag).
Pick up the ADC result (from previous conversion) and transmit it to SCI port. Only the upper 8bit of the ADC result should be picked up and 1 byte of pure binary number should be transmitted (do NOT convert to ASCII).
Increment the transmit byte counter

Start a single Analog-to-Digital conversion of the signal on the AN7 pin
Wait for the transmit byte count to be 1030
Then repeat the last 3 steps, begining with Switch SW1 press waiting.


Copy the HW10 sample program 1, hw10samp1e.asm file. Study it, assemble it, debug it, and run it on the HCS12 board. This program use Timer channel 2 Output Compare interrupt generation of 125usec for the count down timer. You may use some parts of this program.

Copy the HW10 sample program 2, hw10samp2c.asm file. Study it, assemble it, debug it, and run it on the HCS12 board. This program shows how to change the serial port (SCI port) baud rate and transmit 1030 bytes of data with Switch 1 (SW1) press. It also shows how to receive the data on the host PC side. You may use some parts of this program.

Copy the HW10 sample program 3, hw10samp3b.asm file. Study it, assemble it, debug it, and run it on the HCS12 board. This program converts analog signal to digital data and transmits it in ASCII characters. This program is used to test the cable connections and ADC operation. You may use some parts of this program.

Additional comments on your final HW10 sample program are as follows:

The HW10 program must send the raw 8bit binary number (without ASCII conversion).
The sample program 3 use busy ADC wait for ADC completion, your HW10 program must use the Timer Module Channel 2 Output Compare interrupt every 125usec for each ADC completion.
Your HW10 program must do one ADC conversion at the rate of exactly 8KHz, 125usec a part.
The sample program 3 may converts ADC input channel 5 signal, your HW10 program must convert ADC input channel 7 signal.
The sample program 3 does one conversion per return key hit, your HW10 program must do 1024 (or 1030) conversions per each Push Button SW1 press.
The sample program 3 does ADC conversions with a return key hit, your HW10 program must do the ADC conversions with the Push Button Switch 1 press.


HCS12C128 board audio cable connection:

Connect RED wire to 5V, to pin 1 (of the 60pin connector J1).
Connect SILVER wire (or uninsulated copper wire) to GROUND, to pin 3.
Pin numbers are printed on the board: '2', '10', '20', '30', etc.
Connect WHITE wire to AN7, to pin 10.
Connect the audio plug to speaker/ear phone jack (green) of your PC


Read the HCS12 board user Guide. 
HCS12 Users Guide, Schematic, Push Button Switch 1, etc.

Note that the Push Button Switch 1 is connected to the port P bit 0 in HCS12C128 board

To generate audio sound of sine wave and other waves on your Windows PC, go to Online Tone Generator page. For multiple frequency sounds, you may have the page open multiple times on your web browser. Multiple sounds are mixed then. Another way to generate audio sound of sine wave is that you download FREE SineGen 2.5/2.1 program from SineGen 2.5/2.1 page. Unzip the file on your PC and run SineGen.exe file to generate tone signal wave. You may run SineGen.exe file multiple instances to mix multiple frequency signals.

Copy the SBDRx3.zip file. It is a C++ program designed to run on your PC, connecting to COM port. It will ask your COM port number: 1, 2, 3, ... 9 at the start. The program will receive 1026 bytes of raw data through COM port and save them into a text file for later processing.

Unzip SBDRx3.zip file into an empty folder.
Find the file SBDRx.exe and you can run it by double clicking it.
Or you may find the .cpp files and .h files, study them.
You may change the program and recompile it if you fix COM3 or COM5 port, or if you want the longer data lenth than 1024.


Your PC can run Hyper Terminal or SB Data Receiver (SBDR) program but not both at the same time!!! To run SBDR program, you must quit Hyper Terminal. To run Hyper Terminal, you must quit SBDR program. They both use the COM port of your PC, they can NOT be running at the same time.

Download SciLab Program from SciLab Home page. This program allows your PC to read and plot data.

While the SBDRx program is running, press the Push Button switch SW1. The SBDRx program will receive data bytes coming through COM port of your PC. It will save 1024 data points received into the 'RxData3.txt' text file. You can view the 'RxData3.txt' file with Notepad or Wordpad program in your PC.

Once the 'RxData3.txt' file is created, run SciLab program. Then have the SciLab program read the data from the 'RxData3.txt' file and plot the data on a plot window.

For a sample SciLab commands for plotting data, copy the SciLabCOM.txt file. It shows the list of SciLab commands, you can view or edit with any text editor or SciLab. You can also run it (same as MATLAB .m file) in SciLab if you change the file name to 'SciLabCOM.sce'

Check the plot and verify the signal frequency. Use magnify feature to see the signal wave details. Identify one cycle of signal wave, check how many points are plotted. (for plotting, one may also use MS Excel) You may need to increase or decrease the audio signal volume to make the signal magnitude swing more than 60. That is, signal should be centered about 128 and goes to highest above 160 and goes to lowest below 100.

You can aquire another set of 1024 point ADC data as follows:

Close the SBDRx program (if not already closed) by moving the cursor on its window and hit 'Ctrl' and 'C' keys together.
Run the SBDRx program again (double click).
Press the switch SW1.
New set of data will be recorded into the 'RxData3.txt' file.

Change the tone frequency and wave type in NCH Tone program (Online Tone Generator, SineGen program, or any other audio tone generator) and repeat the data acquisition and plotting.

Write a report of your experiments. Your report must include:

Cover sheet with course and your information.
440Hz Sign wave plots.
1000Hz square wave plots.
440Hz triangle wave plots.
Mixed 440Hz and 550Hz sign wave plots.
For each signal wave, plot full 1024pts and plot magnified 2 signal cycles. Note the signal shape difference among square, sign, triangle, and mixed waves. Identify one cycle of signal wave, and verify correct signal frequency by counting how many points are plotted in one cycle.
Run FFT on the mixed 440Hz and 550Hz sign wave data and plot the FFT result for an extra credit. You may use SciLab FFT command. You should expect two peaks, at 440 and 550. (You may also need to make the wave centered at 0 instead of 128 for FFT.)
Detailed explanation of each plot and operations.