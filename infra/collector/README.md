sudo apt install -y git cmake build-essential libtool libusb-1.0-0-dev librtlsdr-dev rtl-sdr doxygen

sudo apt install -y supervisor
sudo vim /etc/supervisor/conf.d/rtl_433.conf

clone the rtl_433 

```bash
git clone https://github.com/merbanan/rtl_433.git
cd rtl_433
mkdir build
cd build
cmake ..
make
sudo make install
```

test

```bash
cat <<EOF>> /etc/supervisor/conf.d/rtl_433.conf
[program:rtl_433]
command=rtl_433 -F "mqtt://mqtt.dcasati.net:1883,retain=0,events=sensors"
autostart=true
autorestart=true
stderr_logfile=/var/log/rtl_433.err.log
stdout_logfile=/var/log/rtl_433.out.log
EOF
```

systemctl restart supervisor
systemctl status supervisor


### Installing SDRConnect on a Raspberry Pi3 (ARM 64)


```bash
wget https://www.sdrplay.com/software/SDRconnect_linux-arm64_83273bcd8.run
bash ./SDRconnect_linux-arm64_83273bcd8.run
```



