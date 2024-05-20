## Generated SDC file "top_NivelControl.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.1.0 Build 590 10/25/2017 SJ Lite Edition"

## DATE    "Wed May 18 16:28:13 2022"

##
## DEVICE  "10M50DAF484C6GES"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk}]
create_clock -name {nRst} -period 1.000 -waveform { 0.000 0.500 } [get_ports {nRst}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {nRst}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {nRst}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {nRst}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {nRst}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {nRst}] -rise_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {nRst}] -fall_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {nRst}] -rise_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {nRst}] -fall_to [get_clocks {clk}]  0.030  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {SDI nRst}] -to [get_ports {seg_Y[6] SDO SPC display_Y[0] display_Y[1] display_Y[2] display_Y[3] display_Y[4] display_Y[5] display_Y[6] display_Y[7] leds_X[0] leds_X[1] leds_X[2] leds_X[3] leds_X[4] leds_X[5] leds_X[6] leds_X[7] nCS seg_Y[0] seg_Y[1] seg_Y[2] seg_Y[3] seg_Y[4] seg_Y[5]}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

