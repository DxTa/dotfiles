# OpenCode Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [2026-01-04] - Plan Mode File Editing Support
### Added
- Plan mode now allows editing and updating files in `~/.config/opencode/plans/` directory
- Auto-approval for creating, editing, and deleting plan files:
  - `~/.config/opencode/plans/*_task_plan.md`
  - `~/.config/opencode/plans/*_notes.md`
- TodoWrite operations remain available for live tracking during plan mode
- This enables plan agents to maintain plan files and TodoWrite synced without requiring mode switches

### Changed
- Plan mode `permission.edit` now auto-approves edits within plans directory
- Plan agent capabilities documented to explicitly allow plan file management

### Technical Details
- Plan agents can use `write`, `edit`, and `delete` tools on files matching:
  - `~/.config/opencode/plans/*_task_plan.md`
  - `~/.config/opencode/plans/*_notes.md`
- All other files remain under standard edit approval workflow (`ask` mode)
- Bash commands for plan directory operations are auto-approved:
  - `mkdir -p ~/.config/opencode/plans`
  - `rm ~/.config/opencode/plans/*`
