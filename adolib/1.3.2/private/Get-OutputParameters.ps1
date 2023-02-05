function Get-Outputparameters{
    param([Parameter(Mandatory=$true)][System.Data.SqlClient.SQLCommand]$cmd,
          [Parameter(Mandatory=$true)][hashtable]$outparams)
        foreach($p in $cmd.Parameters){
            if ($p.Direction -eq [System.Data.ParameterDirection]::Output){
              $outparams[$p.ParameterName.Replace("@","")]=$p.Value
            }
        }
    }