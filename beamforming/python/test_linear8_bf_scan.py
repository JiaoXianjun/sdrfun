# SPDX-FileCopyrightText: 2021 Xianjun Jiao putaoshu@msn.com
# SPDX-License-Identifier: AGPL-3.0-or-later

import numpy as np; 
import beamforminglib as bf; 
import matplotlib.pyplot as plt

for i in np.arange(-8, 9, 1):
    bf.ant_array_beam_pattern(freq_hz=2450e6, array_style='linear', num_ant=8, ant_spacing_wavelength=0.5, beamforming_vec_rad=i*np.pi*np.arange(0, 1, 0.125), pause_interval=0.1)
    