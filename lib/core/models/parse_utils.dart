bool toBoolean(String str, [bool strict])
{
if(str==null) return true;

if (strict == true) {
return str == '1' || str == 'true';
}
return str != '0' && str != 'false' && str != '';
}