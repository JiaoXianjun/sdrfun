% SPDX-FileCopyrightText: 2021 Xianjun Jiao putaoshu@msn.com
% SPDX-License-Identifier: AGPL-3.0-or-later

% function test_sine_offset_combine
close all;
clear all;

offset_degree = 180;
step = 0:0.01:2;
tick = 0:120:780;

c1 = exp(step.*2.*pi.*1j);
c2 = exp(step.*2.*pi.*1j + offset_degree.*pi./180.*1j);
c3 = c1+c2;

subplot(2, 2, 1);
plot(step.*360, imag(c1));
grid on;
xticks(tick);
ylim([-2,2]);
title('sine1');

subplot(2, 2, 3);
plot(step.*360, imag(c2));
grid on;
xticks(tick)
ylim([-2,2])
title(['sine2 offset ' num2str(offset_degree) ' degree']);

subplot(2, 2, [2,4]);
plot(step.*360, imag(c3), 'r');
grid on;
xticks(tick);
ylim([-3.9,3.9]);
title('sine1+sine2');
