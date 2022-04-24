% SPDX-FileCopyrightText: 2022 Xianjun Jiao putaoshu@msn.com
% SPDX-License-Identifier: AGPL-3.0-or-later

function test_bf_per_subcarrier(num_ant, fft_size, sub_carrier_idx, direction)
% close all;

if exist('num_ant', 'var')==0 || isempty(num_ant)
  num_ant = 4;
end

if exist('fft_size', 'var')==0 || isempty(fft_size)
  fft_size = 64;
end

if exist('sub_carrier_idx', 'var')==0 || isempty(sub_carrier_idx)
  sub_carrier_idx = (1:fft_size)-1;
end

if exist('direction', 'var')==0 || isempty(direction)
  direction = -180:179;
  plot_flag = 0; % plot beam
else
    if length(direction) <= 8
        plot_flag = 1; % plot CSI in subplot
    else
        plot_flag = 2; % plot CSI in 3D
    end
end

direction = mod(direction, 360);
tmp_idx = (direction>=180);
direction(tmp_idx) = direction(tmp_idx)-360;
direction = sort(direction);

% ofdm generation
sub_carrier = (round(rand(fft_size,1))-0.5 + 1i.*(round(rand(fft_size,1))-0.5)).*sqrt(2);
ofdm_symbol = ifft(sub_carrier);

% delay for each antenna
ofdm_symbol_per_ant = zeros(fft_size, num_ant);
for i=1:num_ant
    num_sample_shift = i-1;
    ofdm_symbol_per_ant(:,i) = [ofdm_symbol((end-num_sample_shift+1):end); ofdm_symbol(1:(end-num_sample_shift))];
end

% frequency domain after time domain delay
sub_carrier_per_ant = fft(ofdm_symbol_per_ant, [], 1);

% phase shift per subcarrier
sub_carrier_phase_shift = zeros(fft_size, num_ant);
for i=1:num_ant
    sub_carrier_phase_shift(:,i) = angle(sub_carrier_per_ant(:,i)./sub_carrier);
end
sub_carrier_phase_shift = [sub_carrier_phase_shift(((fft_size/2)+1):end,:); sub_carrier_phase_shift(1:(fft_size/2),:)];

% figure;
% plot(-(fft_size/2):((fft_size/2)-1), sub_carrier_phase_shift); grid on;

beamforming_vec_per_subcarrier = sub_carrier_phase_shift;

direction_all = -180:0.1:(180-0.1);
beam_mat = zeros(length(direction_all), fft_size);
for i=1:fft_size
    [~, ~, a, gain_at_direction_total] = ant_array_beam_pattern(2450e6, 'linear', num_ant, 0.5, direction_all, beamforming_vec_per_subcarrier(i,:), 1);
    beam_mat(:, i) = gain_at_direction_total;
end

figure;
if plot_flag == 0 % plot beam
    if length(sub_carrier_idx)>17
        no_legend_flag = 1;
    else
        no_legend_flag = 0;
    end
    
    sub_carrier_idx_str = cell(1, length(sub_carrier_idx));
    for i=1:length(sub_carrier_idx)
        sub_carrier_idx_str{i} = ['carrier idx ' num2str(sub_carrier_idx(i))];
        if exist('OCTAVE_VERSION', 'builtin')
          polar(a, beam_mat(:,sub_carrier_idx(i)+1)); hold on;
        else
          polarplot(a, beam_mat(:,sub_carrier_idx(i)+1)); hold on;
        end
    end
    if no_legend_flag == 0
        legend(sub_carrier_idx_str);
    end
else
    num_direction = length(direction);
    if plot_flag == 1
        legend_str = cell(1, num_direction);
        for i=1:num_direction
            [~, direction_idx] = min(abs(direction(i)-direction_all));
            plot(beam_mat(direction_idx, :)); grid on; hold on;
            legend_str{i} = ['direction ' num2str(direction(i))];
        end
        ylabel('gain');
        xlabel('subcarrier idx');
        legend(legend_str);
    else
        direction_idx = zeros(num_direction,1);
        for i=1:num_direction
            [~, direction_idx(i)] = min(abs(direction(i)-direction_all));
        end
        x = direction;
        y = (1:fft_size)-1;
        z = beam_mat(direction_idx, :).';
        mesh(x, y, z, 'facecolor', 'interp');
        colormap jet;
        colorbar;
        xlabel('direction (degree)'); ylabel('subcarrier idx'); zlabel('gain');
    end
end
