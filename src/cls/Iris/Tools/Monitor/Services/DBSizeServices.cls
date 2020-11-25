Class Iris.Tools.Monitor.Services.DBSizeServices
{

/// Get a list of all database on this system.
ClassMethod getAllDB() As %List
{
	Return ##class(Iris.Tools.Monitor.Dao.DBSizeDAO).getAllDB()
}

ClassMethod updateDBSize(mask As %String = "*") As %Status
{
	Return ##class(Iris.Tools.Monitor.Dao.DBSizeDAO).updateDBSizeInfo(mask)
}

ClassMethod updateAllDBSize() As %Status
{
	Return ##class(Iris.Tools.Monitor.Dao.DBSizeDAO).updateDBSizeInfo("*")
}

/// Usefull method to retrieve size of database, following filters : <br/><ul>
/// <li><b>database</b>: database directory ("*" are allowed for all databases).</li>
/// <li><b>recordType</b>: possible value Day,Week,Month,Year (see Iris.Tools.Monitor.Data.GlobalSize doc for more information).</li>
/// <li><b>startDate</b>: start date in %TimeStamp format</li>
/// <li><b>endDate</b>: end date in %TimeStamp format</li>
/// </ul>
/// Return a %DynamicArray for easy use in a rest call.<br/>
ClassMethod get(database As %String = "*", recordType As %String = "Day", startDate As %TimeStamp = { $zd($h,3)}, endDate As %TimeStamp = { $zd($h,3)}) As %DynamicArray
{
	Set startDateH = $zdh(startDate,3)
	Set endDateH = $zdh(endDate,3)
	Set tDynArray = ##class(Iris.Tools.Monitor.Dao.DBSizeDAO).get(.database,.recordType,.startDateH,.endDateH)
	Return tDynArray
}

/// Usefull method to retrieve size of database, following filters are available : <br/><ul>
/// <li><b>filename</b>: file path to export csv file.</li>
/// <li><b>database</b>: database directory ("*" are allowed for all databases).</li>
/// / <li><b>recordType</b>: possible value Day,Week,Month,Year (see Iris.Tools.Monitor.Data.GlobalSize doc for more information).</li>
/// <li><b>startDate</b>: start date in %TimeStamp format</li>
/// <li><b>startDate</b>: start date in %TimeStamp format</li>
/// </ul>
/// Return a %DynamicArray for easy use in a rest call.<br/>
ClassMethod getAndExportToFile(filename As %String, database As %String = "*", recordType As %String = "Day", startDate As %TimeStamp = { $zd($h,3)}, endDate As %TimeStamp = { $zd($h,3)}) As %Status
{
	Set startDateH = $zdh(startDate,3)
	Set endDateH = $zdh(endDate,3)
	Set sc = ##class(Iris.Tools.Monitor.Dao.DBSizeDAO).exportToFile(.filename,.database,.recordType,.startDateH,.endDateH)
	Return sc
}

/// Export size to the given filename for a date.
ClassMethod exportSizeToFile(filename As %String, date As %TimeStamp, recordType As %String = "Day") As %Status
{
	Set sc = $$$OK
	Set dateH = $zdh(date,3)
	Set sc = ##class(Iris.Tools.Monitor.Dao.DBSizeDAO).exportToFile(filename,"*",recordType,dateH,dateH)
	Return sc
}

/// Return the database directory for a database name.
ClassMethod getDbDirectory(databaseName As %String) As %String
{
	Set ns = $namespace, dbDirectory = ""
	Try {
		Set $namespace = "%SYS"
		Set dbDirectory = ##class(Config.Databases).GetDirectory(databaseName)
		Set $namespace = ns
	}Catch(ex) {
		Set $namespace = ns
		Throw ex
	}
	Return dbDirectory
}

ClassMethod clean(retDay As %Integer = 90, retWeek As %Integer = 24, retMonth As %Integer = -1, retYear As %Integer = -1) As %Status
{
	Return ##class(Iris.Tools.Monitor.Dao.DBSizeDAO).clean(retDay,retWeek,retMonth,retYear)
}

}
