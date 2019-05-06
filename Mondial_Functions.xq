module namespace msim = "Mondial Functions";

declare function msim:population($m1,$m2){min(($m1,$m2)) div max(($m1,$m2))};
declare function msim:area($m1,$m2){min(($m1,$m2)) div max(($m1,$m2))};
declare function msim:population_growth($m1,$m2){if (abs($m1 - $m2)<=1) then 1 else 0};
declare function msim:infant_mortality($m1,$m2){if (abs($m1 - $m2)<=1) then 1 else 0};
declare function msim:inflation($m1,$m2){if (abs($m1 - $m2)<=1) then 1 else 0};
declare function msim:government($m1,$m2){if ($m1=$m2) then 1 else 0};
declare function msim:languages($m1,$m2){if ($m1=$m2) then 1 else 0};
declare function msim:ethnicgroups($m1,$m2){if ($m1=$m2) then 1 else 0};
declare function msim:religions($m1,$m2){if ($m1=$m2) then 1 else 0};

 

