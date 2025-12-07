(: Example XQuery :)
xquery version "1.0";
<Result_Example_XQuery>{

for $s in parse-xml(.)/staffinfo/job/title

return
    <JobTitle>{$s/job/title}</JobTitle>,
let $k := count(parse-xml(.)/staffinfo/job/title)
return
  <CountJobTitle> {$k} </CountJobTitle>

}</Result_Example_XQuery>
