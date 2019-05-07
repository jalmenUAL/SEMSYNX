import module namespace sim = "Similarity" at "semsynx-2.0.xq";


(: THRESHOLDS :)

let $equality := 1
let $similarity := 0.5
let $relevance_value := 1 
let $relevance_path := 0
let $threshold_path := 0
let $rel_main := 1
let $rel_sec := 0
let $rel_new := 0

(: SEMANTICS of FIRST DOCUMENT :)

let $semantics1:=
<semantics>
<name name="hsim:name"/>
<key name="hsim:key"/>
<star name="hsim:star"/>
<type name="hsim:type"/>
<airport_shuttle name="hsim:airport_suttle"/>
<spa name="hsim:spa"/>
<pool name="hsim:pool"/>
<restaurant name="hsim:restaurant"/>
<district name="hsim:district"/>
<price name="hsim:price"/>
<metro name="hsim:metro"/>
</semantics>

(: SEMANTICS OF SECOND ARGUMENT :)

let $semantics2:=
<semantics>
<name name="hsim:name"/>
<key name="hsim:key"/>
<star name="hsim:star"/>
<type name="hsim:type"/>
<airport_shuttle name="hsim:airport_suttle"/>
<spa name="hsim:spa"/>
<pool name="hsim:pool"/>
<restaurant name="hsim:restaurant"/>
<district name="hsim:district"/>
<price name="hsim:price"/>
<metro name="hsim:metro"/>
</semantics>


return 

for $result in
sim:Similarity(false(),
doc("/Users/jesusmanuelalmendrosjimenez/Dropbox/research/similarity/semsynx-2.0/datasets/hotels/hotel1.xml"),
doc("/Users/jesusmanuelalmendrosjimenez/Dropbox/research/similarity/semsynx-2.0/datasets/hotels/hotel2.xml"),
"property","property","@key","@key",
$equality,$similarity,
$relevance_value,$relevance_path,$threshold_path,
$semantics1,$semantics2,
("property/@key","property/name", "property/star","property/type",
"property/facility/airport_shuttle","property/facility/spa", 
"property/facility/pool","property/facility/restaurant",
"property/district", "property/price","property/metro"),
("property/@key","property/name", "property/star","property/type",
"property/facility/airport_shuttle","property/facility/spa", 
"property/facility/pool","property/facility/restaurant",
"property/district", "property/price","property/metro"),
$rel_main,$rel_sec,$rel_new) 
order by $result/@global_score descending
return $result[not(@global_score="NaN")] 
 

 