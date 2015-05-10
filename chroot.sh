#!/bin/bash
CHROOT=$1
echo $CHROOT

function cleanup() {
    sudo umount $CHROOT/sys
    sudo umount $CHROOT/proc
    sudo umount $CHROOT/dev/shm
}

trap cleanup SIGINT EXIT

shift
if [ "$CHROOT" == "" ] || [ ! -d "$CHROOT" ]; then
    echo "invalid usage"
    exit 1
fi
sudo mount -o bind /proc $CHROOT/proc
sudo mount -o bind /sys $CHROOT/sys
sudo cp -a /dev/* $CHROOT/dev/
sudo mount -o bind /dev/shm $CHROOT/dev/shm

sudo chroot $CHROOT "$@"
RESULT=$?

exit $RESULT
