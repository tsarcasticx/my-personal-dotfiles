#!/bin/sh

########################################################################################
# Readme please
# Awalnya aku cuma pengen bikin menu power
# Tapi opsi reboot sama logout malah tidak muncul
# niatnya kalo aku klik salah satu tombol yang muncul, tau lah if statement nya gimana
########################################################################################

shutdown="         Shutdown"
reboot="         Reboot"
logout="󰗽         Logout from BSPWM"

# classshut=$(cat << EOF
# $shutdown
# shutdown
# EOF
# )
# classreboot=$(cat << EOF
# $reboot
# reboot
# EOF
# )
# classlogout=$(cat << EOF
# $logout
# logout
# EOF
# )

# | rofi -dmenu -config $HOME/.config/rofi/powermenu.rasi

pilihan=$(cat << EOF | rofi -dmenu -config $HOME/.config/rofi/powermenu.rasi
$shutdown
$reboot
$logout
EOF
)

if [[ $pilihan == $shutdown ]]; then
  systemctl poweroff
elif [[ $pilihan == $reboot ]]; then
  systemctl reboot
elif [[ $pilihan == $logout ]]; then
  bspc quit
fi
