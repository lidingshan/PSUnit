﻿Import-Module $global:PSUnit_Home"\PSUnit.psm1"
Import-Module $global:PSUnit_Home"\asserts.psm1"

$global:setupIsCalled = $false
$global:testCaseIsCalled = $false
$global:teardownIsCalled = $false
$global:fixtureSetupIsCalled = $false
$global:fixtureTearDownIsCalled = $false

function setup()
{
	PSUnit_SetTestRoot ".\testdata\"
}

function test_get_testing_path()
{
	$expected = ".\testdata\"
	$actual = PSUnit_GetTestRoot
	
	assertAreEqual $expected $actual
}

function test_get_all_testscript_file()
{
	$testPath = PSUnit_GetTestRoot
	$files = dir $testPath
	[int]$expected = $files.length
	
	[array]$scriptFiles = PSUnit_GetTestScripts	
	[int]$actual = $scriptFiles.length
	
	assertAreEqual $expected $actual
}

function test_setup_called()
{
	$scriptFullPath = ".\testdata\test_script1.ps1"
	PSUnit_RunSetup $scriptFullPath "setup"
	assertIsTrue $global:setupIsCalled
}

function test_get_setup_method()
{
	$expected = "setup"
	$scriptFullPath = ".\testdata\test_script1.ps1"
	
	$actual = PSUnit_GetSetupMethod($scriptFullPath)
	
	assertAreEqual $expected $actual
}

function test_no_setup()
{
	$scriptFullPath = ".\testdata\test_script2.ps1"
	$actual = PSUnit_GetSetupMethod($scriptFullPath)
	
	assertIsNone $actual
}

function test_get_testcases()
{
	[int]$expected = 2
	
	$scriptFullPath = ".\testdata\test_script1.ps1"
	[array]$testCases = PSUnit_GetTestCases($scriptFullPath)
	$actual = $testCases.length
	
	assertAreEqual $expected $actual
	assertAreEqual "test_case1" $testCases[0]
}

function test_no_testcase()
{
	$scriptFullPath = ".\testdata\test_script3.ps1"
	[array]$testCases = PSUnit_GetTestCases($scriptFullPath)
	
	assertIsNone $testCases
}

function test_run_one_testcase()
{
	$scriptFullPath = ".\testdata\test_script1.ps1"
	$testCase = "test_case1"
	
	PSUnit_RunOneCase $scriptFullPath $testCase
	
	assertIsTrue $global:testCaseIsCalled
}

function test_expect_fail()
{
	$expected = "The test is set as failed"
	try
	{
		assertFail
	}
	catch [Exception]
	{
		assertAreEqual $expected $_.Exception.Message
	}
}

function test_expect_greater()
{
	$first = 3
	$second = 2
	assertAreGreater $first $second
}

function test_assert_greater_fail_throw_exception()
{
    $first = 3
    $second = 4
    
    $expected = "$first is not greater than $second"
    
    try
    {
        assertAreGreater $first $second
        assertFail
    }
    catch [Exception]
    {
        assertAreEqual $expected $_.Exception.Message
    }
}

function test_assert_less()
{
    $first = 3
    $second = 4
    assertAreLess $first $second
}

function test_assert_less_fail_throw_exception()
{
    $first = 4
    $second = 3
    
    $expected = "$first is not less than $second"
    
    try
    {
        assertAreLess $first $second
        assertFail
    }
    catch [Exception]
    {
        assertAreEqual $expected $_.Exception.Message
    }
}

function test_assert_isnot_null()
{
	$object = "not null"
	assertIsNotNull $object
}

function test_assert_isnot_null_fail_throw_exception()
{
	$expected = "The object is expected to be NOT NULL but it is"
	try
	{
		assertIsNotNull $null
	}
	catch [Exception]
	{
        assertAreEqual $expected $_.Exception.Message
	}
}

function test_get_teardown_method()
{
	$expected = "teardown"
	$scriptFullPath = ".\testdata\test_script1.ps1"
	
	$actual = PSUnit_GetTearDownMethod($scriptFullPath)
	
	assertAreEqual $expected $actual
}

function test_no_teardown()
{
	$scriptFullPath = ".\testdata\test_script2.ps1"	
	$actual = PSUnit_GetTearDownMethod($scriptFullPath)
	
	assertIsNone $actual
}

function test_teardown_iscalled()
{
	$scriptFullPath = ".\testdata\test_script1.ps1"
	PSUnit_RunTearDown $scriptFullPath "teardown"
	assertIsTrue $global:teardownIsCalled
}

function test_get_fixture_setup_method()
{
	$expected = "fixture_setup"
	$scriptFullPath = ".\testdata\test_script1.ps1"
	
	$actual = PSUnit_GetFixtureSetupMethod $scriptFullPath
	
	assertAreEqual $expected $actual
}

function test_fixture_setup_iscalled()
{
	$scriptFullPath = ".\testdata\test_script1.ps1"
	PSUnit_RunFxitureSetup $scriptFullPath "fixture_setup"
	assertIsTrue $global:fixtureSetupIsCalled
}

function test_get_fixture_teardown_method()
{
	$expected = "fixture_teardown"
	$scriptFullPath = ".\testdata\test_script1.ps1"
	
	$actual = PSUnit_GetFixtureTearDownMethod $scriptFullPath
	
	assertAreEqual $expected $actual
}

function test_fixture_teardown_iscalled()
{
	$scriptFullPath = ".\testdata\test_script1.ps1"
	PSUnit_RunFxitureTearDown $scriptFullPath "fixture_teardown"
	assertIsTrue $global:fixtureTearDownIsCalled
}