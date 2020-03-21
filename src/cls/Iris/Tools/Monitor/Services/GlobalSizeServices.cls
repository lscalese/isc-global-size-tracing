Class Iris.Tools.Monitor.Services.GlobalSizeServices
{

/// Return the size in MB of a global<br/>
/// It's a calculate value by %Library.GlobalEdit (not a stored value in Iris.Tools.Monitor.Data.GlobalSize).
/// <b>database</b> must be a direcotry not a database name.<br/>
/// call <b>getDbDirectory</b> to retrieve the database directory from a database name.<br/>
/// 
ClassMethod getAllocatedInMB(database As %String, global As %String) As %Float
{
	Set allocated = 0
	Set sc = ##class(%Library.GlobalEdit).GetGlobalSize(.database,.global,.allocated,,1)
	If $$$ISERR(sc) $$$ThrowStatus(sc)
	Return allocated
}

/// Get a list of all database on this system.
ClassMethod getAllDB() As %List
{
	Return ##class(Iris.Tools.Monitor.Services.DBSizeServices).getAllDB()
}

/// Update GlobalSize table for all databases and globals.
ClassMethod updateAllDBGlobalSize() As %Status
{
	Return ..updateDatabasesGlobalSize(..getAllDB())
}

/// Usefull method to retrieve size of global data, following filters : <br/><ul>
/// <li><b>database</b>: database directory ("*" are allowed for all databases).</li>
/// <li><b>global</b>: global name (with the "^" character, "*" are allowed for all globals)</li>
/// <li><b>recordType</b>: possible value Day,Week,Month,Year (see Iris.Tools.Monitor.Data.GlobalSize doc for more information).</li>
/// <li><b>startDate</b>: start date in %TimeStamp format</li>
/// <li><b>endDate</b>: end date in %TimeStamp format</li>
/// </ul>
/// Return a %DynamicArray for easy use in a rest call.<br/>
ClassMethod get(database As %String = "*", global As %String = "*", recordType As %String = "Day", startDate As %TimeStamp = { $zd($h,3)}, endDate As %TimeStamp = { $zd($h,3)}) As %DynamicArray
{
	Set startDateH = $zdh(startDate,3)
	Set endDateH = $zdh(endDate,3)
	Set tDynArray = ##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).get(.database,.global,.recordType,.startDateH,.endDateH)
	Return tDynArray
}

/// Usefull method to retrieve size of global data, following filters : <br/><ul>
/// <li><b>filename</b>: file path to export csv file.</li>
/// <li><b>database</b>: database directory ("*" are allowed for all databases).</li>
/// <li><b>global</b>: global name (with the "^" character, "*" are allowed for all globals)</li>
/// <li><b>recordType</b>: possible value Day,Week,Month,Year (see Iris.Tools.Monitor.Data.GlobalSize doc for more information).</li>
/// <li><b>startDate</b>: start date in %TimeStamp format</li>
/// <li><b>startDate</b>: start date in %TimeStamp format</li>
/// </ul>
/// Return a %DynamicArray for easy use in a rest call.<br/>
ClassMethod getAndExportToFile(filename As %String, database As %String = "*", global As %String = "*", recordType As %String = "Day", startDate As %TimeStamp = { $zd($h,3)}, endDate As %TimeStamp = { $zd($h,3)}) As %Status
{
	Set startDateH = $zdh(startDate,3)
	Set endDateH = $zdh(endDate,3)
	Set sc = ##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).exportToFile(.filename,.database,.global,.recordType,.startDateH,.endDateH)
	Return sc
}

/// Export global size to the given filename for a date.
/// It's an export for recordType "Day".
ClassMethod exportSizeToFile(filename As %String, date As %TimeStamp, recordType As %String = "Day") As %Status
{
	Set sc = $$$OK
	Set dateH = $zdh(date,3)
	Set sc = ##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).exportToFile(filename,"*","*",recordType,dateH,dateH)
	Return sc
}

/// Set a custom special variable for change decimal separator to a comma.<br/>
/// Currently this variable is used only for csv export file.
ClassMethod setDecimalPointIsComma(setFlag As %Boolean) As %Status
{
	Set %ZDecimalPointIsComma=setFlag
	Return $$$OK
}

/// Update GlobalSize table for a list of databases.
ClassMethod updateDatabasesGlobalSize(databases As %List) As %Status
{
	Set ptr = 0, sc = $$$OK
	While $Listnext(databases,ptr,database) {
		If (database'["lib") {	; temp fix (protect error with enslib)
			$$$TOE(sc,..updateDatabaseGlobalSize(database))
		}
	}
	Return sc
}

/// Update GlobalSize table for a database
ClassMethod updateDatabaseGlobalSize(database As %String) As %Status
{
	Set sc = $$$OK
	Set sizeDate = +$h
	Do ##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).clearGblListCache(database)
	Set global = ""
	For  {
		Set global = ##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).getNextGlobal(database,.global)
		Quit:global=""
		Set allocatedInMB = ..getAllocatedInMB(database,.global)
		$$$TOE(sc,..setRecordSize("Day",database,.global,.allocatedInMB,.sizeDate))
		$$$TOE(sc,..setRecordSize("Week",database,.global,.allocatedInMB,.sizeDate))
		$$$TOE(sc,..setRecordSize("Month",database,.global,.allocatedInMB,.sizeDate))
		$$$TOE(sc,..setRecordSize("Year",database,.global,.allocatedInMB,.sizeDate))
	}
	Return sc
}

/// Return all existing global in a database directory.
ClassMethod getGlobalListForDB(database As %String) As %List
{
	Return ##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).getGlobalList(.database)
}

ClassMethod setRecordSize(recordType As %String, database As %String = "", global As %String, allocatedInMB As %Float, sizeDate As %Date = {+$h}) As %Status [ Private ]
{
	Return ##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).setSize(.recordType,.database,.global,.allocatedInMB,.sizeDate)
}

/// Return the database directory for a database name.<br/>
/// deprecated use : ##class(Iris.Tools.Monitor.Services.DBSizeServices).getDbDirectory(databaseName)
ClassMethod getDbDirectory(databaseName As %String) As %String [ Deprecated ]
{
	Return ##class(Iris.Tools.Monitor.Services.DBSizeServices).getDbDirectory(databaseName)
}

ClassMethod clean(retDay As %Integer = 90, retWeek As %Integer = 24, retMonth As %Integer = -1, retYear As %Integer = -1) As %Status
{
	Return ##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).clean(retDay,retWeek,retMonth,retYear)
}

}
