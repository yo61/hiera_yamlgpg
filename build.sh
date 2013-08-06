#!/bin/bash

# Set up build setting
project_name=compete-hiera_yamlgpg
project_base_dir="$(readlink -f "$(dirname "${BASH_SOURCE}")")"

version=$(cat "${project_base_dir}/Modulefile" \
             | awk '$1=="version" {print $2}' \
             | tr -d "'")

# Build the module
puppet module build "${project_base_dir}"

# Enter the package directory
pushd "${project_base_dir}/pkg" > /dev/null

# Remove what puppet created
rm ${project_name}-${version}.tar.gz

# Remove any bad files from the package
find ${project_name}-${version} -name '*~' -delete

# Lock down the permissions
chmod -R go-w ${project_name}-${version}
chmod -R a+rX ${project_name}-${version}

# Create the new tar with root as owner and group
tar --owner 0 --group 0 -czf ${project_name}-${version}.tar.gz ${project_name}-${version}

# Exit the package directory
popd > /dev/null
