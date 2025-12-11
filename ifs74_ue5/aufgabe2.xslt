<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <html style="font-family: Arial;">
            <body>
                <h1>New Employees</h1>
                <xsl:apply-templates select="Firma/Abteilung"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="Abteilung">
        <h3 style="margin-bottom:0">Department: <xsl:value-of select="AbteilungsName"/></h3>
        Location: <xsl:value-of select="Ort"/>
        <br>
            Total Number of Employees:
            <xsl:value-of select="count(Mitarbeiter)"/>
        </br>

        <xsl:variable name="newEmpCount" select="count(Mitarbeiter[Einstellungsjahr = 2025])"/>
        New Employees:
        <xsl:choose>
            <xsl:when test="count(Mitarbeiter) > 0">
                <xsl:choose>
                    <xsl:when test="$newEmpCount > 0">
                        <xsl:call-template name="empTable"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <span style="color:red">No new employees in this department</span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="empTable">
        <table style="border: 1px solid black;">
            <tr>
                <th style="border: 1px solid black; background-color: #ADD8E6;">EmpNo</th>
                <th style="border: 1px solid black; background-color: #ADD8E6;">Name</th>
                <th style="border: 1px solid black; background-color: #ADD8E6;">Weekly Salary</th>
            </tr>

            <xsl:for-each select="Mitarbeiter[Einstellungsjahr = 2025]">
                <tr>
                    <td style="border: 1px solid black; background-color: #FFFFFF;"><xsl:value-of select="Nr"/></td>
                    <td style="border: 1px solid black; background-color: #FFFFFF;"><xsl:value-of select="Name"/></td>
                    <td style="border: 1px solid black; background-color: #FFFFFF;"><xsl:value-of select="Gehalt"/></td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>

</xsl:stylesheet>
