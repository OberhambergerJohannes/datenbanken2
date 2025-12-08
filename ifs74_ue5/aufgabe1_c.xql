xquery version "1.0";
<Result_c_XQuery>{

(:used parse-xml instead of doc() because otherwise, input was interpreted as string by editor :)
for $e in parse-xml(.)//country[name = "Canada"]//employee, $m in parse-xml(.)//employee
where $e/manager = $m/@id and $e/ancestor::department/@id != $m/ancestor::department/@id

return
    <employee employeeId="{data($e/@id)}">
        <lastName>{data($e/lastname)}</lastName>
        <departmentId>{data($e/ancestor::department/@id)}</departmentId>
      <manager managerId="{data($m/@id)}">
        <lastName>{data($m/lastname)}</lastName>
        <departmentId>{data($m/ancestor::department/@id)}</departmentId>
      </manager>
    </employee>
}</Result_c_XQuery>
