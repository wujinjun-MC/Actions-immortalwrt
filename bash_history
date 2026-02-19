ls -Al
cd ~/work/Actions-immortalwrt/Actions-immortalwrt/openwrt
make menuconfig

#make clean ; time pipetty make -j$(( $(nproc) + 1 )) V=w 2>&1 | tee -a "./build-log-color.log" 2>&1
touch /tmp/make-force-success

tmux attach
kill_cpolar
enter_menuconfig
rm /tmp/keep-term
nano /home/runner/work/Actions-immortalwrt/Actions-immortalwrt/openwrt/custom_release_notes.txt
tail -F build-log-color.log
