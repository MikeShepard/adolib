<#
      .SYNOPSIS
          Execute a sql statement, ignoring the result set.  Returns the number of rows modified by the statement (or -1 if it was not a DML staement)

      .DESCRIPTION
          This function executes a sql statement, using the parameters provided and returns the number of rows modified by the statement.  You may optionally
          provide a connection or sufficient information to create a connection, as well as input parameters, command timeout value, and a transaction to join.

      .PARAMETER  sql
          The SQL Statement

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
          PS C:\> invoke-sql "ALTER DATABASE AdventureWorks Modify Name = Northwind" -server MyServer


      .EXAMPLE
          PS C:\> $con=New-Connection MyServer
          PS C:\> invoke-sql "Update Table1 set Col1=null where TableID=@ID" -parameters @{ID=5}

      .INPUTS
          None.
          You cannot pipe objects to invoke-sql

      .OUTPUTS
          Integer

  #>
  function Invoke-Sql{
    param([Parameter(Mandatory=$true,Position=0)][string]$sql,
          [Parameter(ParameterSetName="SuppliedConnection")][System.Data.SqlClient.SQLConnection]$connection,
          [hashtable]$parameters=@{},
          [hashtable]$outparameters=@{},
          [Parameter(Position=4, Mandatory=$false)][int]$timeout=30,
          [Parameter(ParameterSetName="AdHocConnection")][string]$server,
          [Parameter(ParameterSetName="AdHocConnection")][string]$database,
          [Parameter(ParameterSetName="AdHocConnection")][string]$user,
          [Parameter(ParameterSetName="AdHocConnection")][string]$password,
          [Parameter(ParameterSetName="AdHocConnection")][string]$AccessToken,
          [System.Data.SqlClient.SqlTransaction]$transaction=$null)


           $cmd=new-sqlcommand @PSBoundParameters

           $result=$cmd.ExecuteNonQuery()
           #if it was an ad hoc connection, close it
           if ($server){
              $cmd.connection.close()
           }

           return $result

    }