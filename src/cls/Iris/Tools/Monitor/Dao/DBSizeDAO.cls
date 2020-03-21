Class Iris.Tools.Monitor.Dao.DBSizeDAO
{

/// Insert or update a database size record.
ClassMethod setSize(recordType As %String, database As %String, dbSizeInMB As %Float, freeSpaceInMB As %Float, diskFreeSpaceInMB As %Float, sizeDate As %Date = {+$h}) As %Status
{
	Set tSc = $$$OK
	Set uHlp =##class(Iris.Tools.Monitor.Data.DBSize).cmUHlpGet(.recordType,.sizeDate)
	Set sizeRecord = ##class(Iris.Tools.Monitor.Data.DBSize).uniqueIOpen(.uHlp,.database,.recordType)
	Set:'$Isobject(sizeRecord) sizeRecord = ##class(Iris.Tools.Monitor.Data.DBSize).%New()
	Set sizeRecord.recordType = recordType
	Set sizeRecord.database = database
	Set sizeRecord.dbSizeInMB = dbSizeInMB
	Set sizeRecord.sizeDate = sizeDate
	Set sizeRecord.freeSpaceInMB = freeSpaceInMB
	Set sizeRecord.diskFreeSpaceInMB = diskFreeSpaceInMB
	Set sc = sizeRecord.%Save()
	Set sizeRecord = ""
	return sc
}

ClassMethod updateDBSizeInfo(mask As %String = "*") As %Status
{
	Set tSc = $$$OK
	Set tStatement = ##class(%SQL.Statement).%New()
	Set sc = tStatement.%PrepareClassQuery("%SYS.DatabaseQuery","FreeSpace")
	If $$$ISERR(sc) $$$ThrowStatus(sc)
	Set tResult = tStatement.%Execute(mask)
	If (tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) $$$ThrowStatus($$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message)) 
	Set sizeDate = +$h
	While tResult.%Next() {
		$$$TOE(tSc,..setSize("Day",tResult.%Get("Directory"),..convertInMB(tResult.%Get("Size")),tResult.%Get("Free"),..convertInMB(tResult.%Get("DiskFreeSpace")),sizeDate))
		$$$TOE(tSc,..setSize("Week",tResult.%Get("Directory"),..convertInMB(tResult.%Get("Size")),tResult.%Get("Free"),..convertInMB(tResult.%Get("DiskFreeSpace")),sizeDate))
		$$$TOE(tSc,..setSize("Month",tResult.%Get("Directory"),..convertInMB(tResult.%Get("Size")),tResult.%Get("Free"),..convertInMB(tResult.%Get("DiskFreeSpace")),sizeDate))
		$$$TOE(tSc,..setSize("Year",tResult.%Get("Directory"),..convertInMB(tResult.%Get("Size")),tResult.%Get("Free"),..convertInMB(tResult.%Get("DiskFreeSpace")),sizeDate))
	}
	Kill tResult,tStatement
	Return tSc
}

ClassMethod convertInMB(size As %String) As %Float [ Private ]
{
	Set unit = $Extract(size,*-1,*)
	Set fSize = $Extract(size,1,*-2)
	Set coef = $s(unit="MB":1,unit="GB":1024,unit="TB":1024**2,unit="KB":1/1024,1:doh/*force an error*/)
	Return fSize*coef
}

/// Usefull method to retrieve size of database, following filters : <br/><ul>
/// <li><b>database</b>: database directory ("*" are allowed for all databases).</li>
/// <li><b>recordType</b>: possible value Day,Week,Month,Year</li>
/// <li><b>startDate</b>: start date in %Date format</li>
/// <li><b>endDate</b>: end date in %Date format</li>
/// </ul>
ClassMethod get(database As %String, recordType As %String, startDate As %Date, endDate As %Date = {+$h}) As %DynamicArray
{
	Set response = []
	Set tStatement = ##class(%SQL.Statement).%New()
	Set sc = tStatement.%PrepareClassQuery("Iris.Tools.Monitor.Dao.DBSizeDAO","FilterDBSize")
	If $$$ISERR(sc) $$$ThrowStatus(sc)
	Set tResult = tStatement.%Execute(.database,.recordType,.startDate,.endDate)
	If (tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) $$$ThrowStatus($$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message)) 
	While tResult.%Next() {
		Set tObj = ..getDTO(tResult.%Get("database"),
							tResult.%Get("sizeDate"),
							tResult.%Get("dbSizeInMB"),
							tResult.%Get("freeSpaceInMB"),
							tResult.%Get("diskFreeSpaceInMB"),
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

/// Return a dynamic object from DBSize object.
ClassMethod getDTOFromObj(sizeRecord As Iris.Tools.Monitor.Data.DBSize) As %DynamicObject
{
	Return {
		"database":(sizeRecord.database),
		"sizeDate":($zd(sizeRecord.sizeDate,3)),
		"dbSizeInMB":(sizeRecord.dbSizeInMB),
		"freeSpaceInMB":(sizeRecord.freeSpaceInMB),
		"diskFreeSpaceInMB":(sizeRecord.diskFreeSpaceInMB),
		"tsUpdate":(sizeRecord.tsUpdate),
		"tsCreate":(sizeRecord.tsCreate),
		"year":(sizeRecord.year),
		"month":(sizeRecord.month),
		"week":(sizeRecord.week),
		"uHlp":(sizeRecord.uHlp)
	}
}

/// Return a dynamic object from DBSize data.
ClassMethod getDTO(database As %String, sizeDate As %Date, dbSizeInMB As %Float, freeSpaceInMB As %Float, diskFreeSpaceInMB As %Float, tsUpdate As %TimeStamp, tsCreate As %TimeStamp, year As %Integer, month As %Integer, week As %Integer, uHlp As %Integer) As %DynamicObject
{
	Return {
		"database":(database),
		"sizeDate":($zd(sizeDate,3)),
		"dbSizeInMB":(dbSizeInMB),
		"freeSpaceInMB":(freeSpaceInMB),
		"diskFreeSpaceInMB":(diskFreeSpaceInMB),
		"tsUpdate":(tsUpdate),
		"tsCreate":(tsCreate),
		"year":(year),
		"month":(month),
		"week":(week),
		"uHlp":(uHlp)
	}
}

/// Perform the same operation as <b>get</b> method and store the result in a CSV file.
ClassMethod exportToFile(fileName As %String, database As %String, recordType As %String, startDate As %Date, endDate As %Date) As %Status
{
	Set sc = $$$OK
	Set dir = ##class(%File).GetDirectory(fileName)
	Do:##class(%File).DirectoryExists(dir) ##class(%File).CreateDirectoryChain(dir)
	Set file=##class(%File).%New(fileName)
	Do file.Open("WSN")
	Set sc = ..exportToStream(.file,.database,.recordType,.startDate,.endDate)
	Return sc
}

/// Perform the same operation as <b>get</b> method and store  result to a stream.
/// 
ClassMethod exportToStream(ByRef stream As %Stream.GlobalCharacter = {##class(%Stream.GlobalCharacter).%New()}, database As %String, recordType As %String, startDate As %Date, endDate As %Date) As %Status
{
	Set sc = $$$OK, sep = ";"
	Set tStatement = ##class(%SQL.Statement).%New()
	Set sc = tStatement.%PrepareClassQuery("Iris.Tools.Monitor.Dao.DBSizeDAO","FilterDBSize")
	Return:'sc sc
	Set tResult = tStatement.%Execute(.database,.recordType,.startDate,.endDate)
	Return:(tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) $$$ERROR($$$SQLError, tResult.%SQLCODE,tResult.%Message)
	Set sc = ##class(Iris.Tools.Monitor.Dao.UtilsDAO).rsToCSVStream(.stream,.tResult)
	Kill tStatement,tResult
	Return sc
}

/// Return the list of database directory on this system.
ClassMethod getAllDB() As %List
{
	Set ns = $namespace, dbList = ""
	Try{
		Set $namespace = "%SYS", rs=##class(%Library.ResultSet).%New("Config.Databases:List")
		Do rs.Execute()
		While rs.Next() {
			Set $List(dbList,$i(i))=rs.Data("Directory")
		}
		Do rs.Close()
		Set $namespace = ns
	}Catch(ex) {
		Set $namespace = ns
		Throw ex
	}
	Return dbList
}

Query FilterDBSize(database As %String, recordType As %String, startDate As %Date, endDate As %Date) As %Query(ROWSPEC = "database:%String,dbSizeInMB:%Float,freeSpaceInMB:%Float,diskFreeSpaceInMB:%Float,tsUpdate:%TimeStamp,tsCreate:%TimeStamp,Year:%Integer,Month:%Integer,Week:%Integer,sizeDate:%Date,uHlp:%Integer,tsDate:%TimeStamp") [ SqlProc ]
{
}

ClassMethod FilterDBSizeExecute(ByRef qHandle As %Binary, database As %String, recordType As %String, startDate As %Date, endDate As %Date) As %Status
{
	Set startUHlp = ##class(Iris.Tools.Monitor.Data.DBSize).cmUHlpGet(.recordType,.startDate)
    Set endUHlp = ##class(Iris.Tools.Monitor.Data.DBSize).cmUHlpGet(.recordType,.endDate)
    Set tSql = "SELECT database,dbSizeInMB,freeSpaceInMB,diskFreeSpaceInMB,tsUpdate,tsCreate,Year,Month,Week,sizeDate,uHlp "
    			_"FROM Iris_Tools_Monitor_Data.DBSize "
    			_"WHERE uHLP >= ? AND uHLP <= ? "
    			_$s($lv(database):"and database %INLIST ? ",database'="*":"and database = ? ",1:"")
    			_"and recordType = ?"
    Set params($i(params))=startUHlp
    Set params($i(params))=endUHlp
    Set:database'="*" params($i(params))=database
    Set params($i(params))=recordType
    Set tStatement = ##class(%SQL.Statement).%New()
    Set sc = tStatement.%Prepare(.tSql)
	;Set ^CacheTempDBSizeLast("sql")=tSql
	;Merge ^CacheTempDBSizeLast("args") = params
    Set tResult = tStatement.execute(params...) ; ^lsc:No %Execute for passing array.  The first time I have bitten my keyboard... GoTo Read %SQL.Statement code for understanding.
    Return:(tResult.%SQLCODE'=0)&&(tResult.%SQLCODE'=100) $$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message) 
    Set qHandle=tResult
    Quit $$$OK
}

ClassMethod FilterDBSizeFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = FilterDBSizeExecute ]
{
	Set tResult=qHandle, sc = $$$OK
	If 'tResult.%Next() {
		Set AtEnd = 1, Row = ""
	}Else{
		Set Row = $Listbuild(tResult.%Get("database"),tResult.%Get("dbSizeInMB"),tResult.%Get("freeSpaceInMB"),tResult.%Get("diskFreeSpaceInMB"),tResult.%Get("tsUpdate"),tResult.%Get("tsCreate"),tResult.%Get("Year"),tResult.%Get("Month"),tResult.%Get("Week"),tResult.%Get("sizeDate"),tResult.%Get("uHlp"),$zd(tResult.%Get("sizeDate"),3))
	}
	Return sc
}

ClassMethod FilterDBSizeClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = FilterDBSizeFetch ]
{
	Set qHandle=""
    Return $$$OK
}

///  <b>!NOT TESTED ! Todo ...</b>
ClassMethod clean(retDay As %Integer = 90, retWeek As %Integer = 24, retMonth As %Integer = -1, retYear As %Integer = -1) As %Status
{
	Set sc = $$$OK,
			whereStr =" (uHlp < ? AND recordType= ?) OR",
			tSql($i(tSql)) = "DELETE Iris_Tools_Monitor_Data.DBSize WHERE ",
			tArgs=0
	
	If retDay'=-1 {
		Set uHlp = ##class(Iris.Tools.Monitor.Data.DBSize).cmUHlpGet("Day",$h-retDay)
		Set tSql($i(tSql)) = whereStr, tArgs($i(tArgs))=uHlp, tArgs($i(tArgs))="Day"	
	}
	
	If retWeek'=-1 {
		Set uHlp = ##class(Iris.Tools.Monitor.Data.DBSize).cmUHlpGet("Week",$h-(retWeek*7))
		Set tSql($i(tSql)) = whereStr, tArgs($i(tArgs))=uHlp, tArgs($i(tArgs))="Week"
	}
	
	If retMonth'=-1 {
		Set uHlp = ##class(Iris.Tools.Monitor.Data.DBSize).cmUHlpGet("Month",$zdh($SYSTEM.SQL.DATEADD("mm",-retMonth,+$h),3))
		Set tSql($i(tSql)) = whereStr, tArgs($i(tArgs))=uHlp, tArgs($i(tArgs))="Month"
	}
	
	If retYear'=-1 {
		Set uHlp = ##class(Iris.Tools.Monitor.Data.DBSize).cmUHlpGet("Year",$zdh($SYSTEM.SQL.DATEADD("yy",-retYear,+$h),3))
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
