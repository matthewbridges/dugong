% Fs/8 Hanning off
% Fs/8 Hanning on
% 15MHz Haning off
% 15MHz Hanning on
% Discrete value of pi

Fs = 245.76e6;
AMPL_WIDTH = 16;
PHASE_WIDTH = 16;

FULL_SCALE = 2^(AMPL_WIDTH-1) - 1;

global SINE_LUT;
SINE_LUT = generate_lut(AMPL_WIDTH, PHASE_WIDTH);
figure(1); plot(SINE_LUT);
xlabel('Sample Number'); ylabel('Amplitude');

%Create Simulation timescale
N = 30000;

Ts = 1/Fs;
t = 0:Ts:(N-1)*Ts;

finc = Fs/N;
f = 0:finc:(N/2)*finc;
fundamental_frequency = Fs/(2^PHASE_WIDTH);

frequency = 15e6;

PHASE_INCREMENT = round(frequency/fundamental_frequency)

x = dds(PHASE_INCREMENT, 0, N);

x_gold = sin(2*pi*frequency*t);

t_plot = 4/frequency;
N_plot = round(t_plot/Ts);

figure(2); plot(t(1:N_plot), x(1:N_plot)/FULL_SCALE, t(1:N_plot), x_gold(1:N_plot));
xlabel('Time [seconds]'); ylabel('Amplitude [FS]');

x_error = (x_gold*FULL_SCALE - x);
max(x_error)
mean(x_error)

figure(3); plot(t(1:N_plot), x_error(1:N_plot));
xlabel('Time [seconds]'); ylabel('Error [LSB]');

han_window = 2*hanning(N);
han_window = han_window';

%Signal Spectral Analysis
X = fft((x/FULL_SCALE).*han_window);
X_Ampl = abs(X)./N;
X_Ampl(2:N/2) = 2*X_Ampl(2:N/2);
X_Ampl_dBFS = 20*log10(X_Ampl);

%Gold Measure Spectral Analysis
X_gold = fft(x_gold.*han_window);
X_gold_Ampl = abs(X_gold)./N;
X_gold_Ampl(2:N/2) = 2*X_gold_Ampl(2:N/2);
X_gold_Ampl_dB = 20*log10(X_gold_Ampl);

%Gold Measure Spectral Analysis
X_error = fft((x_error/FULL_SCALE).*han_window);
X_error_Ampl = abs(X_error)./N;
X_error_Ampl(2:N/2) = 2*X_error_Ampl(2:N/2);
X_error_Ampl_dB = 20*log10(X_error_Ampl);

N_plot = N/2;
figure(4); plot(f(1:N_plot)./1e6, X_Ampl_dBFS(1:N_plot), f(1:N_plot)./1e6, X_gold_Ampl_dB(1:N_plot));
xlabel('Frequency [MHz]'); ylabel('Amplitude [dB / dBFS]');
title('15MHz tone comparison of custom Fixed-point DDS function vs Matlab Floating-point sin function','FontWeight','bold');

figure(5); plot(f(1:N_plot)./1e6, X_Ampl_dBFS(1:N_plot), f(1:N_plot)./1e6, X_error_Ampl_dB(1:N_plot));
xlabel('Frequency [MHz]'); ylabel('Amplitude [dB / dBFS]');
title('15MHz tone comparison of custom Fixed-point DDS function vs error','FontWeight','bold');
