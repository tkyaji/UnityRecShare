#if UNITY_IOS
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using System.IO;
using System.Linq;


namespace RecShare {
	public class RecSharePostProcessBuild {

		[PostProcessBuild]
		public static void OnPostProcessBuild(BuildTarget buildTarget, string path) {
			
			copyAssetCatalogFiles("./Assets/RecShare/Editor/Images.xcassets",
			                      Path.Combine(path, "Unity-iPhone/Images.xcassets"));


			string projPath = path + "/Unity-iPhone.xcodeproj/project.pbxproj";

			PBXProject proj = new PBXProject();
			proj.ReadFromString(File.ReadAllText(projPath));
			string target = proj.TargetGuidByName("Unity-iPhone");

			var toImageDir = Path.Combine(path, "Libraries/RecShare/Images");
			if (!Directory.Exists(toImageDir)) {
				Directory.CreateDirectory(toImageDir);
			}

			var dirInfo = new DirectoryInfo("./Assets/RecShare/Editor/Images");
			foreach (FileInfo fileInfo in dirInfo.GetFiles()) {
				if (fileInfo.Name.StartsWith(".") || fileInfo.Name.EndsWith(".meta") || fileInfo.Name.EndsWith(".txt")) {
					continue;
				}
				copyFileOrDirectory(fileInfo.FullName, Path.Combine(toImageDir, fileInfo.Name));

				var f = Path.Combine("Libraries/RecShare/Images", fileInfo.Name);
				proj.AddFileToBuild(target, proj.AddFile(f, f, PBXSourceTree.Source));
			}

			File.WriteAllText(projPath, proj.WriteToString());
		}

		private static void copyAssetCatalogFiles(string srcPath, string dstPath) {
			foreach (var srcDir in Directory.GetDirectories(srcPath)) {
				var pathArr = srcDir.Split(Path.DirectorySeparatorChar);
				var dirName = pathArr.Last();
				var dstDir = Path.Combine(dstPath, dirName);
				if (!Directory.Exists(dstDir)) {
					Directory.CreateDirectory(dstDir);
				}
				foreach (var file in Directory.GetFiles(srcDir)) {
					var fileName = Path.GetFileName(file);
					if (fileName.StartsWith(".") || fileName.EndsWith(".meta") || fileName.EndsWith(".txt")) {
						continue;
					}
					var filePath = Path.Combine(dstDir, fileName);
					if (File.Exists(filePath)) {
						File.Delete(filePath);
					}
					File.Copy(file, filePath);
				}
			}
		}

		private static void copyFileOrDirectory(string fromPath, string toPath) {
			if (File.Exists(toPath)) {
				File.Delete(toPath);

			} else if (Directory.Exists(toPath)) {
				Directory.Delete(toPath, true);
			}

			if (File.Exists(fromPath)) {
				File.Copy(fromPath, toPath);

			} else if (Directory.Exists(fromPath)) {
				Directory.CreateDirectory(toPath);

				foreach (string name in Directory.GetFiles(fromPath)) {
					if (name.StartsWith(".") || name.EndsWith(".meta") || name.EndsWith(".txt")) {
						continue;
					}
					FileInfo fInfo = new FileInfo(name);

					copyFileOrDirectory(fInfo.FullName, Path.Combine(toPath, fInfo.Name));
				}
				foreach (string name in Directory.GetDirectories(fromPath)) {
					if (name.StartsWith(".")) {
						continue;
					}
					DirectoryInfo dInfo = new DirectoryInfo(name);

					copyFileOrDirectory(dInfo.FullName, Path.Combine(toPath, dInfo.Name));
				}
			}
		}
	}
}

#endif
