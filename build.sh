#!/bin/bash

# @abrahamgcc
# ./build.sh great,dream2,dream ++DeluxeKernel_v15.2++

KERNEL_NAME="${2}"
YELLOW="\e[93m"
GREEN="\e[92m"
RED="\e[91m"
NONE="\e[39m"

time_check() {
	if (( $SECONDS > 3600 )) ; then
		let "hours=SECONDS/3600"
		let "minutes=(SECONDS%3600)/60"
		let "seconds=(SECONDS%3600)%60"
		echo -e "${GREEN}${hours}h.:${minutes}mins.:${seconds}s.${NONE}"
	elif (( $SECONDS > 60 )) ; then
		let "minutes=(SECONDS%3600)/60"
		let "seconds=(SECONDS%3600)%60"
		echo -e "${GREEN}${minutes}mins.:${seconds}s.${NONE}"
	else
		echo -e "${GREEN}${SECONDS}s.${NONE}"
	fi
}

abort() {
  echo -e "\n\n ${RED}$@ ${NONE}"
  exit 1
}

clear
export CROSS_COMPILE=toolchain/gcc-cfp/gcc-cfp-jopp-only/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=p
export LOCALVERSION="${KERNEL_NAME}"
[ "$1" == "clear" ] && make clean && make mrproper && clear && exit 0
echo "$1" | tr ',' '\n' | while read device; do
	SECONDS=0
	[ -f arch/arm64/configs/exynos8895-${device}lte_defconfig ] || abort "exynos8895-${device}lte_defconfig DOESN'T EXIST"
	echo -e "${YELLOW} CLEANING SOURCES ..."
	make clean && make mrproper && clear
	echo " PREPARING CONFIGURATION ..."
	make exynos8895-${device}lte_defconfig && clear
	echo " BUILDING ${KERNEL_NAME} FOR ${device}lte ..."
	make -j64 && clear
	cp -rf arch/arm64/boot/dtb.img deluxe/${device}/split_img/${device}lte.img-dt
	cp -rf arch/arm64/boot/Image deluxe/${device}/split_img/${device}lte.img-zImage
	for file in deluxe/${device}/split_img/${device}lte.img-dt deluxe/${device}/split_img/${device}lte.img-zImage; do
		sudo chmod 644 $file
	done
	for fl in data storage omr acct system lib lib/modules mnt config cache oem/secure_storage sys dev keydata proc keyrefuge; do
		mkdir -p deluxe/${device}/ramdisk/${fl}
	done
	# Use proper permissions before compile boot.img
	for perm in 0600 0640 0644 0750 0755 0771; do
		cat deluxe/.perms/${perm}_perms | while read line; do
			sudo chmod $perm deluxe/${device}/$line
		done
	done
	cp -rf deluxe/aik_linux/* deluxe/${device}
	chmod a+x deluxe/${device}/repackimg.sh
	bash deluxe/${device}/repackimg.sh &>/dev/null
	# Keep 777 permissions on ramdisk to allow editions
	for perm in 0600 0640 0644 0750 0755 0771; do
		cat deluxe/.perms/${perm}_perms | while read line; do
			sudo chmod 777 deluxe/${device}/$line
		done
	done
	cp -rf deluxe/${device}/image-new.img deluxe/${KERNEL_NAME}_${device}lte.img
	rm -rf deluxe/${device}/*.sh deluxe/${device}/bin deluxe/${device}/image-new.img deluxe/${device}/ramdisk-new.cpio.gz \
		deluxe/${device}/split_img/${device}lte.img-dt deluxe/${device}/split_img/${device}lte.img-zImage
	echo -e " BUILT ${KERNEL_NAME}_${device}lte.img in $(time_check). ${NONE}"
done
