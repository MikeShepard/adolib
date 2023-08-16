function Get-ParamType{
    param([string]$typename)
        $type=switch -wildcard ($typename.ToLower()) {
            'uniqueidentifier' {[System.Data.SqlDbType]::UniqueIdentifier}
            'int'  {[System.Data.SQLDbType]::Int}
            'datetime'  {[System.Data.SQLDbType]::Datetime}
            'tinyint'  {[System.Data.SQLDbType]::tinyInt}
            'smallint'  {[System.Data.SQLDbType]::smallInt}
            'bigint'  {[System.Data.SQLDbType]::BigInt}
            'bit'  {[System.Data.SQLDbType]::Bit}
            'char*'  {[System.Data.SQLDbType]::char}
            'nchar*'  {[System.Data.SQLDbType]::nchar}
            'date'  {[System.Data.SQLDbType]::date}
            'datetime'  {[System.Data.SQLDbType]::datetime}
            'varchar*' {[System.Data.SqlDbType]::Varchar}
            'nvarchar*' {[System.Data.SqlDbType]::nVarchar}
            default {[System.Data.SqlDbType]::Int}
        }
        return $type
        
    }