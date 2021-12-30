# SPDX-FileCopyrightText: 2021 Xianjun Jiao putaoshu@msn.com
# SPDX-License-Identifier: AGPL-3.0-or-later

import numpy as np
import matplotlib.pyplot as plt

def pol2cart(rho, theta):
    x = rho * np.cos(theta)
    y = rho * np.sin(theta)
    return(x, y)

def cart2pol(x, y):
    z = x + 1j * y
    rho = np.sqrt(x**2 + y**2)
    theta = np.arctan2(y, x)
    return(theta, rho)

def ant_gen(array_style = None,num_ant = None,ant_spacing_m = None): 
    print(array_style, num_ant, ant_spacing_m)
    
    if array_style.lower()=='square':
        if np.mod(num_ant,4) != 0:
            print('num_ant must be 4, 8, 12, 16, ....!')
            return
        len_edge = 2 * ant_spacing_m
        half_len_edge = ant_spacing_m
        num_ant_per_edge = num_ant / 4
        step_size = len_edge / num_ant_per_edge
        ant_x_set = np.zeros((num_ant,1))
        ant_y_set = np.zeros((num_ant,1))
        ant_idx = 0
        start_x = - half_len_edge
        start_y = half_len_edge
        ant_x_set[ant_idx] = start_x
        ant_y_set[ant_idx] = start_y
        ant_idx = ant_idx + 1
        for i in np.arange(num_ant_per_edge - 1):
            ant_x_set[ant_idx] = ant_x_set[ant_idx - 1] + step_size
            ant_y_set[ant_idx] = ant_y_set[ant_idx - 1]
            ant_idx = ant_idx + 1
        start_x = half_len_edge
        start_y = half_len_edge
        ant_x_set[ant_idx] = start_x
        ant_y_set[ant_idx] = start_y
        ant_idx = ant_idx + 1
        for i in np.arange(num_ant_per_edge - 1):
            ant_x_set[ant_idx] = ant_x_set[ant_idx - 1]
            ant_y_set[ant_idx] = ant_y_set[ant_idx - 1] - step_size
            ant_idx = ant_idx + 1
        start_x = half_len_edge
        start_y = - half_len_edge
        ant_x_set[ant_idx] = start_x
        ant_y_set[ant_idx] = start_y
        ant_idx = ant_idx + 1
        for i in np.arange(num_ant_per_edge - 1):
            ant_x_set[ant_idx] = ant_x_set[ant_idx - 1] - step_size
            ant_y_set[ant_idx] = ant_y_set[ant_idx - 1]
            ant_idx = ant_idx + 1
        start_x = - half_len_edge
        start_y = - half_len_edge
        ant_x_set[ant_idx] = start_x
        ant_y_set[ant_idx] = start_y
        ant_idx = ant_idx + 1
        for i in np.arange(num_ant_per_edge - 1):
            ant_x_set[ant_idx] = ant_x_set[ant_idx - 1]
            ant_y_set[ant_idx] = ant_y_set[ant_idx - 1] + step_size
            ant_idx = ant_idx + 1
    elif array_style.lower()=='circular':
        if num_ant < 2:
            print('num_ant must be >= 2!')
            return
        a = 2*np.pi*np.arange(0, 1, 1/num_ant)
        ant_x_set = ant_spacing_m*np.cos(a)
        ant_y_set = ant_spacing_m*np.sin(a)
    elif array_style.lower()=='linear':
        ant_x_set = np.zeros((num_ant,1))
        ant_y_set = ant_spacing_m*np.array([np.arange(0, num_ant, 1)]).T
        span_total = (num_ant - 1) * ant_spacing_m
        ant_y_set = ant_y_set - (span_total) / 2
    elif array_style.lower()=='customized':
        num_row,num_col = ant_spacing_m.shape
        if num_col != 2:
            print('Please input a num_ant*2 matrix!')
            print('The 1st column for X axis position set')
            print('The 2nd column for Y axis position set')
            return
        ant_x_set = ant_spacing_m[:,0]
        ant_y_set = ant_spacing_m[:,1]
    else:
        print('array_style must be linear, circular or square!')
        return
    
    return ant_x_set, ant_y_set

# ant_x_set, ant_y_set = ant_gen("circular", 16, 0.02)
# print(ant_x_set)
# print(ant_y_set)

def ant_array_beam_pattern(freq_hz = None, array_style = None, num_ant = None, ant_spacing_wavelength = None, angle_vec_degree = None, plot_in_polar = None, beamforming_vec_rad = None, pause_interval = None): 
    c = 299792458
    
    print(freq_hz, array_style, num_ant, ant_spacing_wavelength, angle_vec_degree, plot_in_polar, beamforming_vec_rad, pause_interval)

    if angle_vec_degree is None:
        angle_vec_degree = 360*np.arange(0, 1, 0.001)
    
    angle_vec_degree = np.array([angle_vec_degree]).T

    if freq_hz is None:
        freq_hz = 2450000000
    
    if array_style is None:
        array_style = 'linear'
    
    if num_ant is None:
        num_ant = 8
    
    if ant_spacing_wavelength is None:
        ant_spacing_wavelength = 0.5
    
    if beamforming_vec_rad is None:
        beamforming_vec_rad = np.zeros((1, num_ant))
    
    wavelength = c / freq_hz
    if array_style.lower() != 'customized':
        ant_spacing_m = ant_spacing_wavelength * wavelength
    else:
        ant_spacing_m = ant_spacing_wavelength
    
    #Generate the antenna locations
    ant_x_set,ant_y_set = ant_gen(array_style, num_ant, ant_spacing_m)
    num_ant = len(ant_x_set)
    
    mat_size = beamforming_vec_rad.shape
    #extend it to matrix if it is not a matrix
    if len(mat_size) == 1:
        beamforming_vec_rad = np.array([beamforming_vec_rad])
        mat_size = beamforming_vec_rad.shape

    if beamforming_vec_rad.size != num_ant:
        print('The number of element in beamforming_vec_rad should be qual to the num_ant')
        return

    if mat_size[0] != num_ant:
        beamforming_vec_rad = beamforming_vec_rad.T
    
    beamforming_vec = np.exp(beamforming_vec_rad*1j)

    #Generate the angle and radius
    a = angle_vec_degree*np.pi/180
    r = 100000.0
    
    #Calculate x, y on the circle
    x = r*np.cos(a)
    y = r*np.sin(a)

    #Calculate the distance from the circle to each antenna
    num_sample = len(x)
    d = np.zeros((num_sample,num_ant))
    for i in np.arange(num_ant):
        ant_x = ant_x_set[i]
        ant_y = ant_y_set[i]
        tmp = np.sqrt((x - ant_x) ** 2 + (y - ant_y) ** 2)
        d[:,i] = tmp[:,0]
    
    #Calculate the rx signal
    signal_rx_at_direction_total = np.sqrt(1 / num_ant)*np.matmul(np.exp((d/wavelength)*2*np.pi*1j), beamforming_vec)
    gain_at_direction_total = np.abs(signal_rx_at_direction_total) ** 2
    
    #Plot
    fig = plt.figure(0)
    fig.clf()

    max_gain = np.amax(gain_at_direction_total)
    if plot_in_polar is True or plot_in_polar is None:
        if np.abs(np.ceil(max_gain) - max_gain) < 0.1:
            max_r = np.ceil(max_gain) + 1
        else:
            max_r = np.ceil(max_gain)
        
        ax = fig.add_subplot(projection='polar')
        ax.plot(a, gain_at_direction_total)
    else:
        x, y = pol2cart(gain_at_direction_total, a)

        ax = fig.add_subplot()
        ax.plot(x, y)
    
    if array_style.lower() == 'linear':
        scale_target_for_ant_plot = (max_gain / 4) / (ant_spacing_m * num_ant / 2)
    elif array_style.lower() == 'customized':
        fake_ant_spacing_m = np.amax([np.amax(ant_x_set) - np.amin(ant_x_set), np.amax(ant_y_set) - np.amin(ant_y_set)]) / 2
        scale_target_for_ant_plot = (max_gain / 4) / fake_ant_spacing_m
    else:
        scale_target_for_ant_plot = (max_gain / 4) / ant_spacing_m
    
    ant_x = ant_x_set*scale_target_for_ant_plot
    ant_y = ant_y_set*scale_target_for_ant_plot

    if plot_in_polar is True or plot_in_polar is None:
        ant_theta,ant_rho = cart2pol(ant_x,ant_y)
        ax.plot(ant_theta, ant_rho, 'ro')
        ax.set_rmax(max_r)
        ax.set_rticks(np.arange(0, max_r+1, 1))
    else:
        ax.plot(ant_x, ant_y, 'ro')
        
    ax.grid(True)

    if pause_interval is not None:
        fig.show()
        plt.pause(pause_interval)
    else:
        plt.show()

    return d, wavelength

# ant_array_beam_pattern(freq_hz=2450e6, array_style='linear', num_ant=3, ant_spacing_wavelength=0.5)
# ant_array_beam_pattern(freq_hz=2450e6, array_style='customized', num_ant=3, ant_spacing_wavelength=np.array([[0.1, 0.2], [-0.3, 0.4], [-0.5, -0.6]]))
# ant_array_beam_pattern(freq_hz=428.6e12, array_style='linear', num_ant=2, ant_spacing_wavelength=714, angle_vec_degree=np.arange(-1, 1, 0.0001), plot_in_polar=False, beamforming_vec_rad=np.array([0, np.pi]))
# ant_array_beam_pattern(freq_hz=2450e6, array_style='linear', num_ant=1, ant_spacing_wavelength=0.5)
# ant_array_beam_pattern(freq_hz=2450e6, array_style='linear', num_ant=2, ant_spacing_wavelength=0.5)
# ant_array_beam_pattern(2450000000, 'circular', 4, 0.5) 
# ant_array_beam_pattern(480e12, 'linear', 2, 700, np.arange(-1, 1, 0.00001))
# ant_array_beam_pattern(2450e6, 'linear', 2, 0.5)
# ant_array_beam_pattern(428.6e12, 'linear', 2, 714, np.arange(-1, 1, 0.0001))
# ant_array_beam_pattern(428.6e12, 'linear', 2, 714, np.array([np.arange(-1, 1, 0.0001)]))
# ant_array_beam_pattern(428.6e12, 'linear', 2, 714, np.array([np.arange(-1, 1, 0.0001)]), np.array([0, np.pi]))
# ant_array_beam_pattern()
# ant_array_beam_pattern(428.6e12, 'linear', 2, 714, np.array([np.arange(-1, 1, 0.0001)]), np.array([0,0]))

