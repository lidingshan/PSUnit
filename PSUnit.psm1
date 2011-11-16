
[string]$script:PSUnit_Root = ""
$script:PSUnit_TestCases = @{}

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
		$testCases[$index] = getMethodName($delcaration)
		$index = $index + 1
	}
	
	return $testCases
}

function PSUnit_GetOneTestCase($scriptPath, $testCase)
{
	$testCaseScriptBlock = ". " + $scriptFullPath + "; " + $testCase
	return $testCaseScriptBlock
}

function PSUnit_RunOneCase($scriptFullPath, $testCaseName)
{
	$testCaseScriptBlock = PSUnit_GetOneTestCase($scriptFullPath, $testCaseName)
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
	$originalColor = $Host.UI.RawUI.ForegroundColor
	$Host.UI.RawUI.ForegroundColor = "Green"
	Write-Host "PASS" $testCase
	$Host.UI.RawUI.ForegroundColor = $originalColor
	
}

function PSUnit_WriteFail($testCase, $errorMsg)
{
	$originalColor = $Host.UI.RawUI.ForegroundColor
	$Host.UI.RawUI.ForegroundColor = "Red"
	Write-Host "FAIL" $testCase "`n`tError Message: " $errorMsg
	$Host.UI.RawUI.ForegroundColor = $originalColor
}

function PSUnit_ExcecuteOneScriptFile($script)
{
	$scriptFullPath = $script.FullName
	
	$setupMethod = PSUnit_GetSetupMethod($scriptFullPath)
	$testCases = PSUnit_GetTestCases($scriptFullPath)
	
	foreach($testCase in $testCases)
	{
		$currentCase = $scriptFullPath + " - " + $testCase
		
		try
		{
			PSUnit_RunSetup $scriptFullPath $setupMethod				
			PSUnit_RunOneCase $scriptFullPath $testCase
			
			PSUnit_WritePass $currentCase
		}
		catch [Exception]
		{
			PSUnit_WriteFail $currentCase $_.Exception.Message
		}
	}
}

