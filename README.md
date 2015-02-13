# stealth-sound
Interfaces digital microphones with the BeagleBone Black.

This project provides the device-tree overlay, assembly, 
and C source code to interface the BeagleBone Black with 
up to 16 INMP441 digital microphones.



The starting point for this project was taken from the work
posted by user "shabaz" here:
http://www.element14.com/community/community/designcenter/single-board-computers/next-gen_beaglebone/blog/2013/08/04/bbb--high-speed-data-acquisition-and-web-based-ui


The device-tree overlay can be compiled like so using the device tree compiler:
$ dtc -@ -O dtb -o BBB-DMIC-INMP441-00A0.dtbo BBB-DMIC-INMP441-00A0.dts

The "-@" symbol tells the device-tree compiler that this will be an
overlay.  If you do not use it, then you will get errors like this:
ERROR (phandle_references): Reference to non-existent node or label "am33xx_pinmux"
ERROR (phandle_references): Reference to non-existent node or label "ocp"
ERROR (phandle_references): Reference to non-existent node or label "pruss"

The device-tree overlay should then be installed in /lib/firmware like so:
$ cp BBB-DMIC-INMP441-OOA0.dtbo /lib/firmware/

The device tree module can then be loaded manually:
SLOTS=/sys/devices/bone_capemgr.*/slots
echo BBB-DMIC-INMP441 > $SLOTS

After you successfully load the device-tree overlay, if you look at
the contents of SLOTS you will see something like this:
$ cat $SLOTS
 0: 54:PF--- 
 1: 55:PF--- 
 2: 56:PF--- 
 3: 57:PF--- 
 4: ff:P-O-L Bone-LT-eMMC-2G,00A0,Texas Instrument,BB-BONE-EMMC-2G
 5: ff:P-O-- Bone-Black-HDMI,00A0,Texas Instrument,BB-BONELT-HDMI
 6: ff:P-O-- Bone-Black-HDMIN,00A0,Texas Instrument,BB-BONELT-HDMIN
 7: ff:P-O-L Override Board Name,00A0,Override Manuf,BBB-DMIC-INMP441

If you get an error it is probably because you have not disabled
the HDMI interface. Your error might look like this:
-sh: echo: write error: File exists

Our overlay is requesting "exclusive-use" of pins
that are already assigned to the HDMI interface.
There are several ways to disable the HDMI interface:
1. When the BeagleBone Black is connected to a computer via USB it
will look like a USB storage device.
On my computer, it mounts at /media/BEAGLEBONE
If you browse inside in your favorite file explorer you will 
see a file: /media/BEAGLEBONE/uEnv.txt
Open this file and add the following line:
optargs=quiet capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN

In later revisions this line is already in the file and commented
out, so you simply need to uncomment it.
Reboot after making the change.

2. Load a device tree overlay that disables the HDMI interface.

3. Decompile your device tree /boot/am335x-boneblack.dtb into
a .dts file. Disable the HDMI interface and recompile into .dtb













