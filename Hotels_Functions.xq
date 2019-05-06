module namespace hsim = "Hotels Functions";

declare function hsim:name($name1,$name2){
  if ($name1=$name2) then 1 else 0
};

declare function hsim:key($k1,$k2){
  if ($k1=$k2) then 1 else 0
};

declare function hsim:star($star1,$star2){
  if (abs($star1 - $star2)>=1) then 0 else 1
};

declare function hsim:type($type1,$type2){
  if ($type1=$type2) then 1 else 0
};

declare function hsim:airport_suttle($a1,$a2)
{
  if ($a1 = $a2) then 1 else 0
};

declare function hsim:spa($a1,$a2)
{
  if ($a1 = $a2) then 1 else 0
};

declare function hsim:pool($a1,$a2)
{
  if ($a1 = $a2) then 1 else if ($a1="outdoor" and $a2="indoor")
  then 0.5 else if ($a1="indoor" and $a2="outdoor") then 0.5 else 0
};

declare function hsim:restaurant($a1,$a2)
{
  if ($a1 = $a2) then 1 else 0
};

declare function hsim:district($a1,$a2)
{
  if ($a1 = $a2) then 1 else 0
};

declare function hsim:price($a1,$a2)
{
  (:
  if (abs($a1 - $a2) >= 20) then 1 else 0
  :)
  min(($a1,$a2)) div max(($a1,$a2))
  
};

declare function hsim:metro($a1,$a2)
{
  if (abs($a1 - $a2) <= 500) then 1 else 0
};

