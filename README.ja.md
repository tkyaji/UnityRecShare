# UnityRecShare

Unityでプレイ動画を録画し、共有することができます

[English](README.md) | 日本語


# 対応状況
* iOSのみ
* 録画のみ、音声なし


# 使い方
* `RecShare.unitypackage` をインポート
* サンプルが必要な場合、`RecShareSample.unitypackage` を追加でインポート


# API

## void RecShare.Initialize()

初期処理を実行します。録画実行前に必ず実行が必要です。



## void RecShare.StartRecording()

録画を開始します。`Initialize`を実行済みである必要があります。

## void RecShare.StopRecording(Action completion = null)

録画を終了します。

* `completion` 録画終了処理が完了したタイミングで実行されます

## void RecShare.PauseRecording

録画を一時停止します

## void RecShare.ResumeRecording

`PauseRecording`で一時停止した録画を再開します

## bool RecShare.IsRecording

録画実行中の場合、`true`を返します

## bool RecShare.IsPaused

`PauseRecording`で録画を一時停止中の場合、`true`を返します

## void RecShare.ShowSharingModal(string text = "")

iOSの共有シートを表示します

* `text` 共有テキストを指定します

## void RecShare.ShowVideoPlayer

録画した動画を再生するためのプレイヤーを表示します

## string RecShare.GetVideoFilePath

録画ファイルのパスを返しします

## float RecShare.GetVideoDuration

録画時間（秒）を返します。録画実行前、実行中の場合は0を返します。

## Texture2D RecShare.GetScreenShot(float seconds)

指定した時間（秒）のフレームの画像を取り出し、Texture2Dにして返します。
なお、録画時間を超える値を指定した場合、最後のフレームが返却されます。

* `seconds` 録画の何フレーム目を取得するか時間（秒）で指定

## void RecShare.SetFrameInterval(int frameInterval)

録画する間隔を指定します。
デフォルトは`1`（毎フレーム録画）です。

* `frameInterval` 録画する間隔（フレーム数）

## void RecShare.SetFirstImage(Texture2D tex2d, Vector2 imageSize, float displayTime[, Color bgColor])

動画の最初に差し込む画像を`Texture2D`で設定します。
録画開始前に実行する必要があります。

* `tex2d` 差し込む画像
* `imageSize` 画像のサイズ
* `displayTime` 画像を表示する時間（秒）
* `bgColor` 背景色（デフォルト:`Color.black`)


> 指定するTexture2Dは、読み取り可能（`Read / Write Enabled`）である必要があります

## void RecShare.SetFirstImage(string imageName, Vector2 imageSize, float displayTime[, Color bgColor])

動画の最初に差し込む画像を画像名で設定します。
録画開始前に実行する必要があります。

* `imageName` 差し込む画像の画像名
* `imageSize` 画像のサイズ
* `displayTime` 画像を表示する時間（秒）
* `bgColor` 背景色（デフォルト:`Color.black`)

> 画像は`Assets/RecShare/Editor/Images`、または`Assets/RecShare/Editor/Images.xcassets`に配置します。
`Images.xcassets`の場合、Asset Catalog形式で配置します。
配置した画像を`imageName`引数で指定します。

## void RecShare.SetLastImage(Texture2D tex2d, Vector2 imageSize, float displayTime[, Color bgColor])

動画の最後に差し込む画像を`Texture2D`で設定します。
録画開始前に実行する必要があります。

* `tex2d` 差し込む画像
* `imageSize` 画像のサイズ
* `displayTime` 画像を表示する時間（秒）
* `bgColor` 背景色（デフォルト:`Color.black`)


> 指定するTexture2Dは、読み取り可能（`Read / Write Enabled`）である必要があります

## void RecShare.SetLastImage(string imageName, Vector2 imageSize, float displayTime[, Color bgColor])

動画の最後に差し込む画像を画像名で設定します。
録画開始前に実行する必要があります。

* `imageName` 差し込む画像の画像名
* `imageSize` 画像のサイズ
* `displayTime` 画像を表示する時間（秒）
* `bgColor` 背景色（デフォルト:`Color.black`)

> 画像は`Assets/RecShare/Editor/Images`、または`Assets/RecShare/Editor/Images.xcassets`に配置します。
`Images.xcassets`の場合、Asset Catalog形式で配置します。
配置した画像を`imageName`引数で指定します。

## void RecShare.SetOverlayImage(Texture2D tex2d, Vector2 imageSize, RecShare.Alignment alignment)

動画に重ねる画像をTexture2Dで指定します。
録画開始前に実行する必要があります。
`SetOverlayImage`を使用した場合、録画中のCPU消費が増加します。

* `tex2d` 重ねる画像
* `imageSize` 画像のサイズ
* `alignment ` 画像を表示する位置

> 指定するTexture2Dは、読み取り可能（`Read / Write Enabled`）である必要があります

## void RecShare.SetOverlayImage(string imageName, Vector2 imageSize, RecShare.Alignment alignment)

動画に重ねる画像を画像名で指定します。
録画開始前に実行する必要があります。
`SetOverlayImage`を使用した場合、録画中のCPU消費が増加します。

* `imageName` 重ねる画像の画像名
* `imageSize` 画像のサイズ
* `alignment ` 画像を表示する位置

> 画像は`Assets/RecShare/Editor/Images`、または`Assets/RecShare/Editor/Images.xcassets`に配置します。
`Images.xcassets`の場合、Asset Catalog形式で配置します。
配置した画像を`imageName`引数で指定します。
