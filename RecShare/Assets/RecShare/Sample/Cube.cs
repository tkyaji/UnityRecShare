using UnityEngine;

public class Cube : MonoBehaviour {

	private Vector3 toPosition = new Vector3(0f, 3f, 0f);

	void Update () {
		if (this.toPosition.y - transform.position.y <= 0.1f) {
			this.toPosition = new Vector3(0f, -3f, 0f);
		} else if (transform.position.y - this.toPosition.y <= 0.1f) {
			this.toPosition = new Vector3(0f, 3f, 0f);
		}
		transform.position = transform.position + this.toPosition * 1f * Time.deltaTime;
		transform.Rotate (new Vector3 (Time.deltaTime * 30f, 10f, 5f));
	}
}
