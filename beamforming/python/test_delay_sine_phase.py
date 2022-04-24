# SPDX-FileCopyrightText: 2022 Xianjun Jiao putaoshu@msn.com
# SPDX-License-Identifier: AGPL-3.0-or-later

import numpy as np
import matplotlib.pyplot as plt

sampling_rate = 20e6
time_span  = 10e-6
delay_time = 1e-6

f0 = 0.1e6
f1 = 0.2e6
f2 = 0.4e6

sampling_time = 1/sampling_rate
num_total_sample = int(time_span/sampling_time)
num_delay_sample = int(delay_time/sampling_time)

t = sampling_time*np.arange(0, num_total_sample)
sine0 = np.sin(2*np.pi*f0*t)
sine1 = np.sin(2*np.pi*f1*t)
sine2 = np.sin(2*np.pi*f2*t)

ax1 = plt.subplot(211)
ax1.grid(True)
ax1.plot(t*1e6, sine0, 'r')
ax1.plot(t*1e6, sine1, 'b')
ax1.plot(t*1e6, sine2, 'k')
ax1.plot(np.array([t[num_delay_sample], t[num_delay_sample]])*1e6, np.array([-1, 1]), 'k--')
ax1.set_title('sampling rate 20MHz; time span 10us')
ax1.legend(['f0=0.1MHz', 'f1=0.2MHz', 'f2=0.4MHz'], bbox_to_anchor=(1.2,1), loc="upper right")
ax1.set_xlabel('us')

sine0_delay_1us = np.concatenate((sine0[(num_total_sample-num_delay_sample):num_total_sample], sine0[0:(num_total_sample-num_delay_sample)]))
sine1_delay_1us = np.concatenate((sine1[(num_total_sample-num_delay_sample):num_total_sample], sine1[0:(num_total_sample-num_delay_sample)]))
sine2_delay_1us = np.concatenate((sine2[(num_total_sample-num_delay_sample):num_total_sample], sine2[0:(num_total_sample-num_delay_sample)]))

ax2 = plt.subplot(212)
ax2.grid(True)
ax2.plot(t*1e6, sine0_delay_1us, 'r')
ax2.plot(t*1e6, sine1_delay_1us, 'b')
ax2.plot(t*1e6, sine2_delay_1us, 'k')
ax2.plot(np.array([t[num_delay_sample], t[num_delay_sample]])*1e6, np.array([-1, 1]), 'k--')
ax2.legend(['f0=0.1MHz delay 1us', 'f1=0.2MHz delay 1us', 'f2=0.4MHz delay 1us'], bbox_to_anchor=(1.4,1), loc="upper right")
ax2.set_xlabel('us')

plt.subplots_adjust(right=0.75)
plt.show()
