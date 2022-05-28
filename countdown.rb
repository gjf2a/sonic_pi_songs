run_file "~/Documents/sonic_pi_songs/my_funcs.rb"
countdown = [[66, 0.42, 1.0], [66, 0.55, 0.0], [73, 0.17, 1.0], [73, 0.01, 0.0],
             [71, 0.13, 0.77], [71, 0.0, 0.0], [73, 0.45, 0.41], [73, 0.13, 0.0],
             [66, 0.85, 0.8], [66, 0.32, 0.0], [74, 0.16, 1.0], [74, 0.0, 0.0],
             [74, 0.37, 0.87], [74, 0.03, 0.0], [73, 0.2, 1.0], [73, 0.03, 0.0],
             [71, 0.03, 0.06], [71, 0.04, 0.0], [71, 0.93, 1.0], [71, 0.27, 0.0],
             [74, 0.16, 1.0], [74, 0.03, 0.0], [73, 0.13, 1.0], [73, 0.03, 0.0],
             [74, 0.45, 1.0], [74, 0.12, 0.0], [66, 0.58, 0.8], [66, 0.5, 0.0],
             [71, 0.15, 0.75], [71, 0.02, 0.0], [71, 0.13, 0.81], [71, 0.03, 0.0],
             [71, 0.21, 1.0], [71, 0.08, 0.0], [69, 0.24, 0.94], [69, 0.08, 0.0],
             [68, 0.22, 0.65], [68, 0.07, 0.0], [71, 0.24, 1.0], [71, 0.06, 0.0],
             [69, 0.68, 1.0], [69, 0.15, 0.0], [73, 0.16, 1.0], [73, 0.03, 0.0],
             [71, 0.14, 0.91], [71, 0.03, 0.0], [73, 0.29, 1.0], [73, 0.22, 0.0],
             [66, 0.61, 0.64], [66, 0.45, 0.0], [74, 0.15, 0.87], [74, 0.04, 0.0],
             [74, 0.14, 0.83], [74, 0.02, 0.0], [74, 0.2, 1.0], [74, 0.13, 0.0],
             [73, 0.29, 0.96], [73, 0.0, 0.0], [72, 0.04, 0.49], [72, 0.03, 0.0],
             [71, 1.01, 1.0], [71, 0.41, 0.0], [74, 0.14, 0.94], [74, 0.04, 0.0],
             [73, 0.13, 0.8], [73, 0.03, 0.0], [74, 0.49, 1.0], [74, 0.12, 0.0],
             [66, 0.93, 0.54], [66, 0.19, 0.0], [71, 0.16, 0.81], [71, 0.02, 0.0],
             [71, 0.13, 0.79], [71, 0.03, 0.0], [71, 0.21, 0.87], [71, 0.11, 0.0],
             [69, 0.24, 0.86], [69, 0.08, 0.0], [68, 0.24, 0.67], [68, 0.07, 0.0],
             [71, 0.24, 1.0], [71, 0.11, 0.0], [69, 0.75, 0.86], [69, 0.05, 0.0],
             [68, 0.18, 0.71], [68, 0.02, 0.0], [69, 0.16, 0.89], [69, 0.04, 0.0],
             [71, 0.02, 0.99], [71, 0.0, 0.0], [83, 0.01, 1.0], [83, 0.0, 0.0],
             [71, 0.56, 0.98], [71, 0.16, 0.0], [69, 0.19, 1.0], [69, 0.04, 0.0],
             [71, 0.2, 1.0], [71, 0.05, 0.0], [73, 0.24, 1.0], [73, 0.0, 0.0],
             [72, 0.03, 0.62], [72, 0.07, 0.0], [71, 0.2, 0.91], [71, 0.03, 0.0],
             [69, 0.01, 0.06], [69, 0.06, 0.0], [69, 0.18, 0.73], [69, 0.11, 0.0],
             [68, 0.19, 0.46], [68, 0.18, 0.0], [66, 0.51, 0.76], [66, 0.17, 0.0],
             [74, 0.56, 1.0], [74, 0.01, 0.0], [73, 1.09, 0.79], [73, 0.07, 0.0],
             [75, 0.16, 0.9], [75, 0.03, 0.0], [73, 0.16, 0.84], [73, 0.03, 0.0],
             [71, 0.18, 0.57], [71, 0.03, 0.0], [73, 0.78, 0.64], [73, 0.06, 0.0],
             [73, 0.14, 0.91], [73, 0.04, 0.0], [73, 0.14, 0.87], [73, 0.04, 0.0],
             [73, 0.26, 0.81], [73, 0.1, 0.0], [71, 0.23, 0.91], [71, 0.07, 0.0],
             [69, 0.19, 0.98], [69, 0.1, 0.0], [68, 0.23, 0.59], [68, 0.15, 0.0],
             [66, 1.22, 0.68], [66, 2.0, 0.0]]


play_melody countdown, :additive_1

puts best_scale_for countdown