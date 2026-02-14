ls -Al
cd ~/work/openwrt-ci/openwrt-ci/openwrt
make menuconfig

tmux attach
kill_cpolar
enter_menuconfig
rm /tmp/keep-term
nano /home/runner/work/openwrt-ci/openwrt-ci/openwrt/custom_release_notes.txt
tail -F build-log.log
