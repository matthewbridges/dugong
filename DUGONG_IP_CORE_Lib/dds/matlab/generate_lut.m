function [ SINE_LUT ] = generate_lut( AMPL_WIDTH, PHASE_WIDTH )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

N = 2^PHASE_WIDTH;

n = 0:1:N/2-1;

SINE_LUT = round((2^(AMPL_WIDTH-1)-1)*sin(2*pi*(n/N)));

end

