------------------------------------------------------------
-- Ordered list of files to require

local tFiles = {
	'functions',
	'map',
	'physics',
	'material',
	'camera',
}

------------------------------------------------------------
-- Root path

local sRoot = 'settings/'

------------------------------------------------------------
-- Requiring

for _, sPath in ipairs( tFiles ) do
	require( sRoot .. sPath )
end