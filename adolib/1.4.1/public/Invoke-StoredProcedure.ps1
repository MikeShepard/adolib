  <#
      .SYNOPSIS
          Execute a stored procedure, returning the results of the query.

      .DESCRIPTION
          This function executes a stored procedure, using the parameters provided (both input and output) and returns the results of the query.  You may optionally
          provide a connection or sufficient information to create a connection, as well as input and output parameters, command timeout value, and a transaction to join.

      .PARAMETER  sql
          The SQL Statement

      .PARAMETER  connection
          An existing connection to perform the sql statement with.

      .PARAMETER  parameters
          A hashtable of input parameters to be supplied with the query.  See example 2.

      .PARAMETER  outparameters
          A hashtable of input parameters to be supplied with the query.  Entries in the hashtable should have names that match the parameter names, and string values that are the type of the parameters.
          Note:  not all types are accounted for by the code. int, uniqueidentifier, varchar(n), and char(n) should all work, though.

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
          #Calling a simple stored procedure with no parameters
          PS C:\> $c=New-Connection -server '.\sqlexpress'
          PS C:\> invoke-storedprocedure 'sp_who2' -conn $c
      .EXAMPLE
          #Calling a stored procedure that has an output parameter and multiple result sets
          PS C:\> $c=New-Connection '.\sqlexpress'
          PS C:\> $res=invoke-storedprocedure -storedProcName 'AdventureWorks2008.dbo.stp_test' -outparameters @{LogID='int'} -conne $c
          PS C:\> $res.Results.Tables[1]
          PS C:\> $res.OutputParameters

          For reference, here's the stored procedure:
          CREATE procedure [dbo].[stp_test]
              @LogID int output
          as
              set @LogID=5
              select * from master.dbo.sysdatabases
              select * from master.dbo.sysservers
      .EXAMPLE
          #Calling a stored procedure that has an input parameter
          PS C:\> invoke-storedprocedure 'sp_who2' -conn $c -parameters @{loginame='sa'}
      .INPUTS
          None.
          You cannot pipe objects to invoke-storedprocedure

      .OUTPUTS
          Several possibilities (depending on the structure of the query and the presence of output variables)
          1.  A list of rows
          2.  A dataset (for multi-result set queries)
          3.  An object that contains a hashtables of ouptut parameters and their values and either 1 or 2 (for queries that contain output parameters)
  #>
  function Invoke-StoredProcedure{
    param([Parameter(Mandatory=$true)][string]$storedProcName,
          [Parameter(ParameterSetName="SuppliedConnection")][System.Data.SqlClient.SqlConnection]$connection,
          [hashtable] $parameters=@{},
          [hashtable]$outparameters=@{},
          [int]$timeout=30,
          [Parameter(ParameterSetName="AdHocConnection")][string]$server,
          [Parameter(ParameterSetName="AdHocConnection")][string]$database,
          [Parameter(ParameterSetName="AdHocConnection")][string]$user,
          [Parameter(ParameterSetName="AdHocConnection")][string]$password,
          [Parameter(ParameterSetName="AdHocConnection")][string]$AccessToken,
          [System.Data.SqlClient.SqlTransaction]$transaction=$null)

        $cmd=new-sqlcommand @PSBoundParameters
        $cmd.CommandType=[System.Data.CommandType]::StoredProcedure
        $ds=New-Object system.Data.DataSet
        $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
        $da.fill($ds) | out-null

        get-outputparameters $cmd $outparameters

        #if it was an ad hoc connection, close it
        if ($server){
           $cmd.connection.close()
        }

        return (get-commandresults $ds $outparameters)
    }
