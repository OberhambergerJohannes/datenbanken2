xquery version "1.0";
<Result_b_XQuery>{

(:used parse-xml instead of doc() because otherwise, input was interpreted as string by editor :)
for $e in parse-xml(.)//employee, $j in parse-xml(.)//job
where $e/jobid = $j/@id and $e//salary = $j/minsalary

return
    <employee>
        <employeeId>{data($e/@id)}</employeeId>
        <lastName>{data($e/lastname)}</lastName>
        <jobId>{data($j/@id)}</jobId>
        <jobTitle>{data($j/title)}</jobTitle>
        <salary>{data($e//salary)}</salary>
    </employee>
}</Result_b_XQuery>
