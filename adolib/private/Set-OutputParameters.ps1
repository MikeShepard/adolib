function Set-OutputParameters{
    param([Parameter(Mandatory=$true)][System.Data.SqlClient.SQLCommand]$cmd, 
          [hashtable]$outparams)
        if ($outparams){
            foreach($outp in $outparams.Keys){
                $paramtype=get-paramtype $outparams[$outp]
                $p=$cmd.Parameters.Add("@$outp",$paramtype)
                $p.Direction=[System.Data.ParameterDirection]::Output
                if ($paramtype -like '*char*'){
                   $p.Size=[int]$outparams[$outp].Replace($paramtype.ToString().ToLower(),'').Replace('(','').Replace(')','')
                }
            }
        }
    }