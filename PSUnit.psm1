
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
	$declaration = "function setup*"
	return GetSepcificMethod $scriptFullPath $declaration
}

function PSUnit_GetTearDownMethod($scriptFullPath)
{
	$declaration = "function teardown*"
	return GetSepcificMethod $scriptFullPath $declaration
}

function GetSepcificMethod($scriptFullPath, $delcaration)
{
	$functionName = Get-Content $scriptFullPath | where {$input -like $delcaration}
	if ($functionName -eq $null)
	{
		return $null
	}
	
	$method = GetMethodNameWithoutFunctionPrefix $functionName
	
	return $method	
}

function GetMethodNameWithoutFunctionPrefix($functionName)
{
	$length = [int]$functionName.length
	$prefixLength = [int]"function ".length
	$suffixLength = [int]"()".length
	
	$subStringLength = $length - $prefixLength - $suffixLength
	$startPosition = $prefixLength
	
	return $functionName.SubString($startPosition, $subStringLength)
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
		$testCases[$index] = GetMethodNameWithoutFunctionPrefix $delcaration 
		$index = $index + 1
	}
	
	return $testCases
}

function PSUnit_RunOneCase($scriptFullPath, $testCaseName)
{
	ExecuteFunction $scriptFullPath $testCaseName
}

function PSUnit_RunSetup($scriptFullPath, $setupMethod)
{
	ExecuteFunction $scriptFullPath $setupMethod
}

function PSUnit_RunTearDown($scriptFullPath, $teardownMethod)
{
	ExecuteFunction $scriptFullPath $teardownMethod
}

function ExecuteFunction($scriptFullPath, $methodName)
{
	if($methodName -eq $null)
	{
		return
	}
	
	$scriptBlock = ". " + $scriptFullPath + "; " + $methodName
	Invoke-Expression $scriptBlock
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
	
	$fixtureSetupMethod = PSUnit_GetFixtureSetupMethod $scriptFullPath
	$fixtureTearDownMethod = PSUnit_GetFixtureTearDownMethod $scriptFullPath
	$setupMethod = PSUnit_GetSetupMethod $scriptFullPath
	$testCases = PSUnit_GetTestCases $scriptFullPath
	$teardownMethod = PSUnit_GetTearDownMethod $scriptFullPath
	
	if ($testCases -eq $null)
	{
		return
	}
	
	PSUnit_RunFxitureSetup $scriptFullPath $fixtureSetupMethod
	
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
		
		PSUnit_RunTearDown $scriptFullPath $teardownMethod 
	}
	
	PSUnit_RunFxitureTearDown $scriptFullPath $fixtureTearDownMethod
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
	
	PSUnit_WriteOutputHead
	
	foreach($script in $scriptFiles)
	{
		PSUnit_ExcecuteOneScriptFile $script
	}
	
	PSUnit_WriteOutputFoot 
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

function PSUnit_WriteOutputHead()
{
	Write-Host "==================================================================="
	Write-Host "Start testing $script:PSUnit_Root..."
	Write-Host "==================================================================="
}

function PSUnit_WriteOutputFoot()
{
	$totalTestNumber = $script:PSUnit_SuccessCount + $script:PSUnit_FailedCount
	
	Write-Host "==================================================================="
	Write-Host -NoNewline "Total $totalTestNumber tests completed "
	
	if ($script:PSUnit_FailedCount -gt 0)
	{
		PSUnit_WriteFailedInfo
	}
	else
	{
		PSUnit_WriteSuccessInfo
	}
	
	Write-Host
	Write-Host "==================================================================="
}

function PSUnit_WriteSuccessInfo()
{
	$isNewLine = $false
	
	WriteWithSuccessColor "Successfully. " $isNewLine
	WriteWithSuccessColor "Succeed - $script:PSUnit_SuccessCount, " $isNewLine
	WriteWithSuccessColor "Failed - $script:PSUnit_FailedCount" $isNewLine
}

function PSUnit_WriteFailedInfo()
{
	$isNewLine = $false

	WriteWithFailColor "Failed. " $isNewLine
	WriteWithSuccessColor "Succeed - $script:PSUnit_SuccessCount, " $isNewLine
	WriteWithFailColor "Failed - $script:PSUnit_FailedCount" $isNewLine
}

function PSUnit_GetFixtureSetupMethod($scriptFullPath)
{
	$declaration = "function fixture_setup*"
	return GetSepcificMethod $scriptFullPath $declaration
}

function PSUnit_RunFxitureSetup($scriptFullPath, $fixtureSetupMethod)
{
	ExecuteFunction $scriptFullPath $fixtureSetupMethod
}

function PSUnit_GetFixtureTearDownMethod($scriptFullPath)
{
	$declaration = "function fixture_teardown*"
	return GetSepcificMethod $scriptFullPath $declaration
}

function PSUnit_RunFxitureTearDown($scriptFullPath, $fixtureTearDownMethod)
{
	ExecuteFunction $scriptFullPath $fixtureTearDownMethod
}