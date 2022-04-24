% SPDX-FileCopyrightText: 2022 Xianjun Jiao putaoshu@msn.com
% SPDX-License-Identifier: AGPL-3.0-or-later

% function test_delay_sine_phase
close all;
clear all;

sampling_rate = 20e6;
time_span  = 10e-6;
delay_time = 1e-6;

f0 = 0.1e6;
f1 = 0.2e6;
f2 = 0.4e6;

sampling_time = 1/sampling_rate;
num_total_sample = time_span/sampling_time;
num_delay_sample = delay_time/sampling_time;

t = (0:num_total_sample-1).*sampling_time;
sine0 = sin(2.*pi.*f0.*t);
sine1 = sin(2.*pi.*f1.*t);
sine2 = sin(2.*pi.*f2.*t);

subplot(2,1,1);
plot(t.*1e6, sine0, 'r'); hold on; grid on;
plot(t.*1e6, sine1, 'b'); hold on; grid on;
plot(t.*1e6, sine2, 'k'); hold on; grid on;
plot([t(num_delay_sample+1), t(num_delay_sample+1)].*1e6, [-1, 1], 'k--');
title('sampling rate 20MHz; time span 10us');
legend('f0=0.1MHz', 'f1=0.2MHz', 'f2=0.4MHz');
xlabel('us');

sine0_delay_1us = [sine0(end-num_delay_sample+1:end), sine0(1:end-num_delay_sample)];
sine1_delay_1us = [sine1(end-num_delay_sample+1:end), sine1(1:end-num_delay_sample)];
sine2_delay_1us = [sine2(end-num_delay_sample+1:end), sine2(1:end-num_delay_sample)];

subplot(2,1,2);
plot(t.*1e6, sine0_delay_1us, 'r'); hold on; grid on;
plot(t.*1e6, sine1_delay_1us, 'b'); hold on; grid on;
plot(t.*1e6, sine2_delay_1us, 'k'); hold on; grid on;
plot([t(num_delay_sample+1), t(num_delay_sample+1)].*1e6, [-1, 1], 'k--');
legend('f0=0.1MHz delay 1us', 'f1=0.2MHz delay 1us', 'f2=0.4MHz delay 1us');
xlabel('us');
