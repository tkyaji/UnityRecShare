#if UNITY_IOS && !UNITY_EDITOR

using UnityEngine;
using System;
using System.Runtime.InteropServices;
using AOT;


public class RecShare {

	public enum Alignment {
		TopCenter = 1,
		TopLeft,
		TopRight,
		BottomCenter,
		BottomLeft,
		BottomRight,
	}


	public class RecShareCallback {
		private Action callback;
		public RecShareCallback(Action callback) {
			this.callback = callback;
		}
		public void Invoke() {
			if (this.callback != null) {
				this.callback.Invoke();
			}
		}
	}

	delegate void CompletionDelegate(IntPtr callbackPtr, bool ret);

	[MonoPInvokeCallback(typeof(CompletionDelegate))]
	private static void csCompletion(IntPtr callbackPtr, bool ret) {
		GCHandle handle = (GCHandle)callbackPtr;
		var callback = (RecShareCallback)handle.Target;
		callback.Invoke();
		handle.Free();

	}

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_initialize();

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_startRecoding();

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_stopRecording(IntPtr instance, CompletionDelegate completion);

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_pauseRecording();

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_resumeRecording();

	[DllImport("__Internal")]
	private static extern bool _RecSharePlugin_isRecording();

	[DllImport("__Internal")]
	private static extern bool _RecSharePlugin_isPaused();

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_showSharingModal(string text);

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_showVideoPlayer();

	[DllImport("__Internal")]
	private static extern string _RecSharePlugin_getVideoFilePath();

	[DllImport("__Internal")]
	private static extern float _RecSharePlugin_getVideoDuration();

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_getScreenShotImage(float seconds, out IntPtr byteArrPtr, out int size);

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_setFrameInterval(int frameInterval);

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_setFirstImage_data(
		byte[] bytes, int length, float width, float height, float r, float g, float b, float displayTime);

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_setFirstImage_imageName(
		string imageName, float width, float height, float r, float g, float b, float displayTime);

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_setLastImage_data(
		byte[] bytes, int length, float width, float height, float r, float g, float b, float displayTime);

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_setLastImage_imageName(
		string imageName, float width, float height, float r, float g, float b, float displayTime);

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_setOverlayImage_data(byte[] bytes, int length, float width, float height, int alignment);

	[DllImport("__Internal")]
	private static extern void _RecSharePlugin_setOverlayImage_imageName(string imageName, float width, float height, int alignment);



	public static void Initialize() {
		_RecSharePlugin_initialize();
	}

	public static void StartRecording() {
		_RecSharePlugin_startRecoding();
	}

	public static void StopRecording(Action completion = null) {
		var callback = new RecShareCallback(completion);
		IntPtr callbackPtr = (IntPtr)GCHandle.Alloc(callback);
		_RecSharePlugin_stopRecording(callbackPtr, csCompletion);
	}

	public static void PauseRecording() {
		_RecSharePlugin_pauseRecording();
	}

	public static void ResumeRecording() {
		_RecSharePlugin_resumeRecording();
	}

	public static bool IsRecording() {
		return _RecSharePlugin_isRecording();
	}

	public static bool IsPaused() {
		return _RecSharePlugin_isPaused();
	}

	public static void ShowSharingModal(string text = "") {
		_RecSharePlugin_showSharingModal(text);
	}

	public static void ShowVideoPlayer() {
		_RecSharePlugin_showVideoPlayer();
	}

	public static string GetVideoFilePath() {
		return _RecSharePlugin_getVideoFilePath();
	}

	public static float GetVideoDuration() {
		return _RecSharePlugin_getVideoDuration();
	}

	public static Texture2D GetScreenShot(float seconds) {
		IntPtr byteArrPtr = IntPtr.Zero;
		int size = 0;

		_RecSharePlugin_getScreenShotImage(seconds, out byteArrPtr, out size);

		byte[] arr = new byte[size];
		Marshal.Copy(byteArrPtr, arr, 0, size);

		var tex2d = new Texture2D(Screen.width, Screen.height);
		tex2d.LoadImage(arr);

		return tex2d;
	}

	public static void SetFrameInterval(int frameInterval) {
		_RecSharePlugin_setFrameInterval(frameInterval);
	}

	public static void SetFirstImage(Texture2D tex2d, Vector2 imageSize, float displayTime) {
		SetFirstImage(tex2d, imageSize, displayTime, Color.black);
	}

	public static void SetFirstImage(Texture2D tex2d, Vector2 imageSize, float displayTime, Color bgColor) {
		byte[] bytes = tex2d.EncodeToPNG();
		_RecSharePlugin_setFirstImage_data(bytes, bytes.Length, imageSize.x, imageSize.y, bgColor.r, bgColor.g, bgColor.b, displayTime);
	}

	public static void SetFirstImage(string imageName, Vector2 imageSize, float displayTime, Color bgColor) {
		_RecSharePlugin_setFirstImage_imageName(imageName, imageSize.x, imageSize.y, bgColor.r, bgColor.g, bgColor.b, displayTime);
	}

	public static void SetLastImage(Texture2D tex2d, Vector2 imageSize, float displayTime) {
		SetLastImage(tex2d, imageSize, displayTime, Color.black);
	}

	public static void SetLastImage(Texture2D tex2d, Vector2 imageSize, float displayTime, Color bgColor) {
		byte[] bytes = tex2d.EncodeToPNG();
		_RecSharePlugin_setLastImage_data(bytes, bytes.Length, imageSize.x, imageSize.y, bgColor.r, bgColor.g, bgColor.b, displayTime);
	}

	public static void SetLastImage(string imageName, Vector2 imageSize, float displayTime, Color bgColor) {
		_RecSharePlugin_setLastImage_imageName(imageName, imageSize.x, imageSize.y, bgColor.r, bgColor.g, bgColor.b, displayTime);
	}

	public static void SetOverlayImage(Texture2D tex2d, Vector2 imageSize, RecShare.Alignment alignment) {
		byte[] bytes = tex2d.EncodeToPNG();
		_RecSharePlugin_setOverlayImage_data(bytes, bytes.Length, imageSize.x, imageSize.y, (int)alignment);
	}

	public static void SetOverlayImage(string imageName, Vector2 imageSize, RecShare.Alignment alignment) {
		_RecSharePlugin_setOverlayImage_imageName(imageName, imageSize.x, imageSize.y, (int)alignment);
	}

}

#endif
