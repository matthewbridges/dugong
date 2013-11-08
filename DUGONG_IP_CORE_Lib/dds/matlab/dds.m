function [ SIN_OUT, COS_OUT  ] = dds( PHASE_INCREMENT, PHASE_OFFSET, N )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
global SINE_LUT;
lut_size = length(SINE_LUT)

phase_accum = 0;
SIN_OUT = zeros(1,N);
COS_OUT = zeros(1,N);

for i = 1:N
    
    phase = phase_accum + PHASE_OFFSET;
    lut_addr = fix(phase + 1);
    switch fix(phase/lut_size)
        case 0
            sin_ampl = SINE_LUT(lut_addr);
            cos_ampl = phase;
        case 1            
            sin_ampl = -SINE_LUT(lut_addr - lut_size);
            cos_ampl = phase;
        otherwise
            sin_ampl = 0;
            cos_ampl = 0;
    end
    
    phase_accum = phase_accum + PHASE_INCREMENT;
    if (phase_accum > 2*lut_size)
        phase_accum = phase_accum - 2*lut_size;
    end
        
    SIN_OUT(i) = sin_ampl;
    COS_OUT(i) = cos_ampl;
end

end

