using Godot;

public static class TestHelper
{
    /// <summary>
    /// Sets up an OfflineMultiplayerPeer so that multiplayer.IsServer() returns true
    /// and multiplayer.GetUniqueId() returns 1. Required for testing code guarded by
    /// multiplayer.IsServer() in unit tests.
    /// </summary>
    public static void SetupOfflineMultiplayer(Node testSuite)
    {
        if (testSuite.Multiplayer is null)
            return;
        var peer = new OfflineMultiplayerPeer();
        testSuite.Multiplayer.MultiplayerPeer = peer;
    }
}
