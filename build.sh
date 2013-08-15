#!/bin/bash

# Set up build setting
project_name=compete-hiera_yamlgpg
project_base_dir="$(readlink -f "$(dirname "${BASH_SOURCE}")")"

version=$(cat "${project_base_dir}/Modulefile" \
             | awk '$1=="version" {print $2}' \
             | tr -d "'")

# Make the build directory
mkdir -p "${project_base_dir}/build"

# rsync the source to the build and exclude bad files
rsync \
    -a \
    --exclude '/.git*' \
    --exclude '/build' \
    --exclude '*~' \
    --delete \
    --delete-excluded \
    "${project_base_dir}/" "${project_base_dir}/build"

# Build the module
puppet module build "${project_base_dir}/build"

# Enter the package directory
pushd "${project_base_dir}/build/pkg" > /dev/null

# Remove what puppet created
rm ${project_name}-${version}.tar.gz

# Lock down the permissions
chmod -R go-w ${project_name}-${version}
chmod -R a+rX ${project_name}-${version}

# Create the new tar with root as owner and group
tar --owner 0 --group 0 -czf ${project_name}-${version}.tar.gz ${project_name}-${version}

# Exit the package directory
popd > /dev/null
