using System;
using System.IO;
using UnityEngine;

namespace CatchGoose.Editor
{
    // Resolve from Assets rather than the editor's working directory.
    public static class GooseWorkspace
    {
        public const string ProjectName = "catch-big-goose";
        public static string Root
        {
            get
            {
                var directory = new DirectoryInfo(Application.dataPath);
                while (directory != null)
                {
                    if (File.Exists(Path.Combine(directory.FullName, "workspace.json")))
                        return directory.FullName;
                    directory = directory.Parent;
                }
                throw new InvalidOperationException("Cannot locate catch-big-goose workspace.json above Assets");
            }
        }
        public static string WeChatProject => Path.Combine(Root, "builds/catch-big-goose-wechat");
    }
}
