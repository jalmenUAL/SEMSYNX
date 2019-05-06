module namespace sim = "Similarity";

import module namespace stsim = "String Functions" at "String_Functions.xq";
import module namespace hsim = "Hotels Functions" at "Hotels_Functions.xq";
import module namespace msim = "Mondial Functions" at "Mondial_Functions.xq";

 


 
 

 
(: EQUAL WORDS :)

declare function sim:equal_word($word1,$word2)
{
$word1=$word2
};

(: FIND PATH :)

declare function sim:find_path($path,$name,$listp)
{
  if (empty($listp)) then false()
  else if ($path=head($listp) or 
        ($path=substring-before(head($listp),'/@')) and $name=substring-after(head($listp),'/@')) 
       then true()
       else sim:find_path($path,$name,tail($listp))
};
 
(: EVAL WHERE :) 
 
 declare function sim:eval_where($args1,$args2,$key1,$key2){
     let $query := 'declare variable $xml external; declare variable $xml2 external; $xml'
     let $vars  := map { '$xml':= $args2, '$xml2' := $args1 }
     return     
     xquery:eval($query  || '/' || $key1 || "=" || "$xml2" || '/' || $key2, $vars)
 };

(: EVAL PATH :)

declare function sim:eval_path($doc,$path)
{
  let $query := 'declare variable $xml external; $xml'
     let $vars  := map { '$xml':= $doc }
     return   
     xquery:eval($query || '/' || $path  , $vars)
}; 

(: PATH TO NODE :)

declare function sim:path-to-node
  ( $nodes as node()* )  as xs:string* {

$nodes/string-join(ancestor-or-self::*/name(.), '/')
 } ;
 
(: SEMANTICS :) 
 
declare function sim:semantics($name,$sem)
{
  data($sem/*[name(.)=$name]/@name)
};

(: SCORE :)
 
declare function sim:Score($item1,$item2,$name1,$name2,$sem1,$sem2)
{
let $fun1 := sim:semantics($name1,$sem1)
let $fun2 := sim:semantics($name2,$sem2)
return
  if (empty($fun1)) then 0
  else if (empty($fun2)) then 0
        else
        if ($fun1=$fun2) then
        let $op := function-lookup(xs:QName($fun1),2)
        return $op($item1,$item2)
        else 0
};

(: SCORE PATH :)

declare function sim:Score_path($path1,$path2)
{
  let $split1 := count(sim:split_path($path1))
  let $split2 := count(sim:split_path($path2))
  let $div := max(($split1,$split2))
  return sim:Score_path_equal($path1,$path2) div $div
  
};

(: IS A NUMBER :)
 

declare function sim:is-a-number
  ( $value as xs:anyAtomicType? )  as xs:boolean {
   string(number($value)) != 'NaN'
 } ;
 
(: DISTINCT ELEMENT PATHS :)

declare function sim:distinct-element-paths
  ( $nodes as node()* )  as xs:string* {
   distinct-values(sim:path-to-node($nodes/descendant-or-self::*))
 } ;
 
(: DISTINCT ATTRIBUTE NAMES :) 
 
declare function sim:distinct-attribute-names
  ( $nodes as node()* )  as xs:string* {

   distinct-values($nodes//@*/name(.))
 } ;

(: DISTINCT ELEMENT NAMES :)
 
declare function sim:distinct-element-names
  ( $nodes as node()* )  as xs:string* {

   distinct-values($nodes/descendant-or-self::*/name(.))
 } ;

(: SCORE PATH EQUAL :)

declare function sim:Score_path_equal($path1,$path2)
{
  if ($path1="" and $path2="") then 0
  else if ($path1="" and not($path2="")) then 0
  else if ($path2="" and not($path1="")) then 0
  else  
  if (substring-before($path1,'/')="") 
       then
         if (substring-before($path2,'/')="") 
         then 
             if (sim:equal_word($path1,$path2)) then 1
             else 0
         else sim:Score_path_equal($path1,substring-after($path2,'/')) 
       else 
       if (substring-before($path2,'/')="") then 
             sim:Score_path_equal(substring-after($path1,'/'),$path2)  
       else
       if (sim:equal_word(substring-before($path1,'/'),substring-before($path2,'/')))
       then 
       let $one := (1+sim:Score_path_equal(substring-after($path1,'/'),substring-after($path2,'/')))  
       let $two := sim:Score_path_equal($path1,substring-after($path2,'/'))  
       let $three := sim:Score_path_equal(substring-after($path1,'/'),$path2)  
       return
       max(($one,$two,$three))
       else
       let $one := (sim:Score_path_equal(substring-after($path1,'/'),substring-after($path2,'/')))  
       let $two := sim:Score_path_equal($path1,substring-after($path2,'/'))  
       let $three := sim:Score_path_equal(substring-after($path1,'/'),$path2)  
       return
       max(($one,$two,$three))
  
 
};

(: SPLIT PATH :)

declare function sim:split_path($path)
{
if (substring-after($path,'/')="") then $path
else (substring-before($path,'/'),sim:split_path(substring-after($path,'/')))  
};

(: PATH TO NODE 2:)
 
declare function sim:path-to-node-2($path2,$p2)
{
sim:path-to-node-2-rec(sim:path-to-node($path2),$p2)
};

(: PATH TO NODE 2 REC :)

declare function sim:path-to-node-2-rec($path2,$p2)
{
  if (substring-after($p2,'/')="") then $path2
  else sim:path-to-node-2-rec(substring-after($path2,'/'),substring-after($p2,'/'))
};

(: NEW :)

declare function sim:new($path1,$path2,$p1,$p2,$theq,$thp,$sem1,$sem2)
{
(for $element1 in $path1//*[not(*)] where 
      (every $element2 in $path2//*[not(*)] union $path2/@* 
        satisfies 
        (not(sim:equal_word(name($element1),name($element2))) 
          and sim:Score(data($element1),data($element2),name($element1),name($element2),$sem1,$sem2)<$theq
          or (sim:Score_path(sim:path-to-node-2($element1,$p1),sim:path-to-node-2($element2,$p2)) < $thp))
)
return 
  <new>
    <path>{$p1}</path>
    <subpath>{sim:path-to-node-2($element1,$p1)}</subpath>
  </new>
)
union
(for $element1 in $path1/@*  where 
       (every $element2 in $path2//*[not(*)] union $path2/@* 
         satisfies 
          (not(sim:equal_word(name($element1),name($element2))) 
            and sim:Score(data($element1),data($element2),name($element1),name($element2),$sem1,$sem2)<$theq))
return 
    <new>
        <path>{$p1}</path>
        <attribute>{name($element1)}</attribute>
        <subpath>{sim:path-to-node-2($element1,$p1)}</subpath>
    </new>
)
};

 
declare function sim:EqLabelandContent($item1,$item2,$p1,$p2,
              $theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
{
let $main:=(
      if (sim:find_path(sim:path-to-node-2($item1,$p1),name($item1),$listp1)
         and sim:find_path(sim:path-to-node-2($item2,$p2),name($item2),$listp2))
      then true()
      else false()
)
return 
if (sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))>=$thp) 
    then
      if (sim:equal_word(name($item1),name($item2)) and 
      sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$theq) 
      then 
      let $score := ($r1*sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2) 
      + $r2*sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))) div ($r1+$r2) 
      return
          if (sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$ths)
          then
          <EqLabelandContent score="{$score}" main="{$main}">
          <item>
          <path>{ sim:path-to-node-2($item1,$p1)}</path>
          <content >{data($item1)}</content>
          </item>
          <item>
          <path>{ sim:path-to-node-2($item2,$p2)}</path>
          <content >{data($item2)}</content>
          </item>
          </EqLabelandContent> 
          else
          <EqLabelandSimilarContent score="{$score}" main="{$main}">
          <item>
          <path>{ sim:path-to-node-2($item1,$p1)}</path>
          <content >{data($item1)}</content>
          </item>
          <item>
          <path>{ sim:path-to-node-2($item2,$p2)}</path>
          <content >{data($item2)}</content>
          </item>
          </EqLabelandSimilarContent>
    else <no/>
 else <no/>

};

declare function sim:EqAttributeandContent($item1,$item2,$p1,$p2,
            $theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
{
let $main:=(
if (sim:find_path(sim:path-to-node-2($item1,$p1),name($item1),$listp1)
     and sim:find_path(sim:path-to-node-2($item2,$p2),name($item2),$listp2))
then true()
else false()
)
return
      if (sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))>=$thp) 
      then
        if (sim:equal_word(name($item1),name($item2)) and 
        sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$theq) 
        then 
        let $score :=  ($r1*sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2) 
        + $r2*sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))) div ($r1+$r2)
        return
          if (sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$ths) 
          then
            <EqAttributeandContent score="{$score}" main="{$main}">
            <item>
            <path>{ sim:path-to-node-2($item1,$p1)}</path>
            <attribute>{name($item1)}</attribute>
            <content >{data($item1)}</content>
            </item>
            <item>
            <path>{ sim:path-to-node-2($item2,$p2)}</path>
            <attribute>{name($item2)}</attribute>
            <content >{data($item2)}</content>
            </item>
            </EqAttributeandContent> 
          else
            <EqAttributeandSimilarContent score="{$score}" main="{$main}">
            <item>
            <path>{ sim:path-to-node-2($item1,$p1)}</path>
            <attribute>{name($item1)}</attribute>
            <content >{data($item1)}</content>
            </item>
            <item>
            <path>{ sim:path-to-node-2($item2,$p2)}</path>
            <attribute>{name($item2)}</attribute>
            <content >{data($item2)}</content>
            </item>
            </EqAttributeandSimilarContent>
     else <no/>
else <no/>

};

declare function sim:EqAttributeLabelandContent($item1,$item2,$p1,$p2,
            $theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
{
let $main:=(
if (sim:find_path(sim:path-to-node-2($item1,$p1),name($item1),$listp1)
   and sim:find_path(sim:path-to-node-2($item2,$p2),name($item2),$listp2))
then true()
else false()
)
return
        if (sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))>=$thp) 
        then
            if ( sim:equal_word(name($item1),name($item2)) 
            and sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$theq) 
            then 
              let $score := ($r1*sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2) 
              + $r2*sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))) 
              div ($r1+$r2)
            return
              if (sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$ths) 
              then
              <EqAttributeLabelandContent score="{$score}" main="{$main}">
              <item>
              <path>{ sim:path-to-node-2($item1,$p1)}</path>
              <attribute>{name($item1)}</attribute>
              </item>
              <path>{ sim:path-to-node-2($item2,$p2)}</path>
              <content >{data($item1)}</content>
              </EqAttributeLabelandContent> 
              else
              <EqAttributeLabelandSimilarContent score="{$score}" main="{$main}">
              <attribute>{name($item1)}</attribute>
              <item>
              <path>{ sim:path-to-node-2($item1,$p1)}</path>
              <content >{data($item1)}</content>
              </item>
              <item>
              <path>{ sim:path-to-node-2($item2,$p2)}</path>
              <content >{data($item2)}</content>
              </item>
              </EqAttributeLabelandSimilarContent>
    else <no/>
else <no/>

};

declare function sim:EqLabel($item1,$item2,$p1,$p2,
          $theq,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
{
let $main:=(
if (sim:find_path(sim:path-to-node-2($item1,$p1),name($item1),$listp1)
   and sim:find_path(sim:path-to-node-2($item2,$p2),name($item2),$listp2))
then true()
else false()
)
return
      if (sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))>=$thp) 
      then
          if ( sim:equal_word(name($item1),name($item2)) 
          and sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)<$theq) 
          then
            let $score :=  ($r1*sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2) 
            + $r2*sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))) 
            div ($r1+$r2)
            return
              <EqLabelandDistinctValue score="{$score}" main="{$main}">
              <item>
              <path>{ sim:path-to-node-2($item1,$p1)}</path>
              <content>{data($item1)}</content>
              </item>
              <item>
              <path>{ sim:path-to-node-2($item2,$p2)}</path>
              <content>{data($item2)}</content>
              </item> 
              </EqLabelandDistinctValue>
        else <no/>
    else <no/>

};

declare function sim:EqAttribute($item1,$item2,$p1,$p2,
              $theq,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
{
let $main:=(
if (sim:find_path(sim:path-to-node-2($item1,$p1),name($item1),$listp1)
   and sim:find_path(sim:path-to-node-2($item2,$p2),name($item2),$listp2))
then true()
else false()
)
return
        if (sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))>=$thp) 
        then
            if ( sim:equal_word(name($item1),name($item2)) 
              and sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)<$theq) 
            then
            let $score :=  ($r1*sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2) 
                + $r2*sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))) 
                div ($r1+$r2)
            return
              <EqAttributeandDistinctValue score="{$score}" main="{$main}">
              <item>
              <path>{ sim:path-to-node-2($item1,$p1)}</path>
              <attribute>{name($item1)}</attribute>
              <content>{data($item1)}</content>
              </item>
              <item>
              <path>{ sim:path-to-node-2($item2,$p2)}</path>
              <attribute>{name($item2)}</attribute>
              <content>{data($item2)}</content>
              </item> 
              </EqAttributeandDistinctValue>
          else <no/>
      else <no/>

};

declare function sim:EqAttributeLabel($item1,$item2,$p1,$p2,
            $theq,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
{
let $main:=(
if (sim:find_path(sim:path-to-node-2($item1,$p1),name($item1),$listp1)
   and sim:find_path(sim:path-to-node-2($item2,$p2),name($item2),$listp2))
then true()
else false()
)
return
      if (sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))>=$thp) 
      then
        if ( sim:equal_word(name($item1),name($item2)) 
              and sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)<$theq) 
        then
          let $score :=  ($r1*sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2) 
          + $r2*sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))) 
          div ($r1+$r2)
          return
            <EqAttributeLabelandDistinctValue score="{$score}" main="{$main}">
            <item>
            <path>{ sim:path-to-node-2($item1,$p1)}</path>
            <attribute>{name($item1)}</attribute>
            <content>{data($item1)}</content>
            </item>
            <item>
            <path>{ sim:path-to-node-2($item2,$p2)}</path>
            <content>{data($item2)}</content>
            </item> 
            </EqAttributeLabelandDistinctValue>
      else <no/>
    else <no/>
};


declare function sim:EqContentofLabels($item1,$item2,$p1,$p2,
          $theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
{
let $main:=(
if (sim:find_path(sim:path-to-node-2($item1,$p1),name($item1),$listp1)
   and sim:find_path(sim:path-to-node-2($item2,$p2),name($item2),$listp2))
then true()
else false()
)
return
      if (sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))>=$thp) 
      then
          if (not ( sim:equal_word(name($item1),name($item2))) 
          and sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$theq) 
          then 
          let $score :=  ($r1*sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2) 
              + $r2*sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))) 
              div ($r1+$r2) 
          return
              if (sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$ths)
              then
                <EqValueandDistinctLabel score="{$score}" main="{$main}">
                <item>
                <content >{data($item1)}</content>
                <path>{ sim:path-to-node-2($item1,$p1)}</path>
                </item>
                <item>
                <content >{data($item2)}</content>
                <path>{ sim:path-to-node-2($item2,$p2)}</path>
                </item>
                </EqValueandDistinctLabel>
              else
                <SimilarValueandDistinctLabel score="{$score}" main="{$main}">
                <item>
                <content >{data($item1)}</content>
                <path>{ sim:path-to-node-2($item1,$p1)}</path>
                </item>
                <item>
                <content >{data($item2)}</content>
                <path>{ sim:path-to-node-2($item2,$p2)}</path>
                </item>
                </SimilarValueandDistinctLabel>
          else <no/>
      else <no/>

};

declare function sim:EqContentofAttributes($item1,$item2,$p1,$p2,
            $theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
{
let $main:=(
if (sim:find_path(sim:path-to-node-2($item1,$p1),name($item1),$listp1)
   and sim:find_path(sim:path-to-node-2($item2,$p2),name($item2),$listp2))
then true()
else false()
)
return
        if (sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))>=$thp) 
        then
            if (not (sim:equal_word(name($item1),name($item2))) 
                and sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$theq) 
            then 
            let $score :=  ($r1*sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2) 
              + $r2*sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2)))
              div ($r1+$r2)
            return
                if (sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$ths) 
                then
                  <EqValueandDistinctAttribute score="{$score}" main="{$main}">
                  <content >{data($item1)}</content>
                  <item>
                  <path>{ sim:path-to-node-2($item1,$p1)}</path>
                  <attribute>{name($item1)}</attribute>
                  </item>
                  <item>
                  <path>{ sim:path-to-node-2($item2,$p2)}</path>
                  <attribute>{name($item2)}</attribute>
                  </item>
                  </EqValueandDistinctAttribute>
                else
                  <SimilarValueandDistinctAttribute score="{$score}" main="{$main}">
                  <item>
                  <path>{ sim:path-to-node-2($item1,$p1)}</path>
                  <attribute>{name($item1)}</attribute>
                  <content >{data($item1)}</content>
                  </item>
                  <item>
                  <path>{ sim:path-to-node-2($item2,$p2)}</path>
                  <attribute>{name($item2)}</attribute>
                  <content >{data($item2)}</content>
                  </item>
                  </SimilarValueandDistinctAttribute>
            else <no/>
      else <no/>

};

declare function sim:EqContentofAttributeLabel($item1,$item2,$p1,$p2,
            $theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
{
let $main:=(
if (sim:find_path(sim:path-to-node-2($item1,$p1),name($item1),$listp1)
   and sim:find_path(sim:path-to-node-2($item2,$p2),name($item2),$listp2))
then true()
else false()
)
return
if (sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))>=$thp) 
then
      if (not (sim:equal_word(name($item1),name($item2))) 
          and sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$theq) 
      then
          let $score :=  ($r1*sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2) 
              + $r2*sim:Score_path(sim:path-to-node-2($item1,$p1),sim:path-to-node-2($item2,$p2))) 
              div ($r1+$r2)
          return 
          if (sim:Score(data($item1),data($item2),name($item1),name($item2),$sem1,$sem2)>=$ths) 
          then
            <EqValueandDistinctAttributeLabel score="{$score}" main="{$main}">
            <content >{data($item1)}</content>
            <item>
            <path>{ sim:path-to-node-2($item1,$p1)}</path>
            <attribute>{name($item1)}</attribute>
            </item>
            <item>
            <path>{ sim:path-to-node-2($item2,$p2)}</path>
            <attribute>{name($item2)}</attribute>
            </item>
            </EqValueandDistinctAttributeLabel>
          else
            <SimilarValueandDistinctAttributeLabel score="{$score}" main="{$main}">
            <item>
            <path>{ sim:path-to-node-2($item1,$p1)}</path>
            <attribute>{name($item1)}</attribute>
            <content >{data($item1)}</content>
            </item>
            <item>
            <path>{ sim:path-to-node-2($item2,$p2)}</path>
            <content >{data($item2)}</content>
            </item>
            </SimilarValueandDistinctAttributeLabel>
      else <no/>
    else <no/>

};

declare function 
sim:Analysis($key,$file1,$file2,$p1,$p2,$key1,$key2,$theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
{
 
let $analysis:=
(
for $path1 in sim:eval_path($file1,$p1)  
for $path2 in sim:eval_path($file2,$p2) 
where not($key) or sim:eval_where($path1,$path2,$key1,$key2) 
return
<result>
{
 (
  for $element1 in $path1//*[not(*)]   return 
  for $element2 in $path2//*[not(*)]  return
  let $sim1 := 
    sim:EqLabelandContent($element1,$element2,$p1,$p2,$theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
     return
     if (name($sim1)="no") 
     then
     let $sim2 := 
     sim:EqLabel($element1,$element2,$p1,$p2,$theq,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
     return
     if (name($sim2)="no") then
     let $sim3 := 
     sim:EqContentofLabels($element1,$element2,$p1,$p2,$theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
     return 
     if (name($sim3)="no") then () 
     else $sim3
     else $sim2
     else $sim1
)
union
(
for $element1 in $path1/@*  return 
for $element2 in $path2/@* return
  let $sim1 := 
  sim:EqAttributeandContent($element1,$element2,$p1,$p2,$theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
  return
    if (name($sim1)="no") then
      let $sim2 := 
      sim:EqAttribute($element1,$element2,$p1,$p2,$theq,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
      return
        if (name($sim2)="no") then
            let $sim3 := 
           sim:EqContentofAttributes($element1,$element2,$p1,$p2,$theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
            return
            if (name($sim3)="no") then ()
         else $sim3
      else $sim2
  else $sim1
)
union
(
for $element1 in $path1//*[not(*)]  return 
for $element2 in $path2/@* return
    let $sim1 := 
        sim:EqAttributeLabelandContent($element2,$element1,$p1,$p2,$theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
    return
      if (name($sim1)="no") then
          let $sim2 := 
          sim:EqAttributeLabel($element2,$element1,$p1,$p2,$theq,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
          return
            if (name($sim2)="no") then
                let $sim3 := 
                sim:EqContentofAttributeLabel($element2,$element1,$p1,$p2,$theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
                return 
            if (name($sim3)="no") then ()
              else $sim3
                  else $sim2
                      else $sim1
)
union
(
for $element1 in $path1/@*  return 
for $element2 in $path2//*[not(*)] return
let $sim1 := sim:EqAttributeLabelandContent($element1,$element2,$p1,$p2,$theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
return
if (name($sim1)="no") then
let $sim2 := sim:EqAttributeLabel($element1,$element2,$p1,$p2,$theq,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
return
if (name($sim2)="no") then
let $sim3 := sim:EqContentofAttributeLabel($element1,$element2,$p1,$p2,$theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
return 
if (name($sim3)="no") then ()
else $sim3
else $sim2
else $sim1

)

union
sim:new($path1,$path2,$p1,$p2,$theq,$thp,$sem1,$sem2)
union
sim:new($path2,$path1,$p2,$p1,$theq,$thp,$sem1,$sem2)

}

</result>

)
return $analysis

};

declare function sim:Similarity($key,$file1,$file2,$p1,$p2,$key1,$key2,
      $theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2,$rel_main,$rel_sec,$rel_new)
{
let $analysis :=
sim:Analysis($key,$file1,$file2,$p1,$p2,$key1,$key2,$theq,$ths,$r1,$r2,$thp,$sem1,$sem2,$listp1,$listp2)
return
for $result in $analysis
let $count_new := count($result/new)
let $count_main := count($result/*[not(name(.)="new") and @main=true()])
let $count_not_main := count($result/*[not(name(.)="new") and @main=false()])
let $num_main := sum($result/*[@main=true()]/@score)
let $num_not_main := sum($result/*[@main=false()]/@score)
let $den := $rel_new*$count_new + $rel_main*$count_main + $rel_sec*$count_not_main
let $count_not_new := $count_main + $count_not_main
let $score_diss := ($num_main*$rel_main + $rel_sec*$num_not_main) div $den
return
<result global_score="{$score_diss}"
dissimilar ="{$count_new}" similar="{$count_not_new}" >
{$result/*}
</result>

};

 


