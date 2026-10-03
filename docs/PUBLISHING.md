# yyyt0807 发布准备记录（2026-10-03）

- GitHub：`https://github.com/yyyt0807/MoonBitemporal`，公开仓库，默认分支 `main`。
- Mooncakes：`yyyt0807/moonbitemporal@0.1.0`。
- 本仓库作者和提交者使用 `yyyt0807 <325130583+yyyt0807@users.noreply.github.com>`；仅修改项目级 Git 配置。
- 用户要求的 55 条尚未推送本地历史已统一身份；提交内容、消息、父子关系和时间保留，哈希随身份变化。
- 原始完整 Git bundle、哈希映射、修改前配置与 README 在工作区 `发布备份/MoonBitemporal-yyyt0807-20261003/`，不进入公开项目或发布包。
- 包命名空间、所有内部导入、公开接口和申报仓库链接同步；申报书参赛者空白。
- 旧审查报告中的账号和提交哈希是改写前的历史快照，以本记录及实际远端状态更新。

## 发布门禁

修改命名空间后，重新执行严格四后端 check/build/test、可执行场景与 Native release 负载。
创建仓库并推送后核验 owner、所有提交关联身份及默认分支 CI；CI 成功后发布 Mooncakes，再从公共注册表独立安装验证。
实际发布源码由 `v0.1.0` 标签和 GitHub Release 记录，后续本记录更新不改变已发布实现。
