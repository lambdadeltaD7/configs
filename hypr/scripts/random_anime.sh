#!/bin/bash

data=$(curl -s  https://api.nekosia.cat/api/v1/images/random)

img_addr=$(echo $data | jq -r '.image.compressed.url')
pic_id=$(echo $data | jq -r '.id')
pic_name="${pic_id}.png"
fname="${HOME}/Pictures/anime/${pic_name}"
curl -s  $img_addr > $fname

gsettings set org.gnome.eog.ui sidebar false
eog $fname
# gsettings set org.gnome.eog.ui sidebar true
