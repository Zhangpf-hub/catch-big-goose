# 构建交付目录

微信小游戏工程：`catch-big-goose-wechat/`。开发者工具项目名：`catch-big-goose`。AppID：`wx60b50db2472c4782`，配置类型为 `game`。

从工作区双击 `打开微信工程.cmd`，或者将本目录下的 `catch-big-goose-wechat` 文件夹导入微信开发者工具。不要导入工作区根目录或 Unity 源工程。

构建命令为 `npm run wechat:build`。转换成功后自动替换当前导出；不要直接在导出文件中长期维护玩法改动。Unity 源工程位于 [projects/catch-big-goose-unity](../projects/catch-big-goose-unity/README.md)。

SDK 的 `minigame` 是中间目录，构建完成后不再作为用户导入入口。生成文件未纳入源码版本管理。

可下载的 Windows／微信构建包保存在本工程私有仓库的 [GitHub Releases](https://github.com/Zhangpf-hub/catch-big-goose/releases)。每次交付附带源码提交号、构建清单和 `SHA256SUMS.txt`；下载微信 ZIP 后解压并导入其中的 `catch-big-goose-wechat` 目录。
