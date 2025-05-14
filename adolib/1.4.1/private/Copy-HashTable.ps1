

  
  function Copy-HashTable{
    param([hashtable]$hash,
    [String[]]$include,
    [String[]]$exclude)
    
        if($include){
           $newhash=@{}
           foreach ($key in $include){
            if ($hash.ContainsKey($key)){
                   $newhash.Add($key,$hash[$key]) | Out-Null 
            }
           }
        } else {
           $newhash=$hash.Clone()
           if ($exclude){
               foreach ($key in $exclude){
                    if ($newhash.ContainsKey($key)) {
                           $newhash.Remove($key) | Out-Null 
                    }
               }
           }
        }
        return $newhash
    }