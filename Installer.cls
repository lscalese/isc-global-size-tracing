Class App.Installer
{

XData setup
{
<Manifest>
  <Default Name="SourceDir" Value="#{$system.Process.CurrentDirectory()}src"/>
  <Default Name="Namespace" Value="IRISAPP"/>
  <Default Name="app" Value="irisapp" />

  <Namespace Name="${Namespace}" Code="${Namespace}-CODE" Data="${Namespace}-DATA" Create="yes" Ensemble="no">

    <Configuration>
      <Database Name="${Namespace}-DATA" Dir="/opt/${app}/data" Create="yes" Resource="%DB_${Namespace}"/>
      <Database Name="${Namespace}-CODE" Dir="/opt/${app}/code" Create="yes" Resource="%DB_${Namespace}"/>
	    <Import File="${SourceDir}" Flags="ck" Recurse="1"/>
    </Configuration>
    <CSPApplication Url="/csp/${app}" Directory="${cspdir}${app}"  ServeFiles="1" Recurse="1" MatchRoles=":%DB_${Namespace}" AuthenticationMethods="32"
       
    />
  </Namespace>

  <Namespace Name="${Namespace}">
    <Invoke Class="Iris.Tools.Monitor.Test.UnitTestUtils" Method="SetUnitTestRoot">
      <Arg Value="/irisdev/app/src/cls/Iris/Tools/Monitor/Test/"/>
    </Invoke>
    <Invoke Class="Iris.Tools.Monitor.Tasks.UpdateSize" Method="installTask"></Invoke>
  </Namespace>

</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method. 
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

}
