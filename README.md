# UnityRecShare

You can record and share your gameplay.

English | [日本語](README.ja.md)


# Supported
* iOS Only
* Without sound



# API

## void RecShare.Initialize()

Perform the initial processing. You need call before start recording.


## void RecShare.StartRecording()

Start recording.

## void RecShare.StopRecording(Action completion = null)

Stop recording.

* `completion` Called at record completion

## void RecShare.PauseRecording

Pause recording.

## void RecShare.ResumeRecording

Resume Recording.

## bool RecShare.IsRecording

if during recording, return the `true'.

## bool RecShare.IsPaused

if during pausing, return the `true'.

## void RecShare.ShowSharingModal(string text = "")

Show sharing sheet.

* `text` sharing text

## void RecShare.ShowVideoPlayer

Show video player.

## string RecShare.GetVideoFilePath

Return the recorded video file path.

## float RecShare.GetVideoDuration

Return the recorded video duration.

## Texture2D RecShare.GetScreenShot(float seconds)

Return the screen shot image.

	* `seconds` Time to take screen shot.(sec)1

## void RecShare.SetFrameInterval(int frameInterval)

Set the recording interval.
Default is `1' (recording every frame)

* `frameInterval` recording interval (frame)

## void RecShare.SetFirstImage(Texture2D tex2d, Vector2 imageSize, float displayTime[, Color bgColor])

Set the video of the first to insert the image in `Texture2D`.
You need to run before the start of recording.

* `tex2d` Insert image
* `imageSize` Image size
* `displayTime` Display time(sec)
* `bgColor` Background color（default:`Color.black`)

> Texture2D must be readable.(`Read / Write Enabled`)

## void RecShare.SetFirstImage(string imageName, Vector2 imageSize, float displayTime[, Color bgColor])

Set the video of the first to lat the image in `Texture2D`.
You need to run before the start of recording.

* `imageName` Image name
* `imageSize` Image size
* `displayTime` Display time(sec)
* `bgColor` Background color（default:`Color.black`)

> You can set image to `Assets/RecShare/Editor/Images` or `Assets/RecShare/Editor/Images.xcassets`.
if set to `Images.xcassets`, you need to Asset Catalog format.

## void RecShare.SetLastImage(Texture2D tex2d, Vector2 imageSize, float displayTime[, Color bgColor])

Set the video of the last to insert the image in `Texture2D`.
You need to run before the start of recording.

* `tex2d` Insert image
* `imageSize` Image size
* `displayTime` Display time(sec)
* `bgColor` Background color（default:`Color.black`)

> Texture2D must be readable.(`Read / Write Enabled`)

## void RecShare.SetLastImage(string imageName, Vector2 imageSize, float displayTime[, Color bgColor])

Set the video of the last to lat the image in `Texture2D`.
You need to run before the start of recording.

* `imageName` Image name
* `imageSize` Image size
* `displayTime` Display time(sec)
* `bgColor` Background color（default:`Color.black`)

> You can set image to `Assets/RecShare/Editor/Images` or `Assets/RecShare/Editor/Images.xcassets`.
if set to `Images.xcassets`, you need to Asset Catalog format.

## void RecShare.SetOverlayImage(Texture2D tex2d, Vector2 imageSize, RecShare.Alignment alignment)

Set the image superimposed on the video in Texture2D.
You need to run before the start of recording.
If you use the `SetOverlayImage`, CPU consumption during the recording will increase.

* `tex2d` Overlay image
* `imageSize` Image size
* `alignment ` Image alignment

> Texture2D must be readable.(`Read / Write Enabled`)

## void RecShare.SetOverlayImage(string imageName, Vector2 imageSize, RecShare.Alignment alignment)

Set the image superimposed on the video in image name.
You need to run before the start of recording.
If you use the `SetOverlayImage`, CPU consumption during the recording will increase.

* `imageName` Image name
* `imageSize` Image size
* `alignment ` Image alignment

> You can set image to `Assets/RecShare/Editor/Images` or `Assets/RecShare/Editor/Images.xcassets`.
if set to `Images.xcassets`, you need to Asset Catalog format.

