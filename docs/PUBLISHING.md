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

## 已完成发布

- 公开仓库 `yyyt0807/MoonBitemporal`，默认分支 `main`；GitHub API 核验拥有者为 yyyt0807。
- 首次推送 56 条提交，GitHub API 核验全部 author.login 和 committer.login 均为 yyyt0807。
- 发布源提交：`cbc09d5431ca126db310f48b599fe096f5708dce`；[发布 CI](https://github.com/yyyt0807/MoonBitemporal/actions/runs/37109618413) Ubuntu/Windows 作业全部成功。
- 本地严格全后端 check/build/test 通过，各后端 85 项测试成功；维护示例及 Native release 负载成功。
- Mooncakes `yyyt0807/moonbitemporal@0.1.0` 发布 API 返回 `200 OK`，归档与解包校验通过。
- 独立 `发布验证/MoonBitemporal-yyyt0807-0.1.0` 从公共注册表下载 0.1.0，历史重放、完整批次分页和多键联合覆盖实际运行通过。
- `v0.1.0` 标签指向发布源提交；本记录后续更新只增加发布证据，不覆盖已发布实现。
- 既有带日期审查文档中的发布前状态以本记录更新，申报资料仍需申请人按章程人工核实定稿。
