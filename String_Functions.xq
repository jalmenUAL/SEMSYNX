module namespace stsim = "String Functions";


import module namespace simc = "http://zorba.io/modules/data-cleaning/character-based-string-similarity" at "character-based-string-similarity.xq";
import module namespace simh = "http://zorba.io/modules/data-cleaning/hybrid-string-similarity"
at "hybrid-string-similarity.xq";

import module namespace set = "http://zorba.io/modules/data-cleaning/set-similarity" at "set-similarity.xq";


import module namespace simt = "http://zorba.io/modules/data-cleaning/token-based-string-similarity" at
"token-based-string-similarity.xq";


declare function stsim:equal($string1,$string2)
{
  if  ($string1=$string2) then 1 else 0
};

declare function stsim:same_keyphrase($string1,$string2,$range)
 {
 let $key1 := subsequence(stsim:keyphrase($string1)/word/@word,1,$range)
 let $key2 := subsequence(stsim:keyphrase($string2)/word/@word,1,$range)
 return   
 set:jaccard($key1,$key2)
 };
 
 declare function stsim:keyphrase($content)
 {
 
let $corpus := for $w in tokenize($content, '\W+') return lower-case($w)
let $wordList := distinct-values($corpus)
return
<words> {
for $w in $wordList
let $freq := count($corpus[. eq $w])
order by $freq descending
return <word word="{$w}" frequency="{$freq}"/>
}</words>
 };

declare function stsim:same_keyphrase($string1,$string2)
{
  stsim:same_keyphrase($string1,$string2,3)
};

declare function stsim:edit-distance($string1,$string2)
{
  simc:edit-distance($string1,$string2)
};

declare function stsim:jaro($string1,$string2)
{
  simc:jaro($string1,$string2)
};

declare function stsim:jaro-winkler($string1,$string2)
{
simc:jaro-winkler($string1, $string2, 4, 0.1 )
};

declare function stsim:needleman-wunsch($string1,$string2)
{
simc:needleman-wunsch($string1, $string2, 1, 1)
};

declare function stsim:cosine($string1,$string2)
{
simt:cosine($string1,$string2)
};

declare function stsim:dice-ngrams($string1,$string2)
{
simt:dice-ngrams($string1,$string2,5)
};

declare function stsim:overlap-ngrams($string1,$string2)
{
simt:overlap-ngrams($string1,$string2,5)  
};

declare function stsim:jaccard-ngrams($string1,$string2){
simt:jaccard-ngrams($string1,$string2,5)
};

declare function stsim:cosine-ngrams($string1,$string2)
{
  simt:cosine-ngrams($string1,$string2,5)
};

declare function stsim:dice-tokens($string1,$string2)
{
  simt:dice-tokens($string1,$string2," +")
};

declare function stsim:overlap-tokens($string1,$string2)
{
  simt:overlap-tokens($string1,$string2," +")
};

declare function stsim:jaccard-tokens($string1,$string2)
{
  simt:jaccard-tokens($string1,$string2," +")
};

declare function stsim:cosine-tokens($string1,$string2)
{
  simt:cosine-tokens($string1,$string2," +")
};

declare function stsim:monge-elkan-jaro-winkler($string1,$string2)
{
simh:monge-elkan-jaro-winkler($string1, $string2, 4, 0.1)
};

declare function stsim:soft-cosine-tokens-edit-distance($string1,$string2)
{
simh:soft-cosine-tokens-edit-distance($string1,$string2, " +", 0 )
};

declare function stsim:soft-cosine-tokens-jaro-winkler($string1,$string2)
{
simh:soft-cosine-tokens-jaro-winkler($string1, $string2, " +", 1, 4, 0.1 )
};

declare function stsim:soft-cosine-tokens-jaro($string1,$string2)
{
simh:soft-cosine-tokens-jaro($string1, $string2, " +", 1 )
};

declare function stsim:soft-cosine-tokens-metaphone($string1,$string2)
{
simh:soft-cosine-tokens-metaphone($string1, $string2, " +" )
};

declare function stsim:soft-cosine-tokens-soundex($string1,$string2)
{
simh:soft-cosine-tokens-soundex($string1, $string2, " +")
};
