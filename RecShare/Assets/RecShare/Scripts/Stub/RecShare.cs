#if !UNITY_IOS || UNITY_EDITOR

using UnityEngine;
using System;

public class RecShare {

	public enum Alignment {
		TopCenter = 1,
		TopLeft,
		TopRight,
		BottomCenter,
		BottomLeft,
		BottomRight,
	}


	public static void Initialize() {
		Debug.Log("Initialize");
	}

	public static void StartRecording() {
		Debug.Log("StartRecording");
	}

	public static void StopRecording(Action completion = null) {
		Debug.Log("StopRecording");
	}

	public static void PauseRecording() {
		Debug.Log("PauseRecording");
	}

	public static void ResumeRecording() {
		Debug.Log("ResumeRecording");
	}

	public static bool IsRecording() {
		Debug.Log("IsRecording");
		return false;
	}

	public static bool IsPaused() {
		Debug.Log("IsPaused");
		return false;
	}

	public static void ShowSharingModal(string text = "") {
		Debug.Log("ShowSharingModal : " + text);
	}

	public static void ShowVideoPlayer() {
		Debug.Log("ShowVideoPlayer");
	}

	public static string GetVideoFilePath() {
		Debug.Log("GetVideoFilePath");
		return null;
	}

	public static float GetVideoDuration() {
		Debug.Log("GetVideoDuration");
		return 0f;
	}

	public static Texture2D GetScreenShot(float seconds) {
		Debug.Log("GetScreenShot : " + seconds);
		return null;
	}

	public static void SetFrameInterval(int frameInterval) {
		Debug.Log("SetFrameInterval : " + frameInterval);
	}

	public static void SetFirstImage(Texture2D tex2d, Vector2 imageSize, float displayTime) {
		Debug.Log("SetFirstImage");
	}

	public static void SetFirstImage(Texture2D tex2d, Vector2 imageSize, float displayTime, Color bgColor) {
		Debug.Log("SetFirstImage");
	}

	public static void SetFirstImage(string imageName, Vector2 imageSize, float displayTime, Color bgColor) {
		Debug.Log("SetFirstImage");
	}

	public static void SetLastImage(Texture2D tex2d, Vector2 imageSize, float displayTime) {
		Debug.Log("SetLastImage");
	}

	public static void SetLastImage(Texture2D tex2d, Vector2 imageSize, float displayTime, Color bgColor) {
		Debug.Log("SetLastImage");
	}

	public static void SetLastImage(string imageName, Vector2 imageSize, float displayTime, Color bgColor) {
		Debug.Log("SetLastImage");
	}

	public static void SetOverlayImage(Texture2D tex2d, Vector2 imageSize, RecShare.Alignment alignment) {
		Debug.Log("SetOverlayImage");
	}

	public static void SetOverlayImage(string imageName, Vector2 imageSize, RecShare.Alignment alignment) {
		Debug.Log("SetOverlayImage");
	}

}

#endif
