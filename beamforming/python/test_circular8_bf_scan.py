# SPDX-FileCopyrightText: 2021 Xianjun Jiao putaoshu@msn.com
# SPDX-License-Identifier: AGPL-3.0-or-later

import numpy as np; 
import beamforminglib as bf; 
import matplotlib.pyplot as plt

# Get the antenna response at the direction we want to scan
beam_scan_directions = np.arange(0, 360, 15)
d, wavelength = bf.ant_array_beam_pattern(freq_hz=2450e6, array_style='circular', num_ant=8, ant_spacing_wavelength=0.5, angle_vec_degree=beam_scan_directions, pause_interval=0.000001)
beamforming_vec_at_directions = -(d/wavelength)*2*np.pi
plt.close('all')

# Beam scan
for i in np.arange(len(beam_scan_directions)+1):
    bf.ant_array_beam_pattern(freq_hz=2450e6, array_style='circular', num_ant=8, ant_spacing_wavelength=0.5, beamforming_vec_rad=beamforming_vec_at_directions[i%len(beam_scan_directions),], pause_interval=0.1)
    # plt.savefig('circular8-scan-'+str(i)+'.png')