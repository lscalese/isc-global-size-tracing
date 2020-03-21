Class Iris.Tools.Monitor.Data.GSCommon [ Abstract ]
{
/// Timestamp of record creation.
Property tsCreate As %TimeStamp;

/// Timestamp of last record update.
Property tsUpdate As %TimeStamp;

/// Define the record type.  For a Global & database, there are differents records
/// possible value are : <br/><table>
/// <thead><tr><th>Value</th><th>Description</th></tr></thead>
/// <tr><td>Day</td><td>Measure for a day (see <b>sizedate</b> property for the date)</td></tr>
/// <tr><td>Week</td><td>Mesasure for a week. The record is updated every day until the end of the Week</td></tr>
/// <tr><td>Month</td><td>Mesasure for a Month. The record is updated every day until the end of the Month</td></tr>
/// <tr><td>Year</td><td>Mesasure for a Year. The record is updated every day until the end of the Year</td></tr>
/// </table>
Property recordType As %String (VALUELIST=",Day,Week,Month,Year") [ Required ];

/// The year in 4 digits.
Property year As %Integer [ Calculated, SqlComputed, SqlComputeCode = { Set {*} = ##class(Iris.Tools.Monitor.Data.GlobalSize).yearExp({sizeDate}) } ];

/// The month number...
Property month As %Integer[ Calculated, SqlComputed, SqlComputeCode = { Set {*} = ##class(Iris.Tools.Monitor.Data.GlobalSize).monthExp({sizeDate}) } ];

/// the week number.
Property week As %Integer [ Calculated, SqlComputed, SqlComputeCode = { Set {*} = ##class(Iris.Tools.Monitor.Data.GlobalSize).weekExp({sizeDate})  } ];

/// Special property used as an helper for record unicity and facilited SQL search.
/// The value depend of <b>recordType</b><br/><table>
/// <thead><tr><th>Recordtype</th><th>uHlp</th></tr></thead>
/// <tr><td>Day</td><td>sizeDate value</td></tr>
/// <tr><td>Week</td><td>Year concatenate with Week number in 6 digits (ex : 201914)</td></tr>
/// <tr><td>Month</td><td>Year concatenate with Month number in 6 digits (ex : 201904)</td></tr>
/// <tr><td>Year</td><td>Year in 4 digits</td></tr>
/// </table>
Property uHlp As %Integer [ Calculated, SqlComputed, SqlComputeCode = { Set {*} = ##class(Iris.Tools.Monitor.Data.GlobalSize).cmUHlpGet({recordType},{sizeDate})}];

/// Date of measure.
Property sizeDate As %Date;

Method yearGet() As %Integer
{
	Return ..yearExp(..sizeDate)
}

Method monthGet() As %Integer
{
	Return ..monthExp(..sizeDate)
}

Method weekGet() As %Integer
{
	Return ..weekExp(..sizeDate)
}

Method uHlpGet() As %Integer
{
	Return ..cmUHlpGet(..recordType,..sizeDate)
}

ClassMethod cmUHlpGet(recordType As %String,sizeDate As %Date) As %String
{
	Return:recordType="Day" +sizeDate
	Return:recordType="Week" +(..yearExp(.sizeDate)_$Replace($Justify(..weekExp(.sizeDate),2)," ","0"))
	Return:recordType="Month" +(..yearExp(.sizeDate)_$Replace($Justify(..monthExp(.sizeDate),2)," ","0"))
	Return:recordType="Year" +(..yearExp(.sizeDate))
	$$$ThrowStatus($$$ERROR($$$GeneralError,$$$FormatText("recordType %1 not implemented",recordType)))
}

ClassMethod yearExp(sizeDate As %Date) As %Integer [ CodeMode = Expression ]
{
	+$Piece($zd(sizeDate,3),"-",1)
}

ClassMethod monthExp(sizeDate As %Date) As %Integer [ CodeMode = Expression ]
{
	+$Piece($zd(sizeDate,3),"-",2)
}

ClassMethod weekExp(sizeDate As %Date) As %Integer [ CodeMode = Expression ]
{
	##class(%SYSTEM.SQL).WEEK(sizeDate)
}

}