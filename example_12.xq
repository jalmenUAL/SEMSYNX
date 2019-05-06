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
<author name="stsim:equal"/>
<title name="stsim:equal"/>
<conference name="stsim:equal"/>
<keywords name="stsim:equal"/>
<type name="stsim:equal"/>
</semantics>

(: SEMANTICS OF SECOND ARGUMENT :)

let $semantics2:=
<semantics>
<author name="stsim:equal"/>
<title name="stsim:equal"/>
<conference name="stsim:equal"/>
<keywords name="stsim:equal"/>
<type name="stsim:equal"/>
</semantics>


return 

for $result in
sim:Similarity(false(),
doc("/Users/jesusmanuelalmendrosjimenez/Dropbox/research/similarity/semsynx-2.0/datasets/papers/paper1.xml"),
doc("/Users/jesusmanuelalmendrosjimenez/Dropbox/research/similarity/semsynx-2.0/datasets/papers/paper2.xml"),
"paper","paper","@key","@key",
$equality,$similarity,
$relevance_value,$relevance_path,$threshold_path,
$semantics1,$semantics2,
("paper/author", "paper/title","paper/conference",
"paper/keywords","paper/type"),
("paper/author", "paper/title","paper/conference",
"paper/keywords","paper/type"),
$rel_main,$rel_sec,$rel_new) 
order by $result/@global_score descending
return $result[not(@global_score="NaN")] 
 

 