Fs = 100e6%245.76e3;
AMPL_WIDTH = 16;
PHASE_WIDTH = 16;

FULL_SCALE = 2^(AMPL_WIDTH-1) - 1;

global SINE_LUT;
SINE_LUT = generate_lut(AMPL_WIDTH, PHASE_WIDTH);
figure(1); plot(SINE_LUT);
xlabel('Sample_Number'); ylabel('Amplitude');

%Create Simulation timescale
N = 2^16;
Ts = 1/Fs;
t = 0:Ts:(N-1)*Ts;

fundamental_frequency = Fs/(2^PHASE_WIDTH);

frequency = Fs/64;

PHASE_INCREMENT = (frequency/fundamental_frequency)

[cha_o, chb_o] = dds(PHASE_INCREMENT, 0, N);

x_gold = sin(2*pi*frequency*t);

figure(2); plot(t, cha_o/FULL_SCALE, t, x_gold);
xlabel('Time [seconds]'); ylabel('Amplitude [FS]');

x_error = (x_gold - cha_o/FULL_SCALE);
figure(3); plot(t, x_error);
xlabel('Time [seconds]'); ylabel('Voltage [Volts]');


X = fft(cha_o/((2^AMPL_WIDTH-1)-1));
X_Ampl = (1/N).*(abs(X(1:N/2+1)));
X_Ampl(2:N/2) = 2*X_Ampl(2:N/2);
X_Ampl_dB = 10*log10(X_Ampl);

figure(4); plot(X_Ampl_dB);