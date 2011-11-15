$PSUNIT_HOME = Get-Location

Import-Module $PSUNIT_HOME"\PSUnit.psm1"

function getMethodName($methodDeclaration)
{
	$length = [int]$methodDeclaration.length
	$prefixLength = [int]"function ".length
	$suffixLength = [int]"()".length
	
	$subStringLength = $length - $prefixLength - $suffixLength
	$startPosition = $prefixLength
	
	return $methodDeclaration.SubString($startPosition, $subStringLength)
}

function WritePassMessage($testCase)
{
	$originalColor = $Host.UI.RawUI.ForegroundColor
	$Host.UI.RawUI.ForegroundColor = "Green"
	Write-Host "PASS" $testCase
	$Host.UI.RawUI.ForegroundColor = $originalColor
	
}

function WriteFaileMessage($testCase, $errorMsg)
{
	$originalColor = $Host.UI.RawUI.ForegroundColor
	$Host.UI.RawUI.ForegroundColor = "Red"
	Write-Host "FAIL" $testCase "`nError Message: " $errorMsg
	$Host.UI.RawUI.ForegroundColor = $originalColor
}


function Run($path)
{
	$directories = Get-ChildItem $path -Recurse		
	$scriptFiles = $directories | where {$_.name -like "test*.ps1" -and $_.name -ne "testRunner.ps1"}

	if (!$scriptFiles)
	{
		Write-Host "No tests executed"
		return
	}

	foreach($script in $scriptFiles)
	{
		$scriptFullPath = $script.fullname
		
		$setupMethod = Get-Content $scriptFullPath | where {$input -like "function setup*"}
		
		$testCases = Get-Content $scriptFullPath | where {$input -like "function test*"}
		
		foreach($testCase in $testCases)
		{
			$testCaseName = getMethodName $testCase	
			$currentCase = $scriptFullPath + " - " + $testCaseName
			
			try
			{
				if ($setupMethod -ne $null)
				{
					$setup = getMethodName $setupMethod
					$setupScriptBlock = ". " + $scriptFullPath + "; " + $setup
					Invoke-Expression $setupScriptBlock
				}
				
				$testCaseScriptBlock = ". " + $scriptFullPath + "; " + $testCaseName
				Invoke-Expression $testCaseScriptBlock
				
				WritePassMessage $currentCase
			}
			catch [Exception]
			{
				WriteFaileMessage $currentCase $_.Exception.Message
			}
		}
	}
}

$path = $args[0]
Run $path

