
  <#
      .SYNOPSIS
          Create a SQLConnection object with the given parameters

      .DESCRIPTION
          This function creates a SQLConnection object, using the parameters provided to construct the connection string.  You may optionally provide the initial database, and SQL credentials (to use instead of NT Authentication).

      .PARAMETER  Server
          The name of the SQL Server to connect to.  To connect to a named instance, enclose the server name in quotes (e.g. "Laptop\SQLExpress")

      .PARAMETER  Database
          The InitialDatabase for the connection.

      .PARAMETER  User
          The SQLUser you wish to use for the connection (instead of using NT Authentication)

      .PARAMETER  Password
          The password for the user specified by the User parameter.

      .PARAMETER  Timeout
          The connection timeout (defaults to 0)

      .EXAMPLE
          PS C:\> New-Connection -server MYSERVER -database master

      .EXAMPLE
          PS C:\> Get-Something -server MYSERVER -user sa -password sapassword

      .INPUTS
          None.
          You cannot pipe objects to New-Connection

      .OUTPUTS
          System.Data.SqlClient.SQLConnection

  #>
  function New-Connection{
    param([Parameter(Mandatory=$true)][string]$server,
          [string]$database='',
          [string]$user='',
          [string]$password='',
          [int][Alias('ConnectTimeout')]$timeout,
          $AccessToken)

        if($database -ne ''){
          $dbclause="Database=$database;"
        }
        $conn=new-object System.Data.SqlClient.SQLConnection

        if ($AccessToken){
           #don't do anything
            $conn.ConnectionString="Server=$server;$dbclause;Pooling=false;MultipleActiveResultSets=true"
        }  elseif ($user -ne ''){
            $conn.ConnectionString="Server=$server;$dbclause`User ID=$user;Password=$password;Pooling=false;MultipleActiveResultSets=true"
        } else {
            $conn.ConnectionString="Server=$server;$dbclause`Integrated Security=True;MultipleActiveResultSets=true"
        }
        if($timeout){
            $conn.ConnectionString+=";Connection Timeout=$timeout"
        }
        if($accessToken){
          $conn.AccessToken = $AccessToken
        }
          $conn.Open()
        write-debug $conn.ConnectionString
        return $conn
    }
