<# https://www.essential.exchange/2013/03/14/powershell-quick-script-finding-the-exchange-schema-version/ #>

$root = [ADSI]"LDAP://RootDSE"
$name = "CN=ms-Exch-Schema-Version-Pt," + $root.schemaNamingContext
$value = [ADSI]( "LDAP://" + $name )
"Exchange Schema Version = $( $value.rangeUpper )"