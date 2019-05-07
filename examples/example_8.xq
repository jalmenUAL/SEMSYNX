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

let $semantics1:=
<semantics>
<population name="msim:population"/>
<total_area name="msim:area"/>
<population_growth name="msim:population_growth"/>
<infant_mortality name="msim:infant_mortality"/>
<inflation name="msim:inflation"/>
<government name="msim:government"/>
<languages name="msim:languages"/>
<ethnicgroups name="msim:ethnicgroups"/>
<religions name="msim:religions"/>
</semantics>

let $semantics2:=
<semantics>
<population name="msim:population"/>
<total_area name="msim:area"/>
<population_growth name="msim:population_growth"/>
<infant_mortality name="msim:infant_mortality"/>
<inflation name="msim:inflation"/>
<government name="msim:government"/>
<languages name="msim:languages"/>
<ethnicgroups name="msim:ethnicgroups"/>
<religions name="msim:religions"/>
</semantics>

for $result in
sim:Similarity(false(),
doc("/Users/jesusmanuelalmendrosjimenez/Dropbox/research/similarity/semsynx-2.0/datasets/mondial/mondial-3.0.xml"),
doc("/Users/jesusmanuelalmendrosjimenez/Dropbox/research/similarity/semsynx-2.0/datasets/mondial/italy2.xml"),
"mondial/country","country","@key","@key",
$equality,$similarity,$relevance_value,$relevance_path,$threshold_path,
$semantics1,$semantics2,
("country/@population","country/@total_area","country/@population_growth","country/@infant_mortality","country/@inflation","country/@government","country/languages","country/ethnicgroups","country/religions"
),
((:"country/@population","country/@total_area":)
"country/@population_growth","country/@infant_mortality","country/@inflation","country/@government","country/languages","country/ethnicgroups","country/religions"),
$rel_main,$rel_sec,$rel_new) 

order by $result/@global_score descending
return $result[not(@global_score="NaN")]