xquery version "1.0";
declare option output:method "xml";
declare option output:indent "yes";

<Result_c_XQuery>{
for $emp in doc("./Studium/3.Semester/Datenbanken2/UE/datenbanken2/ifs74_ue5/staffinfo.xml")//country[name = "Canada"]//employee,
    $manager in doc("./Studium/3.Semester/Datenbanken2/UE/datenbanken2/ifs74_ue5/staffinfo.xml")//employee[@id = $emp/manager]
    where $emp/ancestor::department/@id = $manager/ancestor::department/@id
    return   <employee employeeId="{data($emp/@id)}">
                   <lastName>{data($emp/lastname)}</lastName>
                   <departmentId>{data($emp/ancestor::department/@id)}</departmentId>
                 <manager managerId="{data($manager/@id)}">
                   <lastName>{data($manager/lastname)}</lastName>
                   <departmentId>{data($manager/ancestor::department/@id)}</departmentId>
                 </manager>
               </employee>
}</Result_c_XQuery>
