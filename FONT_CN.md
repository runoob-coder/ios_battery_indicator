# 字体子集化说明（SF-Pro.ttf）

本包的电量百分比文字（`lib/src/ios_battery_indicator.dart` 中 `DefaultTextStyle` 的
`fontFamily: 'SF Pro'`）使用的并不是完整的 SF Pro 字体，而是一个经过 **子集化
（subset）** 裁剪后的精简版 `fonts/SF-Pro.ttf`。这样做是为了：

- **减小发布体积**：完整 SF Pro 体积数 MB，而实际只用到少量字形。
- **保留必要的 OpenType 特性**：电量数字依赖 `tnum`（等宽数字）特性实现
  `FontFeature.tabularFigures()`，必须保留相关布局特性。
- **剔除无用字形**：只保留渲染所需的数字、符号与少量 SF Symbol 字形。

---

## 1. 前置依赖

子集化使用 Python 的 `fonttools` 工具链，通过 [Homebrew](https://brew.sh/zh-cn/) 安装：

```bash
brew install fonttools
```

> `pyftsubset` 会随 `fonttools` 一同安装，安装后可直接在终端调用。

---

## 2. 子集化命令

从系统完整字体 `/Library/Fonts/SF-Pro.ttf` 裁剪出最小可用子集：

```bash
pyftsubset /Library/Fonts/SF-Pro.ttf \
  --text='1234567890%􀋦 ' \
  --layout-features=kern,tnum,pnum \
  --gids=9634,9635 \
  --output-file=$HOME/Downloads/SF-Pro.ttf
```

将生成的 `SF-Pro.ttf` 拷回仓库 `fonts/` 目录即可：

```bash
cp $HOME/Downloads/SF-Pro.ttf fonts/SF-Pro.ttf
```