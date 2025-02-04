  <#
  Helper function figure out what kind of returned object to build from the results of a sql call (ds). 
  Options are:
      1.  Dataset   (multiple lists of rows)
      2.  Datatable (list of datarows)
      3.  Nothing (no rows and no output variables
      4.  Dataset with output parameter dictionary
      5.  Datatable with output parameter dictionary
      6.  A dictionary of output parameters
      
  
  #>
  function Get-CommandResults{
    param([Parameter(Mandatory=$true)][System.Data.Dataset]$ds, 
          [Parameter(Mandatory=$true)][HashTable]$outparams)   
    
        if ($ds.tables.count -eq 1){
            $retval= $ds.Tables[0]
        }
        elseif ($ds.tables.count -eq 0){
            $retval=$null
        } else {
            [system.Data.DataSet]$retval= $ds 
        }
        if ($outparams.Count -gt 0){
            if ($retval){
                return @{Results=$retval; OutputParameters=$outparams}
            } else {
                return $outparams
            }
        } else {
            return $retval
        }
    }