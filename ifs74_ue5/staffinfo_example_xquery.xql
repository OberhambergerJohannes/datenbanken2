xquery version "1.0";
<Result_Example_XQuery>{

(:used parse-xml instead of doc() because otherwise, input was interpreted as string by editor :)
for $l in parse-xml(.)//location
where count($l//employee) > 20

return
    <location>
        <locationId>{data($l/@id)}</locationId>
        <city>{data($l/city)}</city>
    </location>
}</Result_Example_XQuery>
