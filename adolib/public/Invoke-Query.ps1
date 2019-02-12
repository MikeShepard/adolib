
  <#
      .SYNOPSIS
          Execute a sql statement, returning the results of the query.  
  
      .DESCRIPTION
          This function executes a sql statement, using the parameters provided (both input and output) and returns the results of the query.  You may optionally 
          provide a connection or sufficient information to create a connection, as well as input and output parameters, command timeout value, and a transaction to join.
  
      .PARAMETER  sql
          The SQL Statement
  
      .PARAMETER  connection
          An existing connection to perform the sql statement with.  
  
      .PARAMETER  parameters
          A hashtable of input parameters to be supplied with the query.  See example 2. 
  
      .PARAMETER  outparameters
          A hashtable of input parameters to be supplied with the query.  Entries in the hashtable should have names that match the parameter names, and string values that are the type of the parameters. See example 3. 
          
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
          This is an example of a query that returns a single result.  
          PS C:\> $c=New-Connection '.\sqlexpress'
          PS C:\> $res=invoke-query 'select * from master.dbo.sysdatabases' -conn $c
          PS C:\> $res 
     .EXAMPLE
          This is an example of a query that returns 2 distinct result sets.  
          PS C:\> $c=New-Connection '.\sqlexpress'
          PS C:\> $res=invoke-query 'select * from master.dbo.sysdatabases; select * from master.dbo.sysservers' -conn $c
          PS C:\> $res.Tables[1]
      .EXAMPLE
          This is an example of a query that returns a single result and uses a parameter.  It also generates its own (ad hoc) connection.
          PS C:\> invoke-query 'select * from master.dbo.sysdatabases where name=@dbname' -param  @{dbname='master'} -server '.\sqlexpress' -database 'master'
  
       .INPUTS
          None.
          You cannot pipe objects to invoke-query
  
     .OUTPUTS
          Several possibilities (depending on the structure of the query and the presence of output variables)
          1.  A list of rows 
          2.  A dataset (for multi-result set queries)
          3.  An object that contains a dictionary of ouptut parameters and their values and either 1 or 2 (for queries that contain output parameters)
  #>
  function Invoke-Query{
    param( [Parameter(Mandatory=$true)][string]$sql,
           [Parameter(ParameterSetName="SuppliedConnection")][System.Data.SqlClient.SqlConnection]$connection,
           [hashtable]$parameters=@{},
           [hashtable]$outparameters=@{},
           [int]$timeout=30,
           [Parameter(ParameterSetName="AdHocConnection")][string]$server,
           [Parameter(ParameterSetName="AdHocConnection")][string]$database,
           [Parameter(ParameterSetName="AdHocConnection")][string]$user,
           [Parameter(ParameterSetName="AdHocConnection")][string]$password,
           [System.Data.SqlClient.SqlTransaction]$transaction=$null,
           [ValidateSet("DataSet", "DataTable", "DataRow", "Dynamic")] [string]$AsResult="Dynamic"
           )
        
        $connectionparameters=copy-hashtable $PSBoundParameters -exclude AsResult
        $cmd=new-sqlcommand @connectionparameters
        $ds=New-Object system.Data.DataSet
        $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
        $da.fill($ds) | Out-Null
        
        #if it was an ad hoc connection, close it
        if ($server){
           $cmd.connection.close()
        }
        get-outputparameters $cmd $outparameters
        switch ($AsResult)
        {
            'DataSet'   { $result = $ds }
            'DataTable' { $result = $ds.Tables }
            'DataRow'   { $result = $ds.Tables[0] }
            'Dynamic'   { $result = get-commandresults $ds $outparameters } 
        }
        return $result
    }