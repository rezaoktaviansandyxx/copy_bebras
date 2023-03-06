using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Nuke.Common;
using Nuke.Common.Execution;
using Nuke.Common.IO;
using Nuke.Common.ProjectModel;
using Nuke.Common.Tooling;
using Nuke.Common.Utilities.Collections;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;
using static Nuke.Common.EnvironmentInfo;
using static Nuke.Common.IO.FileSystemTasks;
using static Nuke.Common.IO.PathConstruction;
using static Nuke.Common.IO.HttpTasks;
using static Nuke.Common.Tools.Git.GitTasks;
using static SimpleExec.Command;
using System.IO.Compression;

[UnsetVisualStudioEnvironmentVariables]
class Build : NukeBuild
{
    /// Support plugins are available for:
    ///   - JetBrains ReSharper        https://nuke.build/resharper
    ///   - JetBrains Rider            https://nuke.build/rider
    ///   - Microsoft VisualStudio     https://nuke.build/visualstudio
    ///   - Microsoft VSCode           https://nuke.build/vscode

    public static int Main() => Execute<Build>(x => x.FlutterClean);

    string Configuration => Environment.GetEnvironmentVariable("Configuration") ?? "Release";

    string iOSSDK => Environment.GetEnvironmentVariable("SDK") ?? "iphoneos";

    [Parameter]
    bool ShouldGenerateApkFromAab { get; } = true;

    [Parameter]
    readonly string FlutterPathTool;

    string _FlutterTool
    {
        get
        {
            string path;
            if (FlutterPathTool != null)
            {
                path = ToolPathResolver.GetPathExecutable(FlutterPathTool);
            }
            else
            {
                path = ToolPathResolver.GetPathExecutable("flutter");
            }
            return path;
        }
    }

    Target FlutterClean => _ => _
        .Executes(() =>
        {
            Run(_FlutterTool, new Arguments()
                .Add("clean")
                .RenderForExecution());
        });

    Target FlutterPubGet => _ => _
        .DependsOn(FlutterClean)
        .Executes(() =>
        {
            Run(_FlutterTool, new Arguments()
                .Add("pub")
                .Add("get")
                .RenderForExecution());
        });

    Target FlutterBuildRunner => _ => _
        .DependsOn(FlutterPubGet)
        .Executes(() =>
        {
            Run(_FlutterTool, new Arguments()
               .Add("packages")
               .Add("pub")
               .Add("run")
               .Add("build_runner")
               .Add("build")
               .Add("--delete-conflicting-outputs")
               .RenderForExecution());
        });

    Target BuildAndroidAab => _ => _
        .DependsOn(FlutterBuildRunner)
        .Triggers(GenerateApkFromAab)
        .Executes(async () =>
        {
            await RunAsync(_FlutterTool, new Arguments()
                .Add("build")
                .Add("appbundle")
                .RenderForExecution());

            var newFilename = $"fluxapp_v{GetAppVersion}.aab";
            RenameFile("build/app/outputs/bundle/release/app-release.aab", newFilename);
            Logger.Info("aab renamed to: {0}", newFilename);
        });

    Target GenerateApkFromAab => _ => _
        .OnlyWhenDynamic(() => ShouldGenerateApkFromAab)
        .Executes(async () =>
        {
            try
            {
                var bundletooloutput = TemporaryDirectory / "bundletooloutput";
                EnsureExistingDirectory(bundletooloutput);

                var bundletool = bundletooloutput / "bundletool.jar";
                if (!FileExists(bundletool))
                {
                    await HttpDownloadFileAsync("https://github.com/google/bundletool/releases/download/1.2.0/bundletool-all-1.2.0.jar", bundletool);
                }

                var aab = GlobFiles(RootDirectory, "build/app/outputs/bundle/release/*.aab").First();

                var apksFolder = bundletooloutput / "apks";
                var apksFile = apksFolder / "myapp.apks";
                EnsureExistingDirectory(apksFolder);

                // Disable signing using debug.keystore
                var homePath = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
                var debugKeystore = Path.Combine(homePath, ".android", "debug.keystore");
                if (File.Exists(debugKeystore))
                {
                    RenameFile(debugKeystore, "d.keystore", FileExistsPolicy.Overwrite);
                }

                await RunAsync($"java", new Arguments()
                    .Add("-jar {0}", bundletool)
                    .Add("build-apks")
                    .Add("--bundle={0}", aab)
                    .Add("--output={0}", apksFile)
                    .Add("--mode={0}", "universal")
                    .RenderForExecution());

                ZipFile.ExtractToDirectory(apksFile, apksFolder);
                var outputApk = TemporaryDirectory / $"fluxapp_v{GetAppVersion}.apk";
                MoveFile(apksFolder / "universal.apk", outputApk);
                Logger.Info("apk renamed to: {0}", outputApk);
            }
            finally
            {
                var homePath = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
                var dKeystore = Path.Combine(homePath, ".android", "d.keystore");
                if (File.Exists(dKeystore))
                {
                    RenameFile(dKeystore, "debug.keystore", FileExistsPolicy.Overwrite);
                }
            }
        });

    Target FlutterBuildiOS => _ => _
        .DependsOn(FlutterBuildRunner)
        .Triggers(GenerateIpa)
        .Executes(async () =>
        {
            await RunAsync(_FlutterTool, new Arguments()
                .Add("build")
                .Add("ios")
                .Add("--no-codesign")
                .RenderForExecution());
        });

    [Parameter]
    public SigningOption SigningOption { get; } = SigningOption.Default;

    [Parameter]
    public string SigningIdentity { get; }

    [Parameter]
    public string ProvisioningProfileUuid { get; }

    [Parameter]
    public string ProvisioningProfileName { get; }

    Target GenerateIpa => _ => _
        .Executes(async () =>
        {
            var ipaFolder = RootDirectory / "build" / "Runner";

            // Extract xcode task
            var zipFile = RootDirectory / "buildapp" / "azure-pipepline-tasks" / "Task.XcodeV5.c6c000cf745d3f0a71cba49f351932b28bddad77.zip";
            var zipXcodeFolderTask = TemporaryDirectory / Path.GetFileNameWithoutExtension(zipFile);
            if (!Directory.Exists(zipXcodeFolderTask))
            {
                ZipFile.ExtractToDirectory(zipFile, zipXcodeFolderTask);
            }

            SwitchWorkingDirectory("ios");

            var env = new Dictionary<string, string>();
            env.Add("actions", "archive");
            env.Add("configuration", Configuration);
            env.Add("sdk", iOSSDK);
            env.Add("xcWorkspacePath", RootDirectory / "ios" / "Runner.xcworkspace");
            env.Add("scheme", "Runner");
            env.Add("xcodeVersion", "default");
            env.Add("packageApp", "true");
            env.Add("archivePath", RootDirectory / "build" / "Runner.xcarchive");
            env.Add("exportPath", ipaFolder);
            env.Add("exportOptions", "auto");
            if (SigningOption == SigningOption.Default)
            {
                env.Add("signingOption", "default");
            }
            else if (SigningOption == SigningOption.Manual)
            {
                env.Add("signingOption", "manual");
                env.Add("signingIdentity", SigningIdentity);
                env.Add("provisioningProfileUuid", ProvisioningProfileUuid);
                env.Add("provisioningProfileName", ProvisioningProfileName);
            }
            Logger.Info("xcode archive env: {0}", System.Text.Json.JsonSerializer.Serialize(env));
            await RunAsync("node", new Arguments()
                .Add(zipXcodeFolderTask / "XcodeV5" / "xcode.js")
                .RenderForExecution(), configureEnvironment: (e) =>
                {
                    foreach (var item in env)
                    {
                        e.Add($"INPUT_{item.Key}", item.Value);
                    }
                });

            SwitchWorkingDirectory(RootDirectory);

            var ipa = GlobFiles(ipaFolder, "*.ipa");
            RenameFile(ipa.FirstOrDefault(), $"fluxapp_v{GetAppVersion}.ipa", FileExistsPolicy.Overwrite);
        });

    Target GenerateReleaseNotes => _ => _
        .Executes(async () =>
        {
            var gitRevTag = Git(new Arguments()
                .Add("rev-list --tags")
                .Add("--max-count={value}", "1")
                .RenderForExecution());
            var gitLatestTag = Git(new Arguments()
                .Add("describe")
                .Add("--tags {value}", gitRevTag.FirstOrDefault().Text)
                .RenderForExecution());
            await RunAsync("git-chglog", new Arguments()
                .Add("--output {value}", "release.md")
                .Add(gitLatestTag.FirstOrDefault().Text)
                .RenderForExecution());
            Logger.Info(File.ReadAllText("release.md"));
        });

    string GetAppVersion
    {
        get
        {
            var deserializer = new DeserializerBuilder()
                .WithNamingConvention(CamelCaseNamingConvention.Instance)
                .Build();

            var d = deserializer.Deserialize<Dictionary<string, object>>(File.ReadAllText("pubspec.yaml"));
            var version = d["version"].ToString();
            return version;
        }
    }
}

public enum SigningOption
{
    Default,
    Manual,
}