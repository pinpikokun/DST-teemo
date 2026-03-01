# CLAUDE.md

このファイルは Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイドです。

## プロジェクト概要

Don't Starve Together (DST) のキャラクターMOD「Captain Teemo」（League of Legends のキャラクター）。Steam Workshop で公開中（ID: 390684095）。Lua で記述、DST のゲームエンジンが直接解釈する — ビルド不要、テストなし、CI なし。

- **DST API バージョン:** 10
- **MOD バージョン:** 0.2.2.3
- **全クライアントにこのMODが必要**

## アーキテクチャ

### エントリポイント

- **modinfo.lua** — MODメタデータ（名前、バージョン、互換性フラグ）+ 14項目の設定オプション（体力/満腹/正気度、ダメージ倍率、防御、移動速度、Blind Dart初撃・DOT・耐久力、Noxious Trap初撃・DOT、Igniteダメージ、毒腐敗率、キノコ無効）
- **modmain.lua** — メインエントリポイント: 設定値をGLOBALに展開、アセット読み込み、レシピ定義、`AddModCharacter("teemo", "MALE")` でキャラクター登録、RPC定義（トラップ設置・Flash・Ignite）、インベントリバーUI拡張（ノクサストラップ専用スロット + サモナースペルスロット）、月キノコ睡眠無効化

### スクリプト

- **scripts/prefabs/teemo.lua** — キャラクター定義。主要な能力:
  - *Camouflage* — 1.5秒静止で透明化、衝突判定無効化で敵の攻撃すり抜け、`BlankOutAttacks`で敵の攻撃を0.5秒毎にブロック。解除時に攻撃速度40%UP（5秒間）。被弾時は移動速度が通常に戻る（5秒間）。騎乗中は無効
  - *Toxic Shot* — Blind Dart命中時の毒DOT（毎秒ダメージ × 4秒間、プレイヤーは30%軽減）
  - *Noxious Trap スタック管理* — 専用スロットからの罠設置（初期3個、30秒で1個回復、最大5）。スタック数・タイマーはセーブ/ロード対応
  - *Summoner Spells* — Flash（ブリンク、壁抜け対応、CD300秒）とIgnite（単体トゥルーダメージDOT + 炎上パニック、CD180秒）。`net_ushortint`でクールダウン同期、騎乗中・ゴースト状態は発動不可
  - *Mushroom Expert* — キノコのマイナスステータス無効化（`custom_stats_mod_fn`）
  - *初期インベントリ*: blind_dart
  - *サウンド*: net_eventでサーバー→クライアント通知（spwn/attack/emote/move）、talk_LPは1回再生に制御
- **scripts/prefabs/blind_dart.lua** — 遠距離武器（吹き矢タイプ、射程8-10）。命中時: 2秒ブラインド（`BlankOutAttacks`）+ 毒DOT。テーモ専用（`characterspecific`コンポーネント）。耐久力は被弾で減少（`finiteuses` + `SetIgnoreCombatDurabilityLoss`で攻撃時消費を無効化）、設定で無限も可
- **scripts/prefabs/noxious_trap.lua** — 設置型トラップ。5分の寿命、0.3秒間隔でエンティティ検出、起爆でAoEダメージ + スローデバフ。PvP時はteemoタグ以外が対象、非PvP時はplayer以外が対象。最大10個設置（超過分は古い順に削除）。1秒後にステルス化
- **scripts/prefabs/blind_effect.lua, explode_noxious_trap.lua, toxic_effect_by_teemo.lua** — ターゲットエンティティに子としてアタッチするビジュアルエフェクト（非永続、アニメーション後自動削除）
- **scripts/components/characterspecific.lua** — テーモ専用のアイテム装備制限コンポーネント（`SetOwner`, `SetStorable`, `SetComment`）
- **scripts/components/explosive_noxious_trap.lua** — トラップ爆発処理: 範囲4のAoEエンティティ検索、初撃ダメージ（`GetAttacked`）、毒DOT（毎秒 × 4秒、プレイヤー30%軽減）、50%スローデバフ（4秒間）。設置者をダメージ帰属先に使用（nil時は近くのteemoプレイヤーをフォールバック検索）
- **scripts/teemo_poison_util.lua** — 毒による食料腐敗ユーティリティ。`markTeemoPoisoned`/`unmarkTeemoPoisoned`で`loot_prefab_spawned`イベントリスナーを管理。毒DOT中に死んだ敵のドロップ食料の鮮度を設定値±15%ランダムで低下
- **scripts/widgets/noxioustrap_slot.lua** — ノクサストラップ専用インベントリスロットUI。`noxioustrapstacksdirty`イベントで表示更新、クリックでRPC送信、スタック0でグレーアウト
- **scripts/widgets/summoner_spell_slot.lua** — サモナースペル（Flash/Ignite）用UIスロット。クールダウン表示、ホバーアニメーション、Flashはクリック後にレティクル表示→左クリックで発動のターゲティングモード
- **scripts/speech_teemo.lua** — キャラクターセリフ文字列（約46KB）

### アセット

- **anim/** — アニメーションZIPアーカイブ（キャラクター、アイテム、エフェクト）
- **images/** — テクスチャ (.tex) とアトラス (.xml) のペア。UIコンテキスト別に整理（ポートレート、アバター、インベントリアイコン、HUD、マップアイコン）
- **bigportraits/** — キャラクター選択画面の大型ポートレート
- **sound/** — FMOD サウンドバンク (.fev + .fsb)

## DST MOD開発パターン

**Prefab パターン:** 各ゲームエンティティは `fn(Sim)` 関数で定義された prefab。`Prefab("path/name", fn, assets)` で返す。

**Component パターン:** カスタムコンポーネントは `Class(function(self, inst) ... end)` を使用。メソッドは `ComponentName:Method()` で定義。

**サーバー/クライアント分離:** `common_postinit` は全クライアントで実行（ビジュアル/UI/ネットワーク変数宣言）、`master_postinit` はサーバーのみ（ゲームロジック）。サーバー専用コードは `if not TheWorld.ismastersim then return inst end` でガード。

**ネットワーク同期:** `net_byte` で数値同期（トラップスタック数）、`net_event` でイベント通知（サウンド再生）。クライアント→サーバーは `SendModRPCToServer` / `AddModRPCHandler` で処理。

**イベント駆動:** ゲームロジックはイベントに応答（`inst:ListenForEvent("eventname", callback)`）。主なイベント: `equipped`, `onattackother`, `attacked`, `death`, `ms_respawnedfromghost`, `working`, `picksomething`。

**タスクシステム:** `inst:DoPeriodicTask(interval, fn)` で繰り返し処理、`inst:DoTaskInTime(delay, fn)` で遅延実行。`task:Cancel()` でキャンセル。

**セーブ/ロード:** `inst.OnSave` / `inst.OnLoad` をオーバーライドしてカスタムデータを永続化（既存の関数をチェインで保持）。

**設定値管理:** `modinfo.lua` の `configuration_options` → `GetModConfigData()` → `GLOBAL.TEEMO_*` に展開。各スクリプトからグローバル変数として参照。

## Git ブランチ命名規則

- メインブランチ: `develop/claude`
- 機能ブランチ: `develop/claude-<機能名>` （例: `develop/claude-summoner-spells`）

## Git 操作ルール

- **コミット・プッシュは必ずユーザーに確認してから行うこと**（自動モード・プランモード等のモードに関わらず、勝手に実行しない）

## コア原則

- **シンプルさの追求**: あらゆる変更を可能な限りシンプルに保つ。コードへの影響範囲を最小限に抑える。
- **妥協の排除**: 根本原因を突き止める。一時しのぎの修正は行わない。
- **影響の最小化**: 必要な箇所のみを変更する。不必要な変更によって新たなバグを作り込まない。

## バグ・クラッシュチェック

- **複数エージェントで徹底検証すること**: コード変更のレビュー時は、複数の観点（ロジック安全性、レースコンディション、エッジケース等）を並行して検証する
- **マルチプレイ挙動の考慮**: サーバー/クライアント間の同期、他プレイヤーへの影響、ホスト/ゲスト間の差異を必ず確認する
- **DST環境固有のエッジケース**: 攻撃可能な壁、海上、ボート上、洞窟（地上↔洞窟の切り替え）での挙動を忘れずに検証する

## 備考

- コメントは英語と日本語が混在
- DST API上の制約: `FRAMES` はゲームの1フレーム時間（1/30秒）
