Class Iris.Tools.Monitor.Tasks.Projection Extends %Projection.AbstractProjection
{

ClassMethod CreateProjection(classname As %String, ByRef parameters As %String, modified As %String, qstruct) As %Status
{
    New $namespace
    Set oldNs = $namespace
    Set $namespace = "%SYS"
    set webName = "/csp/globaltracing"
    Quit:##class(Security.Applications).Exists(webName) $$$OK
    set webProperties("NameSpace") = oldNs
    set webProperties("Enabled") = 1
    set webProperties("CSPZENEnabled") = 1
    set webProperties("AutheEnabled") = 64
    set webProperties("iKnowEnabled") = 0
    set webProperties("DeepSeeEnabled") = 0
    Set webProperties("DispatchClass")="Iris.Tools.Monitor.Rest.Size"
    Set webProperties("MatchRoles")=":%DB_%DEFAULT"
    set sc = ##class(Security.Applications).Create(webName, .webProperties)
    write "Web application "_webName_" creation status : ", $SYSTEM.Status.GetOneErrorText(sc),! 
	QUIT $$$OK
}

ClassMethod RemoveProjection(classname As %String, ByRef parameters As %String, recompile As %Boolean, modified As %String, qstruct) As %Status
{
    New $namespace
    Set $namespace = "%SYS"
    set webName = "/csp/globaltracing"
    Quit:'##class(Security.Applications).Exists(webName) $$$OK
    Do ##class(Security.Applications).Delete(webName)
	QUIT $$$OK
}

}
