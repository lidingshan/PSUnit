Import-Module c:\workspace\PSUnit\asserts.psm1

function test_assert_pass()
{
	$expected = 3
	$actual = 1 + 2
	
	assertAreEqual $expected, $actual
}

function test_assert_fail()
{
	$expected = 3
	$actual = 1 + 1
	
	assertAreEqual $expected, $actual
}