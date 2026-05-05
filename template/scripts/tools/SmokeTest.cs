using Godot;

/// <summary>
/// Smoke test: loads the main scene, runs ~120 frames, then quits.
/// Errors in autoload _Ready() or scene loading will cause Godot to emit
/// errors on stderr or crash with a non-zero exit.
/// Uses run/main_scene from project.godot so this works without modification.
/// </summary>
public partial class SmokeTest : SceneTree
{
    private int _frameCount;
    private const int MaxFrames = 120;

    public override void _Initialize()
    {
        string mainScenePath = ProjectSettings
            .GetSetting("application/run/main_scene", "")
            .AsString();

        if (string.IsNullOrEmpty(mainScenePath))
        {
            GD.Print("SMOKE TEST FAIL: run/main_scene not set in project.godot");
            Quit(1);
            return;
        }

        var scene = GD.Load<PackedScene>(mainScenePath);
        if (scene == null)
        {
            GD.Print($"SMOKE TEST FAIL: could not load {mainScenePath}");
            Quit(1);
            return;
        }

        var instance = scene.Instantiate();
        Root.AddChild(instance);
    }

    public override bool _Process(double delta)
    {
        _frameCount++;
        if (_frameCount >= MaxFrames)
        {
            GD.Print($"SMOKE TEST PASS: {_frameCount} frames completed");
            Quit(0);
            return true;
        }
        return false;
    }
}
