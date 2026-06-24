#!/usr/bin/env bats

@test "format_command shell-quotes arguments" {
	run bash -c 'source scripts/func.sh; format_command useradd -c "Demo User" demo'
	[ "$status" -eq 0 ]
	[[ "$output" == *"Demo\\ User"* ]]
}

@test "dry-run command execution does not run the command" {
	run bash -c 'export SAH_DRY_RUN=1 SAH_LOG_DIR="$1"; source scripts/func.sh; run_admin_command test_action target false; test -f "$SAH_AUDIT_LOG_FILE"; grep -q dry-run "$SAH_AUDIT_LOG_FILE"' _ "$BATS_TEST_TMPDIR/logs"
	[ "$status" -eq 0 ]
}

@test "non-interactive command execution is blocked without explicit approval" {
	run bash -c 'export SAH_LOG_DIR="$1"; source scripts/func.sh; run_admin_command test_action target true' _ "$BATS_TEST_TMPDIR/logs"
	[ "$status" -eq 130 ]
}
