xquery version "1.0";
<Result_c_XQuery>{

(:used parse-xml instead of doc() because otherwise, input was interpreted as string by editor :)
for $e in parse-xml(.)//employee, $m in parse-xml(.)//employee, $c in parse-xml(.)//country/name
where $c = "Canada" and $e/manager = $m/@id and $e/department != $m/department

return
    <employee>
        <employeeId>{data($e/@id)}</employeeId>
        <lastName>{data($e/lastname)}</lastName>
        <jobId>{data($j/@id)}</jobId>
        <jobTitle>{data($j/title)}</jobTitle>
        <salary>{data($e//salary)}</salary>
    </employee>
}</Result_c_XQuery>
