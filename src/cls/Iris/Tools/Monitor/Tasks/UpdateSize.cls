/// Task used for update data of growth of global size<br/>
/// Should be performed every day.
Class Iris.Tools.Monitor.Tasks.UpdateSize Extends %SYS.Task.Definition
{

Projection autoDeploy As Iris.Tools.Monitor.Tasks.Projection;

Parameter TaskName = "Global Size Updater";

/// If a filename is set, a csv file will be created with the last gobal size update.
Property latestSizeFile As %String(MAXLEN = 256);

/// If a filename is set, a csv file will be created with the last database size update.
Property latestDBSizeFile As %String(MAXLEN = 256);

/// If true, decimal separator is "," in csv file
Property decimalPointIsComma As %Boolean [ InitialExpression = 0 ];

/// if not empty, global size will be performed only for listed database<br/>
/// ex: /opt/irisapp/data/,/usr/irissys/mgr/user/ <br/>
Property dbList As %String(MAXLEN = 1024);

Method OnTask() As %Status
{
	Set tSc = $$$OK
	Try {
		$$$TOE(sc,..cmTask(..latestSizeFile,..latestDBSizeFile,..decimalPointIsComma,..dbList))
	}Catch(ex) {
		Set tSc = ex.AsStatus()
	}
	Return tSc
}

ClassMethod cmTask(latestSizeFile As %String = "", latestDBSizeFile As %String = "", decimalPointIsComma As %Boolean = 0, dbList As %String = "") As %Status
{
	Set tSc = $$$OK
	Try {
		$$$TOE(tSc,##class(Iris.Tools.Monitor.Services.DBSizeServices).updateAllDBSize())
		If dbList = "" {
			$$$TOE(tSc,##class(Iris.Tools.Monitor.Services.GlobalSizeServices).updateAllDBGlobalSize())
		} Else {
			Set list = $Listfromstring(dbList, "," )
			$$$TOE(tSc,##class(Iris.Tools.Monitor.Services.GlobalSizeServices).updateDatabasesGlobalSize(list))
		}
		Do:+decimalPointIsComma ##class(Iris.Tools.Monitor.Services.GlobalSizeServices).setDecimalPointIsComma(1)
		If (latestSizeFile'="") {
			$$$TOE(tSc,##class(Iris.Tools.Monitor.Services.GlobalSizeServices).exportSizeToFile(latestSizeFile,$zd($h,3)))
		}
		If (latestDBSizeFile'="") {
			$$$TOE(tSc,##class(Iris.Tools.Monitor.Services.DBSizeServices).exportSizeToFile(latestDBSizeFile,$zd($h,3)))
		}
		$$$TOE(tSc,##class(Iris.Tools.Monitor.Services.GlobalSizeServices).clean())
		$$$TOE(tSc,##class(Iris.Tools.Monitor.Services.DBSizeServices).clean())
	}Catch(ex) {
		Set tSc = ex.AsStatus()
	}
	Return tSc
}

/// Install the task for execution every day at 11:00 p.m.
ClassMethod installTask() As %Status
{
	Set tSc = $$$OK
	Set id = $Get(^monitor.tasks.UpdateSize.id)
	Return:(id'="")&&(##class(%SYS.Task).%ExistsId(id)) $$$ERROR($$$GeneralError,$$$FormatText("Task already exist with id %1",id))
	Set task = ##class(%SYS.Task).%New()
	Set task.DailyFrequency = 0
	Set task.DailyFrequencyTime = ""
	Set task.DailyIncrement = ""
	Set task.DailyStartTime = 1*3600	; 1:00 a.m.
	Set task.DailyEndTime = ""
	Set task.TimePeriod = 0
	Set task.TimePeriodEvery = 1
	Set task.Description = "Update table with all globals size"
	Set task.TaskClass = ..%ClassName(1)
	Set task.NameSpace = $namespace
	Set task.Name = ..#TaskName
	Set tSc = task.%Save()
	Set:$$$ISOK(tSc) ^monitor.tasks.UpdateSize.id=task.%Id()
	Return tSc
}

}
