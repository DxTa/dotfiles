#!/bin/bash
$GLOBALAUTOSTART
# xfce4-power-manager &
# (sleep 1 && indicator-cpufreq) &
(sleep 1 && xmodmap -e 'keycode 66 = Escape') &
(sleep 1 && xmodmap -e 'clear Lock') &
# tint2;
# synapse
(sleep 1 && nitrogen --restore) &
