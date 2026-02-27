# CLAUDE.md

このファイルは Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイドです。

## プロジェクト概要

Don't Starve Together (DST) のキャラクターMOD「Captain Teemo」（League of Legends のキャラクター）。Steam Workshop で公開中（ID: 390684095）。Lua で記述、DST のゲームエンジンが直接解釈する — ビルド不要、テストなし、CI なし。

- **DST API バージョン:** 10
- **MOD バージョン:** 0.2.2.3
- **全クライアントにこのMODが必要**

## アーキテクチャ

### エントリポイント

- **modinfo.lua** — MODメタデータ（名前、バージョン、互換性フラグ）
- **modmain.lua** — メインエントリポイント: アセット読み込み、レシピ定義、`AddModCharacter("teemo", "MALE")` でキャラクター登録

### スクリプト

- **scripts/prefabs/teemo.lua** — キャラクター定義。主要な能力:
  - *Camouflage* — 1.5秒静止で透明化、敵の攻撃すり抜け、解除時に攻撃速度UP
  - *Toxic Shot* — 攻撃時の毒DOT（初撃ダメージ + 毎秒DOT × 4秒間）
  - *Noxious Trap スタック管理* — 専用スロットからの罠設置（初期3個、30秒で回復、最大5）
  - *Mushroom Expert* — キノコのマイナスステータス無効化
  - *初期インベントリ* セットアップ
- **scripts/prefabs/blind_dart.lua** — 遠距離武器（吹き矢タイプ）。ブラインド効果 + 毒DOT。テーモ専用。
- **scripts/prefabs/noxious_trap.lua** — 設置型トラップ。5分の寿命、AoEダメージ + スローデバフ。PvP対応の起爆ロジック。最大10個設置。
- **scripts/prefabs/blind_effect.lua, explode_noxious_trap.lua, toxic_effect_by_teemo.lua** — ターゲットエンティティに子としてアタッチするビジュアルエフェクト
- **scripts/components/characterspecific.lua** — テーモ専用のアイテム装備制限
- **scripts/components/explosive_noxious_trap.lua** — トラップ爆発処理: AoEエンティティ検索、クリーチャータグ別ダメージ計算、スローデバフ適用
- **scripts/teemo_poison_util.lua** — 毒による食料腐敗ユーティリティ（毒状態で死んだ敵のドロップ食料の鮮度低下）
- **scripts/widgets/noxioustrap_slot.lua** — ノクサストラップ専用インベントリスロットUI
- **scripts/components/lootdropper.lua, perishable.lua** — DST標準コンポーネントの上書き
- **scripts/speech_teemo.lua** — キャラクターセリフ文字列（約46KB）

### アセット

- **anim/** — アニメーションZIPアーカイブ（キャラクター、アイテム、エフェクト）
- **images/** — テクスチャ (.tex) とアトラス (.xml) のペア。UIコンテキスト別に整理（ポートレート、アバター、インベントリアイコン、HUD、マップアイコン）
- **sound/** — FMOD サウンドバンク (.fev + .fsb)

## DST MOD開発パターン

**Prefab パターン:** 各ゲームエンティティは `fn(Sim)` 関数で定義された prefab。`Prefab("path/name", fn, assets)` で返す。

**Component パターン:** カスタムコンポーネントは `Class(function(self, inst) ... end)` を使用。メソッドは `ComponentName:Method()` で定義。

**サーバー/クライアント分離:** `common_postinit` は全クライアントで実行（ビジュアル/UI）、`master_postinit` はサーバーのみ（ゲームロジック）。サーバー専用コードは `if not TheWorld.ismastersim then return inst end` でガード。

**イベント駆動:** ゲームロジックはイベントに応答（`inst:ListenForEvent("eventname", callback)`）。主なイベント: `equipped`, `onattackother`, `attacked`, `death`。

**タスクシステム:** `inst:DoPeriodicTask(interval, fn)` で繰り返し処理、`inst:DoTaskInTime(delay, fn)` で遅延実行。`task:Cancel()` でキャンセル。

## 備考

- コメントは英語と日本語が混在
