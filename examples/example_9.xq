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
<edition name="stsim:equal"/>
<price name="stsim:equal"/>
<editorial name="stsim:equal"/>
</semantics>

(: SEMANTICS OF SECOND ARGUMENT :)

let $semantics2:=
<semantics>
<first name="stsim:equal"/>
<second name="stsim:equal"/>
<edition_number name="stsim:equal"/>
<format name="stsim:equal"/>
<title name="stsim:equal"/>
<editorial name="stsim:equal"/>
<isbn name="stsim:equal"/>
</semantics>


return 

for $result in
sim:Similarity(false(),
doc("/Users/jesusmanuelalmendrosjimenez/Dropbox/research/similarity/semsynx-2.0/datasets/bibs/amazon.xml"),
doc("/Users/jesusmanuelalmendrosjimenez/Dropbox/research/similarity/semsynx-2.0/datasets/bibs/library.xml"),
"amazon/book","library/book","@key","@key",
$equality,$similarity,
$relevance_value,$relevance_path,$threshold_path,
$semantics1,$semantics2,
("book/author", "book/title","book/edition",
"book/price","book/editorial"),
("book/authors/first","book/authors/second", "book/edition_number","book/format",
"book/title","book/publisher/editorial", 
"book/publisher/isbn"),
$rel_main,$rel_sec,$rel_new) 
order by $result/@global_score descending
return $result[not(@global_score="NaN")] 
 

 