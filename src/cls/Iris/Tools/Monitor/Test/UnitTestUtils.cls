Class Iris.Tools.Monitor.Test.UnitTestUtils
{

ClassMethod StartUnitTest()
{
    Do ##class(%UnitTest.Manager).RunTest(,"/nodelete")
    Quit
}

ClassMethod SetUnitTestRoot(directory As %String) As %Status
{
    Set ^UnitTestRoot=##class(%File).NormalizeDirectory(directory)
    Return $$$OK
}

}
