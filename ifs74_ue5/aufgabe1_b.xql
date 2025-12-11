xquery version "1.0";
declare option output:method "xml";
declare option output:indent "yes";

<Result_b_XQuery>{
for $emp in doc("./Studium/3.Semester/Datenbanken2/UE/datenbanken2/ifs74_ue5/staffinfo.xml")//employee,
    $job in doc("./Studium/3.Semester/Datenbanken2/UE/datenbanken2/ifs74_ue5/staffinfo.xml")//job[@id = $emp/jobid]
    where $emp/salary = $job/minsalary
    return <employee>
               <employeeId>{data($emp/@id)}</employeeId>
               <lastName>{data($emp/lastname)}</lastName>
               <jobId>{data($job/@id)}</jobId>
               <jobTitle>{data($job/title)}</jobTitle>
               <salary>{data($emp//salary)}</salary>
           </employee>
}</Result_b_XQuery>
