function New-AZSqlAccessToken{
    [CmdletBinding()]
    Param($TenantID,
          [Alias('AppID')]$ClientID,
          $ClientSecret
          )

          $resourceAppIdURI = 'https://database.windows.net'

          $tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.windows.net/$($TenantID)/oauth2/token" -Body @{
            grant_type='client_credentials'
            resource=$resourceAppIdURI
            client_id=$clientID
            client_secret=$clientSecret
            } -ContentType 'application/x-www-form-urlencoded'

        $tokenResponse.access_token
}