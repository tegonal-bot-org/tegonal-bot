#!/usr/bin/env bash
#
#  This script is provided to you by https://github.com/tegonal-bot/bot
#  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
#  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Creative Commons Zero v1.0 Universal
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
sourceOnce "$dir_of_tegonal_scripts/utility/io.sh"

function githubApiGet() {
	if ! (($# == 2)); then
		logError "Exactly two arguments needs to be passed to getMatrix, given \033[0;36m%s\033[0m\n" "$#"
		echo >&2 '1: url      github api endpoint'
		echo >&2 '2: secret   github api token'
		printStackTrace
		exit 9
	fi
	local -r url=$1
	local -r secret=$2
	shift 2

	local response status
	response=$(mktemp -t github-api-XXXXXXXXXX)
	status=$(curl -s -o "$response" -w "%{response_code}" \
		--request GET \
		--url "$url" \
		--header "Accept: application/vnd.github+json" \
		--header "X-GitHub-Api-Version: 2022-11-28" \
		--header "authorization: Bearer $secret") || die "unknown error: could not get %s" "$url"
	if ! [[ $status == "200" ]]; then
		# shellcheck disable=SC2312		# we suppress fail of cat on purpose
		returnDying "server error, could not get %s\nserver responded with status: %s\nand message:\n%s" "$url" "$status" "$(cat "$response")}"
	fi
	cat "$response"
}

function getUpstream() {
	if ! (($# == 2)); then
		logError "Exactly two arguments need to be passed to getUpstreamRepo, given \033[0;36m%s\033[0m\n" "$#"
		echo >&2 '1: repository   name of the repository including the prefixed owner, for instance tegonal-bot/scripts'
		echo >&2 '2: secret       github api token'
		printStackTrace
		exit 9
	fi
	local -r repository=$1
	local -r secret=$2
	shift 2

	local response
	response=$(githubApiGet "https://api.github.com/repos/$repository" "$secret")
	r='"parent"\s*:\s*\{[^\}]+?"full_name"\s*:\s*"([^"]+)"'
	if [[ $response =~ $r ]]; then
		echo "${BASH_REMATCH[1]}"
	else
		echo "$repository"
	fi
}

function getRepos() {
	if ! (($# == 1)); then
		logError "Exactly one argument needs to be passed to getUpstreamRepo, given \033[0;36m%s\033[0m\n" "$#"
		echo >&2 '1: secret   github api token'
		printStackTrace
		exit 9
	fi
	local -r secret=$1
	shift 1

	local response repos
	response=$(githubApiGet "https://api.github.com/users/tegonal-bot/repos" "$secret")
	repos=$(
		echo "$response" | grep '"full_name"' | sed -r 's@\s*"full_name"\s*:\s*"([^"]+)",@\1@'
	) || die "looks like no repo in response:\n%s" "response"
	echo "$repos"
}

function getRepoMatrix() {
	if ! (($# == 1)); then
		logError "Exactly one argument needs to be passed to getMatrix, given \033[0;36m%s\033[0m\n" "$#"
		echo >&2 '1: secret   github api token'
		printStackTrace
		exit 9
	fi
	local -r secret=$1
	shift 1
	local repos upstreams
	repos=$(getRepos "$secret")

	upstreams="$(while IFS= read -r repository; do
		getUpstream "$repository" "$secret"
	done <<<"$repos")"

	printf 'matrix={"include":['
	local i=0
	while IFS= read -r repo && IFS= read -r upstream <&3; do
		if ((i > 0)); then
			printf ","
		fi
		((++i))
		if ((i > 19)); then
			die "there are more than 19 repos, please adjust the outputs of determine_remotes";
		fi
		printf '{ "repository": "%s", "upstream": "%s", "nr": "%s" }' "$repo" "$upstream" "$i"
	done <<<"$repos" 3<<<"$upstreams"
	printf "]}"
}

${__SOURCED__:+return}
getRepoMatrix "$@"
