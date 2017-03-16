IF EXISTS (SELECT name 
           FROM sys.xml_schema_collections
           WHERE name='JournalEntrySchema')
BEGIN
  DROP XML SCHEMA COLLECTION JournalEntrySchema
END

CREATE XML SCHEMA COLLECTION [JournalEntrySchema]
AS
'<xsd:schema xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:element name="JournalEntry">
    <xsd:complexType>
      <xsd:sequence>
        <xsd:element name="System">
          <xsd:simpleType>
            <xsd:restriction base="xsd:unsignedByte">
              <xsd:minInclusive value="1"/>
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:element>
        <xsd:element name="Type" minOccurs="1">
          <xsd:simpleType>
            <xsd:restriction base="xsd:token">
              <xsd:enumeration value="Diario"/>
              <xsd:enumeration value="Ingresos"/>
              <xsd:enumeration value="Egresos"/>
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:element>
        <xsd:element name="EffectiveDate" type="xsd:date" minOccurs="1"/>
        <xsd:element name="Concept" minOccurs="0">
          <xsd:simpleType>
            <xsd:restriction base="xsd:token">
              <xsd:maxLength value="50"/>
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:element>
        <xsd:element name="Reference" minOccurs="0">
          <xsd:simpleType>
            <xsd:restriction base="xsd:token">
              <xsd:maxLength value="50"/>
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:element>
        <xsd:element name="Records" minOccurs="1"  maxOccurs="unbounded">
          <xsd:complexType>
            <xsd:sequence>
              <xsd:element name="Record" minOccurs="1"  maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:sequence>
                    <xsd:element name="Account" minOccurs="1">
                      <xsd:simpleType>
                        <xsd:restriction base="xsd:token">
                          <xsd:pattern value="[0-9]{3}-[0-9]{3}-[0-9]{3}-[0-9]{4}"/>
                          <xsd:maxLength value="20"/>
                        </xsd:restriction>
                      </xsd:simpleType>
                    </xsd:element>
                    <xsd:element name="CostCenter" minOccurs="0">
                      <xsd:simpleType>
                        <xsd:restriction base="xsd:token">
                          <xsd:maxLength value="50"/>
                        </xsd:restriction>
                      </xsd:simpleType>
                    </xsd:element>
                    <xsd:element name="Debit" type="xsd:decimal" minOccurs="1"/>
                    <xsd:element name="Credit" type="xsd:decimal" minOccurs="1"/>
                    <xsd:element name="Concept" minOccurs="0">
                      <xsd:simpleType>
                        <xsd:restriction base="xsd:token">
                          <xsd:maxLength value="50"/>
                        </xsd:restriction>
                      </xsd:simpleType>
                    </xsd:element>
                    <xsd:element name="OriginalCurrency" minOccurs="0">
                      <xsd:simpleType>
                        <xsd:restriction base="xsd:token">
                          <xsd:enumeration value="Pesos"/>
                          <xsd:enumeration value="Dlls"/>
                        </xsd:restriction>
                      </xsd:simpleType>
                    </xsd:element>
                    <xsd:element name="OriginalExchangeRate" type="xsd:decimal" minOccurs="0"/>
                  </xsd:sequence>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
          </xsd:complexType>
        </xsd:element>
      </xsd:sequence>
    </xsd:complexType>
  </xsd:element>
</xsd:schema>'