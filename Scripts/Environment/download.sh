#!/bin/bash
# Script to download WRCCDC archive images

RED="31"
GREEN="32"
BOLDGREEN="\e[1;${GREEN}m"
ITALICRED="\e[3;${RED}m"
ENDCOLOR="\e[0m"

URL='https://archive.wrccdc.org/images/2020/wrccdc-2020-invitationals/rock.bottom'

files=('coal.rock.bottom.ova'
  'dynomite.rock.bottom.ova'
  'flint.rock.bottom.ova'
  'hiddenite.rock.bottom.ova'
  'kryptonite.rock.bottom.ova'
  'obsidian.rock.bottom.ova'
  'pebbles.rock.bottom.ova'
  'pfSense.rock.bottom.ova'
  'relations.rock.bottom.ova'
  'rockyrelations.rock.bottom.ova'
  'taconite.rock.bottom.ova'
'tuff.rock.bottom.ova')

for item in ${files[@]} ;
do
  toDownload=$URL/$item
  echo -e "${BOLDGREEN}Downloading $toDownload${ENDCOLOR}"
  sleep 1;
  wget $toDownload && echo -e "${BOLDGREEN}$item download complete${ENDCOLOR}" || echo -e "${ITALICRED}$item failed to download${ENDCOLOR}"
  echo Extracting $item
  sleep 1;
  tar -xpvf $item && echo -e "${BOLDGREEN}$item unzipped${ENDCOLOR}" || echo -e "${ITALICRED}$item failed to extract${ENDCOLOR}"
  sleep 1;
  echo unzipping vmdk images;
  pigz -dvvv -p12 ./*.gz && echo -e "${BOLDGREEN}vmdk images unzipped...${ENDCOLOR}" || echo -e "${ITALICRED}vmdk unzip error!${ENDCOLOR}"
  sleep 1;
  echo The following vmdk files have been output:
  ls -1 ./*.vmdk
  sleep 3;
  vmdkFiles=$(ls -1 ./*.vmdk)
  for vmdk in $vmdkFiles ;
  do
    echo Converting $vmdk to raw format;
    curDir=$(pwd);
    curDir+="/${vmdk}";
    qemu-img convert -f vmdk -O raw $curDir ./$vmdk.raw && echo -e "${BOLDGREEN}conversion of $vmdk complete${ENDCOLOR}" || echo -e "${ITALICRED}conversion of $vmdk failed${ENDCOLOR}"
    echo removing extra files;
    sleep 1;
    echo compressing $vmdk
    pigz -9 -p 12 -vvv ./$vmdk.raw && echo -e "${BOLDGREEN}$vmdk compressed!" || echo -e "${ITALICRED}$vmdk compression failed...${ENDCOLOR}"
    sleep 3;
  done
  echo Removing extra files.
  
  rm -rf *.ova
  rm -rf *.ovf
  rm -rf *.vmdk
  rm -rf *.nvram
  rm -rf *.mf
  rm rf *.raw
  mv *.gz ./images/
  echo -e "${BOLDGREEN}Moving to next target.${ENDCOLOR}"
  sleep 3;
done
echo -e "${BOLDGREEN}PROCESS COMPLETE!!!${ENDCOLOR}"
