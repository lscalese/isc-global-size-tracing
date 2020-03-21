/// Peristent class designed for store the database size following one record per : <br/><ul>
/// <li>Day</li>
/// <li>Week</li>
/// <li>Month</li>
/// <li>Year</li>
/// </ul>
Class Iris.Tools.Monitor.Data.DBSize Extends (%Persistent, Iris.Tools.Monitor.Data.GSCommon)
{

/// Database directory.
Property database As %String(MAXLEN = 512) [ Required ];

/// Cache.dat or Iris.dat file size In Mega bytes.
Property dbSizeInMB As %Float [ Required ];

/// Freespace on database file (in MB).
Property freeSpaceInMB As %Float [ Required ];

/// Freespace on the used disk by the database file.
Property diskFreeSpaceInMB As %Float;

Index uniqueI On (uHlp, database, recordType) [ Unique ];

Method %OnAddToSaveSet(depth As %Integer, insert As %Integer, callcount As %Integer) As %Status [ Private, ServerOnly = 1 ]
{
	If insert {
		Set (..tsCreate,..tsUpdate) = $ZDT($h,3,1)
    }Else{
		Set ..tsUpdate = $ZDT($h,3,1)
	}
	Return $$$OK
}

Trigger triggerInsert [ Event = INSERT ]
{
	Set ({tsCreate},{tsUpdate}) = $ZDT($h,3,1)
}

Trigger triggerUpdate [ Event = UPDATE ]
{
	Set {tsUpdate} = $ZDT($h,3,1)
}

Storage Default
{
<Data name="DBSizeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>database</Value>
</Value>
<Value name="3">
<Value>dbSizeInMB</Value>
</Value>
<Value name="4">
<Value>freeSpaceInMB</Value>
</Value>
<Value name="5">
<Value>diskFreeSpaceInMB</Value>
</Value>
<Value name="6">
<Value>sizeDate</Value>
</Value>
<Value name="7">
<Value>recordType</Value>
</Value>
<Value name="8">
<Value>tsCreate</Value>
</Value>
<Value name="9">
<Value>tsUpdate</Value>
</Value>
</Data>
<DataLocation>^Iris.Tools.MonitorA859.DBSizeD</DataLocation>
<DefaultData>DBSizeDefaultData</DefaultData>
<IdLocation>^Iris.Tools.MonitorA859.DBSizeD</IdLocation>
<IndexLocation>^Iris.Tools.MonitorA859.DBSizeI</IndexLocation>
<StreamLocation>^Iris.Tools.MonitorA859.DBSizeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
