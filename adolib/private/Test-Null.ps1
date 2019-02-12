<#
	.SYNOPSIS
		Tests to see if a value is a SQL NULL or not

	.DESCRIPTION
		Returns $true if the value is a SQL NULL.

	.PARAMETER  value
		The value to test

	

	.EXAMPLE
		PS C:\> Test-NULL $row.columnname

	
    .INPUTS
        None.
        You cannot pipe objects to New-Connection

	.OUTPUTS
		Boolean

#>
function Test-NULL{
    param([Parameter(Mandatory=$true)]$value)
    return  [System.DBNull]::Value.Equals($value)
  }