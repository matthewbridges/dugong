AMPL_WIDTH = 16;
PHASE_WIDTH = 16;

FULL_SCALE = 2^(AMPL_WIDTH-1) - 1;

%Collect file data
dds_sim = csvread('dds_simulation_out.csv'); 
%Extract file data
x_sin_out = dds_sim(:,1);
x_cos_out = dds_sim(:,2);
t_out = dds_sim(:,3);
t_out = t_out* 1e-12; %convert from pico seconds

sim_length = length(t_out)
sim_time = t_out(sim_length)

%Create Simulation timescale
N = 30000;

Ts = t_out(2);
t = t_out(1:N);

Fs = 1/Ts;
finc = Fs/N;
f = 0:finc:(N/2)*finc;
fundamental_frequency = Fs/(2^PHASE_WIDTH);

x = x_sin_out(1:N)';
y = x_cos_out(1:N)';

t_plot = 0.000005;
N_plot = round(t_plot/Ts);

figure(1); plot(t(1:N_plot), x(1:N_plot)/FULL_SCALE, t(1:N_plot), y(1:N_plot)/FULL_SCALE);
xlabel('Time [seconds]'); ylabel('Amplitude [FS]');

han_window = 2*hanning(N);
han_window = han_window';

%Signal Spectral Analysis
X = fft((x/FULL_SCALE).*han_window);
X_Ampl = abs(X)./N;
X_Ampl(2:N/2) = 2*X_Ampl(2:N/2);
X_Ampl_dBFS = 20*log10(X_Ampl);

[max_value, max_index] = max(X_Ampl_dBFS);

frequency = (max_index-1)*finc

PHASE_INCREMENT = round(frequency/fundamental_frequency)

x_gold_dds = dds(PHASE_INCREMENT, 0, N);

x_gold = sin(2*pi*frequency*t);

figure(2); plot(t(1:N_plot), x(1:N_plot)/FULL_SCALE, t(1:N_plot), x_gold(1:N_plot));
xlabel('Time [seconds]'); ylabel('Amplitude [FS]');

x_error = (x_gold_dds - x);
max(x_error)
mean(x_error)

figure(3); plot(t(1:N_plot), x_error(1:N_plot));
xlabel('Time [seconds]'); ylabel('Error [LSB]');

N_plot = N/2;
figure(4); plot(f(1:N_plot)./1e6, X_Ampl_dBFS(1:N_plot));
xlabel('Frequency [MHz]'); ylabel('Amplitude [dB / dBFS]');
title('15MHz tone compaarison of custom Fixed-point DDS function vs Matlab Floating-point sin function','FontWeight','bold');
