# HiClaw Persistent History

这个仓库用于保存 Manager 的**持久化日志与 Git 历史**。

原则：
- 只保存可公开审计的操作日志、任务状态摘要、非敏感说明。
- 不提交密钥、token、原始 `openclaw.json`、媒体文件、临时文件。
- 每次同步会从 Manager 本地 memory/state 生成一份脱敏快照并提交。

主目录：
- `logs/`：按日期归档的脱敏运行日志。
- `snapshots/`：当前任务/Worker 状态快照。
- `scripts/sync-manager-history.sh`：同步脚本。
