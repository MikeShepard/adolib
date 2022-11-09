 <#
      .SYNOPSIS
          Create a sql command object
  
      .DESCRIPTION
          This function uses the information contained in the parameters to create a sql command object.  In general, you will want to use the invoke- functions directly, 
          but if you need to manipulate a command object in ways that those functions don't allow, you will need this.  Also, the invoke-bulkcopy function allows you to pass 
          a command object instead of a set of records in order to "stream" the records into the destination in cases where there are a lot of records and you don't want to
          allocate memory to hold the entire result set.
  
      .PARAMETER  sql
          The sql to be executed by the command object (although it is not executed by this function).
  
      .PARAMETER  connection
          An existing connection to perform the sql statement with.  
  
      .PARAMETER  parameters
          A hashtable of input parameters to be supplied with the query.  See example 2. 
          
      .PARAMETER  timeout
          The commandtimeout value (in seconds).  The command will fail and be rolled back if it does not complete before the timeout occurs.
  
      .PARAMETER  Server
          The server to connect to.  If both Server and Connection are specified, Server is ignored.
  
      .PARAMETER  Database
          The initial database for the connection.  If both Database and Connection are specified, Database is ignored.
  
      .PARAMETER  User
          The sql user to use for the connection.  If both User and Connection are specified, User is ignored.
  
      .PARAMETER  Password
          The password for the sql user named by the User parameter.
  
      .PARAMETER  Transaction
          A transaction to execute the sql statement in.
  
      .EXAMPLE
          PS C:\> $cmd=new-sqlcommand "ALTER DATABASE AdventureWorks Modify Name = Northwind" -server MyServer
          PS C:\> $cmd.ExecuteNonQuery()
  
  
      .EXAMPLE
          PS C:\> $cmd=new-sqlcommand -server MyServer -sql "Select * from MyTable"
          PS C:\> invoke-sqlbulkcopy -records $cmd -server MyOtherServer -table CopyOfMyTable
  
      .INPUTS
          None.
          You cannot pipe objects to new-sqlcommand
  
      .OUTPUTS
          System.Data.SqlClient.SqlCommand
  
  #>
  function New-SQLCommand{
    param([Parameter(Mandatory=$true)][Alias('storedProcName')][string]$sql,
          [Parameter(ParameterSetName="SuppliedConnection")][System.Data.SqlClient.SQLConnection]$connection,
          [hashtable]$parameters=@{},
          [int]$timeout=30,
          [Parameter(ParameterSetName="AdHocConnection")][string]$server,
          [Parameter(ParameterSetName="AdHocConnection")][string]$database,
          [Parameter(ParameterSetName="AdHocConnection")][string]$user,
          [string]$password,
          [System.Data.SqlClient.SqlTransaction]$transaction=$null,
          [hashtable]$outparameters=@{})
       
        $dbconn=Get-Connection -conn $connection -server $server -database $database -user $user -password $password
        $close=($dbconn.State -eq [System.Data.ConnectionState]'Closed')
        if ($close) {
            $dbconn.Open()
        }	
        $cmd=new-object system.Data.SqlClient.SqlCommand($sql,$dbconn)
        $cmd.CommandTimeout=$timeout
        foreach($p in $parameters.Keys){
            $parm=$cmd.Parameters.AddWithValue("@$p",$parameters[$p])
            if (Test-NULL $parameters[$p]){
               $parm.Value=[DBNull]::Value
            }
        }
        Set-outputparameters $cmd $outparameters
    
        if ($transaction -is [System.Data.SqlClient.SqlTransaction]){
        $cmd.Transaction = $transaction
        }
        return $cmd
    
    
    }