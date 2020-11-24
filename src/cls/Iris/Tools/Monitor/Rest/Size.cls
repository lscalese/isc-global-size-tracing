Class Iris.Tools.Monitor.Rest.Size Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
      <Route Url="/v1/dbsize" Method="GET" Call="getDBSize"/>
      <Route Url="/v1/test" Method="GET" Call="test"/>
      <Route Url="/v1/gsize" Method="GET" Call="getGSize"/>
      <Route Url="/v1/directorybyname/:databaseName" Method="GET" Call="getDirectoryByDBName"/>
      <Route Url="/v1/alldirectory" Method="GET" Call="getAllDirectory"/>
   </Routes>
}

ClassMethod test() As %Status
{
	Write {"test":($zdt($h,3,1))}.%ToJSON()
	Return $$$OK
}

ClassMethod getDBSize() As %Status
{
	Set tSc = $$$OK
	Set directory = $Get(%request.Data("directory",1))
	Set recordType = $Get(%request.Data("recordType",1))
	Set startDate = $Get(%request.Data("startDate",1))
	Set endDate = $Get(%request.Data("endDate",1))
	
	Set:directory="" directory="*"
	Set:recordType="" recordType="Day"
	Set:startDate="" startDate=$zd($h,3)
	Set:endDate="" endDate=$zd($h,3)
	
	Set jsonResponse = ##class(Iris.Tools.Monitor.Services.DBSizeServices).get(directory,recordType,startDate,endDate)
	Write jsonResponse.%ToJSON()
	Return tSc
}

ClassMethod getGSize() As %Status
{
	Set tSc = $$$OK
	Set directory = $Get(%request.Data("directory",1))
	Set globals = $Get(%request.Data("global",1))
	Set recordType = $Get(%request.Data("recordType",1))
	Set startDate = $Get(%request.Data("startDate",1))
	Set endDate = $Get(%request.Data("endDate",1))
	
	Set:directory="" directory="*"
	Set:globals="" globals="*"
	Set:recordType="" recordType="Day"
	Set:startDate="" startDate=$zd($h,3)
	Set:endDate="" endDate=$zd($h,3)
	
	Set jsonResponse = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).get(directory,globals,recordType,startDate,endDate)
	Write jsonResponse.%ToJSON()
	Return tSc
}

ClassMethod getAllDirectory() As %Status
{
	Set tSc = $$$OK, array = [], ptr = 0
	Set directoryList = ##class(Iris.Tools.Monitor.Services.DBSizeServices).getAllDB()
	While $listnext(directoryList,ptr,directory) {
		Do array.%Push(directory)
	}
	Set jsonResponse = { "directoryList" : (array) }
	Write jsonResponse.%ToJSON()
	Return tSc
}

ClassMethod getDirectoryByDBName(databaseName As %String = "") As %Status
{
	Set tSc = $$$OK
	Set directory = ##class(Iris.Tools.Monitor.Services.DBSizeServices).getDbDirectory(databaseName)
	Set jsonResponse = { "database" : { "databaseName" : (databaseName),"directory" : (directory)}}
	Write jsonResponse.%ToJSON()
	Return tSc
}

}
