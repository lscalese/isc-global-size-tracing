Class UnitTest.Iris.Tools.Monitor.SizeUnitTest Extends %UnitTest.TestCase
{

Property tempDirectory As %String [ InitialExpression = {$zu(12,"unittest")}, Private ];

Property testUpdateDatabaseGlobalSizeDone [ InitialExpression = 0, Private ];

Method tempDirectorySet(tempDirectory As %String) As %Status
{
	Set i%tempDirectory = ##class(%File).NormalizeDirectory(tempDirectory)
	Do:(i%tempDirectory'="")&&('##class(%File).DirectoryExists(i%tempDirectory)) ##class(%File).CreateDirectoryChain(i%tempDirectory)
	Return $$$OK
}

Method OnBeforeAllTests() As %Status
{
	Set tSc = $$$OK
	$$$TOE(tSc,..backupData())
	Set ptr=0, listGbl=$lfs(..globalsToRestore(),",")
	While $listnext(listGbl,ptr,gbl) {
		Kill @gbl
	}
	Return tSc
}

Method OnAfterAllTests() As %Status
{
	Return ..restoreData()
}

Method backupData() As %Status
{
	Set dbSizeGof = ..backupGofFileName(), tSc = $$$OK, ptr=0, strGbl=..globalsToRestore(), backup = 0, listGbl=$lfs(strGbl,",")
	While $listnext(listGbl,ptr,gbl) {
		If $d(@gbl) {
			Set backup = 1
			Quit
		}
	}
	Set gofDir = ##class(%File).GetDirectory(dbSizeGof)
	Do:##class(%File).Exists(dbSizeGof) ##class(%File).Delete(dbSizeGof)
	Do:'##class(%File).DirectoryExists(gofDir) ##class(%File).CreateDirectoryChain(gofDir)
	Set:backup tSc = ##class(%Library.Global).Export(,strGbl,dbSizeGof,7)
	Return tSc
}

Method restoreData() As %Status
{
	Set dbSizeGof = ..backupGofFileName(), tSc = $$$OK, ptr=0, strGbl = ..globalsToRestore(), listGbl=$lfs(strGbl,",")
	While $listnext(listGbl,ptr,gbl) {
		Kill @gbl
	}
	Set:##class(%File).Exists(dbSizeGof) tSc = ##class(%Library.Global).Import(,strGbl,dbSizeGof,7)
	Return tSc
}

ClassMethod globalsToRestore() As %String [ CodeMode = expression ]
{
"^Iris.Tools.MonitorA859.DBSizeD,^Iris.Tools.MonitorA859.DBSizeI,^Iris.Tools.MonitorA859.DBSizeS,"
		_"^Iris.Tools.MoniA859.GlobalSizeD,^Iris.Tools.MoniA859.GlobalSizeI,^Iris.Tools.MoniA859.GlobalSizeS"
}

Method backupGofFileName() As %String [ CodeMode = expression ]
{
..tempDirectory_"backup-dbSize.gof"
}

/// Test service ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getAllDB()
Method TestGetAllDB()
{
	Set dbList = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getAllDB()
	Do $$$AssertNotEquals(($ll(dbList)>0),0,"Test service getAllDB() - check if dbList size > 0")
}

/// Test service ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getDbDirectory(databasename)
Method TestGetDbDirectory()
{
	Set dbName = ..getDBName()
	Do $$$AssertNotEquals(##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getDbDirectory(dbName),"","Test service getDbDirectory(databasename)")
}

/// Test service ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getGlobalListForDB(database)
Method TestGetGlobalListForDB()
{
	Set dbName = ..getDBName()
	Do $$$LogMessage("Get global list for "_dbName)
	Set database = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getDbDirectory(dbName)
	Do $$$LogMessage("DB directory "_database)
	Set gblList = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getGlobalListForDB(database)
	Do $$$AssertEquals(($ll(gblList)>0),1,"Test service getGlobalListForDB(database) - check if list of global > 0")
}

/// Test service ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).updateDatabaseGlobalSize(database)
Method TestUpdateDatabaseGlobalSize()
{
	Set dbName = ..getDBName()
	Set database = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getDbDirectory(dbName)
	Set tSc = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).updateDatabaseGlobalSize(database)
	Do $$$AssertStatusOK(##class(Iris.Tools.Monitor.Services.GlobalSizeServices).updateDatabaseGlobalSize(database),"Update all globals size for a database.")
	Set ..testUpdateDatabaseGlobalSizeDone=1
}

/// Test service ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).updateDatabaseGlobalSize(database)
Method TestGet()
{
	Do:'..testUpdateDatabaseGlobalSizeDone ..TestUpdateDatabaseGlobalSize()
	Set dbName = ..getDBName()
	Set database = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getDbDirectory(dbName)
	Set gblList = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getGlobalListForDB(database)
	Set periodList = ..periodList()
	For i=1:1:$ll(gblList) {
		For j=1:1:$ll(periodList) {
			Set res=##class(Iris.Tools.Monitor.Services.GlobalSizeServices).get(database,$lg(gblList,i),$lg(periodList,j))
			Do $$$AssertEquals(res.%Size(),1,$$$FormatText("Checking global %1 in DB %2, period %3 ",$lg(gblList,i),database,$lg(periodList,j)))
		}
	}
}

/// Test service ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).updateDatabaseGlobalSize(database)
Method TestGetByDatabase()
{
	Do:'..testUpdateDatabaseGlobalSizeDone ..TestUpdateDatabaseGlobalSize()
	Set dbName = ..getDBName()
	Set database = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getDbDirectory(dbName)
	Set gblList = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).getGlobalListForDB(database)
	Set periodList = ..periodList()
	
	For j=1:1:$ll(periodList) {
		Set res=##class(Iris.Tools.Monitor.Services.GlobalSizeServices).get(database,"*",$lg(periodList,j))
		Set iter = res.%GetIterator()
		While iter.%GetNext(.key , .value ) {
			Set arrResult(value.global)=""
	    }
		For i=1:1:$ll(gblList) {
			Do $$$AssertEquals($Data(arrResult($lg(gblList,i))),1,$$$FormatText("Checking global %1 in DB %2, period %3 ",$lg(gblList,i),database,$lg(periodList,j)))
		}
		Kill arrResult
	}
}

/*Method TestTask()
{
 	#dim task As Iris.Tools.Monitor.Tasks.UpdateSize
 	Set task = ##class(Iris.Tools.Monitor.Tasks.UpdateSize).%New()
	Set task.latestSizeFile = $zu(12)_"Temp/lastestGlobalSize.csv"
	Set task.latestDBSizeFile = $zu(12)_"Temp/lastestDBSize.csv"
	Set task.decimalPointIsComma = 1
	Do:##class(%File).Exists(task.latestSizeFile) ##class(%File).Delete(task.latestSizeFile)
	Do $$$AssertStatusOK(task.OnTask(),"Test task update all globals size for all databases.")
	Do $$$AssertEquals(##class(%File).Exists(task.latestSizeFile),1,"file "_task.latestSizeFile_" exists")
	Do $$$AssertEquals(##class(%File).Exists(task.latestDBSizeFile),1,"file "_task.latestDBSizeFile_" exists")
	Do:##class(%File).Exists(task.latestSizeFile) ##class(%File).Delete(task.latestSizeFile)
	Do:##class(%File).Exists(task.latestDBSizeFile) ##class(%File).Delete(task.latestDBSizeFile)
}*/
Method TestUpdateAllDBSize()
{
	Do $$$AssertStatusOK(##class(Iris.Tools.Monitor.Services.DBSizeServices).updateAllDBSize(),"Update all database size")
}

Method TestDBSizeGet()
{
	Do $$$LogMessage($i(i))
	Do ..TestUpdateAllDBSize()
	Do $$$LogMessage($i(i))
	Set dbName = ..getDBName()
	Do $$$LogMessage($i(i))
	Set database = ##class(Iris.Tools.Monitor.Services.DBSizeServices).getDbDirectory(dbName)
	Do $$$LogMessage($i(i))
	Set periodList = ..periodList()
	For j=1:1:$ll(periodList) {
		Set res=##class(Iris.Tools.Monitor.Services.DBSizeServices).get(database,$lg(periodList,j))
		Do $$$AssertEquals(res.%Size(),1,$$$FormatText("Checking DB %1, period %2 , result %3",database,$lg(periodList,j),res.%Size()))
	}
}

Method TestDBSizeGetAndExportToFile()
{
	Do ..TestUpdateAllDBSize()
	Set latestDBSizeFile = "lastestDBSize.csv"
	Do $$$LogMessage($$$FormatText("Delete file %1 (if exist)",latestDBSizeFile))
	Do:##class(%File).Exists(latestDBSizeFile) ##class(%File).Delete(latestDBSizeFile)
	Set periodList = ..periodList()
	For i=1:1:$ll(periodList) {
		Set tSc = ##class(Iris.Tools.Monitor.Services.DBSizeServices).getAndExportToFile(latestDBSizeFile,"*",$lg(periodList,i),,)
		Do $$$AssertStatusOK(tSc,$$$FormatText("Test service getAndExportToFile with recordType %1",$lg(periodList,i)))
		Do $$$AssertEquals(##class(%File).Exists(latestDBSizeFile),1,"file "_latestDBSizeFile_" exists")
		Do $$$LogMessage($$$FormatText("Delete file %1 (if exist)",latestDBSizeFile))
		;hang 0.5 ; Windows security, waiting for release lock
		Do:##class(%File).Exists(latestDBSizeFile) ##class(%File).Delete(latestDBSizeFile)
	}
}

Method TestDBSizeExportSizeToFile()
{
	Do ..TestUpdateAllDBSize()
	Set latestDBSizeFile = "lastestDBSize.csv"
	Do $$$LogMessage($$$FormatText("Delete file %1 (if exist)",latestDBSizeFile))
	Do:##class(%File).Exists(latestDBSizeFile) ##class(%File).Delete(latestDBSizeFile)
	Set periodList = ..periodList()
	For i=1:1:$ll(periodList) {
		Set tSc = ##class(Iris.Tools.Monitor.Services.DBSizeServices).exportSizeToFile(latestDBSizeFile,$zd($h,3,1),$lg(periodList,i))
		Do $$$AssertStatusOK(tSc,$$$FormatText("Test service exportSizeToFile with recordType %1",$lg(periodList,i)))
		Do $$$AssertEquals(##class(%File).Exists(latestDBSizeFile),1,"file "_latestDBSizeFile_" exists")
		Do $$$LogMessage($$$FormatText("Delete file %1 (if exist)",latestDBSizeFile))
		;hang 0.5 ; Windows security, waiting for release lock
		Do:##class(%File).Exists(latestDBSizeFile) ##class(%File).Delete(latestDBSizeFile)
	}
}

Method TestDBSizeClean()
{
	Set tSc = ..generateDBSizeData($h-110,$h-70)
	Do $$$AssertStatusOK(tSc,"Generate old fake data.")
	
	Set database = $lg(..getDBDir(),1)
	Set checkDate = $zd($h-91,3)
	Set periodList = ..periodList()
	
	For j=1:1:$ll(periodList) {
		Set res=##class(Iris.Tools.Monitor.Services.DBSizeServices).get(database,$lg(periodList,j),checkDate,checkDate)
		Do $$$AssertEquals(res.%Size(),1,$$$FormatText("Checking DB %1, recordtype %2 ",database,$lg(periodList,j)))
	}
	
	
	
	Set tSc = ##class(Iris.Tools.Monitor.Services.DBSizeServices).clean(90,12,-1,-1)
	Do $$$AssertStatusOK(tSc,"Test service DBSize clean.")
	Do $$$LogMessage("Check if the data has been deleted.")
	
	For j=1:1:$ll(periodList) {
		Set cPeriod = $lg(periodList,j)
		Set res=##class(Iris.Tools.Monitor.Services.DBSizeServices).get(database,cPeriod,checkDate,checkDate)
		If (cPeriod="Day")||(cPeriod="Week") {
			Do $$$AssertEquals(res.%Size(),0,$$$FormatText("Checking DB %1, period %2 ",database,cPeriod))
		}Else{
			Do $$$AssertEquals(res.%Size(),1,$$$FormatText("Checking DB %1, period %2 ",database,cPeriod))
		}
	}
	
	Set checkDate = $zd($h-71,3)
	
	Do $$$LogMessage("Check if recent data still available.")
	
	For j=1:1:$ll(periodList) {
		Set cPeriod = $lg(periodList,j)
		Set res=##class(Iris.Tools.Monitor.Services.DBSizeServices).get(database,cPeriod,checkDate,checkDate)
		Do $$$AssertEquals(res.%Size(),1,$$$FormatText("Checking DB %1, recordtype %2 ",database,cPeriod))
	}
}

Method generateDBSizeData(dStart = {$h-100}, dEnd = {$h-70})
{
	Set tSc = $$$OK
	Try{
		Set dbList = ..getDBDir()
		For i=dStart:1:dEnd {
			Set sizeDate=i
			Set ptr = 0
			While $listnext(dbList,ptr,db) {
				Set v1=$r(10000),v2=$r(10000),v3=$r(10000)
				$$$TOE(tSc,##class(Iris.Tools.Monitor.Dao.DBSizeDAO).setSize("Day",db,v1,v2,v3,sizeDate))
				$$$TOE(tSc,##class(Iris.Tools.Monitor.Dao.DBSizeDAO).setSize("Week",db,v1,v2,v3,sizeDate))
				$$$TOE(tSc,##class(Iris.Tools.Monitor.Dao.DBSizeDAO).setSize("Month",db,v1,v2,v3,sizeDate))
				$$$TOE(tSc,##class(Iris.Tools.Monitor.Dao.DBSizeDAO).setSize("Year",db,v1,v2,v3,sizeDate))
			}
		}
	}Catch(ex) {
		Set tSc = ex.AsStatus()
	}
	Return tSc
}

Method TestClean()
{
	
	Set tSc = ..generateData($h-110,$h-70)
	Do $$$AssertStatusOK(tSc,"Generate old fake data.")
	Set gblList = ..getGlobalName()
	Set database = $lg(..getDBDir())
	Set checkDate = $zd($h-91,3)
	Set periodList = ..periodList()
	For i=1:1:$ll(gblList) {
		For j=1:1:$ll(periodList) {
			Set res=##class(Iris.Tools.Monitor.Services.GlobalSizeServices).get(database,$lg(gblList,i),$lg(periodList,j),checkDate,checkDate)
			Do $$$AssertEquals(res.%Size(),1,$$$FormatText("Checking global %1 in DB %2, period %3 ",$lg(gblList,i),database,$lg(periodList,j)))
		}
	}
	
	Set tSc = ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).clean(90,12,-1,-1)
	
	Do $$$AssertStatusOK(tSc,"Test service clean.")
	Do $$$LogMessage("Check if the data has been deleted.")
	For i=1:1:$ll(gblList) {
		For j=1:1:$ll(periodList) {
			Set cPeriod = $lg(periodList,j)
			Set res=##class(Iris.Tools.Monitor.Services.GlobalSizeServices).get(database,$lg(gblList,i),cPeriod,checkDate,checkDate)
			If (cPeriod="Day")||(cPeriod="Week") {
				Do $$$AssertEquals(res.%Size(),0,$$$FormatText("Checking global %1 in DB %2, period %3 ",$lg(gblList,i),database,cPeriod))
			}Else{
				Do $$$AssertEquals(res.%Size(),1,$$$FormatText("Checking global %1 in DB %2, period %3 ",$lg(gblList,i),database,cPeriod))
			}
		}
	}
	Set checkDate = $zd($h-71,3)
	
	Do $$$LogMessage("Check if recent data is still available.")
	For i=1:1:$ll(gblList) {
		For j=1:1:$ll(periodList) {
			Set cPeriod = $lg(periodList,j)
			Set res=##class(Iris.Tools.Monitor.Services.GlobalSizeServices).get(database,$lg(gblList,i),cPeriod,checkDate,checkDate)
			Do $$$AssertEquals(res.%Size(),1,$$$FormatText("Checking global %1 in DB %2, period %3 ",$lg(gblList,i),database,cPeriod))
		}
	}
}

ClassMethod getDBName()
{
	Set ns = $namespace
	Try {
		Set $namespace="%SYS"
		Do ##class(Config.Namespaces).Get(ns,.Properties)
		Set dbName = Properties("Globals")
		Set ^||dbName = dbName
		Set $namespace=ns
	}Catch(ex){
		Set $namespace=ns
		Throw ex
	}
	Return dbName
}

ClassMethod periodList() [ CodeMode = expression ]
{
$lb("Day","Week","Month","Year")
}

ClassMethod generateData(dStart = {$h-100}, dEnd = {$h-70}) As %Status
{
	Set tSc = $$$OK
	Try{
		
		;Write !,$$$FormatText("Generate data from %1 to %2",$zd(dStart,3),$zd(dEnd,3))
		Set dbList = ..getDBDir()
		Set gblName = ..getGlobalName()
		
		For i=dStart:1:dEnd {
			Set sizeDate=i
			Set ptr = 0
			While $listnext(dbList,ptr,db) {
				Set ptr2 = 0
				While $listnext(gblName,ptr2,gbl) {
					If +$g(arrSize(db,gbl))=0 {
						Set arrSize(db,gbl)=$r(2000)
					}Else{
						Set v = arrSize(db,gbl) * $r(20) / 1000
						Set arrSize(db,gbl) = $s($r(10)>8:arrSize(db,gbl)-v,1:arrSize(db,gbl)+v)
					}
					$$$TOE(tSc,##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).setSize("Day",db,gbl,arrSize(db,gbl),sizeDate))
					$$$TOE(tSc,##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).setSize("Week",db,gbl,arrSize(db,gbl),sizeDate))
					$$$TOE(tSc,##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).setSize("Month",db,gbl,arrSize(db,gbl),sizeDate))
					$$$TOE(tSc,##class(Iris.Tools.Monitor.Dao.GlobalSizeDAO).setSize("Year",db,gbl,arrSize(db,gbl),sizeDate))
				}
			}
		}
		
	}Catch(ex) {
		Set tSc = ex.AsStatus()
	}
	Return tSc
}

ClassMethod getDBDir() As %List
{
	Return $lb("c:\dev\dummydb\unittest\")
}

ClassMethod getGlobalName() As %List
{
	Return $lb("a",
		"zzzUnitTestability",
		"zzzUnitTestable",
		"zzzUnitTestabout",
		"zzzUnitTestabove",
		"zzzUnitTestaccept",
		"zzzUnitTestaccording",
		"zzzUnitTestaccount")
}

}
