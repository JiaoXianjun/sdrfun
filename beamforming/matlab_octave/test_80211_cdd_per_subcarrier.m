% SPDX-FileCopyrightText: 2022 Xianjun Jiao putaoshu@msn.com
% SPDX-License-Identifier: AGPL-3.0-or-later

% function test_80211_cdd_per_subcarrier
clear all;
close all;

% num_subcarrier = 56;
num_subcarrier = 52;
fft_size = 64;
sampling_rate = 20e6;
sampling_time_ns = 1e9*(1/sampling_rate);

% 802.11-2020: Table 19-9—Cyclic shift for non-HT portion of PPDU
ant0_csd_ns = 0;
ant1_csd_ns = 50;
ant2_csd_ns = 100;
ant3_csd_ns = 150;

% ant0_csd_ns = 0;
% ant1_csd_ns = 0;
% ant2_csd_ns = 0;
% ant3_csd_ns = 0;

ant0_csd_sample = ant0_csd_ns/sampling_time_ns;
ant1_csd_sample = ant1_csd_ns/sampling_time_ns;
ant2_csd_sample = ant2_csd_ns/sampling_time_ns;
ant3_csd_sample = ant3_csd_ns/sampling_time_ns;

num_subcarrier_half = num_subcarrier/2;
sub_carrier = ones(num_subcarrier+1, 1);
sub_carrier_re_arrange_before_ifft = zeros(fft_size, 1);
sub_carrier_re_arrange_before_ifft(1:(num_subcarrier_half+1)) = sub_carrier((num_subcarrier_half+1):end);
sub_carrier_re_arrange_before_ifft((fft_size-(num_subcarrier_half-1)):fft_size) = sub_carrier(1:num_subcarrier_half);

ofdm_symbol_in_time_domain = ifft(sub_carrier_re_arrange_before_ifft);

csd_ant0 = [ofdm_symbol_in_time_domain((end-ant0_csd_sample+1):end); ofdm_symbol_in_time_domain(1:(end-ant0_csd_sample))];
csd_ant1 = [ofdm_symbol_in_time_domain((end-ant1_csd_sample+1):end); ofdm_symbol_in_time_domain(1:(end-ant1_csd_sample))];
csd_ant2 = [ofdm_symbol_in_time_domain((end-ant2_csd_sample+1):end); ofdm_symbol_in_time_domain(1:(end-ant2_csd_sample))];
csd_ant3 = [ofdm_symbol_in_time_domain((end-ant3_csd_sample+1):end); ofdm_symbol_in_time_domain(1:(end-ant3_csd_sample))];

csd_sub_carrier_ant0 = fft(csd_ant0);
csd_sub_carrier_ant1 = fft(csd_ant1);
csd_sub_carrier_ant2 = fft(csd_ant2);
csd_sub_carrier_ant3 = fft(csd_ant3);

csd_sub_carrier_ant0 = [csd_sub_carrier_ant0((fft_size-(num_subcarrier_half-1)):fft_size); csd_sub_carrier_ant0(1:(num_subcarrier_half+1))];
csd_sub_carrier_ant1 = [csd_sub_carrier_ant1((fft_size-(num_subcarrier_half-1)):fft_size); csd_sub_carrier_ant1(1:(num_subcarrier_half+1))];
csd_sub_carrier_ant2 = [csd_sub_carrier_ant2((fft_size-(num_subcarrier_half-1)):fft_size); csd_sub_carrier_ant2(1:(num_subcarrier_half+1))];
csd_sub_carrier_ant3 = [csd_sub_carrier_ant3((fft_size-(num_subcarrier_half-1)):fft_size); csd_sub_carrier_ant3(1:(num_subcarrier_half+1))];

% plot(-num_subcarrier_half:num_subcarrier_half, angle(csd_sub_carrier_ant0), 'b'); hold on; grid on;
% plot(-num_subcarrier_half:num_subcarrier_half, angle(csd_sub_carrier_ant1), 'r'); hold on; grid on;
% plot(-num_subcarrier_half:num_subcarrier_half, angle(csd_sub_carrier_ant2), 'k'); hold on; grid on;
% plot(-num_subcarrier_half:num_subcarrier_half, angle(csd_sub_carrier_ant3), 'g'); hold on; grid on;
% legend('ant0', 'ant1', 'ant2', 'ant3');

beamforming_vec_per_subcarrier = angle([csd_sub_carrier_ant0, csd_sub_carrier_ant1, csd_sub_carrier_ant2, csd_sub_carrier_ant3]);

gain_per_sub_carrier_at_direction = zeros(num_subcarrier+1, 1);
% Plot beam per sub carrier
for i=1:(num_subcarrier+1)
    disp(num2str(i));
%     clf;
    [~, ~, gain_at_direction_total] = ant_array_beam_pattern(2450e6, 'linear', 4, 0.5, 0:0.01:1, beamforming_vec_per_subcarrier(i,:));
%     hold on; drawnow;
    gain_per_sub_carrier_at_direction(i) = gain_at_direction_total(1);
end
close all;
plot(gain_per_sub_carrier_at_direction); grid on;

sum(gain_per_sub_carrier_at_direction)
