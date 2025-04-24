#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/k1LoW/tbls"
TOOL_NAME="tbls"
TOOL_TEST="tbls version"

fail() {
	printf "asdf-%s: %s\n" "$TOOL_NAME" "$*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
	list_github_tags
}

detect_platform() {
	local platform
	platform=$(uname -s | tr '[:upper:]' '[:lower:]')
	case "$platform" in
	linux) printf "linux\n" ;;
	darwin) printf "darwin\n" ;;
	*) fail "Unsupported platform: $platform" ;;
	esac
}

detect_arch() {
	local arch
	arch=$(uname -m | tr '[:upper:]' '[:lower:]')
	case "$arch" in
	x86_64) printf "amd64\n" ;;
	aarch64 | arm64) printf "arm64\n" ;;
	*) fail "Unsupported architecture: $arch" ;;
	esac
}

download_release() {
	local version filename url platform arch
	version="$1"
	filename="$2"
	local platform
	platform=$(detect_platform)
	local arch
	arch=$(detect_arch)

	if [ "$platform" = "darwin" ]; then
		url="$GH_REPO/releases/download/v${version}/tbls_v${version}_${platform}_${arch}.zip"
	else
		url="$GH_REPO/releases/download/v${version}/tbls_v${version}_${platform}_${arch}.tar.gz"
	fi

	printf "* Downloading %s release %s...\n" "$TOOL_NAME" "$version"
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"
	local platform
	platform=$(detect_platform)
	local arch
	arch=$(detect_arch)

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"

		# Determine the downloaded file name
		local downloaded_file
		if [ "$platform" = "darwin" ]; then
			downloaded_file="$ASDF_DOWNLOAD_PATH/tbls_v${version}_${platform}_${arch}.zip"
		else
			downloaded_file="$ASDF_DOWNLOAD_PATH/tbls_v${version}_${platform}_${arch}.tar.gz"
		fi

		# Download the file
		download_release "$version" "$downloaded_file"

		# Extract the downloaded file
		if [ "$platform" = "darwin" ]; then
			unzip -q "$downloaded_file" -d "$install_path"
		else
			tar -xzf "$downloaded_file" -C "$install_path"
		fi

		# Assert tbls executable exists
		if [ ! -f "$install_path/tbls" ]; then
			fail "Expected tbls executable not found in $install_path"
		fi

		local tool_cmd
		tool_cmd="$(printf "%s" "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		printf "%s %s installation was successful!\n" "$TOOL_NAME" "$version"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
