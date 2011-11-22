
[string]$script:PSUnit_Root = ""
[int]$script:PSUnit_SuccessCount = 0
[int]$script:PSUnit_FailedCount = 0

function PSUnit_SetTestRoot($testRoot) 
{ 
	if ($testRoot -eq $null -or $testRoot.length -eq 0)
	{
		$script:PSUnit_Root = Get-Location
	}
	else
	{
		$script:PSUnit_Root = $testRoot;
	}
} 

function PSUnit_GetTestRoot()
{
	return $script:PSUnit_Root
}

function PSUnit_GetTestScripts()
{
	$directories = Get-ChildItem $script:PSUnit_Root -Recurse
	
	[array]$scriptFiles = $directories | where {$_.name -like "test*.ps1" -and $_.name -ne "testRunner.ps1"}	
	return $scriptFiles
}

function PSUnit_GetSetupMethod($scriptFullPath)
{
	$setupFunction = Get-Content $scriptFullPath | where {$input -like "function setup*"}
	if ($setupFunction -eq $null)
	{
		return $null
	}
	
	$setupMethod = getMethodName $setupFunction
	
	return $setupMethod
}

function getMethodName($delcaration)
{
	$length = [int]$delcaration.length
	$prefixLength = [int]"function ".length
	$suffixLength = [int]"()".length
	
	$subStringLength = $length - $prefixLength - $suffixLength
	$startPosition = $prefixLength
	
	return $delcaration.SubString($startPosition, $subStringLength)
}

function PSUnit_GetTestCases($scriptFullPath)
{
	$declarations = Get-Content $scriptFullPath | where {$input -like "function test*"}
	if($declarations -eq $null)
	{
		return $null
	}
	
	[array]$testCases = $declarations
	
	[int]$index = 0
	foreach($delcaration in $declarations)
	{
		$testCases[$index] = getMethodName $delcaration 
		$index = $index + 1
	}
	
	return $testCases
}

function PSUnit_GetOneTestCase($scriptFullPath, $testCaseName)
{
#    Write-Host "5 - test case is $testCaseName"
    
	$testCaseScriptBlock = ". " + $scriptFullPath + ";" + $testCaseName
	return $testCaseScriptBlock
}

function PSUnit_RunOneCase($scriptFullPath, $testCaseName)
{
	$testCaseScriptBlock = PSUnit_GetOneTestCase $scriptFullPath $testCaseName 
	Invoke-Expression $testCaseScriptBlock
}

function PSUnit_RunSetup($scriptFullPath, $setupMethod)
{
	if($setupMethod -eq $null)
	{
		return
	}
	
	$setupScriptBlock = ". " + $scriptFullPath + "; " + $setupMethod
	Invoke-Expression $setupScriptBlock
}

function PSUnit_WritePass($testCase)
{
	WriteWithSuccessColor "PASS $testCase"
}

function PSUnit_WriteFail($testCase, $errorMsg)
{
	WriteWithFailColor "FAIL $testCase `n`tError Message: $errorMsg"
}

function PSUnit_ExcecuteOneScriptFile($script)
{
	$scriptFullPath = $script.FullName
	
	$setupMethod = PSUnit_GetSetupMethod $scriptFullPath
	$testCases = PSUnit_GetTestCases $scriptFullPath
	
	if ($testCases -eq $null)
	{
		return
	}
	
	foreach($testCase in $testCases)
	{
		$currentCase = $scriptFullPath + " - " + $testCase
		
		try
		{
			PSUnit_RunSetup $scriptFullPath $setupMethod
			PSUnit_RunOneCase $scriptFullPath $testCase
			
			PSUnit_WritePass $currentCase
			$script:PSUnit_SuccessCount = $script:PSUnit_SuccessCount + 1
		}
		catch [Exception]
		{
			PSUnit_WriteFail $currentCase $_.Exception.Message
			$script:PSUnit_FailedCount = $script:PSUnit_FailedCount + 1
		}
	}
}

function PSUnit_Run()
{
	$scriptFiles = PSUnit_GetTestScripts
	
	if (!$scriptFiles)
	{
		Write-Host "No tests executed"
		return
	}

	$script:PSUnit_SuccessCount = 0
	$script:PSUnit_FailedCount = 0
	
	Write-Host "==================================================================="
	Write-Host "Start testing $script:PSUnit_Root..."
	Write-Host "==================================================================="
	
	foreach($script in $scriptFiles)
	{
		PSUnit_ExcecuteOneScriptFile $script
	}
	
	Write-Host "==================================================================="
	Write-Host -NoNewline "Test completed: "
	WriteWithSuccessColor "Succeed - $script:PSUnit_SuccessCount, " $false
	WriteWithFailColor "Failed - $script:PSUnit_FailedCount" $false
	Write-Host
	Write-Host "==================================================================="
}

function WriteWithSuccessColor($msg, $isNewLine=$true)
{
	WriteWithSpecificColor $msg "Green" $isNewLine
}

function WriteWithFailColor($msg, $isNewLine=$true)
{
	WriteWithSpecificColor $msg "Red" $isNewLine
}

function WriteWithSpecificColor($msg, $color, $isNewLine)
{
	$originalColor = $Host.UI.RawUI.ForegroundColor
	$Host.UI.RawUI.ForegroundColor = $color
	
	if ($true -eq $isNewLine)
	{
		Write-Host $msg
	}
	else
	{
		Write-Host -NoNewline $msg
	}
	
	$Host.UI.RawUI.ForegroundColor = $originalColor
}

function PSUnit_GetSucceedCount()
{
	return $script:PSUnit_SuccessCount
}

function PSUnit_GetFailedCount()
{
	return $script:PSUnit_FailedCount
}
