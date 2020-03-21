/// Peristent class designed for store the growth of global size following one record per : <br/><ul>
/// <li>Day</li>
/// <li>Week</li>
/// <li>Month</li>
/// <li>Year</li>
/// </ul>
Class Iris.Tools.Monitor.Data.GlobalSize Extends (%Persistent, Iris.Tools.Monitor.Data.GSCommon)
{

/// Database reference (full directory, not database name).
Property database As %String(MAXLEN = 512) [ Required ];

/// Global reference<br/>
/// Use sql_global in SQL.
Property global As %String(MAXLEN = 511) [ Required, SqlFieldName = sql_global ];

/// Allocated size for the global in MB.
Property allocatedInMB As %Float(MINVAL = 0) [ Required ];

Index uniqueI On (uHlp, global, database, recordType) [ Unique ];

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
<Data name="GlobalSizeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>database</Value>
</Value>
<Value name="3">
<Value>global</Value>
</Value>
<Value name="4">
<Value>allocatedInMB</Value>
</Value>
<Value name="5">
<Value>sizeDate</Value>
</Value>
<Value name="6">
<Value>recordType</Value>
</Value>
<Value name="7">
<Value>tsCreate</Value>
</Value>
<Value name="8">
<Value>tsUpdate</Value>
</Value>
</Data>
<DataLocation>^Iris.Tools.MoniA859.GlobalSizeD</DataLocation>
<DefaultData>GlobalSizeDefaultData</DefaultData>
<IdLocation>^Iris.Tools.MoniA859.GlobalSizeD</IdLocation>
<IndexLocation>^Iris.Tools.MoniA859.GlobalSizeI</IndexLocation>
<StreamLocation>^Iris.Tools.MoniA859.GlobalSizeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
