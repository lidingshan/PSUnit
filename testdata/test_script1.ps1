function fixture_setup()
{
	$global:fixtureSetupIsCalled = $true
}

function fixture_teardown()
{
	$global:fixtureTearDownIsCalled = $true
}

function setup()
{
	$global:setupIsCalled = $true
}

function teardown()
{
	$global:teardownIsCalled = $true
}

function test_case1()
{
	$global:testCaseIsCalled = $true
}

function test_case2()
{
	Write-Host "do nothing"
}
