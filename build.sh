#!/bin/bash

echo
echo "--------------------------------------"
echo "        AwakenOS 14.0 Buildbot        "
echo "                  by                  "
echo "                YZBruh                "
echo "        original author: ponces       "
echo "--------------------------------------"
echo

set -e

BL=$PWD/treble_build_awaken
BD=$PWD/treble_build_awaken/GSI_images

initRepos() {
    if [ ! -d .repo ]; then
        echo "--> Initializing workspace"
        repo init -u https://github.com/Project-Awaken/android_manifest -b ursa
        echo

        echo "--> Preparing local manifest"
        mkdir -p .repo/local_manifests
        cp $BL/manifest.xml .repo/local_manifests/awaken.xml
        echo
    fi
}

syncRepos() {
    echo "--> Syncing repos"
    repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc --all)
    echo
}

applyPatches() {
    echo "--> Applying prerequisite patches"
    bash $BL/apply-patches.sh $BL prerequisite
    echo

    echo "--> Applying TrebleDroid patches"
    bash $BL/apply-patches.sh $BL trebledroid
    echo

    echo "--> Applying personal patches"
    bash $BL/apply-patches.sh $BL personal
    echo

    echo "--> Generating makefiles"
    cd device/phh/treble
    cp $BL/awaken.mk .
    bash generate.sh awaken
    cd ../../..
    echo
}

setupEnv() {
    echo "--> Setting up build environment"
    sudo apt update
    sudo apt -y upgrade
    sudo apt -y install gperf gcc-multilib gcc-10-multilib g++-multilib g++-10-multilib libc6-dev lib32ncurses5-dev x11proto-core-dev libx11-dev tree lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc bc ccache lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk3.0-gtk3-dev libxml2 lzop pngcrush schedtool squashfs-tools imagemagick libbz2-dev lzma ncftp qemu-user-static libstdc++-10-dev libncurses5 python3 python2
    source build/envsetup.sh &>/dev/null
    mkdir -p $BD
    echo
}

buildTrebleApp() {
    echo "--> Building treble_app"
    cd treble_app
    bash build.sh release
    cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
    cd ..
    echo
}

buildVariantARMplus() {
    echo "--> Building treble_arm64_bvN"
    lunch treble_arm64_bvN-userdebug
    make -j$(nproc --all) installclean
    make -j$(nproc --all) systemimage
    mv $OUT/system.img $BD/system-treble_arm64_bvN.img
    echo
}

buildVndkliteVariantplus() {
    echo "--> Building treble_arm64_bvN-vndklite"
    cd sas-creator
    sudo bash lite-adapter.sh 64 $BD/system-treble_arm64_bvimg
    cp s.img $BD/system-treble_arm64_bvN-vndklite.img
    sudo rm -rf s.img d tmp
    cd ..
    echo
}

buildVariantARM() {
    echo "--> Building treble_a64_bvN"
    lunch treble_a64_bvN-userdebug
    make -j$(nproc --all) installclean
    make -j$(nproc --all) systemimage
    mv $OUT/system.img $BD/system-treble_a64_bvN.img
    echo
}

buildVndkliteVariant() {
    echo "--> Building treble_a64_bvN-vndklite"
    cd sas-creator
    sudo bash lite-adapter.sh 32 $BD/system-treble_a64_bvimg
    cp s.img $BD/system-treble_a64_bvN-vndklite.img
    sudo rm -rf s.img d tmp
    cd ..
    echo
}

generatePackages() {
    echo "--> Generating packages"
    buildDate="$(date +%Y%m%d)"
    xz -cv $BD/system-treble_arm64_bvN.img -T0 > $BD/awaken_arm64-ab-ursa-unofficial-$buildDate.img.xz
    xz -cv $BD/system-treble_arm64_bvN-vndklite.img -T0 > $BD/awaken_arm64-ab-vndklite-ursa-unofficial-$buildDate.img.xz
    xz -cv $BD/system-treble_a64_bvN.img -T0 > $BD/awaken_a64-ab-ursa-unofficial-$buildDate.img.xz
    xz -cv $BD/system-treble_a64_bvN-vndklite.img -T0 > $BD/awaken_a64-ab-vndklite-ursa-unofficial-$buildDate.img.xz
    rm -rf $BD/system-*.img
    echo
}

START=$(date +%s)

initRepos
syncRepos
applyPatches
setupEnv
buildTrebleApp
buildVariantARMplus
buildVndkliteVariantplus
buildVariantARM
buildVndkliteVariant
generatePackages

END=$(date +%s)
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo
