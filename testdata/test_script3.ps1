﻿Import-Module c:\workspace\PSUnit\asserts.psm1

function script3_case1()
{
	$expected = 3
	$actual = 1 + 2
	
	assertAreEqual $expected $actual
}

function script3_case2()
{
	$expected = 6
	$actual = 6
	
	assertAreEqual $expected $actual
}
