% SPDX-FileCopyrightText: 2021 Xianjun Jiao putaoshu@msn.com
% SPDX-License-Identifier: AGPL-3.0-or-later

function [d, wavelength] = ant_array_beam_pattern(freq_hz, array_style, num_ant, ant_spacing_wavelength, angle_vec_degree, beamforming_vec_rad)
c = 299792458;

if exist('angle_vec_degree', 'var')==0 || isempty(angle_vec_degree)
  angle_vec_degree = 0:0.001:360;
end

[num_row, ~] = size(angle_vec_degree);

if num_row == 1
    plot_in_polar = 1;
else
    plot_in_polar = 0;
end

angle_vec_degree = angle_vec_degree(:);

if nargin == 0
  close all;
end

if exist('freq_hz', 'var')==0 || isempty(freq_hz)
  freq_hz = 2450000000;
end

if exist('array_style', 'var')==0 || isempty(array_style)
  array_style = 'linear'; 
end

if exist('num_ant', 'var')==0 || isempty(num_ant)
  num_ant = 8;
end

if exist('ant_spacing_wavelength', 'var')==0 || isempty(ant_spacing_wavelength)
  ant_spacing_wavelength = 0.5; % wavelength/2
end

wavelength = c/freq_hz;
if ~strcmpi(array_style, 'customized')
  ant_spacing_m = ant_spacing_wavelength*wavelength;
else
  ant_spacing_m = ant_spacing_wavelength; % now the ant_spacing_wavelength is [ant_x_set, ant_y_set]
end

%Generate the antenna locations
[ant_x_set, ant_y_set] = ant_gen(array_style, num_ant, ant_spacing_m);
num_ant = length(ant_x_set); % in case customized array

if exist('beamforming_vec_rad', 'var')==0 || isempty(beamforming_vec_rad)
  beamforming_vec_rad = zeros(num_ant, 1);
end

if length(beamforming_vec_rad) ~= num_ant
    disp('The number of element in beamforming_vec_rad should be qual to the num_ant');
    return;
end

beamforming_vec = exp(beamforming_vec_rad(:).*1i);

%Generate the angle and radius
a = (pi./180).*angle_vec_degree;
r = 1e5; % very far to emulate far field

%Calculate x, y on the circle
x = r.*cos(a);
y = r.*sin(a);

%Calculate the distance from the circle to each antenna
num_sample = length(x);
d = zeros(num_sample, num_ant);
for i = 1 : num_ant
  ant_x = ant_x_set(i);
  ant_y = ant_y_set(i);
  d(:, i) = sqrt( (x - ant_x).^2 + (y - ant_y).^2);
end

%Calculate the gain at direction
signal_rx_at_direction_total = sqrt(1/num_ant).*exp((d./wavelength).*2.*pi.*1i)*beamforming_vec;
gain_at_direction_total = abs(signal_rx_at_direction_total).^2;
% gain_db_at_direction_total = 10.*log10(gain_at_direction_total);

%Plot
% figure; 
max_gain = max(gain_at_direction_total);
if abs(ceil(max_gain) - max_gain) < 0.1
  max_r = ceil(max_gain) + 1;
else
  max_r = ceil(max_gain) ;
end
if exist('OCTAVE_VERSION', 'builtin')
    polar(a, gain_at_direction_total); hold on;
else
    if plot_in_polar == 1
        polarplot(a, gain_at_direction_total); hold on;
    else
        [x, y] = pol2cart(a, gain_at_direction_total);
        plot(x, y); hold on;
    end
end

if strcmpi(array_style, 'linear') 
  scale_target_for_ant_plot = (max_gain/4)./(ant_spacing_m*num_ant/2);
elseif strcmpi(array_style, 'customized')
  fake_ant_spacing_m = max(max(ant_x_set)-min(ant_x_set), max(ant_y_set)-min(ant_y_set))/2;
  scale_target_for_ant_plot = (max_gain/4)./fake_ant_spacing_m;
else
  scale_target_for_ant_plot = (max_gain/4)./ant_spacing_m;
end

if exist('OCTAVE_VERSION', 'builtin')
  plot(ant_x_set.*scale_target_for_ant_plot, ant_y_set.*scale_target_for_ant_plot, 'ro');
else
  x = ant_x_set.*scale_target_for_ant_plot;
  y = ant_y_set.*scale_target_for_ant_plot;
  if plot_in_polar == 1
      [theta,rho] = cart2pol(x,y);
      polarplot(theta, rho, 'ro');
  else
      plot(x, y, 'ro');
      grid on;
  end
end

if plot_in_polar == 1
  if ~exist('OCTAVE_VERSION', 'builtin')
    rlim([0, max_r]);
  end
    rticks(0:1:max_r);
end

%figure;
%idx_remove = gain_db_at_direction_total<-6;
%gain_db_at_direction_total(idx_remove) = [];
%a(idx_remove) = [];
%polar(a, gain_db_at_direction_total);

%idx_right = (a>=0 & a<=pi/2) | (a<=0 & a >= -pi/2);
%idx_left   = ~idx_right;
%polar(a(idx_right), gain_db_at_direction_total(idx_right)); hold on;
%polar(a(idx_left), gain_db_at_direction_total(idx_left)); hold on;

%xlabel('x - m'); ylabel('y - m'); 
%axis('square');