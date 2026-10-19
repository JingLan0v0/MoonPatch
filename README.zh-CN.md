# MoonPatch

简体中文 | [English](README.md) · [GitHub 仓库](https://github.com/JingLan0v0/MoonPatch) · [Mooncakes 页面](https://mooncakes.io/docs/JingLan0v0/moonpatch)

MoonPatch 是用 MoonBit 编写的**可回滚 JSON Patch 事务库**，也提供命令行工具。传入 JSON 文档与 [RFC 6902](https://www.rfc-editor.org/info/rfc6902/) 补丁，`apply_with_receipt` 返回更新结果、受影响路径，以及一份仍符合 RFC 6902 的回滚补丁。回滚补丁首先用 `test` 检查更新后的完整文档；如果文档已被再次修改，回滚会失败，不会覆盖后续变更。

0.1.0 版本实现六种标准补丁操作与 [RFC 6901](https://www.rfc-editor.org/info/rfc6901/) 指针。这些是已有生态能力，[forey217/moonconfig](https://github.com/forey217/moonconfig) 也提供相应功能。**0.2.0 的新增价值是按操作生成带状态校验的回滚凭证**，用于执行外部工具或人工提供的补丁并保留恢复路径。MoonPatch 可以消费 moonconfig 生成的标准补丁；不复用其源码，也不声称替代其差异生成与合并能力。详见[生态对比](docs/moonconfig-comparison.md)和[来源说明](THIRD_PARTY_NOTICES.md)。

## 快速体验

安装 MoonBit 和 Node.js 24 后，在仓库根目录运行：

```powershell
.\scripts\moon.ps1 run cmd/main --target js -- --compact --receipt examples/service-config.json examples/service-config.patch.json
```

命令返回 `value`（修改后的 JSON）、`rollback`（带 `test` 前置条件的标准补丁）和 `paths`（改动涉及的路径）。将 `value`、`rollback` 分别保存为 JSON 文件后运行 `moon run cmd/main --target js -- --compact value.json rollback.json`，即可得到原始文档。省略 `--receipt` 时只输出更新后的 JSON。CLI 不覆盖输入文件；失败时向标准错误输出诊断并以状态码 2 退出。

公开库接口包括 `apply_with_receipt(document, patch) -> PatchReceipt`、`apply(document, patch) -> Json`、接收 JSON 文本的对应接口、指针工具及诊断信息。可运行的 [`examples/library`](examples/library) 直接调用公开接口，演示修改与恢复。模块名为 `JingLan0v0/moonpatch`；可在 [Mooncakes](https://mooncakes.io/docs/JingLan0v0/moonpatch) 查看已发布版本。

## 功能边界

- 正向补丁支持 `add`、`remove`、`replace`、`move`、`copy`、`test`，以及数组插入、`-` 追加、根节点替换和指针转义。
- 对调用者传入的 JSON 不产生部分修改；任何一步失败都返回结构化 `PatchError`。
- 回滚按操作逆序生成；`move` 会恢复两个路径的最小公共祖先，避免数组索引移动导致错误，因此回滚凭证有时比正向补丁大。
- 普通补丁最多 4096 步；生成回滚凭证时最多 4095 步，为前置状态检查保留一步。指针最多 16384 字符、128 段；CLI 每份输入最多 16 MiB，但输出和内存中构造的凭证没有同等大小上限。
- 目前只支持 MoonBit JS 目标。Node.js 只负责 CLI 文件和进程 I/O；不提供差异生成、合并、Schema 校验或 HTTP 服务，亦不支持删除整个 JSON 根节点。

回滚前的根 `test` 只校验 JSON 值，不验证调用者身份或外部存储版本。持久化与并发场景还需要由调用方处理存储事务、权限与凭证保存。

## 场景与验证

`examples/` 包含服务配置、发布队列、权限策略三个完整场景。运行 `node scripts/verify.mjs` 会检查格式、编译、单元测试、公开 API 示例、三个场景的回滚往返、真实 CLI 边界，以及固定版本的 [json-patch-tests](https://github.com/json-patch/json-patch-tests)：108 个启用用例全部通过，4 个上游标为 disabled 的用例单独列出。[GitHub Actions](https://github.com/JingLan0v0/MoonPatch/actions/workflows/ci.yml) 在 Windows 和 Ubuntu 检查；特定提交的证据见[验收记录](docs/acceptance.md)。

采用 Apache-2.0 许可证；第三方测试向量及复用的 CLI 基础设施见[来源声明](THIRD_PARTY_NOTICES.md)。
