#!/usr/bin/env bash

if [ -d "$HOME/.local/share/JetBrains/Toolbox" ]; then
    echo 'It is already installed'
    exit
fi

if ! [ -x "$(command -v jq)" ]; then
  sudo apt-get install -y jq
  command -v jq || exit 1
fi


json=$(wget -qO - "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release&build=&_=$(date +%s%3N)")
download_link=$(echo "$json" | jq -r .TBA[0].downloads.linux.link)
checksum_link=$(echo "$json" | jq -r .TBA[0].downloads.linux.checksumLink)
download_filename=$(basename "$download_link")
checksum_filename=$(basename "$checksum_link")

cd $(xdg-user-dir DOWNLOAD)
wget "$download_link" "$checksum_link"

if ! sha256sum --quiet --check "$checksum_filename"; then
    echo 'Checksum verification failed'
    exit 1
fi

extract_dir=$(tar tf "$download_filename" | head -1)
tar xf "$download_filename"
"${extract_dir}jetbrains-toolbox"

test -f "$download_filename" && rm "$download_filename"
test -f "$checksum_filename" && rm "$checksum_filename"
test -d "$extract_dir" && rm -r "$extract_dir"
