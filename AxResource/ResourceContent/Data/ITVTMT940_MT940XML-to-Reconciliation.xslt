<!-- This stylesheet converts the MT940 xml file to the schema of BankStmtISOService.
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
                xmlns:bsiso="http://schemas.microsoft.com/dynamics/2008/01/services/BankStmtService/"
                xmlns="http://schemas.microsoft.com/dynamics/2008/01/documents/BankStmt">
  <xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="utf-16"/>

  <xsl:template match ="/" >
    <Batch xmlns="http://schemas.microsoft.com/dynamics/2009/06/documents/Batch" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
      <Envelope xmlns="http://schemas.microsoft.com/dynamics/2011/01/documents/Message">
        <Header>
          <Action>http://tempuri.org/BankStmtService/create</Action>
        </Header>
        <Body>
          <MessageParts>
            <xsl:apply-templates/>
          </MessageParts>
        </Body>
      </Envelope>
    </Batch>
  </xsl:template>
  <!-- This template populates the top level table 'Document' (BankStmtISODocument) -->
  <xsl:template match ="BankStmtISO">
    <BankStmt>
      <Document  class="entity">
        <FormatName>MT940</FormatName>
        <FormatVersion>1</FormatVersion>
        <!--The header is empty-->
        <Header  class="entity">
        </Header>
        <xsl:call-template name="AccountHeader"/>
      </Document>
    </BankStmt>
  </xsl:template>
  <!-- This template populates the 'AccountStatement' table (BankStmtISOAccountStatement) -->
  <xsl:template name="AccountHeader">
    <xsl:for-each select="//HeaderAcccount">
      <xsl:variable name="accountHeader" select ="."></xsl:variable>
      <xsl:for-each select ="//StatementId[@accountGroup=$accountHeader/@accountGroup]">
        <xsl:variable name="statementHeader" select ="."></xsl:variable>
        <xsl:variable name="statementOpening" select ="//StatementOpening[@statementGroup=$statementHeader/@statementGroup]"/>
        <xsl:variable name="statementClosing" select ="//StatementClosing[@statementGroup=$statementHeader/@statementGroup]"/>
        <xsl:variable name="transactions" select="//Transaction[@statementGroup=$statementHeader/@statementGroup] "/>
        <AccountStatement  class="entity">
          <AccountCurrency>
            <xsl:value-of select ="normalize-space($accountHeader/AccountCurrency)"/>
          </AccountCurrency>
          <AccountIdOtherId>
            <xsl:value-of select ="normalize-space($accountHeader/AccountNumber)"/>
          </AccountIdOtherId>
          <BankStatementType>Reconciliation</BankStatementType>
          <FromDateTime>
            <xsl:value-of select ="bsiso:convertToDateTime($statementOpening/Date,'')"/>
          </FromDateTime>
          <IBAN>
            <xsl:value-of select="normalize-space($accountHeader/IBAN)"/>
          </IBAN>
          <Identification>
            <xsl:value-of select ="normalize-space($statementHeader/Id)"/>
          </Identification>
          <SequenceNumber>
            <xsl:value-of select= "normalize-space($statementHeader/SequenceNumber)"/>
          </SequenceNumber>
          <SwiftNo>
            <xsl:value-of select="normalize-space($accountHeader/BIC)"/>
          </SwiftNo>
          <ToDateTime>
            <xsl:value-of select ="bsiso:convertToDateTime($statementClosing/Date,'')"/>
          </ToDateTime>
          <!--Balance-->
          <xsl:call-template name ="CashBalance">
            <xsl:with-param name="balance" select ="$statementOpening">
            </xsl:with-param>
            <xsl:with-param name="type" select ="'Opening'">
            </xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name ="CashBalance">
            <xsl:with-param name="balance" select ="$statementClosing">
            </xsl:with-param>
            <xsl:with-param name="type" select ="'Closing'">
            </xsl:with-param>
          </xsl:call-template>
          <!--Transactions-->
          <xsl:call-template name ="ReportEntry">
            <xsl:with-param name="transactions" select ="$transactions">
            </xsl:with-param>
          </xsl:call-template>
        </AccountStatement>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- This template populates the table 'CashBalance' BankStatementISOCashBalance -->
  <xsl:template name="CashBalance">
    <xsl:param name="balance">
    </xsl:param>
    <xsl:param name="type">
    </xsl:param>
      <AccountStatementCashBalance class="entity">
        <AmountCreditDebitIndicator>
          <xsl:call-template name ="GetCreditDebitIndicator">
            <xsl:with-param name ="Direction" select ="normalize-space($balance/Direction)"></xsl:with-param>
          </xsl:call-template>
        </AmountCreditDebitIndicator>
        <BankStatementBalanceType>
          <xsl:value-of select ="$type"/>
        </BankStatementBalanceType>
        <CashBalanceAmount>
          <xsl:call-template name ="GetAmount">
            <xsl:with-param name="amount" select ="normalize-space($balance/Amount)"/>
          </xsl:call-template>
        </CashBalanceAmount>
      </AccountStatementCashBalance>
  </xsl:template>
  <xsl:template name="ReportEntry">
    <xsl:param name="transactions">
    </xsl:param>
    <xsl:for-each select ="$transactions">
      <AccountStatementReportEntry class="entity">
        <AdditionalEntryInformation>
          <xsl:value-of select="concat(normalize-space(TransactionText), ' ', normalize-space(TransactionDescription/TransactionDescription))"/>
        </AdditionalEntryInformation>
        <Amount>
          <xsl:call-template name ="GetAmount">
            <xsl:with-param name="amount" select ="normalize-space(Amount)"/>
          </xsl:call-template>
        </Amount>
        <AmountCreditDebitIndicator>
          <xsl:call-template name ="GetCreditDebitIndicator">
            <xsl:with-param name ="Direction" select ="normalize-space(FundsCode)"></xsl:with-param>
          </xsl:call-template>
        </AmountCreditDebitIndicator>
        <BankDocumentNumber>
          <xsl:value-of select="normalize-space(BankReference)"/>
        </BankDocumentNumber>
        
        <BankStatementCounterCurrency>
          <xsl:value-of select="normalize-space(TransactionDescription/CounterCurrency)"/>
        </BankStatementCounterCurrency>
        <BankStatementCounterCurrencyAmount>
          <xsl:call-template name ="GetAmount">
            <xsl:with-param name="amount" select ="normalize-space(TransactionDescription/CounterAmount)"/>
          </xsl:call-template>
        </BankStatementCounterCurrencyAmount>
        <BookingDateTime>
          <xsl:variable name="BookingDate">
            <xsl:choose>
              <xsl:when test="EntryDate = ''">
                <xsl:value-of select="Date"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat(substring(Date,1,2),EntryDate)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:value-of select="bsiso:convertToDateTime($BookingDate,'')"/>
        </BookingDateTime>
        <ProprietaryBankTransactionCode>
          <xsl:value-of select ="normalize-space(TypeCode)"/>
        </ProprietaryBankTransactionCode>
        <ReferenceNumber>
          <xsl:value-of select ="normalize-space(AccountOwnerReference)"/>
        </ReferenceNumber>
        <RelatedBankAccount>
          <xsl:value-of select ="normalize-space(CustVendAccount)"/>
        </RelatedBankAccount>
        <ReversalIndicator>
          <xsl:call-template name ="GetReversal">
            <xsl:with-param name ="Direction" select ="normalize-space(FundsCode)"></xsl:with-param>
          </xsl:call-template>
        </ReversalIndicator>
        <xsl:if test="CustVendNameSender != ''">
          <ReportEntryTradingParty class="entity">
            <xsl:call-template name ="PartyId">
              <xsl:with-param name ="OrgId" select ="normalize-space(CustVendNameSender)"></xsl:with-param>
            </xsl:call-template>
          </ReportEntryTradingParty>
        </xsl:if>
        <!--Start - Added for TKINF
        <xsl:call-template name="Refernces">
          <xsl:with-param name="Keys" select="$Keys" />
        </xsl:call-template>-->
        <xsl:if test="Key00 != ''">
          <ITVTMT940KeyField00>
            <xsl:value-of select="normalize-space(Key00)"/>
          </ITVTMT940KeyField00>
        </xsl:if>
        <xsl:if test="Key10 != ''">
          <ITVTMT940KeyField10>
            <xsl:value-of select="normalize-space(Key10)"/>
          </ITVTMT940KeyField10>
        </xsl:if>
        <xsl:if test="Key20 != ''">
          <ITVTMT940KeyField20>
              <xsl:value-of select="normalize-space(Key20)"/>
          </ITVTMT940KeyField20>
        </xsl:if>
        <xsl:if test="Key21 != ''">
          <ITVTMT940KeyField21>
              <xsl:value-of select="normalize-space(Key21)"/>
          </ITVTMT940KeyField21>
        </xsl:if>
        <xsl:if test="Key22 != ''">
          <ITVTMT940KeyField22>
            <xsl:value-of select="normalize-space(Key22)"/>
          </ITVTMT940KeyField22>
        </xsl:if>
        <xsl:if test="Key23 != ''">
          <ITVTMT940KeyField23>
            <xsl:value-of select="normalize-space(Key23)"/>
          </ITVTMT940KeyField23>
        </xsl:if>
        <xsl:if test="Key24 != ''">
          <ITVTMT940KeyField24>
            <xsl:value-of select="normalize-space(Key24)"/>
          </ITVTMT940KeyField24>
        </xsl:if>
        <xsl:if test="Key25 != ''">
          <ITVTMT940KeyField25>
            <xsl:value-of select="normalize-space(Key25)"/>
          </ITVTMT940KeyField25>
        </xsl:if>
        <xsl:if test="Key26 != ''">
          <ITVTMT940KeyField26>
            <xsl:value-of select="normalize-space(Key26)"/>
          </ITVTMT940KeyField26>
        </xsl:if>
        <xsl:if test="Key27 != ''">
          <ITVTMT940KeyField27>
            <xsl:value-of select="normalize-space(Key27)"/>
          </ITVTMT940KeyField27>
        </xsl:if>
        <xsl:if test="Key28 != ''">
          <ITVTMT940KeyField28>
            <xsl:value-of select="normalize-space(Key28)"/>
          </ITVTMT940KeyField28>
        </xsl:if>
        <xsl:if test="Key29 != ''">
          <ITVTMT940KeyField29>
            <xsl:value-of select="normalize-space(Key29)"/>
          </ITVTMT940KeyField29>
        </xsl:if>
        <xsl:if test="Key30 != ''">
          <ITVTMT940KeyField30>
            <xsl:value-of select="normalize-space(Key30)"/>
          </ITVTMT940KeyField30>
        </xsl:if>
        <xsl:if test="Key31 != ''">
          <ITVTMT940KeyField31>
            <xsl:value-of select="normalize-space(Key31)"/>
          </ITVTMT940KeyField31>
        </xsl:if>
        <xsl:if test="Key32 != ''">
          <ITVTMT940KeyField32>
            <xsl:value-of select="normalize-space(Key32)"/>
          </ITVTMT940KeyField32>
        </xsl:if>
        <xsl:if test="Key33 != ''">
          <ITVTMT940KeyField33>
            <xsl:value-of select="normalize-space(Key33)"/>
          </ITVTMT940KeyField33>
        </xsl:if>
        <xsl:if test="Key34 != ''">
          <ITVTMT940KeyField34>
            <xsl:value-of select="normalize-space(Key34)"/>
          </ITVTMT940KeyField34>
        </xsl:if>
        <xsl:if test="Key60 != ''">
          <ITVTMT940KeyField60>
            <xsl:value-of select="normalize-space(Key60)"/>
          </ITVTMT940KeyField60>
        </xsl:if>
          <xsl:if test="Key61 != ''">
          <ITVTMT940KeyField61>
            <xsl:value-of select="normalize-space(Key61)"/>
          </ITVTMT940KeyField61>
        </xsl:if>
        <xsl:if test="Key62 != ''">
          <ITVTMT940KeyField62>
            <xsl:value-of select="normalize-space(Key62)"/>
          </ITVTMT940KeyField62>
        </xsl:if>
        <xsl:if test="Key63 != ''">
          <ITVTMT940KeyField63>
              <xsl:value-of select="normalize-space(Key63)"/>
          </ITVTMT940KeyField63>
        </xsl:if>
        <!--Stop - Added for TKINF-->
      </AccountStatementReportEntry>
    </xsl:for-each>
  </xsl:template>
  
  <!-- This template populates the table 'PartyIdentification_*' (BankStatementISOPartyIdentification) -->
  <xsl:template name="PartyId">
    <xsl:param name ="OrgId" select ="''"/>
    <Name>
      <xsl:value-of select="$OrgId" />
    </Name>
    <PartyIdOrganisationGenericOrgId>
      <xsl:value-of select="$OrgId" />
    </PartyIdOrganisationGenericOrgId>
  </xsl:template>

  <xsl:template name="GetCreditDebitIndicator">
    <xsl:param name ="Direction" select ="''"/>
    <!--Reverse Debit Credit-->
    <xsl:choose>
      <xsl:when test="starts-with($Direction,'D') or starts-with($Direction,'RC')">
        <xsl:value-of select="'Debit'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'Credit'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="GetReversal">
    <xsl:param name ="Direction" select ="''"/>
    <xsl:choose>
      <xsl:when test="starts-with($Direction,'R')">
        <xsl:value-of select="'Yes'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'No'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="GetAmount">
    <xsl:param name ="amount" select ="''"/>
    <xsl:choose>
      <xsl:when test="$amount=''">
        <xsl:value-of select="'0'"/>
      </xsl:when>
      <xsl:when test="substring-after($amount,'.') = ''">
        <xsl:value-of select="concat($amount,'00')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$amount"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <msxsl:script language="C#" implements-prefix="bsiso">
    <![CDATA[
  public string convertToDateTime(string strDate, string strTime)
  {
  if (strDate == "") return "1900-01-01T00:00:00Z";
  if (strTime == "") strTime = "0000";
  string stringToConvert = strDate + strTime;
  DateTime dateTime = DateTime.ParseExact(stringToConvert, "yyMMddHHmm", System.Globalization.DateTimeFormatInfo.InvariantInfo);
  return dateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ");
  }
          ]]>
</msxsl:script>
  
</xsl:stylesheet>
