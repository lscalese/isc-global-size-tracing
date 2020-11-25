Class Iris.Tools.Monitor.Dao.GlobalSizeDAO
{

/// Return a list of global for a database directory.
ClassMethod getGlobalList(database As %String) As %List
{
	Set gblList = "", gbl = ""
	Do ..clearGblListCache(database)
	For  {
		Set gbl = ..getNextGlobal(.database,gbl)
		w database, gbl,!
		Quit:gbl=""
		Set $List(gblList,$i(i))=gbl
	}
	Return gblList
}

/// Expression for iterate on existing global on a database.
ClassMethod getNextGlobal(database As %String, gbl As %String) As %String
{
	; $Order(^$["^^"_database]GLOBAL(gbl))	;broken
	Return:$Data(^||tmpGlobalList(database)) $Order(^||tmpGlobalList(database,gbl))
	Set tStatement = ##class(%SQL.Statement).%New()
	Set sc = tStatement.%PrepareClassQuery("%SYS.GlobalQuery","DirectoryList")
	If $$$ISERR(sc) $$$ThrowStatus(sc)
	Set tResult = tStatement.%Execute(.database)
	If (tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) $$$ThrowStatus($$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message)) 
	While tResult.%Next() {
		Set ^||tmpGlobalList(database,tResult.%Get("Name"))=""
	}
	Kill tResult,tStatement
	Return $Order(^||tmpGlobalList(database,gbl))
}

ClassMethod clearGblListCache(database As %String) As %Status
{
	Kill ^||tmpGlobalList(database)
	Return $$$OK
}

/// Insert or update a globalSize record.
ClassMethod setSize(recordType As %String, database As %String, global As %String, allocatedInMB As %Float, sizeDate As %Date = {+$h}) As %Status
{
	Set uHlp =##class(Iris.Tools.Monitor.Data.GlobalSize).cmUHlpGet(.recordType,.sizeDate)
	Set sizeRecord = ##class(Iris.Tools.Monitor.Data.GlobalSize).uniqueIOpen(.uHlp,.global,.database,.recordType)
	Set:'$Isobject(sizeRecord) sizeRecord = ##class(Iris.Tools.Monitor.Data.GlobalSize).%New()
	Set sizeRecord.recordType = recordType
	Set sizeRecord.database = database
	Set sizeRecord.global = global
	Set sizeRecord.allocatedInMB = allocatedInMB
	Set sizeRecord.sizeDate = sizeDate
	Set sc = sizeRecord.%Save()
	Set sizeRecord = ""
	return sc
}

ClassMethod getTopGlobals(top As %Integer, database As %String, recordType As %String = "Day") As %List
{
	Set tSql = "SELECT sql_global "
    			_"FROM Iris_Tools_Monitor_Data.GlobalSize "
    			_"WHERE database = ? "
    			_"and recordType = ? "
				_"order by uHLP DESC, allocatedInMB DESC"

	Set tStatement = ##class(%SQL.Statement).%New()
	Set sc = tStatement.%Prepare( tSql )
	
	Set tResult = tStatement.%Execute(.database,.recordType)
	If (tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) $$$ThrowStatus($$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message)) 

	Set list = "", cnt = 0

	While tResult.%Next() {
		Set $List(list, $Increment(cnt) ) = tResult.%Get("sql_global")
		Quit:cnt=top
	}

	Return list
}

/// Usefull method to retrieve size of global data, following filters : <br/><ul>
/// <li><b>database</b>: database directory ("*" are allowed for all databases).</li>
/// <li><b>global</b>: global name (with the "^" character, "*" are allowed for all globals)</li>
/// <li><b>recordType</b>: possible value Day,Week,Month,Year</li>
/// <li><b>startDate</b>: start date in %Date format</li>
/// <li><b>endDate</b>: end date in %Date format</li>
/// </ul>
ClassMethod get(database As %String, global As %String = "*", recordType As %String, startDate As %Date, endDate As %Date = {+$h}) As %DynamicArray
{
	Set response = []
	Set tStatement = ##class(%SQL.Statement).%New()
	Set sc = tStatement.%PrepareClassQuery("Iris.Tools.Monitor.Dao.GlobalSizeDAO","FilterGlobalSize")
	If $$$ISERR(sc) $$$ThrowStatus(sc)

	Set tResult = tStatement.%Execute(.database,.global,.recordType,.startDate,.endDate)
	If (tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) $$$ThrowStatus($$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message)) 
	While tResult.%Next() {
		Set tObj = ..getDTO(tResult.%Get("database"),
							tResult.%Get("global"),
							tResult.%Get("sizeDate"),
							tResult.%Get("allocatedInMB"),
							tResult.%Get("tsUpdate"),
							tResult.%Get("tsCreate"),
							tResult.%Get("Year"),
							tResult.%Get("Month"),
							tResult.%Get("Week"),
							tResult.%Get("uHlp"))
		Do response.%Push(tObj)
	}
	Kill tResult,tStatement
	Return response
}

/// Return a dynamic object from GlobalSize data.
ClassMethod getDTO(database As %String, global As %String, sizeDate As %Date, allocatedInMB As %Float, tsUpdate As %TimeStamp, tsCreate As %TimeStamp, year As %Integer, month As %Integer, week As %Integer, uHlp As %Integer) As %DynamicObject
{
	Return {
		"database":(database),
		"global":(global),
		"sizeDate":($zd(sizeDate,3)),
		"allocatedInMB":(allocatedInMB),
		"tsUpdate":(tsUpdate),
		"tsCreate":(tsCreate),
		"year":(year),
		"month":(month),
		"week":(week),
		"uHlp":(uHlp)
	}
}

/// Return a dynamic object from GlobalSize object.
ClassMethod getDTOFromObj(sizeRecord As Iris.Tools.Monitor.Data.GlobalSize) As %DynamicObject
{
	Return {
		"database":(sizeRecord.database),
		"global":(sizeRecord.global),
		"sizeDate":($zd(sizeRecord.sizeDate,3)),
		"allocatedInMB":(sizeRecord.allocatedInMB),
		"tsUpdate":(sizeRecord.tsUpdate),
		"tsCreate":(sizeRecord.tsCreate),
		"year":(sizeRecord.year),
		"month":(sizeRecord.month),
		"week":(sizeRecord.week),
		"uHlp":(sizeRecord.uHlp)
	}
}

/// Return the list of database directory on this system.<br/>
/// Deprecated use ##class(Iris.Tools.Monitor.Dao.DBSizeDAO).getAllDB()
ClassMethod getAllDB() As %List [ CodeMode = call, Deprecated ]
{
##class(Iris.Tools.Monitor.Dao.DBSizeDAO).getAllDB()
}

/// Perform the same operation as <b>get</b> method and store the result in a CSV file.
ClassMethod exportToFile(fileName As %String, database As %String, global As %String, recordType As %String, startDate As %Date, endDate As %Date) As %Status
{
	Set sc = $$$OK
	Set dir = ##class(%File).GetDirectory(fileName)
	Do:##class(%File).DirectoryExists(dir) ##class(%File).CreateDirectoryChain(dir)
	Set file=##class(%File).%New(fileName)
	Do file.Open("WSN")
	Set sc = ..exportToStream(.file,.database,.global,.recordType,.startDate,.endDate)
	Return sc
}

/// Perform the same operation as <b>get</b> method and store  result to a stream.
/// 
ClassMethod exportToStream(ByRef stream As %Stream.GlobalCharacter = {##class(%Stream.GlobalCharacter).%New()}, database As %String, global As %String, recordType As %String, startDate As %Date, endDate As %Date) As %Status
{
	Set sc = $$$OK, sep = ";"
	Set tStatement = ##class(%SQL.Statement).%New()
	Set sc = tStatement.%PrepareClassQuery("Iris.Tools.Monitor.Dao.GlobalSizeDAO","FilterGlobalSize")
	Return:'sc sc
	Set tResult = tStatement.%Execute(.database,.global,.recordType,.startDate,.endDate)
	Return:(tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) $$$ERROR($$$SQLError, tResult.%SQLCODE,tResult.%Message)
	Set sc = ##class(Iris.Tools.Monitor.Dao.UtilsDAO).rsToCSVStream(.stream,.tResult)
	Kill tStatement,tResult
	Return sc
}

Query FilterGlobalSize(database As %String, global As %String, recordType As %String, startDate As %Date, endDate As %Date) As %Query(ROWSPEC = "database:%String,global:%String,allocatedInMB:%Float,tsUpdate:%TimeStamp,tsCreate:%TimeStamp,Year:%Integer,Month:%Integer,Week:%Integer,sizeDate:%Date,uHlp:%Integer,tsDate:%TimeStamp") [ SqlProc ]
{
}

ClassMethod FilterGlobalSizeExecute(ByRef qHandle As %Binary, database As %String, global As %String, recordType As %String, startDate As %Date, endDate As %Date) As %Status
{
	Set startUHlp = ##class(Iris.Tools.Monitor.Data.GlobalSize).cmUHlpGet(.recordType,.startDate)
    Set endUHlp = ##class(Iris.Tools.Monitor.Data.GlobalSize).cmUHlpGet(.recordType,.endDate)
    Set tSql = "SELECT database,sql_global,allocatedInMB,tsUpdate,tsCreate,Year,Month,Week,sizeDate,uHlp "
    			_"FROM Iris_Tools_Monitor_Data.GlobalSize "
    			_"WHERE uHLP >= ? AND uHLP <= ? "
    			_$s($lv(database):"and database %INLIST ? ",database'="*":"and database = ? ",1:"")
    			_$s($lv(global):"and sql_global %INLIST ? ",global'="*":"and sql_global = ? ",1:"")
    			_"and recordType = ? "
	
    Set params($i(params))=startUHlp
    Set params($i(params))=endUHlp
    Set:database'="*" params($i(params))=database
    Set:global'="*" params($i(params))=global
    Set params($i(params))=recordType
    Set tStatement = ##class(%SQL.Statement).%New()
    Set sc = tStatement.%Prepare(.tSql)
	Set tResult = tStatement.execute(params...) ; ^lsc:No %Execute for passing array.  The first time I have bitten my keyboard... GoTo Read %SQL.Statement code for understanding.
    Return:(tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message) 
    Set qHandle(1)=tResult
	Quit $$$OK
}

ClassMethod FilterGlobalSizeFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FilterGlobalSizeExecute ]
{
	Set tResult=qHandle(1), sc = $$$OK
	If 'tResult.%Next() {
		Set AtEnd = 1
		Set Row = ""
	}Else{
		Set Row = $Listbuild(tResult.%Get("database"),tResult.%Get("sql_global"),tResult.%Get("allocatedInMB"),tResult.%Get("tsUpdate"),tResult.%Get("tsCreate"),tResult.%Get("Year"),tResult.%Get("Month"),tResult.%Get("Week"),tResult.%Get("sizeDate"),tResult.%Get("uHlp"),$zd(tResult.%Get("sizeDate"),3))
	}
	Return sc
}

ClassMethod FilterGlobalSizeClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FilterGlobalSizeFetch ]
{
	Set qHandle(1)=""
    Return $$$OK
}

///  <b>!NOT TESTED ! Todo ...</b>
ClassMethod clean(retDay As %Integer = 90, retWeek As %Integer = 24, retMonth As %Integer = -1, retYear As %Integer = -1) As %Status
{
	Set sc = $$$OK,
			whereStr =" (uHlp < ? AND recordType= ?) OR",
			tSql($i(tSql)) = "DELETE Iris_Tools_Monitor_Data.GlobalSize WHERE ",
			tArgs=0
	
	If retDay'=-1 {
		Set uHlp = ##class(Iris.Tools.Monitor.Data.GlobalSize).cmUHlpGet("Day",$h-retDay)
		Set tSql($i(tSql)) = whereStr, tArgs($i(tArgs))=uHlp, tArgs($i(tArgs))="Day"	
	}
	
	If retWeek'=-1 {
		Set uHlp = ##class(Iris.Tools.Monitor.Data.GlobalSize).cmUHlpGet("Week",$h-(retWeek*7))
		Set tSql($i(tSql)) = whereStr, tArgs($i(tArgs))=uHlp, tArgs($i(tArgs))="Week"
	}
	
	If retMonth'=-1 {
		Set uHlp = ##class(Iris.Tools.Monitor.Data.GlobalSize).cmUHlpGet("Month",$zdh($SYSTEM.SQL.DATEADD("mm",-retMonth,+$h),3))
		Set tSql($i(tSql)) = whereStr, tArgs($i(tArgs))=uHlp, tArgs($i(tArgs))="Month"
	}
	
	If retYear'=-1 {
		Set uHlp = ##class(Iris.Tools.Monitor.Data.GlobalSize).cmUHlpGet("Year",$zdh($SYSTEM.SQL.DATEADD("yy",-retYear,+$h),3))
		Set tSql($i(tSql)) = whereStr, tArgs($i(tArgs))=uHlp, tArgs($i(tArgs))="Year"
	}
		
	If tSql>1 {
		Set tSql(tSql)=$Extract(tSql(tSql),1,*-2) ; delete last "OR"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set sc = tStatement.%Prepare(.tSql)
		Return:'sc sc
		Set tResult = tStatement.execute(tArgs...)
		Set:(tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) sc = $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message) 
	}
	Return sc
}

}
