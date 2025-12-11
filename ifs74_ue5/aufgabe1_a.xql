xquery version "1.0";
declare option output:method "xml";
declare option output:indent "yes";

<Result_Example_XQuery>{

for $location in doc("./Studium/3.Semester/Datenbanken2/UE/datenbanken2/ifs74_ue5/staffinfo.xml")//location
let $employees := $location/department/employee
where count($employees) > 20
return <location>
        <locationId> {data($location/@id)} </locationId>
        <city> {data($location/city)} </city>
    </location>
}</Result_Example_XQuery>
