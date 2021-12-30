% SPDX-FileCopyrightText: 2021 Xianjun Jiao putaoshu@msn.com
% SPDX-License-Identifier: AGPL-3.0-or-later

function [ant_x_set, ant_y_set] = ant_gen(array_style, num_ant, ant_spacing_m)
%disp(array_style);

if strcmpi(array_style, 'square') % now the antenna spacing is half length of the square edge
 if mod(num_ant, 4) ~= 0
   disp('num_ant must be 4, 8, 12, 16, ....!');
   return;
 end
 
 len_edge = 2*ant_spacing_m;
 half_len_edge = ant_spacing_m;
 num_ant_per_edge = num_ant/4;
 step_size = len_edge/num_ant_per_edge;
 ant_x_set = zeros(num_ant, 1);
 ant_y_set = zeros(num_ant, 1);
 
 ant_idx = 1;
 
 start_x = -half_len_edge;
 start_y = half_len_edge;
 ant_x_set(ant_idx) = start_x;
 ant_y_set(ant_idx) = start_y;
 ant_idx =  ant_idx + 1;
 for i = 1 : (num_ant_per_edge-1)
   ant_x_set(ant_idx) = ant_x_set(ant_idx - 1) + step_size;
   ant_y_set(ant_idx) = ant_y_set(ant_idx - 1);
   ant_idx = ant_idx + 1;
 end

  start_x = half_len_edge;
  start_y = half_len_edge;
  ant_x_set(ant_idx) = start_x;
  ant_y_set(ant_idx) = start_y;
  ant_idx =  ant_idx + 1;
  for i = 1 : (num_ant_per_edge-1)
    ant_x_set(ant_idx) = ant_x_set(ant_idx - 1);
    ant_y_set(ant_idx) = ant_y_set(ant_idx - 1) - step_size;
    ant_idx = ant_idx + 1;
  end

  start_x = half_len_edge;
  start_y = -half_len_edge;
  ant_x_set(ant_idx) = start_x;
  ant_y_set(ant_idx) = start_y;
  ant_idx =  ant_idx + 1;
  for i = 1 : (num_ant_per_edge-1)
    ant_x_set(ant_idx) = ant_x_set(ant_idx - 1) - step_size;
    ant_y_set(ant_idx) = ant_y_set(ant_idx - 1);
    ant_idx = ant_idx + 1;
  end

  start_x = -half_len_edge;
  start_y = -half_len_edge;
  ant_x_set(ant_idx) = start_x;
  ant_y_set(ant_idx) = start_y;
  ant_idx =  ant_idx + 1;
  for i = 1 : (num_ant_per_edge-1)
    ant_x_set(ant_idx) = ant_x_set(ant_idx - 1);
    ant_y_set(ant_idx) = ant_y_set(ant_idx - 1) + step_size;
    ant_idx = ant_idx + 1;
  end

elseif strcmpi(array_style, 'circular') % now the antenna spacing is radius
  if num_ant < 2
    disp('num_ant must be >= 2!')
    return;
  end
 
 a = 2.*pi.*(0 : (1/num_ant) : (1-1e-9))';
 ant_x_set = ant_spacing_m.*cos(a);
 ant_y_set = ant_spacing_m.*sin(a);
 
elseif strcmpi(array_style, 'linear')
 
  ant_x_set = zeros(num_ant, 1);
  ant_y_set = [0 : (num_ant-1)].'.*ant_spacing_m;
  span_total = (num_ant - 1)*ant_spacing_m;
  ant_y_set = ant_y_set - (span_total)/2;

elseif strcmpi(array_style, 'customized')

  [~, num_col] = size(ant_spacing_m);
  if num_col ~= 2
    disp('Please input a num_ant*2 matrix!');
    disp('The 1st column for X axis position set');
    disp('The 2nd column for Y axis position set');
    return;
  end
  ant_x_set = ant_spacing_m(:, 1);
  ant_y_set = ant_spacing_m(:, 2);

else
  disp('array_style must be linear, circular or square!');
  return;
end