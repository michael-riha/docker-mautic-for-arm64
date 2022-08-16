#!/bin/bash
set -e

current="$(curl https://api.github.com/repos/mautic/mautic/releases/latest -s | jq -r .tag_name)"
#current_version_url="$(curl https://api.github.com/repos/mautic/mautic/releases/latest -s | jq -r .assets[1].browser_download_url)"

# TODO - Expose SHA signatures for the packages somewhere
wget -O mautic.zip https://github.com/mautic/mautic/releases/download/$current/$current.zip
#wget -O mautic.zip $current_version_url 
sha1="$(sha1sum mautic.zip | sed -r 's/ .*//')"

for variant in apache fpm; do
	(
		set -x

		sed -ri '
			s/^(ENV MAUTIC_VERSION) .*/\1 '"$current"'/;
			s/^(ENV MAUTIC_SHA1) .*/\1 '"$sha1"'/;
		' "$variant/Dockerfile"

        # To make management easier, we use these files for all variants
		cp common/* "$variant"/
	)
done

rm mautic.zip
