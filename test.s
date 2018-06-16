
	movi	$r0, 3000
	swi	$r0, [$sp + (4)]
	movi	$r0, 3000
	swi	$r0, [$sp + 0]
	lwi	$r1, [$sp + (4)]
	movi	$r0, 3
	divsr	$r0, $r1, $r1, $r0
	ori	$r2, $r0, 0
	lwi	$r1, [$sp + 0]
	movi	$r0, 3
	mul	$r0, $r1, $r0
	add	$r1, $r2, $r0
	lwi	$r0, [$sp + 0]
	sub	$r0, $r1, $r0
	swi	$r0, [$sp + 0]
	movi	$r0, 13
	movi	$r1, 1
	bal	digitalWrite
	lwi	$r0, [$sp + (4)]
	bal	delay
	movi	$r0, 13
	movi	$r1, 0
	bal	digitalWrite
	lwi	$r0, [$sp + 0]
	bal	delay
