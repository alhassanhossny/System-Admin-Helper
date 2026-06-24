#!/usr/bin/env bats

@test "valid usernames are accepted" {
	run bash -c 'source scripts/func.sh; isValidUsername admin_user'
	[ "$status" -eq 0 ]
}

@test "invalid usernames are rejected" {
	run bash -c 'source scripts/func.sh; isValidUsername "Bad User!"'
	[ "$status" -ne 0 ]
}

@test "future ISO dates are accepted" {
	run bash -c 'source scripts/func.sh; isValidDate 2099-01-01'
	[ "$status" -eq 0 ]
}

@test "past ISO dates are rejected" {
	run bash -c 'source scripts/func.sh; isValidDate 2000-01-01'
	[ "$status" -ne 0 ]
}

@test "absolute directories are accepted" {
	run bash -c 'source scripts/func.sh; isValidDir /home/example'
	[ "$status" -eq 0 ]
}

@test "relative directories are rejected" {
	run bash -c 'source scripts/func.sh; isValidDir relative/path'
	[ "$status" -ne 0 ]
}
