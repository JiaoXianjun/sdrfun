% SPDX-FileCopyrightText: 2021 Xianjun Jiao putaoshu@msn.com
% SPDX-License-Identifier: AGPL-3.0-or-later

% function test_circular8_bf_scan
clear all;
close all;

beam_scan_directions = 0:15:360;
[d, wavelength] = ant_array_beam_pattern(2450e6, 'circular', 8, 0.5, beam_scan_directions);
close all;
beamforming_vec_at_directions = -(d./wavelength).*2.*pi;

% Beam scan
for i=1:length(beam_scan_directions)
    clf;
    ant_array_beam_pattern(2450e6, 'circular', 8, 0.5, [], beamforming_vec_at_directions(i,:));
    drawnow;
end
