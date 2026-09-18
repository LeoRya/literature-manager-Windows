# 本地文献管理系统（Windows 版）

一个只建立索引、不改动原始 PDF 的本地桌面文献库。完整需求见 [docs/requirements-v0.1.md](docs/requirements-v0.1.md)。

## 主要功能

- 递归扫描文件夹中的 PDF，并增量更新索引
- 从 PDF 提取正文与元数据，使用 Crossref/OpenAlex 联网补全
- DOI、文件哈希、标题与年份联合去重；一篇文献可关联多个位置
- 自定义标签、待确认队列和人工校对
- 元数据、标签、路径及 PDF 正文的全局搜索
- 条件之间、同字段多个值之间均支持 AND/OR
- 直接打开 PDF 或在 Windows 资源管理器中定位
- CSV、BibTeX、RIS 导入与导出
- 保留并迁移已有 `paper_library.db` 中的文献与标签

## Windows 启动

需要 64 位 Windows 10/11 和 Python 3.10 或更高版本。

最简单的方式是双击：

```text
启动文献管理系统-Windows.bat
```

首次启动会自动创建 `.venv` 并安装依赖，因此需要联网；后续启动不再重复安装。也可以在 PowerShell 中手动运行：

```powershell
py -3 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe run_literature_manager.py
```

## 数据位置

Windows 默认数据库位于 `%LOCALAPPDATA%\LiteratureManager\paper_library.db`。如果项目根目录已经存在 `paper_library.db`，程序会继续使用它，以兼容旧版本。也可以通过 `LITERATURE_MANAGER_DB` 环境变量指定其他位置。

数据库迁移是增量的，不会删除旧记录。建议像备份其他论文资料一样定期备份数据库。

联网元数据查询只发送 DOI 或候选标题；PDF 文件与全文不会上传。关闭“联网补全元数据”后，扫描可以完全离线运行。

## 测试

```powershell
.\.venv\Scripts\python.exe -m unittest discover -s tests -v
```

## 构建 Windows 发布包

在 PowerShell 中运行：

```powershell
.\build_windows.ps1
```

脚本会生成：

- `dist\LiteratureManager\LiteratureManager.exe`：可直接运行的程序
- `dist\LiteratureManager-Windows-x64.zip`：可分发压缩包

仓库中的 GitHub Actions 工作流也会在推送 `v*` 标签或手动触发时构建 Windows x64 压缩包。

## 许可证

本项目以 [GNU Affero General Public License v3.0](LICENSE) 发布。Windows 发行包同时包含第三方组件；相应许可证与来源见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
