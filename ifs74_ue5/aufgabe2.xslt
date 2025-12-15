<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="/">
        <html style="font-family: Arial;">
            <body>
                <h3>
                    New Employees
                </h3>
                <xsl:apply-templates select="/Firma/Abteilung"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="Abteilung">
        <xsl:variable name="count" select="count(Mitarbeiter[Einstellungsjahr = '2025'])"/>
        <xsl:variable name="employeeSum" select="count(Mitarbeiter)"/>

        <h4 style="margin-bottom:0;">Department:
            <xsl:value-of select="AbteilungsName"/>
        </h4>
        Location:
        <xsl:value-of select="Ort"/>
        <br/>
        Total Number Employees:
        <xsl:value-of select="count(Mitarbeiter)"/>
        <br/>


        <xsl:choose>
            <xsl:when test="$employeeSum = 0">
            </xsl:when>
            <xsl:otherwise>
                New Employees:
                <xsl:choose>
                    <xsl:when test="$count > 0">
                        <table style="border: 1px solid black;">
                            <tr>
                                <th style="border: 1px solid black; background-color: #ADD8E6;">EmpNo</th>
                                <th style="border: 1px solid black; background-color: #ADD8E6;">Name</th>
                                <th style="border: 1px solid black; background-color: #ADD8E6;">Weekly Salary</th>
                            </tr>
                            <xsl:apply-templates select="Mitarbeiter[Einstellungsjahr = '2025']"/>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <span style="color: red;">
                            No new employees in this department!
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="Mitarbeiter">
        <tr>
            <td style="border: 1px solid black;">
                <xsl:value-of select="Nr"/>
            </td>
            <td style="border: 1px solid black;">
                <xsl:value-of select="Name"/>
            </td>
            <td style="border: 1px solid black;">
                <xsl:value-of select="Gehalt"/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
