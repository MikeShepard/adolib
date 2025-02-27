function Get-Connection{
    param([System.Data.SqlClient.SQLConnection]$conn,
          [string]$server,
          [string]$database,
          [string]$user,
          [string]$password,
          [string]$AccessToken)
        if (-not $conn){
            if ($server){
                $conn=New-Connection -server $server -database $database -user $user -password $password  -accesstoken $AccessToken
            } else {
                throw "No connection or connection information supplied"
            }
        }
        return $conn
    }
