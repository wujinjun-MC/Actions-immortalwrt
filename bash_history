ls -Al
cd ~/work/Actions-immortalwrt/Actions-immortalwrt/openwrt
make menuconfig

tmux attach
kill_cpolar
enter_menuconfig
rm /tmp/keep-term
nano /home/runner/work/Actions-immortalwrt/Actions-immortalwrt/openwrt/custom_release_notes.txt
tail -F build-log.log
