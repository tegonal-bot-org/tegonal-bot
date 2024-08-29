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
sourceOnce "$dir_of_tegonal_scripts/qa/run-shellcheck.sh"

function customRunShellcheck() {
	declare srcDir="$scriptsDir/../src"

	# shellcheck disable=SC2034   # is passed by name to runShellcheck
	declare -a dirs=("$scriptsDir")
	declare sourcePath="$srcDir:$scriptsDir:$dir_of_tegonal_scripts"
	runShellcheck dirs "$sourcePath"

	local -r gt_remote_dir="$scriptsDir/../.gt/remotes/"
	logInfo "analysing $gt_remote_dir/**/pull-hook.sh"

	# shellcheck disable=SC2034   # is passed by name to runShellcheck
	local -ra dirs2=("$gt_remote_dir")
	runShellcheck dirs2 "$sourcePath" -name "pull-hook.sh"
}

${__SOURCED__:+return}
customRunShellcheck "$@"
