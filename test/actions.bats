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

@test "legacy logs file is migrated to a log directory" {
	run bash -c 'export SAH_LOG_DIR="$1/logs"; printf legacy > "$SAH_LOG_DIR"; source scripts/func.sh; prepare_runtime_paths; test -d "$SAH_LOG_DIR"; test -f "$SAH_LOG_DIR/legacy-commands.log"' _ "$BATS_TEST_TMPDIR"
	[ "$status" -eq 0 ]
}
