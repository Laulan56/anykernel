# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Marisa Kernel by @Laulan56 for OnePlus 8 Series
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus8Pro
device.name2=instantnoodle
device.name3=OnePlus8
device.name4=instantnoodlep
device.name5=instantnoodlev
device.name6=Kebab
device.name7=kebab
device.name8=Kebabt
device.name9=Kebabt
device.name10=OnePlus8T
device.name11=kb2003
device.name12=KB2003
device.name13=kb2005
device.name14=KB2005
supported.versions=11
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 750 750 $ramdisk/*;

# Clean up other kernels' ramdisk overlay files
#rm -rf $ramdisk/overlay;
#rm -rf $ramdisk/overlay.d;

# change kernel image for 8 Pro (credits to Flar2 for this great idea)
#device=$(getprop ro.product.device 2>/dev/null);
#if [ "$device" == "OnePlus8Pro" ]; then
#  echo "OnePlus 8 Pro"
#  mv /tmp/anykernel/8Pro.img /tmp/anykernel/Image.gz
#else
#  echo "OnePlus 8"
#fi

## AnyKernel install
dump_boot;

# begin ramdisk changes

#F2FS Optimization (anykernel implementation by @kdrag0n)
if mountpoint -q /data; then
  # Optimize F2FS extension list (@arter97)
  for list_path in $(find /sys/fs/f2fs* -name extension_list); do
    hash="$(md5sum $list_path | sed 's/extenstion/extension/g' | cut -d' ' -f1)"

    # Skip update if our list is already active
    if [[ $hash == "43df40d20dcb96aa7e8af0e3d557d086" ]]; then
      echo "Extension list up-to-date: $list_path"
      continue
    fi

    ui_print "  • Optimizing F2FS extension list"
    echo "Updating extension list: $list_path"

    echo "Clearing extension list"

    hot_count="$(grep -n 'hot file extens' $list_path | cut -d':' -f1)"
    list_len="$(cat $list_path | wc -l)"
    cold_count="$((list_len - hot_count))"

    cold_list="$(head -n$((hot_count - 1)) $list_path | grep -v ':')"
    hot_list="$(tail -n$cold_count $list_path)"

    for ext in $cold_list; do
      [ ! -z $ext ] && echo "[c]!$ext" > $list_path
    done

    for ext in $hot_list; do
      [ ! -z $ext ] && echo "[h]!$ext" > $list_path
    done

    echo "Writing new extension list"

    for ext in $(cat $home/f2fs-cold.list | grep -v '#'); do
      [ ! -z $ext ] && echo "[c]$ext" > $list_path
    done

    for ext in $(cat $home/f2fs-hot.list); do
      [ ! -z $ext ] && echo "[h]$ext" > $list_path
    done
  done
fi

# end ramdisk changes

write_boot;
## end install

ui_print " "; ui_print "  • Marisa Kernel successfully installed!";

