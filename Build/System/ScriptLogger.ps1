$global:errors = @()
$global:warnings = @()

function Log-Error {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$message,

        [parameter(Mandatory=$false)]
        [switch]$abort = $false
    )

    PROCESS {
        $global:errors += $message

		Write-Host $message -ForegroundColor Red
        
		if($abort) {
			exit 1
        }
    }
        
}

function Log-Warning {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$message
    )

    PROCESS {
        $global:warnings += $message

        $action = "continue"

        Write-Host $message -ForegroundColor Yellow
    }
        
}

function Write-Error-Summary {
    if($global:errors.Length -eq 0) {
        return
    }

    Write-Host "$($global:errors.Length+$Error.Count) ERRORS OCCURRED:" -ForegroundColor Red

    $global:errors | foreach { 
        Write-Host $_ -ForegroundColor Red
    }

    $Error[0] | Get-Member
    $Error | foreach {
        Write-Host "`n$($_)" -ForegroundColor Red
    }

    Write-Host "`n"
}

function Write-Warning-Summary {
    if($global:warnings.Length -eq 0) {
        return
    }

    Write-Host "`n$($global:warnings.Length) WARNINGS OCCURRED:" -ForegroundColor Yellow

    $global:warnings | foreach { 
        Write-Host $_ -ForegroundColor Yellow
    }

    Write-Host "`n"
}