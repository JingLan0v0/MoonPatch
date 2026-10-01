# MoonPatch

简体中文 | [English](README.md)

MoonPatch 是一个用 MoonBit 实现的 JSON Patch 工具库及命令行程序。它按
[RFC 6902](https://www.rfc-editor.org/info/rfc6902/) 对 JSON 文档执行局部修改，
用 [RFC 6901](https://www.rfc-editor.org/info/rfc6901/) JSON Pointer 精确定位字段。
典型用途是更新配置、调整发布队列或修改权限策略，而不必为每种 JSON 结构重写遍历代码。

核心逻辑全部使用 MoonBit；Node.js 仅处理 CLI 的文件和进程输入输出。库采用不修改输入的实现方式：任何一步失败都返回结构化错误，不产生可见的部分结果。固定版本的公开 JSON Patch 测试集中，**108/108 个启用用例通过**，另有 4 个上游标记为 disabled 的用例未运行。

## 功能

- 完整支持 `add`、`remove`、`replace`、`move`、`copy`、`test` 六种标准操作；
- 支持对象字段、数组插入、`-` 追加、移动后的索引变化；
- 支持空键名、根指针、`~0` 和 `~1` 转义；
- `test` 按 JSON 值比较：对象键顺序无关，`1` 与 `1.0` 相等；
- 结构化错误包含错误码、失败操作序号、路径和说明；
- 限制补丁最多 4,096 步、指针最多 16,384 字符和 128 段、CLI 每个输入最多 16 MiB。

当前只支持 MoonBit JS 目标。项目不包含 HTTP 客户端、JSON 差异生成、Schema 校验或自定义补丁指令。删除整个根节点会报错，因为没有可返回的 JSON 值。项目采用标准 `application/json-patch+json` 格式，与 [tiye/recollect](https://mooncakes.io/docs/tiye/recollect) 的自定义结构差分格式有明确边界。

## 快速运行

安装 MoonBit 与 Node.js 24，在项目根目录运行：

```powershell
.\scripts\moon.ps1 run cmd/main --target js -- --compact examples/service-config.json examples/service-config.patch.json
```

结果与 `examples/service-config.expected.json` 一致。还可以将其中一个路径写成 `-` 从标准输入读取，两个路径不能同时使用 `-`。CLI 成功时只向标准输出写 JSON；失败时向标准错误写诊断，退出码为 2，不修改源文件。

## 库接口

在本地检出中导入 `JingLan0v0/moonpatch`，并调用 `apply(document, patch)` 或 `apply_json(document_text, patch_text)`。还提供 `pointer_get`、`parse_pointer`、`format_pointer`、`escape_pointer_token` 与 `json_equal`。可运行的 [`examples/library`](examples/library) 包直接调用公开库接口，不依赖 CLI 宿主层。

**当前尚未发布到 Mooncakes。** 发布前不要在文档或报名材料中声称可以通过 `moon add` 安装。

## 三个可复现的场景

1. **服务配置变更：** 先用 `test` 核对修订号，再修改地址、开启审计并递增版本，避免把补丁应用到错误版本。
2. **发布队列调整：** 插入安全扫描步骤、移动部署步骤，并复制负责人的信息，验证数组索引移动语义。
3. **权限策略修改：** 先核对启用状态，再复制角色、移除访客权限并精确替换审核者权限。

每个场景都有原始 JSON、补丁和预期 JSON；`node scripts/verify.mjs` 会逐一运行并比较结果。

## 验证和工程结构

```powershell
node scripts/verify.mjs
```

这个命令检查格式、编译、MoonBit 单元测试、接口生成、CLI 构建、三个示例、真实命令行边界和 108 个启用的公开测试用例。GitHub Actions 工作流已配置 Windows 与 Ubuntu；创建公开仓库并推送后才能得到远端 CI 结果。

`pointer.mbt` 处理 RFC 6901，`patch.mbt` 负责六种操作与不变式，`cmd/main` 是 CLI 适配层，`testdata` 保存带来源说明的公开测试向量。架构、参赛条件与当前状态见 `docs/`。

项目采用 Apache-2.0 许可证；第三方测试材料的来源与许可见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
