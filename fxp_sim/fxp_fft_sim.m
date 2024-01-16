clear all;close all;clc;
% Genterate complex input data
N = 32000;
F = fimath('OverflowAction','Saturate','RoundingMethod','Floor');

complex_sequence = (randn(1, N) + 1i * randn(1, N)) / sqrt(2);
average_power = mean(abs(complex_sequence).^2);
normalized_sequence = complex_sequence / sqrt(average_power);
verified_average_power = mean(abs(normalized_sequence).^2);

% Check Average Power & Max/Min Value
disp('##########################################');
disp(['# Average Power of input complex data: ', num2str(verified_average_power)]);
disp(['# Max Real: ', num2str(max(real(normalized_sequence)))]);
disp(['# Min Real: ', num2str(min(real(normalized_sequence)))]);
disp(['# Max Image: ', num2str(max(imag(normalized_sequence)))]);
disp(['# Min Image: ', num2str(min(imag(normalized_sequence)))]);
disp(' ');

% Generate complex noise
desired_snr = 30;
noise = (randn(1, N) + 1i * randn(1, N)) / sqrt(2);
noise_power = verified_average_power / (10^(desired_snr / 10));
scale_factor = sqrt(noise_power / mean(abs(noise).^2));
adjusted_noise = noise * scale_factor;

% Check SNR
signal_with_noise = normalized_sequence + adjusted_noise;
actual_snr = 10 * log10(mean(abs(normalized_sequence).^2) / mean(abs(adjusted_noise).^2));
disp(['# Actual SNR: ', num2str(actual_snr)]);
disp(['# Max Real with noise: ', num2str(max(real(signal_with_noise)))]);
disp(['# Min Real with noise: ', num2str(min(real(signal_with_noise)))]);
disp(['# Max Image with noise: ', num2str(max(imag(signal_with_noise)))]);
disp(['# Min Image with noise: ', num2str(min(imag(signal_with_noise)))]);
disp(' ');


% 1.SNR1 - Input & Calculation Result in same width
X_float = zeros(16, N/16);
X_fix = zeros(16, N/16);
snrs = zeros(1, 10);
% Integer length include sign bit
x_il = 5;
% Float FFT
for i = 1:N/16
    X_float(:, i) = fft(normalized_sequence((1:16) + 16*(i-1)), 16);
end
% Fix input & add & multi  FFT
for l = 6:15
    for j = 1:N/16
        X_fix(:, j) = my16fft(signal_with_noise((1:16) + 16*(j-1)), l, l-x_il, 0, 0);
    end
    p_diff = sum(abs(X_fix - X_float).^2, 'all')/N;
    snr = 10  * log10(verified_average_power/p_diff);
    disp(['# SNR with word length: ', num2str(l)]);
    disp([num2str(snr), 'dB']);
    snrs(l - 5) = snr;
end

figure(1);
plot(6:15, snrs, '-o');
xlabel('Word Length');
ylabel('SNR');
title('Input & Calculation WL Fix Point Sim');
grid on;

% 2.SNR2 Twiddle Factor
x_wl = 12;
% Integer length include sign bit
wnr_il = 1;
snrs2 = zeros(1, 10);
X_fix = zeros(16, N/16);
for wl2 = 3:12
    for k = 1:N/16
        X_fix(:, k) = my16fft(signal_with_noise((1:16) + 16*(k-1)), x_wl, x_wl-x_il, wl2, wl2-wnr_il);
    end
    p_diff = sum(abs(X_fix - X_float).^2, 'all')/N;
    snr = 10  * log10(verified_average_power/p_diff);
    disp(['# SNR with Wnr word length: ', num2str(wl2)]);
    disp([num2str(snr), 'dB']);
    snrs2(wl2 - 2) = snr;
end

figure(2);
plot(3:12, snrs2, '-o');
xlabel('Word Length');
ylabel('SNR');
title('Twiddle Factor WL Fix Point Sim');
grid on;

% Do the input & calculation (1,12,7) + Wnr (1,9,8)
X_fix = zeros(16, N/16);
for k = 1:N/16
        X_fix(:, k) = my16fft(signal_with_noise((1:16) + 16*(k-1)), 12, 7, 9, 8);
end

% Write to file
% FIX Twiddle Factor (1, 9, 8)
% for r=0:7
%         wnr(r+1)  = cos(2*pi*r/16) - 1i*sin(2*pi*r/16);
% end
% wnr_real_fxp = fi(real(wnr), 1, 9, 8, F)*pow2(8);
% wnr_image_fxp = fi(imag(wnr), 1, 9, 8, F)*pow2(8);
% wnr_real_bin = dec2bin(wnr_real_fxp, 9);
% wnr_image_bin = dec2bin(wnr_image_fxp, 8);
% writematrix(wnr_real_bin(:, 8:16), "wnr_real_bin.txt");
% writematrix(wnr_image_bin(:, 8:16), "wnr_image_bin.txt");

% input real & image (1, 12, 7)
input_real_fxp = fi(real(signal_with_noise), 1, 12, 7, F).*pow2(7);
input_image_fxp = fi(imag(signal_with_noise), 1, 12, 7, F).*pow2(7);
input_real_bin = dec2bin(input_real_fxp, 12);
input_image_bin = dec2bin(input_image_fxp, 12);
writematrix(input_real_bin(:, 5:16), "input_real_bin.txt");
writematrix(input_image_bin(:, 5:16), "input_image_bin.txt");

% FIX FFT output real & image (1, 12, 7)
output_fix = reshape(X_fix, [], 1).*pow2(7);
writematrix(output_fix);
% X_real_fxp = real(output_fix).*pow2(7);
% X_image_fxp = imag(output_fix).*pow2(7);
% X_real_bin = dec2bin(X_real_fxp, 12);
% X_image_bin = dec2bin(X_image_fxp, 12);
% writematrix(X_real_bin(:, 5:16), "output_real_bin.txt");
% writematrix(X_image_bin(:, 5:16), "output_image_bin.txt");


