# Catch Big Goose workspace

- Read `workspace.json` and `docs/project-structure.md` before choosing a project path.
- Active source project: `projects/catch-big-goose-unity`. Use Unity 2022.3.62f3.
- Current WeChat DevTools project: `builds/catch-big-goose-wechat`; project name `catch-big-goose`.
- `reference-projects` and `competitor-analysis` are separate top-level directories. Keep raw reference data and frozen evidence intact.
- Put this project's implementation/acceptance reports in `docs/development-reports`, research conclusions in `competitor-analysis`, and temporary game outputs in `work`.
- Use lowercase kebab-case for new custom directories; preserve engine-required folder names, GUIDs and package internals.
- Run `npm run structure:check` after changing directory layout or entry paths. Existing launch/build commands are in the root README.
- The project skill copy in `skills/match3-model-pipeline` uses current paths; older installed copies may use the retired `cocos` and `assets-3d` root names. Resolve those through the current structure before running a resource command.
- Do not recreate root `project.config.json`, root `unity`, or a user-facing `minigame` project. The SDK's internal `minigame` export is published to the named `builds` directory by `GooseWeChatBuild`.
- Windows QA players use local-only PlayerConnection via `GoosePlayerNetworkPolicy`; preserve this build hook in new test workspaces. Before launching old mutable players or copied QA executables, run `tools/unity/fix-player-network.ps1 -PlayerPath <exe>`. Keep frozen evidence intact: copy it to a mutable test directory before repair. Do not request firewall access for routine EXE tests. Remote profiling is an explicit opt-in (`GOOSE_REMOTE_PROFILER=1` at build time).
