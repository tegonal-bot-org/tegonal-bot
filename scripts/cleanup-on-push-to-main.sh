#!/usr/bin/env bash
#
#    __                          __
#   / /____ ___ ____  ___  ___ _/ /       This script is provided to you by https://github.com/tegonal-bot-org/tegonal-bot
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2024 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Apache License, Version 2.0
#         /___/                           Please report bugs and contribute back your improvements
#
#                                         Version: v0.1.0-SNAPSHOT
###################################
set -euo pipefail
shopt -s inherit_errexit
unset CDPATH

if ! [[ -v scriptsDir ]]; then
	scriptsDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null && pwd 2>/dev/null)"
	readonly scriptsDir
fi

if ! [[ -v projectDir ]]; then
	projectDir="$(realpath "$scriptsDir/../")"
	readonly projectDir
fi

if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$projectDir/lib/tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi

sourceOnce "$dir_of_tegonal_scripts/utility/log.sh"
sourceOnce "$projectDir/lib/gt/src/install/include-install-doc.sh"

function cleanupOnPushToMain() {
	# shellcheck disable=SC2034   # is passed by name to copyInstallSh
	local -ra includeInstallSh=(
		"$projectDir/.github/workflows/gt-update-in-repos.yml" '          '
	)
	includeInstallDoc "$projectDir/lib/gt/install.doc.sh" includeInstallSh || die "could not include install.doc.sh"
	echo "included install.doc.sh"


	logSuccess "Cleanup on push to main completed"
}

${__SOURCED__:+return}
cleanupOnPushToMain "$@"
