#!/bin/bash

set -e

BUILDPULSE_CACHE_VERSION="v0.14.0"

# Enable double globbing if supported by the shell on the base github runner
if shopt -s globstar; then
	echo "This bash shell version supports double globbing: '${BASH_VERSION}'."
else
  echo "This bash shell version does not support double globbing: '${BASH_VERSION}'. Please upgrade to bash 4+."
fi

RUNNER_OS=$(uname)
case "$RUNNER_OS" in
	Linux)
		OS=linux
		;;
	Darwin)
		OS=macos
		;;
	Windows)
		OS=win.exe
		;;
	*)
		echo "::error::Unrecognized operating system. Expected RUNNER_OS to be one of \"Linux\", \"macOS\", or \"Windows\", but it was \"$RUNNER_OS\"."
		exit 1
esac

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)    ARCH="x64" ;;
  arm64)     ARCH="arm64" ;;
  aarch64)   ARCH="arm64" ;;
  armv7l)    ARCH="armv7" ;;
  *)         ARCH="unknown" ;;
esac

BUILDPULSE_CACHE_BINARY="${BUILDPULSE_CACHE_VERSION}-${ARCH}/cache-${OS}"

BUILDPULSE_CACHE_HOSTS=(
	https://github.com/buildpulse/buildpulse-circleci-orb/releases/download
)
[ -n "${INPUT_CLI_HOST}" ] && BUILDPULSE_CACHE_HOSTS=("${INPUT_CLI_HOST}" "${BUILDPULSE_CACHE_HOSTS[@]}")

getcli() {
	local rval=-1
	for host in "${BUILDPULSE_CACHE_HOSTS[@]}"; do
		url="${host}/${BUILDPULSE_CACHE_BINARY}"
		if (set -x; curl -fsSL --retry 3 --retry-connrefused --connect-timeout 5 "$url" > "$1"); then
			return 0
		else
			rval=$?
		fi
	done;

	return $rval
}

if getcli ./buildpulse-cache; then
	echo Successfully fetched binary. Great!
	echo $(ls -l ./buildpulse-cache)
else
	msg=$(cat <<-eos
		::warning::Unable to fetch BuildPulse Cache binary.

		If you continue seeing this problem, please get in touch at
		https://buildpulse.io/contact so we can look into this issue.
	eos
	)

	echo "${msg//$'\n'/%0A}" # Replace newlines with URL-encoded newlines for proper formatting in GitHub Actions annotations (https://github.com/actions/toolkit/issues/193#issuecomment-605394935)
	exit 0
fi

chmod +x ./buildpulse-cache

set -x

./buildpulse-cache $INPUT_ACTION
