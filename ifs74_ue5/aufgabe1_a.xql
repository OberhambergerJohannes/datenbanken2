xquery version "1.0";
<Result_Example_XQuery>{

(:used parse-xml because otherwise, the editor was throwing error when trying to execute :)
for $l in parse-xml(.)//location
where count($l//employee) > 20

return
    <location>
        <locationId>{data($l/@id)}</locationId>
        <city>{data($l/city)}</city>
    </location>
}</Result_Example_XQuery>
