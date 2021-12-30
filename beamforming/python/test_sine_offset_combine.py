# SPDX-FileCopyrightText: 2021 Xianjun Jiao putaoshu@msn.com
# SPDX-License-Identifier: AGPL-3.0-or-later

import numpy as np; 
import beamforminglib as bf; 
import matplotlib.pyplot as plt

offset_degree = 180
step = np.arange(0, 2, 0.01)
tick = np.arange(0, 780, 120)

c1 = np.exp(step*2*np.pi*1j)
c2 = np.exp(step*2*np.pi*1j + offset_degree*np.pi/180*1j)
c3 = c1+c2

ax1 = plt.subplot(221)
ax1.grid(True)
ax1.plot(step*360, c1.imag)
ax1.set_xticks(tick)
ax1.set_ylim(-2,2)
ax1.set_title('sine1', y=-0.01)

ax2 = plt.subplot(223)
ax2.grid(True)
ax2.plot(step*360, c2.imag)
ax2.set_xticks(tick)
ax2.set_ylim(-2,2)
ax2.set_title('sine2 offset '+str(offset_degree)+' degree', y=-0.01)

ax3 = plt.subplot(122)
ax3.grid(True)
ax3.plot(step*360, c3.imag, 'r')
ax3.set_xticks(tick)
ax3.set_ylim(-3.9,3.9)
ax3.set_title('sine1+sine2', y=-0.01)

plt.show()
