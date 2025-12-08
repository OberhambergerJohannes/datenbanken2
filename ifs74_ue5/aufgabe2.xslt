<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="/">
        <html>
            <body>
                <h2>
                    New Employees
                </h2>
                <xsl:apply-templates select="/Firma/Abteilung"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="Abteilung">
        <xsl:variable name="count" select="count(Mitarbeiter[Einstellungsjahr = '2025'])"/>
        <h4>Department:
            <xsl:value-of select="AbteilungsName"/>
        </h4>
        Location:
        <xsl:value-of select="Ort"/><br/>
        Total Number Employees:
        <xsl:value-of select="count(Mitarbeiter)"/><br/>
        New Employees:

        <xsl:choose>
            <xsl:when test="$count > 0">
                <table width="640">
                    <tr>
                        <th>EmpNo</th>
                        <th>Name</th>
                        <th>Weekly Salary</th>
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
        <hr/>
    </xsl:template>

    <xsl:template match="Mitarbeiter">
        <tr>
            <td><xsl:value-of select="Nr"/></td>
            <td><xsl:value-of select="Name"/></td>
            <td><xsl:value-of select="Gehalt"/></td>
        </tr>
    </xsl:template>
</xsl:stylesheet>