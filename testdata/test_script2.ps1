Import-Module c:\workspace\PSUnit\asserts.psm1

function test_assert_pass()
{
	$expected = 3
	$actual = 1 + 2
	
	assertAreEqual $expected $actual
}

function test_assert_fail()
{
	try
	{
		assertFail
	}
	catch [Exception]
	{
	}
}


function test_fail()
{
	assertFail
}