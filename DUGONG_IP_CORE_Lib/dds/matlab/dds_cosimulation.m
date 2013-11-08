%Collect file data
dds_sim = csvread('dds_simulation_out.csv'); 
%Extract file data
x_sin_out = dds_sim(:,1);
x_cos_out = dds_sim(:,2);
t_out = dds_sim(:,3);
t_out = t_out* 1e-9; %convert to nano seconds

N = length(t_out)
sim_time = t_out(N);
Ts = t_out(2);
Fs = 1/Ts;

next_N2 = nextpow2(N);
N2 = 2^(next_N2 - 1)

t = t_out(1:N2);

AMPL_WIDTH = 16;
PHASE_WIDTH = 16;

FULL_SCALE = 2^(AMPL_WIDTH-1) - 1;

x_sin_out_floating = x_sin_out(1:N2)/FULL_SCALE;

figure(1); plot(t, x_sin_out_floating, t, x_cos_out(1:N2)/FULL_SCALE);
xlabel('Time [seconds]'); ylabel('Voltage [Volts]');

PHASE_INCREMENT = 2^8;

fundamental_frequency = Fs/(2^PHASE_WIDTH);

frequency = fundamental_frequency*PHASE_INCREMENT

x_sin_gold = 1e-32*randn(N2,1) + sin(2*pi*frequency*t);

x_error = x_sin_gold - x_sin_out_floating;
figure(2); plot(t, x_error);
xlabel('Time [seconds]'); ylabel('Voltage [Volts]');

%Spectral Analysis
X_sin_out = fft(x_sin_out_floating);
X_sin_out_Ampl = (1/N2).*(abs(X_sin_out(1:N2/2+1)));
X_sin_out_Ampl(2:N2/2) = 2*X_sin_out_Ampl(2:N2/2);
X_sin_out_Ampl_dB = 10*log10(X_sin_out_Ampl);

X_sin_gold = fft(x_sin_gold);
X_sin_gold_Ampl = (1/N2).*(abs(X_sin_gold(1:N2/2+1)));
X_sin_gold_Ampl(2:N2/2) = 2*X_sin_gold_Ampl(2:N2/2);
X_sin_gold_Ampl_dB = 10*log10(X_sin_gold_Ampl);

f = Fs*(0:1/N2:0.5);

figure(3); plot(f, X_sin_out_Ampl_dB, f, X_sin_gold_Ampl_dB);
xlabel('Frequency [Hz]'); ylabel('Ampitude [dB]');

X_error = fft(x_error);
X_error_Ampl = (1/N2).*(abs(X_error(1:N2/2+1)));
X_error_Ampl(2:N2/2) = 2*X_error_Ampl(2:N2/2);
X_error_Ampl_dB = 10*log10(X_error_Ampl);

figure(4); plot(f, X_sin_out_Ampl_dB, f, X_error_Ampl_dB);
xlabel('Frequency [Hz]'); ylabel('Ampitude [dB]');

%periodogram(x_sin_out(1:N2),rectwin(N2),N2,Fs);
