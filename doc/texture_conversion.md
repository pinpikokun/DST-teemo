# PNG to TEX 変換手順

DST MOD用のテクスチャ (.tex) を PNG から変換する方法。

## ツール

```
"C:\Program Files (x86)\Steam\steamapps\common\Don't Starve Mod Tools\mod_tools\tools\bin\TextureConverter.exe"
```

## 変換コマンド

```bash
TextureConverter.exe -i <input.png> -o <output.tex> -f bc3 -p opengl --mipmap --premultiply
```

### オプション説明

| オプション | 値 | 説明 |
|-----------|-----|------|
| `-i` | 入力ファイル | PNG画像パス |
| `-o` | 出力ファイル | 出力先 .tex パス |
| `-f` | `bc3` | ピクセルフォーマット（DXT5相当、アルファ対応） |
| `-p` | `opengl` | DST は OpenGL プラットフォーム |
| `--mipmap` | - | ミップマップ生成（必須） |
| `--premultiply` | - | アルファ事前乗算 |

## 実行例

```bash
TEXCONV="C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/tools/bin/TextureConverter.exe"

"$TEXCONV" -i DST-teemo-flash_64_noflame.png -o DST-teemo-flash_64_noflame.tex -f bc3 -p opengl --mipmap --premultiply
```

## XML アトラスファイル

各 .tex に対応する .xml を手動で作成する。テクスチャ全体を1要素として使う場合:

```xml
<Atlas><Texture filename="ファイル名.tex" /><Elements><Element name="ファイル名.tex" u1="0" u2="1" v1="0" v2="1" /></Elements></Atlas>
```

## 注意事項

- PNG は正方形・2のべき乗サイズ推奨（64x64, 128x128 等）
- `--mipmap` を付けないとゲーム起動時にテクスチャアサーションエラーが発生する
- `--premultiply` を付けないと半透明部分の描画がおかしくなる場合がある
