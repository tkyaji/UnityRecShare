using UnityEngine;
using UnityEngine.UI;

public class Sample : MonoBehaviour {

	[SerializeField]
	private Button StartButton;

	[SerializeField]
	private Button StopButton;

	[SerializeField]
	private Button PauseButton;

	[SerializeField]
	private Button ResumeButton;

	[SerializeField]
	private Button PlayButton;

	[SerializeField]
	private Button ShareButton;

	[SerializeField]
	private GameObject ScreenShotRawImageGO;


	void Start() {
		RecShare.Initialize();

		RecShare.SetFirstImage("title", new Vector2(320f, 67f), 2f, Color.white);
		RecShare.SetLastImage("title", new Vector2(320f, 67f), 2f, Color.white);
		RecShare.SetOverlayImage("logo", new Vector2(300f, 30f), RecShare.Alignment.BottomRight);
	}

	void Update() {
		Debug.Log("duration : " + RecShare.GetVideoDuration());
		Debug.Log("path : " + RecShare.GetVideoFilePath());
		Debug.Log("recording : " + RecShare.IsRecording());
		Debug.Log("paused : " + RecShare.IsPaused());
	}

	public void StartButtonClick() {
		RecShare.StartRecording();

		this.StartButton.interactable = false;
		this.StopButton.interactable = true;
		this.PauseButton.interactable = true;
		this.ResumeButton.interactable = false;
		this.PlayButton.interactable = false;
		this.ShareButton.interactable = false;

		this.ScreenShotRawImageGO.SetActive(false);
		var tex2d = this.ScreenShotRawImageGO.GetComponent<RawImage>().texture;
		if (tex2d != null) {
			Destroy(tex2d);
		}
		this.ScreenShotRawImageGO.GetComponent<RawImage>().texture = null;
	}

	public void StopButtonClick() {
		RecShare.StopRecording(() => {
			float endTime = RecShare.GetVideoDuration();
			this.ScreenShotRawImageGO.GetComponent<RawImage>().texture = RecShare.GetScreenShot(endTime);
			this.ScreenShotRawImageGO.SetActive(true);

			this.StopButton.interactable = false;
			this.PauseButton.interactable = false;
			this.ResumeButton.interactable = false;
			this.StartButton.interactable = true;
			this.PlayButton.interactable = true;
			this.ShareButton.interactable = true;
		});
	}

	public void PauseButtonClick() {
		RecShare.PauseRecording();

		this.PauseButton.interactable = false;
		this.ResumeButton.interactable = true;
	}

	public void ResumeButtonClick() {
		RecShare.ResumeRecording();

		this.PauseButton.interactable = true;
		this.ResumeButton.interactable = false;
	}

	public void PlayButtonClick() {
		RecShare.ShowVideoPlayer();
	}

	public void ShareButtonClick() {
		RecShare.ShowSharingModal();
	}
}
