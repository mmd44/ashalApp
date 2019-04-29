bool toBoolean(String str, bool defaultValue,[bool strict])
{
  if(str==null) return defaultValue;
  if (strict == true) {
    return str == '1' || str == 'true';
  }
  return str != '0' && str != 'false' && str != '';
}