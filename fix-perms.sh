#!/usr/bin/env bash
set -eu

# Fix ownership/permissions of the dconf.org account on the
# digitalmars.com server.
# Written by Vladimir Panteleev <vladimir@thecybershadow.net>

# This rewrites the data directory on the web server to reset all file
# and directory permissions. It ensures everything is group writable
# and the sgid bit on directories is set, so that all users in the
# dconf.org group can update the website.

# This script must be run on the digitalmars.com server.

cd /usr/local/www/dconf.org/data

rm -rf tmp old

for dir in *
do
	# Use a temporary directory under data/ so that it inherits the
	# group (thanks to its g+s)
	mkdir -p tmp

	# Make a copy so that we are the owner
	rsync -av "$dir" "tmp/"

	# Set the permissions
	find "tmp" -type d -exec chmod 2775 '{}' '+'
	find "tmp" -type f -exec chmod 664 '{}' '+'

	# Move the old directory out of the way
	mkdir -p old
	mv "$dir" "old/$dir-$(date +%s)"

	# Move our copy (which has the correct owner/group/permissions) to
	# the old location
	mv "tmp/$dir" "$dir"
done
