Class App.Installer
{

XData setup
{
<Manifest>
  <Default Name="SourceDir" Value="#{$system.Process.CurrentDirectory()}src"/>
  <Default Name="Namespace" Value="IRISAPP"/>
  <Default Name="app" Value="irisapp" />
  <Default Name="restappname" Value="globaltracing" />
  <Default Name="restappurl" Value="/csp/${restappname}" />
  
  <Namespace Name="${Namespace}" Code="${Namespace}-CODE" Data="${Namespace}-DATA" Create="yes" Ensemble="no">
    <Configuration>
      <Database Name="${Namespace}-DATA" Dir="/opt/${app}/data" Create="yes" Resource="%DB_${Namespace}"/>
      <Database Name="${Namespace}-CODE" Dir="/opt/${app}/code" Create="yes" Resource="%DB_${Namespace}"/>
	    <Import File="${SourceDir}" Flags="ck" Recurse="1"/>
    </Configuration>
    <CSPApplication Url="${restappurl}" Directory="${cspdir}${restappname}"  ServeFiles="1" Recurse="1" MatchRoles=":%DB_${Namespace}" AuthenticationMethods="32"/>
  </Namespace>

  <Namespace Name="${Namespace}">
    <Invoke Class="Iris.Tools.Monitor.Tasks.UpdateSize" Method="installTask"></Invoke>
  </Namespace>

  <Invoke Class="App.Installer" Method="fixDispatchClass">
    <Arg Value="${restappurl}"/>
  </Invoke>

</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method. 
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

ClassMethod fixDispatchClass(cspApp As %String) As %Status
{
	Set tSc = $$$OK, ns = $Namespace
	Zn "%SYS"
	Try {
		$$$TOE(tSc,##class(Security.Applications).Get(cspApp,.p))
		Set p("DispatchClass")="Iris.Tools.Monitor.Rest.Size"
		$$$TOE(tSc,##class(Security.Applications).Modify(cspApp,.p))
	} Catch (ex) {
		Set tSc = ex.AsStatus()
	}
	Zn ns
	Return tSc
}

}
