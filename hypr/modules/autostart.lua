require("modules.vars")

hl.on("hyprland.start", function ()
   hl.exec_cmd("hyprsunset -t 5300") 
   hl.exec_cmd("nm-applet")
   -- hl.exec_cmd("waybar")
   -- hl.exec_cmd("swaync")
   hl.exec_cmd("qs -c ~/.config/quickshell/caelestia")
   -- hl.exec_cmd("hyprpaper")
   hl.exec_cmd(terminal)
   hl.exec_cmd(run_vpn)
   hl.exec_cmd(run_browser)
   hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
   hl.exec_cmd("sudo mount /dev/nvme0n1p2 /mnt/ubuntu")
end)


