using GdUnit4;
using static GdUnit4.Assertions;

/// <summary>
/// Starter gdUnit4 test suite. Confirms the test harness is wired up correctly
/// in a freshly generated project (the test host, adapter, and .runsettings all
/// resolve and `dotnet test` discovers and runs at least one test). Replace or
/// expand this with real tests as your project grows.
/// </summary>
[TestSuite]
public partial class ExampleTest
{
    [TestCase]
    public void Scaffold_TestHarness_Runs()
    {
        AssertBool(true).IsTrue();
    }
}
