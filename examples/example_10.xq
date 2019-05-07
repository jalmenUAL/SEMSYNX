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
<familyname name="stsim:equal"/>
<firstname name="stsim:equal"/>
<age name="stsim:equal"/>
<address name="stsim:equal"/>
<city name="stsim:equal"/>
<description name="stsim:equal"/>
</semantics>

(: SEMANTICS OF SECOND ARGUMENT :)

let $semantics2:=
<semantics>
<familyname name="stsim:equal"/>
<firstname name="stsim:equal"/>
<age name="stsim:equal"/>
<city name="stsim:equal"/>
<street name="stsim:equal"/>
</semantics>


return 

for $result in
sim:Similarity(false(),
doc("/Users/jesusmanuelalmendrosjimenez/Dropbox/research/similarity/semsynx-2.0/datasets/examples/example1.xml"),
doc("/Users/jesusmanuelalmendrosjimenez/Dropbox/research/similarity/semsynx-2.0/datasets/examples/example2.xml"),
"example/member","example/member","@key","@key",
$equality,$similarity,
$relevance_value,$relevance_path,$threshold_path,
$semantics1,$semantics2,
("member/familyname", "member/firstname","member/age",
"member/address","member/city","member/description"),
("member/personal_info/name/familyname","member/personal_info/name/firstname", "member/personal_info/age","member/personal_info/postal_address/street","member/personal_info/postal_address/city"),
$rel_main,$rel_sec,$rel_new) 
order by $result/@global_score descending
return $result[not(@global_score="NaN")] 
 

 