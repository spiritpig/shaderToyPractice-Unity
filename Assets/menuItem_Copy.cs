using UnityEngine;
using UnityEditor;
using System.IO;

public class MenuItem_Copy {

	[MenuItem("Assets/QuickOp/copy %#v")]
	private static void CopyFile()
	{
		if(Selection.activeObject != null)
		{
			string path = AssetDatabase.GetAssetOrScenePath(Selection.activeObject);
			Debug.Log(path);

			string dir = Path.GetDirectoryName(path);
			string filename = Path.GetFileNameWithoutExtension(path);
			string ext = Path.GetExtension(path);
			FileUtil.CopyFileOrDirectory(path, dir + "/" + filename + "_Copy" + ext);
		}

	}
}
