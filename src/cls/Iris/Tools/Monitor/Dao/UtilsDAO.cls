Class Iris.Tools.Monitor.Dao.UtilsDAO
{
ClassMethod rsToCSVStream(ByRef stream As %Stream.GlobalCharacter,
	ByRef rs As %SQL.StatementResult) As %Status
{
	Set sc = $$$OK
	Set line="", sep=";", meta = rs.%GetMetadata(),nbColumn = meta.columnCount
	For i=1:1:nbColumn {
		Set line = line_meta.columns.GetAt(i).colName_sep, odbcType(i)=meta.columns.GetAt(i).ODBCType
	}
	Do stream.WriteLine(line)
	While rs.%Next() {
		Set line = ""
		For i=1:1:nbColumn {
			Set data = rs.%GetData(i)
			If (odbcType(i)=8) {
				Set:($e(data,1)=".") data=0_data
				Set:$Get(%ZDecimalPointIsComma)=1 data=$Replace(data,".",",")
			} 
			Set line = line_data_sep
		}
		Do stream.WriteLine(line)
	}
	Return sc
}
}