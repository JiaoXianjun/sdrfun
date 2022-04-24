# SPDX-FileCopyrightText: 2022 Xianjun Jiao putaoshu@msn.com
# SPDX-License-Identifier: AGPL-3.0-or-later

from re import A
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
import beamforminglib as bf
from mpl_toolkits.mplot3d import axes3d

def test_bf_per_subcarrier(num_ant = None, fft_size = None, sub_carrier_idx = None, direction = None):
    # plt.figure().close("all")

    if num_ant is None:
        num_ant = 4

    if fft_size is None:
        fft_size = 64

    half_fft_size = int(fft_size/2)

    if sub_carrier_idx is None:
        sub_carrier_idx = np.arange(0, fft_size)

    if direction is None:
        direction = np.arange(-180, 180, 1)
        plot_flag = 0; # plot beam
    else:
        if len(direction) <= 8:
            plot_flag = 1; # plot CSI in subplot
        else:
            plot_flag = 2; # plot CSI in 3D

    direction = np.mod(direction, 360)
    tmp_idx = np.where(direction>=180)
    direction[tmp_idx] = direction[tmp_idx]-360
    direction = np.sort(direction)

    # ofdm generation
    sub_carrier = (np.round(np.random.rand(1,fft_size))-0.5 + 1j*(np.round(np.random.rand(1,fft_size))-0.5))*np.sqrt(2)
    ofdm_symbol = np.fft.ifft(sub_carrier)
    # print(ofdm_symbol)

    # delay for each antenna
    ofdm_symbol_per_ant = np.zeros((num_ant, fft_size)) +1j*np.zeros((num_ant, fft_size))
    for i in np.arange(num_ant):
        num_sample_shift = i
        ofdm_symbol_per_ant[i,:] = np.concatenate((ofdm_symbol[0,(fft_size-num_sample_shift):fft_size], ofdm_symbol[0,0:(fft_size-num_sample_shift)]))

    # print(ofdm_symbol_per_ant)
    # frequency domain after time domain delay
    sub_carrier_per_ant = np.fft.fft(ofdm_symbol_per_ant)
    # plt.plot(np.abs(sub_carrier_per_ant[0,:]))
    # plt.show()

    # phase shift per subcarrier
    sub_carrier_phase_shift = np.zeros((num_ant, fft_size))
    for i in np.arange(num_ant):
        sub_carrier_phase_shift[i,:] = np.angle(sub_carrier_per_ant[i,:]/sub_carrier[0,:])

    sub_carrier_phase_shift_natural = np.concatenate(( sub_carrier_phase_shift[:,half_fft_size:fft_size], sub_carrier_phase_shift[:,0:half_fft_size] ), axis=1)

    # for i in np.arange(num_ant):
    #     plt.plot(np.arange(-half_fft_size, half_fft_size), sub_carrier_phase_shift_natural[i,:])
    # plt.legend(['0','1','2','3'])
    # plt.show()

    beamforming_vec_per_subcarrier = sub_carrier_phase_shift_natural

    direction_all = np.arange(-180, 180, 1)
    beam_mat = np.zeros((len(direction_all), fft_size))
    for i in np.arange(fft_size):
        d, wavelength, a, gain_at_direction_total = bf.ant_array_beam_pattern(freq_hz=2450e6, array_style='linear', num_ant=num_ant, ant_spacing_wavelength=0.5, angle_vec_degree=direction_all, beamforming_vec_rad=beamforming_vec_per_subcarrier[:,i], no_plot_flag=True)
        beam_mat[:,i] = gain_at_direction_total[:,0]

    # for i in np.arange(num_ant):
    #     plt.plot(np.arange(-half_fft_size, half_fft_size), sub_carrier_phase_shift_natural[i,:])
    # plt.legend(['0','1','2','3'])
    # plt.show()

    fig = plt.figure(0)
    fig.clf()
    if plot_flag == 0: # plot beam
        if len(sub_carrier_idx)>17:
            no_legend_flag = 1
        else:
            no_legend_flag = 0
        
        # sub_carrier_idx_str = ["" for i in range(len(sub_carrier_idx))]
        sub_carrier_idx_str = [None]*len(sub_carrier_idx)
        ax = fig.add_subplot(projection='polar')
        for i in range(len(sub_carrier_idx)):
            sub_carrier_idx_str[i] = "carrier idx " + str(sub_carrier_idx[i])
            ax.plot(a, beam_mat[:,sub_carrier_idx[i]])

        if no_legend_flag == 0:
            ax.legend(sub_carrier_idx_str, bbox_to_anchor=(1.45,1), loc="upper right")
        plt.subplots_adjust(right=0.75)
    else:
        num_direction = len(direction)
        if plot_flag == 1:
            ax = fig.add_subplot()
            legend_str = [None]*num_direction
            for i in range(num_direction):
                direction_idx = np.argmin(np.abs(direction[i]-direction_all))
                # ax = plt.subplot(num_direction, 1, i+1)
                ax.plot(beam_mat[direction_idx, :])
                legend_str[i] = "direction " + str(direction[i])
            ax.grid(True)
            ax.set_ylabel('gain')
            ax.set_xlabel('subcarrier idx')
            ax.legend(legend_str, bbox_to_anchor=(1.4,1), loc="upper right")
            plt.subplots_adjust(right=0.75)
        else:
            direction_idx = [None]*num_direction
            for i in range(num_direction):
                direction_idx[i] = np.argmin(np.abs(direction[i]-direction_all))

            x = direction
            y = range(fft_size)
            X, Y = np.meshgrid(x, y)
            Z = beam_mat[direction_idx, :].T
            ax = fig.add_subplot(projection='3d')
            surf = ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap=cm.jet, linewidth=1, antialiased=False)
            ax.set_xlabel('direction (degree)')
            ax.set_ylabel('subcarrier idx')
            ax.set_zlabel('gain')
            fig.colorbar(surf, shrink=0.75)

    plt.show()

# test_bf_per_subcarrier()
# test_bf_per_subcarrier(num_ant=4, fft_size=64, sub_carrier_idx=np.array([0,1,2,3,30,40,41,42,43,44,45,20,21,22,23,13,14,15]), direction = None)
# test_bf_per_subcarrier(num_ant=4, fft_size=64, sub_carrier_idx=np.array([41,42,43,44,45,20,21,22,23,13,14,15]), direction = None)
# test_bf_per_subcarrier(num_ant=4, fft_size=64, sub_carrier_idx=None, direction=np.array([0,30,50,70]))
# test_bf_per_subcarrier(num_ant=4, fft_size=64, sub_carrier_idx=None, direction=np.array(np.arange(100,460)))
# test_bf_per_subcarrier(num_ant=4, fft_size=64, sub_carrier_idx=None, direction=np.array(np.arange(-180,180)))
# test_bf_per_subcarrier(num_ant=4, fft_size=64, sub_carrier_idx=None, direction=np.array([0,30,50,70]))

# test_bf_per_subcarrier(num_ant=4, fft_size=64, sub_carrier_idx=np.array([0, 10, 20, 30, 40, 50, 60]))
# test_bf_per_subcarrier(num_ant=4, fft_size=64, direction=np.array([0,20,40,60,80]))
# test_bf_per_subcarrier(num_ant=4, fft_size=64, direction=np.array(np.arange(-180,180)))