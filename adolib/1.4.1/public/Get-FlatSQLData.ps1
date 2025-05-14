function Get-FlatSQLData {
    [CmdletBinding()]
    Param([array]$data, $typename)
    

    if ($data) {
        $columns = $data[0].table.columns.ColumnName
        $data = $data | Select-Object -Property $columns

        if ($typename) {
            $data = $data | ForEach-Object { $_.PSTypeNames.Insert(0, $typename) | Out-Null; $_ }
        }
        $data
    }
    else {
        $null
    }
}
