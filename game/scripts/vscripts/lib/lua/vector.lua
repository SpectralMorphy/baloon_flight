--[[



]]

function IsVector( v )
	return type( v ) == 'userdata' and tostring( v ):match('Vector') and v.x and v.y and v.z
end

function VectorCopy( v )
	return Vector( v.x, v.y, v.z )
end

function RandomVectorCircle( nMaxOffset )
	return RandomVector( RandomFloat( 0, 1 ) ^ 0.5 * nMaxOffset )
end