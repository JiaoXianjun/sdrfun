% SPDX-FileCopyrightText: 2021 Xianjun Jiao putaoshu@msn.com
% SPDX-License-Identifier: AGPL-3.0-or-later

% function test_linear8_bf_scan
clear all;
close all;

for i = -8:8
    clf;
    ant_array_beam_pattern(2450e6, 'linear', 8, 0.5, [], i.*pi.*(0:0.125:1-0.125));
    drawnow;
end
