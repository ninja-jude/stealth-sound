# stealth-sound
Interfaces digital microphones with the BeagleBone Black.

This project provides the device-tree overlay, assembly, 
and C source code to interface the BeagleBone Black with 
up to 16 INMP441 digital microphones.



The starting point for this project was taken from the work
posted by user "shabaz" here:<BR>
http://www.element14.com/community/community/designcenter/single-board-computers/next-gen_beaglebone/blog/2013/08/04/bbb--high-speed-data-acquisition-and-web-based-ui


The device-tree overlay can be compiled like so using the device tree compiler:<BR>
$ dtc -@ -O dtb -o BBB-DMIC-INMP441-00A0.dtbo BBB-DMIC-INMP441-00A0.dts

The "-@" symbol tells the device-tree compiler that this will be an
overlay.  If you do not use it, then you will get errors like this:<BR>
ERROR (phandle_references): Reference to non-existent node or label "am33xx_pinmux"<BR>
ERROR (phandle_references): Reference to non-existent node or label "ocp"<BR>
ERROR (phandle_references): Reference to non-existent node or label "pruss"<BR>

The device-tree overlay should then be installed in /lib/firmware like so:<BR>
$ cp BBB-DMIC-INMP441-OOA0.dtbo /lib/firmware/

The device tree module can then be loaded manually:<BR>
$ SLOTS=/sys/devices/bone_capemgr.*/slots<BR>
$ echo BBB-DMIC-INMP441 > $SLOTS<BR>

After you successfully load the device-tree overlay, if you look at
the contents of SLOTS you will see something like this:<BR>
$ cat $SLOTS<BR>
 0: 54:PF--- <BR>
 1: 55:PF--- <BR>
 2: 56:PF--- <BR>
 3: 57:PF--- <BR>
 4: ff:P-O-L Bone-LT-eMMC-2G,00A0,Texas Instrument,BB-BONE-EMMC-2G<BR>
 5: ff:P-O-- Bone-Black-HDMI,00A0,Texas Instrument,BB-BONELT-HDMI<BR>
 6: ff:P-O-- Bone-Black-HDMIN,00A0,Texas Instrument,BB-BONELT-HDMIN<BR>
 7: ff:P-O-L Override Board Name,00A0,Override Manuf,BBB-DMIC-INMP441<BR>

If you get an error it is probably because you have not disabled
the HDMI interface. Your error might look like this:<BR>
-sh: echo: write error: File exists

Our overlay is requesting "exclusive-use" of pins
that are already assigned to the HDMI interface.
There are several ways to disable the HDMI interface:

1. When the BeagleBone Black is connected to a computer via USB it
will look like a USB storage device.<BR>
On my computer, it mounts at /media/BEAGLEBONE<BR>
If you browse inside in your favorite file explorer you will 
see a file: /media/BEAGLEBONE/uEnv.txt<BR>
Open this file and add the following line:<BR>
optargs=quiet capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN<BR>
In later revisions this line is already in the file and commented
out, so you simply need to uncomment it.<BR>
Reboot after making the change.

2. Load a device tree overlay that disables the HDMI interface.

3. Decompile your device tree /boot/am335x-boneblack.dtb into a .dts file. Disable the HDMI interface and recompile into .dtb













