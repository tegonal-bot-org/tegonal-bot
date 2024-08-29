#!/usr/bin/env bash
#
#  This script is provided to you by https://github.com/tegonal-bot-org/tegonal-bot
#  Copyright 2024 Tegonal Bot <github-bot@tegonal.com>
#  It is licensed under Apache License, Version 2.0
#  Please report bugs and contribute back your improvements
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
if ! [[ -v dir_of_tegonal_scripts ]]; then
	dir_of_tegonal_scripts="$scriptsDir/../lib/tegonal-scripts/src"
	source "$dir_of_tegonal_scripts/setup.sh" "$dir_of_tegonal_scripts"
fi
sourceOnce "$scriptsDir/cleanup-on-push-to-main.sh"
sourceOnce "$scriptsDir/run-shellcheck.sh"

function beforePr() {
	# using && because this function might be used on the left side of an ||
	customRunShellcheck && \
	cleanupOnPushToMain
}

${__SOURCED__:+return}
beforePr "$@"
