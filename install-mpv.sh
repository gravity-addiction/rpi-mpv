#!/bin/bash
#wget --no-check-certificate -q 'https://raw.githubusercontent.com/gravity-addiction/rpi-mpv/master/install-mpv.sh' -O - | bash

echo "------------------------------"
echo "Big thanks to RPI_Mike on https://www.raspberrypi.org/forums/viewtopic.php?f=38&t=199775 for putting most of this script together"
echo "If you're out there Mike look forward to your further input on this script"
echo; echo
echo "Determine which Raspberry Pi Version we're working with." | fold -s
RPI3A="Raspberry Pi 3 Model A Plus"
RPI3B="Raspberry Pi 3 Model B Plus"
RPI4B="Raspberry Pi 4 Model B"
RPIVERSION=$(cat /proc/device-tree/model | tr '\0' '\n')

if [[ $RPIVERSION =~ $RPI3A.* || $RPIVERSION =~ $RPI3B.* ]]; then
  echo "RPI3 - $RPIVERSION" | fold -s
elif [[ $RPIVERSION =~ $RPI4B* ]]; then
  echo "RPI4 - $RPIVERSION" | fold -s
else
  echo "Unknown - $RPIVERSION" | fold -s
  exit
fi


echo; echo
cd ~

echo "------------------------------"
echo "Cleaning and Creating Vidware folders; /home/pi/Vidware_Downloads,  /home/pi/Vidware_Build folders." | fold -s
echo "------------------------------"
echo
##### Remove Old File Cache
sudo rm -rf /home/pi/Vidware_*

##### Vidware_Downloads: My script philosophy is to keep things clean and simple. That's why my first step is to create 3 different folders to keep the main elements of my script completely separate from each other. Before anything can be built, we first have to download 6 files in the form of "stable release tarballs". This is the raw source code my script will use to build the 6 programs. We also need 4 GPU-related files from the Raspberry Pi Foundation's official GitHub site that provide OpenGL ES and EGL support (they allow mpv to "talk" to the Raspberry's VideoCore GPU and thus facilitate hardware acceleration). Finally, we need a "waf" file that will allow us to build mpv. All of this will go inside the "Vidware_Downloads" folder – which we're creating with the mkdir command:
mkdir /home/pi/Vidware_Downloads

##### Vidware_Build: This is the folder where all our "building" will take place – the folder where the raw source code of 6 programs will be compiled and transformed into working software. The "primary" programs are FFmpeg and mpv. But my script also builds a mandatory library called libass – a subtitle renderer that mpv requires. It also builds an advanced H.264 video encoder (x264) and two advanced audio encoders (Fraunhofer AAC and LAME MP3):
mkdir /home/pi/Vidware_Build

##### I've discovered an odd quirk about checkinstall: If we don't manually create a standard usr doc path before running it, checkinstall will fail to install some of our programs. This affects the LAME MP3 encoder – but not having the path up to "doc" also affects FFmpeg (even if you don't build or install LAME). This command line takes care of that:
sudo mkdir -p /usr/share/doc/lame


##### You'll see a lot of "echo" commands in my script. Why? Because I like VISUAL SEPARATION. A simple echo command inserts a blank line in Terminal's output:
echo; echo

##### The echo command is also the tool I'm using to "print" information on the Terminal screen – such as letting the user know that we're about to download the tarballs. I also "pipe" the output of echo through the "fold" command with the "-s" option. This ensures my longer sentences are properly "word wrapped" and that my words aren't abruptly cut in half when they hit the edge of your Terminal screen:
echo "------------------------------"
echo "Now downloading the source code tarballs and other essential files for building FFmpeg, mpv, the 3 advanced encoders, extra libraries and patches." | fold -s
echo "------------------------------"
echo

##### We're about to download all the files that the script needs. It may look like a lot, but the grand total is less than 18 MB! This is quite impressive when you consider that FFmpeg alone contains more than one MILLION lines of source code! Before we do the downloads, however, we need to change our current working directory to the Vidware_Downloads folder with the cd command:
cd /home/pi/Vidware_Downloads


##### This is where my script downloads the 11 files it needs. At the time of this writing – August 2018 – all URLs link to the most recent versions available. Be careful if you think you can simply update these links to get even more recent versions in the future! Other parts of my script make specific assumptions about these particular versions. So unless you fully understand all aspects of my script, you definitely don't want to do that!
wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1lWA1-O6wwzczc33-mBQcTP0XiwQzPiuG' -O ffmpeg-4.0.2.tar.bz2
#wget -nc -q --show-progress --no-use-server-timestamps https://ffmpeg.org/releases/ffmpeg-4.0.2.tar.bz2

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1i_nc7YYBGUNyIN10O4UsquuLUnKppLxQ' -O v0.29.0.tar.gz
#wget -nc -q --show-progress --no-use-server-timestamps https://github.com/mpv-player/mpv/archive/v0.29.0.tar.gz

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1a95tlnRe3kvmTQb2JrOYHVNS-kXYZiPW' -O libass-0.14.0.tar.gz
#wget -nc -q --show-progress --no-use-server-timestamps https://github.com/libass/libass/releases/download/0.14.0/libass-0.14.0.tar.gz

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1e6JIy5fXMYKcPq7L51M6_BcSvVxrSEC9' -O x264-snapshot-20180831-2245-stable.tar.bz2
#wget -nc -q --show-progress --no-use-server-timestamps https://download.videolan.org/x264/snapshots/x264-snapshot-20180831-2245-stable.tar.bz2

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=18bgesyGLCIXmnHe1iM110rL7vXxcmDvY' -O fdk-aac-0.1.6.tar.gz
#wget -nc -q --show-progress --no-use-server-timestamps https://downloads.sourceforge.net/opencore-amr/fdk-aac-0.1.6.tar.gz

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=14ZSxMXiZ1SegB1LuOHCawOB4u8RLzyHW' -O lame-3.100.tar.gz
#wget -nc -q --show-progress --no-use-server-timestamps https://downloads.sourceforge.net/lame/lame-3.100.tar.gz

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1_xLBDmDSTwjv1yvBkKnueaI3YpiRDkV6' -O waf-2.0.9
#wget -nc -q --show-progress --no-use-server-timestamps https://waf.io/waf-2.0.9


wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1Vrv-9b6NaKd1DI4MX8hae38hT_Qoaw_5' -O libGLESv2.so
#wget -nc -q --show-progress --no-use-server-timestamps https://github.com/raspberrypi/firmware/raw/master/hardfp/opt/vc/lib/libGLESv2.so

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=11b8ecLf_7VBOq6qf6R38lcGy7cEP_B9p' -O libEGL.so
#wget -nc -q --show-progress --no-use-server-timestamps https://github.com/raspberrypi/firmware/raw/master/hardfp/opt/vc/lib/libEGL.so

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1svQU1sml_QffrEHoghkRDxO2S03s4WHF' -O brcmglesv2.pc
#wget -nc -q --show-progress --no-use-server-timestamps https://github.com/raspberrypi/firmware/raw/master/hardfp/opt/vc/lib/pkgconfig/brcmglesv2.pc

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1D_XqqCzZIeu74u0269FRjniFzPAysD_j' -O brcmegl.pc
#wget -nc -q --show-progress --no-use-server-timestamps https://github.com/raspberrypi/firmware/raw/master/hardfp/opt/vc/lib/pkgconfig/brcmegl.pc

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1teZuSbE7kR0S8wDa3IezfsmPtq2XkCsH' -O 0001-6838-Fix-rpi-compile-issues.patch.txt
#wget -nc -q --show-progress https://github.com/mpv-player/mpv/files/3458510/0001-6838-Fix-rpi-compile-issues.patch.txt

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1XHbgEyi475lmIcs_BEzOMZNggDV3qfZz' -O alsa_patch.diff

wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1I8jTErzkWCTLtNX84RE7nhflAc-dNSwZ' -O wscript_patch.diff

# Update Wiring Pi to RPI4 Version
if [[ $RPIVERSION =~ $RPI4B* ]]; then
  wget -nc --no-check-certificate -q --show-progress 'https://docs.google.com/uc?export=download&id=1D3cfPtfy1ZMPBJNbcJM8TVA7bM7iMPtN' -O wiringpi-latest.deb
  #wget -nc -q --show-progress https://project-downloads.drogon.net/wiringpi-latest.deb
  sudo dpkg -i wiringpi-latest.deb
fi

echo; echo
echo "------------------------------"
echo "Coping System Files, Requires sudo" | fold -s
echo
##### For backup purposes – and for mental clarity – I deliberately decided not to "wget" the files directly into their ultimate destinations. Instead, I wanted all the downloads to first be consolidated into the Vidware_Downloads folder – and then copy them over, later on, into wherever they need to be. So that's what I'm doing here. Sudo is required, by the way, because the opt parent folder (and its children) are owned by user "root", not "pi". If we didn't add the "sudo", we would get a "permission denied" error:
sudo cp libGLESv2.so /opt/vc/lib
sudo cp libEGL.so /opt/vc/lib

sudo cp /opt/vc/lib/pkgconfig/brcmglesv2.pc /opt/vc/lib/pkgconfig/brcmglesv2_pc_backup
sudo cp brcmglesv2.pc /opt/vc/lib/pkgconfig

sudo cp /opt/vc/lib/pkgconfig/brcmegl.pc /opt/vc/lib/pkgconfig/brcmegl_pc_backup
sudo cp brcmegl.pc /opt/vc/lib/pkgconfig


echo "Coping Tarballs to Build Folder" | fold -s
echo
##### This makes an exact copy of our 6 source code tarballs (for FFmpeg, mpv, etc.) and places them inside the Vidware_Build folder. Some of the tarballs end in tar.gz, while others end in tar.bz2 – hence the 2 separate lines:
cp *.gz /home/pi/Vidware_Build
cp *.bz2 /home/pi/Vidware_Build
cp waf-2.0.9 /home/pi/Vidware_Build

echo "Extracting Tarballs In Build Folder" | fold -s
echo
##### We're pretty much all done with the Vidware_Downloads folder at this point – so we now need to make sure the script is performing its actions inside the Vidware_Build folder. That's why we cd into it. We then need to "unzip" the 6 source code tarballs into folders – that's what the 2 "ls" lines with the xargs command does (for technical reasons, you can't use a simple asterisk wildcard to unzip multiple tarballs in the same folder). Finally, I delete all the tarballs in the build folder with the rm command. Why? Because we already have the original copy of them in our Vidware_Downloads folder – so there's no reason to clutter things up with duplicate tarballs!
cd /home/pi/Vidware_Build
ls *.gz | xargs -n1 tar xzf
ls *.bz2 | xargs -n1 tar jxf
rm *.gz
rm *.bz2


echo "Fixing Library Filenames" | fold -s
echo
##### I don't want to keep seeing "fdk-aac-0.1.6" as the source code folder name, for example. That's just confusing. Instead, I just want to see "aac" – because that's what it really is. It's the AAC audio encoder! That's why I'm simplifying all the source code folder names by renaming them with the mv command:
mv ffmpeg* ffmpeg
mv mpv* mpv
mv x264* x264
mv fdk* aac
mv lame* mp3
mv libass* libass
##### The script downloaded version 2.0.9 of waf (the version that mpv 0.32.0 expects). But mpv also expects the file to simply be named "waf", not "waf-2.0.9". That's why I'm renaming it here with the mv command. Finally, since waf is a Python script that needs to be executed in order to build mpv, I'm using the chmod command to make it executable by the user that owns the file (which in this case is the user named pi):
mv waf* mpv/waf
chmod u+x mpv/waf


echo "Patching Libraries" | fold -s
echo "------------------------------"
cd /home/pi/Vidware_Build/mpv
patch -p1 -r - -i /home/pi/Vidware_Downloads/0001-6838-Fix-rpi-compile-issues.patch.txt

##### In this section, I'm using the sed command to manipulate mpv's raw source code before we build it.
##### The first edit specifically targets line 767 of mpv's wscript file. The wscript file contains
##### the "building instructions" for mpv. There are more than 1,100 lines of code in the file,
##### but only 18 of them are directly related to the Raspberry. The line I'm editing makes reference
##### to a generic OpenGL ES "linkflag". With the sed command, I'm doing a "search & replace" so that
##### it will now make reference to the Broadcom-specific version of the linkflag (Broadcom is the
##### manufacturer of the Raspberry's VideoCore GPU). Beginning with the next line, I delete an entire
##### stanza (13 lines) of audio-related source code and then replace it with 20 lines of modified and
##### expanded code. Specifically, it affects how mpv interacts with the ALSA framework. Without this
##### change, mpv would throw various audio-related "[ao/alsa]" errors. Hat tip: My ALSA source code
##### patch combines the ideas of mpv contributor "orbea" and user "yumkam" on mpv's official GitHub
##### site. And then we have the final sed line – it serves absolutely no purpose other than to give
##### -- Updated to Patches
patch -p1 -r - -i /home/pi/Vidware_Downloads/wscript_patch.diff
patch -p1 -r - -i /home/pi/Vidware_Downloads/alsa_patch.diff



##### This is where we install the dependencies we need to build all 6 pieces of software – via "sudo apt-get install". Read my statement in the echo line for more detail:
echo; echo
echo "------------------------------"
echo "Now downloading and installing the dependencies – essential packages from the official Raspbian repository that are needed to build the programs. At a connection speed of 1 MB per second, it will take less than 50 seconds to download. It will then take about 5 minutes for your system to install all the packages." | fold -s
echo "------------------------------"
echo

sudo apt update
sudo apt install -y automake checkinstall libmpv1 libmpv-dev libsdl2-dev libva-dev libluajit-5.1-dev libgles2-mesa-dev libtool libvdpau-dev libxcb-shm0-dev texinfo libfontconfig1-dev libfribidi-dev python-docutils libbluray-dev libjpeg-dev libtheora-dev libvorbis-dev libgnutls28-dev linux-headers-rpi2 libomxil-bellagio-dev xdotool libcdio-cdda-dev libcdio-paranoia-dev libdvdread-dev libdvdnav-dev libbluray-dev



##### This begins the "software building" phase of my script.
##### We're configuring and compiling the source code for our first program –
##### the advanced x264 video encoder. That's what people mean by "building" a program.
##### In the "./configure" line, we're enabling and disabling various options that will
##### customize the build in the manner necessary for everything to work.
##### We then compile the program with the "make -j4" command –
##### which is quite impressive given that the "j4" means that all 4 cores inside the Raspberry's
##### CPU will be computing simultaneously! For more information on how to use the
##### encoders with FFmpeg, please see my extremely detailed appendices. After the x264
##### encoder is fully built, I use the checkinstall command to both install the program
##### and "package it up" into the extremely useful .deb installer packages I mentioned
##### earlier. The final line – sudo ldconfig – is essential in making sure the
##### "shared libraries" are properly recognized.
echo; echo
echo "------------------------------"
echo "Now building the x264 video encoder. This will take about 2 to 3 minutes." | fold -s
echo "------------------------------"
echo

cd /home/pi/Vidware_Build/x264
if [[ $RPIVERSION =~ $RPI3A.* || $RPIVERSION =~ $RPI3B.* ]]; then
  ./configure --prefix=/usr --enable-shared --disable-opencl --extra-cflags="-march=armv8-a+crc -mfpu=neon-fp-armv8 -mtune=cortex-a53"
elif [[ $RPIVERSION =~ $RPI4B.* ]]; then
  ./configure --prefix=/usr --enable-shared --disable-opencl --extra-cflags="-mcpu=cortex-a72 -mtune=cortex-a72 -mfpu=neon-fp-armv8"
fi


make -j4
sudo checkinstall -y --pkgname x264 --pkgversion 0.155 make install
sudo ldconfig



echo; echo; echo
echo "------------------------------"
echo "Now building the Fraunhofer AAC audio encoder. This will take about 3 to 4 minutes." | fold -s
echo "------------------------------"
echo

cd /home/pi/Vidware_Build/aac
./autogen.sh
./configure --prefix=/usr --enable-shared
make -j4
sudo checkinstall -y --pkgname fdk-aac --pkgversion 0.1.6 make install
sudo ldconfig



echo; echo; echo
echo "------------------------------"
echo "Now building the LAME MP3 audio encoder. This will take about 1 minute." | fold -s
echo "------------------------------"
echo

cd /home/pi/Vidware_Build/mp3
./configure --prefix=/usr --enable-shared
make -j4
sudo checkinstall -y --pkgname mp3lame --pkgversion 3.100 make install
sudo ldconfig



echo; echo; echo
echo "------------------------------"
echo "Now building the libass subtitle renderer. This will take about 1 minute." | fold -s
echo "------------------------------"
echo

cd /home/pi/Vidware_Build/libass
./configure --prefix=/usr --enable-shared
make -j4
sudo checkinstall -y --pkgname libass --pkgversion 0.14.0 make install
sudo ldconfig






##### Now we build and install FFmpeg! This is the very powerful media "engine" at
##### the center of everything we're doing. The last 3 "--enable" lines under
##### "./configure" enable FFmpeg to access the 3 advanced encoders – x264,
##### Fraunhofer AAC, and LAME MP3. Compiling a million+ lines of code is INTENSE
##### and could easily overheat your CPU. Your Raspberry must therefore have its
##### own small fan or an external fan blowing on it. Please see the explicit
##### warnings on this subject in my instructions!

echo; echo; echo
echo "------------------------------"
echo "Now preparing to build FFmpeg. This will take about 2 minutes." | fold -s
echo "------------------------------"
echo

cd /home/pi/Vidware_Build/ffmpeg

if [[ $RPIVERSION =~ $RPI3A.* || $RPIVERSION =~ $RPI3B.* ]]; then

./configure \
--prefix=/usr \
--enable-gpl \
--enable-nonfree \
--enable-static \
--enable-libtheora \
--enable-libvorbis \
--enable-omx \
--enable-omx-rpi \
--enable-mmal \
--enable-libxcb \
--enable-libfreetype \
--enable-libass \
--enable-gnutls \
--disable-opencl \
--enable-libcdio \
--enable-libbluray \
--extra-cflags="-march=armv8-a+crc -mfpu=neon-fp-armv8 -mtune=cortex-a53" \
--enable-libx264 \
--enable-libfdk-aac \
--enable-libmp3lame

elif [[ $RPIVERSION =~ $RPI4B.* ]]; then

./configure \
--prefix=/usr \
--enable-gpl \
--enable-nonfree \
--enable-static \
--enable-libtheora \
--enable-libvorbis \
--enable-omx \
--enable-omx-rpi \
--enable-mmal \
--enable-libxcb \
--enable-libfreetype \
--enable-libass \
--enable-gnutls \
--disable-opencl \
--enable-libcdio \
--enable-libbluray \
--extra-cflags="-march=armv8-a+crc+simd -mfpu=neon-fp-armv8 -mtune=cortex-a72" \
--enable-libx264 \
--enable-libfdk-aac \
--enable-libmp3lame

fi

echo; echo; echo
echo "------------------------------"
echo "Now building FFmpeg. This will take about 24 minutes on the Raspberry 3B+ (and 2 or 3 minutes longer on the 3B)." | fold -s
echo "------------------------------"
echo

make -j4

echo; echo; echo
echo "------------------------------"
echo "Now installing FFmpeg. This will take about 7 minutes." | fold -s
echo "------------------------------"
echo

sudo checkinstall -y --pkgname ffmpeg --pkgversion 4.0.2 make install
sudo ldconfig



##### Now we build and install mpv. Unlike the prior builds which were fairly straightforward,
##### I'll add a few extra comments here – because I had to do quite a bit of arcane tweaking
##### to successfully "port" mpv to the Raspberry platform with full GPU-based hardware acceleration.

echo; echo; echo
echo "------------------------------"
echo "Now preparing to build mpv. This will take about 1 minute." | fold -s
echo "------------------------------"
echo

cd /home/pi/Vidware_Build/mpv


export LIBRARY_PATH=/opt/vc/lib
export PKG_CONFIG_PATH=/opt/vc/lib/pkgconfig
export CPATH=/opt/vc/include

./waf configure --prefix=/usr --enable-rpi --enable-cdda --enable-dvdnav --enable-libbluray


echo; echo; echo
echo "------------------------------"
echo "Now building mpv. This will take about 2 minutes." | fold -s
echo "------------------------------"
echo

./waf build -j4

echo; echo; echo
echo "------------------------------"
echo "Now installing mpv. This will take about 1 minute." | fold -s
echo "------------------------------"
echo

sudo checkinstall -y --pkgname mpv --pkgversion 0.29.0 ./waf install
sudo ldconfig




echo; echo; echo
echo "------------------------------"
echo "Setting default MPV Config options and Assigning default video associates to MPV" | fold -s
echo "------------------------------"
echo

##### This section "pins" the advanced versions of the programs my script just built. Without doing this, anytime you run a standard system update via "sudo apt-get upgrade" or "sudo apt-get dist-upgrade", the Raspbian package manager might wrongly think the newly-built programs are old and therefore need to be "upgraded". They might then be overwritten with the older, more primitive versions that exist in the Raspbian repository! Pinning them, in effect, says to your system's packager manager: "Don't touch these programs – leave them alone!" As per standard etiquette, I first back up your preferences file – on the remote chance you've been pinning other packages. Hat tip to "rpdom" for his pinning suggestion.
sudo cp /etc/apt/preferences /etc/apt/preferences_BACKUP &> /dev/null

echo "Package: ffmpeg
Pin: version 4.0.2-1
Pin-Priority: 1001

Package: mpv
Pin: version 0.29.0-1
Pin-Priority: 1001

Package: x264
Pin: version 0.155-1
Pin-Priority: 1001

Package: fdk-aac
Pin: version 0.1.6-1
Pin-Priority: 1001

Package: mp3lame
Pin: version 3.100-1
Pin-Priority: 1001

Package: libass
Pin: version 0.14.0-1
Pin-Priority: 1001" | sudo cp /dev/stdin /etc/apt/preferences

sudo chmod 644 /etc/apt/preferences





##### This is where we create mpv's configuration file that controls how mpv behaves with ALL video and audio. Please see the full version of Appendix 1 for details; also see the testing section for commentary on the "ytdl-format" line. NOTE: The "alsa-buffer-time" completes the fix to the ALSA issue I described earlier. It defines an audio buffer time of 800,000 microseconds (8/10 of a second). Through extensive testing, I found that this was the final step needed to get mpv and ALSA to play nice together.
mkdir -p /home/pi/.config/mpv
echo "--fullscreen
rpi-background=yes
screenshot-format=png
ytdl-format=bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio/best
--alsa-buffer-time=800000" > /home/pi/.config/mpv/mpv.conf



##### I didn't want users of my script to have to go through the 10-step "Open With" process in File Manager – over and over again – to associate every common type of video and audio file with mpv. So to save everyone a lot of time and eliminate this error-prone task, my script does it automatically! The first line demonstrates proper "etiquette" – before it creates the new associations, it first backs up your original mimeapps.list file (just in case you'd like to review or re-add your initial file associations). I then associate the following video and audio file types with mpv: MP4, WebM, MKV, TS, MOV, AVI, WMV, MPG, WAV, MP3, M4A, and FLAC.
cp /home/pi/.config/mimeapps.list /home/pi/.config/mimeapps.list_BACKUP &> /dev/null

echo "[Added Associations]
video/mp4=mpv.desktop;
video/webm=mpv.desktop;
video/x-matroska=mpv.desktop;
video/mp2t=mpv.desktop;
video/quicktime=mpv.desktop;
video/x-msvideo=mpv.desktop;
video/x-ms-wmv=mpv.desktop;
video/mpeg=mpv.desktop;
audio/x-wav=mpv.desktop;
audio/mpeg=mpv.desktop;
audio/mp4=mpv.desktop;
audio/flac=mpv.desktop;
text/plain=leafpad.desktop;

[Default Applications]
video/mp4=mpv.desktop
video/webm=mpv.desktop
video/x-matroska=mpv.desktop
video/mp2t=mpv.desktop
video/quicktime=mpv.desktop
video/x-msvideo=mpv.desktop
video/x-ms-wmv=mpv.desktop
video/mpeg=mpv.desktop
audio/x-wav=mpv.desktop
audio/mpeg=mpv.desktop
audio/mp4=mpv.desktop
audio/flac=mpv.desktop
text/plain=leafpad.desktop

[Removed Associations]" > /home/pi/.config/mimeapps.list



##### Raspbian places its overall file association "system" in 2 separate locations. The items above act as a kind of pointer to the item below. The two work hand-in-hand. The following stanza generates a special kind of file known as a "desktop" file that ends with the ".desktop" extension – but also has an "alias" (in this case, "MPV") and an executable line that tells it what to do. My complicated use of bash -c and xdotool is the result of hours of testing – to guarantee that you never lose keyboard control of mpv, due to other windows stealing "focus" from mpv's Terminal window. You see, mpv relies upon an active Terminal window "behind the screen" to detect the keyboard inputs which allow you to control the video or audio being played. Of course, if you actively do things to lose keyboard control – like hitting alt + tab or randomly clicking the screen with your mouse – there's nothing I can do about that!
echo "[Desktop Entry]
Type=Application
Name=MPV
Exec=lxterminal -t mpv_control -e bash -c \"sleep 0.25; xdotool search --name mpv_control windowactivate; mpv %f\"
NoDisplay=true
Icon=mpv" > /home/pi/.local/share/applications/mpv.desktop
