<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt"
  xmlns:batch="http://schemas.microsoft.com/dynamics/2009/06/documents/Batch"
  xmlns:bai2="http://schemas.microsoft.com/dynamics/2008/01/services/BankStmtService/"
  xmlns:msg="http://schemas.microsoft.com/dynamics/2011/01/documents/Message"
  xmlns:bs="http://schemas.microsoft.com/dynamics/2008/01/documents/BankStmt"
  exclude-result-prefixes="msxsl batch bai2 msg bs">
  <xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="utf-8"/>

  <xsl:template match="/">
    <Document>
      <xsl:call-template name="Document"/>
    </Document>
  </xsl:template>

  <xsl:template name="Document">
    <xsl:for-each select="batch:Batch/msg:Envelope/msg:Body/msg:MessageParts/bs:BankStmt/bs:Document">
      <BankStatementDocumentEntity>
        <xsl:variable name="docNum">
          <xsl:value-of  select="position()"></xsl:value-of>
        </xsl:variable>
        <DocumentLineNum>
          <xsl:value-of select ="normalize-space($docNum)"/>
        </DocumentLineNum>
        <FormatName>
          <xsl:value-of select ="normalize-space(bs:FormatName)"/>
        </FormatName>
        <FormatVersion>
          <xsl:value-of select ="normalize-space(bs:FormatVersion)"/>
        </FormatVersion>
        <BlockSize>
          <xsl:value-of select ="normalize-space(bs:Header/bs:BlockSize)"/>
        </BlockSize>
        <CreationDateTime>
          <xsl:value-of select ="bs:trimDateTime(bs:Header/bs:CreationDateTime)"/>
        </CreationDateTime>
        <MessageIdentification>
          <xsl:value-of select ="normalize-space(bs:Header/bs:MessageIdentification)"/>
        </MessageIdentification>
        <PhysicalRecordLength>
          <xsl:value-of select ="normalize-space(bs:Header/bs:PhysicalRecordLength)"/>
        </PhysicalRecordLength>
        <SenderName>
          <xsl:value-of select ="normalize-space(bs:Header/bs:Sender/bs:Name)"/>
        </SenderName>
        <SenderId>
          <xsl:value-of select ="normalize-space(bs:Header/bs:Sender/bs:PartyIdOrganisationGenericOrgId)"/>
        </SenderId>
        <RecipientName>
          <xsl:value-of select ="normalize-space(bs:Header/bs:Recipient/bs:Name)"/>
        </RecipientName>
        <RecipientId>
          <xsl:value-of select ="normalize-space(bs:Header/bs:Recipient/bs:PartyIdOrganisationGenericOrgId)"/>
        </RecipientId>
        <xsl:call-template name="Statement">
          <xsl:with-param name ="DocumentNumber" select ="$docNum"></xsl:with-param>
        </xsl:call-template>
      </BankStatementDocumentEntity>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="Statement">
    <xsl:param name="DocumentNumber" ></xsl:param>
    <xsl:for-each select="bs:AccountStatement">
      <xsl:variable name="stmtNum">
        <xsl:value-of  select="position()"></xsl:value-of>
      </xsl:variable>
      <BankStatementEntity>
        <DocumentLineNum>
          <xsl:value-of select ="normalize-space($DocumentNumber)"/>
        </DocumentLineNum>
        <StatementLineNum>
          <xsl:value-of select ="normalize-space($stmtNum)"/>
        </StatementLineNum>
        <BankAccountTable>
          <xsl:value-of select ="normalize-space('')"/>
        </BankAccountTable>
        <AccountCurrency>
          <xsl:value-of select ="normalize-space(bs:AccountCurrency)"/>
        </AccountCurrency>
        <AccountIdOtherId>
          <xsl:value-of select ="normalize-space(bs:AccountIdOtherId)"/>
        </AccountIdOtherId>
        <AsOfDateModifier>
          <xsl:value-of select ="normalize-space(bs:AsOfDateModifier)"/>
        </AsOfDateModifier>
        <BankStatementType>
          <xsl:value-of select ="normalize-space(bs:BankStatementType)"/>
        </BankStatementType>
        <FromDateTime>
          <xsl:value-of select ="bs:trimDateTime(bs:FromDateTime)"/>
        </FromDateTime>
        <IBAN>
          <xsl:value-of select ="normalize-space(bs:IBAN)"/>
        </IBAN>
        <GroupControlTotal>
          <xsl:value-of select ="normalize-space(bs:GroupControlTotal)"/>
        </GroupControlTotal>
        <GroupStatus>
          <xsl:value-of select ="normalize-space(bs:GroupStatus)"/>
        </GroupStatus>
        <Identification>
          <xsl:value-of select ="normalize-space(bs:Identification)"/>
        </Identification>
        <SequenceNumber>
          <xsl:value-of select="normalize-space(bs:SequenceNumber)" />
        </SequenceNumber>
        <SwiftNo>
          <xsl:value-of select ="normalize-space(bs:SwiftNo)"/>
        </SwiftNo>
        <ToDateTime>
          <xsl:value-of select ="bs:trimDateTime(bs:ToDateTime)"/>
        </ToDateTime>
        <TotalAccountsInGroup>
          <xsl:value-of select ="normalize-space(bs:TotalAccountsInGroup)"/>
        </TotalAccountsInGroup>
        <TotalRecordsInGroup>
          <xsl:value-of select ="normalize-space(bs:TotalRecordsInGroup)"/>
        </TotalRecordsInGroup>
        <TotalEntriesNumberOfEntries>
          <xsl:value-of select ="normalize-space(bs:TotalEntriesNumberOfEntries)"/>
        </TotalEntriesNumberOfEntries>
        <OriginatorName>
          <xsl:value-of select ="normalize-space(bs:Originator/bs:Name)"/>
        </OriginatorName>
        <OriginatorId>
          <xsl:value-of select ="normalize-space(bs:Originator/bs:PartyIdOrganisationGenericOrgId)"/>
        </OriginatorId>
        <UltimateReceiverName>
          <xsl:value-of select ="normalize-space(bs:UltimateReceiver/bs:Name)"/>
        </UltimateReceiverName>
        <UltimateReceiverId>
          <xsl:value-of select ="normalize-space(bs:UltimateReceiver/bs:PartyIdOrganisationGenericOrgId)"/>
        </UltimateReceiverId>
        <xsl:call-template name="Balance">
          <xsl:with-param name ="DocumentNumber" select ="$DocumentNumber"></xsl:with-param>
          <xsl:with-param name ="StmtNumber" select ="$DocumentNumber"></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="Line">
          <xsl:with-param name ="DocumentNumber" select ="$stmtNum"></xsl:with-param>
          <xsl:with-param name ="StmtNumber" select ="$stmtNum"></xsl:with-param>
        </xsl:call-template>
      </BankStatementEntity>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="Line">
    <xsl:param name="DocumentNumber" ></xsl:param>
    <xsl:param name="StmtNumber" ></xsl:param>
    <xsl:for-each select="bs:AccountStatementReportEntry">
      <xsl:call-template name="Line_Amount">
        <xsl:with-param name ="DocumentLineNum" select ="$DocumentNumber"></xsl:with-param>
        <xsl:with-param name ="StmtLineNum" select ="$StmtNumber"></xsl:with-param>
        <xsl:with-param name ="StatementLineLineNum" select ="position()"></xsl:with-param>
        <xsl:with-param name ="AccountServicerReference" select ="normalize-space(bs:AccountServicerReference)"></xsl:with-param>
        <xsl:with-param name ="AdditionalEntryInformation" select="normalize-space(bs:AdditionalEntryInformation)"></xsl:with-param>
        <xsl:with-param name ="LineAmount" select="normalize-space(bs:Amount)"></xsl:with-param>
        <xsl:with-param name ="AmountCreditDebitIndicator" select="normalize-space(bs:AmountCreditDebitIndicator)"></xsl:with-param>
        <xsl:with-param name ="BankDocumentNumber" select="normalize-space(bs:BankDocumentNumber)"></xsl:with-param>
        <xsl:with-param name ="BankStatementCounterCurrency" select="normalize-space(bs:BankStatementCounterCurrency)"></xsl:with-param>
        <xsl:with-param name ="BankStatementCounterCurrencyAmount" select="normalize-space(bs:BankStatementCounterCurrencyAmount)"></xsl:with-param>
        <xsl:with-param name ="BankStatementCounterExchangeRate" select="normalize-space(bs:BankStatementCounterExchangeRate)"></xsl:with-param>
        <xsl:with-param name ="BankStatementLineStatus" select="normalize-space(bs:BankStatementLineStatus)"></xsl:with-param>
        <xsl:with-param name ="BookingDateTime" select="normalize-space(bs:BookingDateTime)"></xsl:with-param>
        <xsl:with-param name ="EntryReference" select="normalize-space(bs:EntryReference)"></xsl:with-param>
        <xsl:with-param name ="ProprietaryBankTransactionCode" select="normalize-space(bs:ProprietaryBankTransactionCode)"></xsl:with-param>
        <xsl:with-param name ="ReferenceNumber" select="normalize-space(bs:ReferenceNumber)"></xsl:with-param>
        <xsl:with-param name ="RelatedBankAccount" select="normalize-space(bs:RelatedBankAccount)"></xsl:with-param>
        <xsl:with-param name ="RelatedBankName" select="normalize-space(bs:RelatedBankName)"></xsl:with-param>
        <xsl:with-param name ="ReversalIndicator" select="normalize-space(bs:ReversalIndicator)"></xsl:with-param>
        <xsl:with-param name ="ReportEntryTradingPartyName" select="normalize-space(bs:ReportEntryTradingParty/bs:Name)"></xsl:with-param>
        <xsl:with-param name ="ReportEntryTradingPartyId" select="normalize-space(bs:ReportEntryTradingParty/bs:PartyIdOrganisationGenericOrgId)"></xsl:with-param>
        <xsl:with-param name ="BankStatementInstructedCurrency" select="normalize-space(bs:BankStatementInstructedCurrency)"/>
        <xsl:with-param name ="BankStatementInstructedCurrencyAmt" select="normalize-space(bs:BankStatementInstructedCurrencyAmt)"/>
        <xsl:with-param name ="BankStatementInstructedExchangeRate" select="normalize-space(bs:BankStatementInstructedExchangeRate)"/>
        <xsl:with-param name ="CreditorReferenceInformation" select="normalize-space(bs:CreditorReferenceInformation)"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="Line_Amount">
    <xsl:param name="DocumentLineNum" ></xsl:param>
    <xsl:param name="StmtLineNum" ></xsl:param>
    <xsl:param name="StatementLineLineNum" ></xsl:param>
    <xsl:param name="AccountServicerReference" ></xsl:param>
    <xsl:param name="AdditionalEntryInformation" ></xsl:param>
    <xsl:param name="LineAmount" ></xsl:param>
    <xsl:param name="AmountCreditDebitIndicator" ></xsl:param>
    <xsl:param name="BankDocumentNumber" ></xsl:param>
    <xsl:param name="BankStatementCounterCurrency" ></xsl:param>
    <xsl:param name="BankStatementCounterCurrencyAmount" ></xsl:param>
    <xsl:param name="BankStatementCounterExchangeRate" ></xsl:param>
    <xsl:param name="BankStatementLineStatus" ></xsl:param>
    <xsl:param name="BookingDateTime" ></xsl:param>
    <xsl:param name="EntryReference" ></xsl:param>
    <xsl:param name="ProprietaryBankTransactionCode" ></xsl:param>
    <xsl:param name="ReferenceNumber" ></xsl:param>
    <xsl:param name="RelatedBankAccount" ></xsl:param>
    <xsl:param name="RelatedBankName" ></xsl:param>
    <xsl:param name="ReversalIndicator" ></xsl:param>
    <xsl:param name="ReportEntryTradingPartyName" ></xsl:param>
    <xsl:param name="ReportEntryTradingPartyId" ></xsl:param>
    <xsl:param name="BankStatementInstructedCurrency" />
    <xsl:param name="BankStatementInstructedCurrencyAmt" />
    <xsl:param name="BankStatementInstructedExchangeRate" />
    <xsl:param name="CreditorReferenceInformation" />
    <!-- D -->
    <xsl:choose>
      <xsl:when test="bs:ReportEntryCashBalAvl">
        <xsl:for-each select="bs:ReportEntryCashBalAvl">
          <BankStatementLineEntity>
            <DocumentLineNum>
              <xsl:value-of select ="normalize-space($DocumentLineNum)"/>
            </DocumentLineNum>
            <StatementLineNum>
              <xsl:value-of select ="normalize-space($StmtLineNum)"/>
            </StatementLineNum>
            <StatementLineLineNum>
              <xsl:value-of select ="normalize-space($StatementLineLineNum)"/>
            </StatementLineLineNum>
            <AccountServicerReference>
              <xsl:value-of select ="normalize-space($AccountServicerReference)"/>
            </AccountServicerReference>
            <AdditionalEntryInformation>
              <xsl:value-of select ="normalize-space($AdditionalEntryInformation)"/>
            </AdditionalEntryInformation>
            <LineAmount>
              <xsl:value-of select ="normalize-space($LineAmount)"/>
            </LineAmount>
            <AmountCreditDebitIndicator>
              <xsl:value-of select ="normalize-space($AmountCreditDebitIndicator)"/>
            </AmountCreditDebitIndicator>
            <BankDocumentNumber>
              <xsl:value-of select ="normalize-space($BankDocumentNumber)"/>
            </BankDocumentNumber>
            <BankStatementCounterCurrency>
              <xsl:value-of select ="normalize-space($BankStatementCounterCurrency)"/>
            </BankStatementCounterCurrency>
            <BankStatementCounterCurrencyAmount>
              <xsl:value-of select ="normalize-space($BankStatementCounterCurrencyAmount)"/>
            </BankStatementCounterCurrencyAmount>
              <BankStatementCounterExchangeRate>
              <xsl:value-of select ="normalize-space($BankStatementCounterExchangeRate)"/>
            </BankStatementCounterExchangeRate>
            <BankStatementLineStatus>
              <xsl:value-of select ="normalize-space($BankStatementLineStatus)"/>
            </BankStatementLineStatus>
            <BookingDateTime>
              <xsl:value-of select ="bs:trimDateTime($BookingDateTime)"/>
            </BookingDateTime>
            <EntryReference>
              <xsl:value-of select ="normalize-space($EntryReference)"/>
            </EntryReference>
            <ProprietaryBankTransactionCode>
              <xsl:value-of select ="normalize-space($ProprietaryBankTransactionCode)"/>
            </ProprietaryBankTransactionCode>
            <ReferenceNumber>
              <xsl:value-of select ="normalize-space($ReferenceNumber)"/>
            </ReferenceNumber>
            <RelatedBankAccount>
              <xsl:value-of select ="normalize-space($RelatedBankAccount)"/>
            </RelatedBankAccount>
            <RelatedBankName>
              <xsl:value-of select ="normalize-space($RelatedBankName)"/>
            </RelatedBankName>
            <ReversalIndicator>
              <xsl:value-of select ="normalize-space($ReversalIndicator)"/>
            </ReversalIndicator>
            <ReportEntryTradingPartyName>
              <xsl:value-of select ="normalize-space($ReportEntryTradingPartyName)"/>
            </ReportEntryTradingPartyName>
            <ReportEntryTradingPartyId>
              <xsl:value-of select ="normalize-space($ReportEntryTradingPartyId)"/>
            </ReportEntryTradingPartyId>
            <BankStatementInstructedCurrency>
              <xsl:value-of select ="normalize-space($BankStatementInstructedCurrency)"/>
            </BankStatementInstructedCurrency>
            <BankStatementInstructedCurrencyAmt>
              <xsl:value-of select ="normalize-space($BankStatementInstructedCurrencyAmt)"/>
            </BankStatementInstructedCurrencyAmt>
            <BankStatementInstructedExchangeRate>
              <xsl:value-of select ="normalize-space($BankStatementInstructedExchangeRate)"/>
            </BankStatementInstructedExchangeRate>
            <CreditorReferenceInformation>
              <xsl:value-of select ="normalize-space($CreditorReferenceInformation)"/>
            </CreditorReferenceInformation>
            <AmountLineNum>
              <xsl:value-of select ="position()"/>
            </AmountLineNum>
            <AmountActualDate>
              <xsl:value-of select ="bs:trimDateTime(bs:ActualDate)"/>
            </AmountActualDate>
            <AmountLineAmount>
              <xsl:value-of select ="normalize-space(bs:Amount)"/>
            </AmountLineAmount>
            <AmountNumberOfDays>
              <xsl:value-of select ="normalize-space(bs:NumberOfDays)"/>
            </AmountNumberOfDays>
            <!-- Start - Added for TKINF -->
            <ITVTMT940KeyField00>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField00)"/>
            </ITVTMT940KeyField00>
            <ITVTMT940KeyField10>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField10)"/>
            </ITVTMT940KeyField10>
            <ITVTMT940KeyField20>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField20)"/>
            </ITVTMT940KeyField20>
            <ITVTMT940KeyField21>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField21)"/>
            </ITVTMT940KeyField21>
            <ITVTMT940KeyField22>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField22)"/>
            </ITVTMT940KeyField22>
            <ITVTMT940KeyField23>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField23)"/>
            </ITVTMT940KeyField23>
            <ITVTMT940KeyField24>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField24)"/>
            </ITVTMT940KeyField24>
            <ITVTMT940KeyField25>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField25)"/>
            </ITVTMT940KeyField25>
            <ITVTMT940KeyField26>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField26)"/>
            </ITVTMT940KeyField26>
            <ITVTMT940KeyField27>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField27)"/>
            </ITVTMT940KeyField27>
            <ITVTMT940KeyField28>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField28)"/>
            </ITVTMT940KeyField28>
            <ITVTMT940KeyField29>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField29)"/>
            </ITVTMT940KeyField29>
            <ITVTMT940KeyField30>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField30)"/>
            </ITVTMT940KeyField30>
            <ITVTMT940KeyField31>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField31)"/>
            </ITVTMT940KeyField31>
            <ITVTMT940KeyField32>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField32)"/>
            </ITVTMT940KeyField32>
            <ITVTMT940KeyField33>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField33)"/>
            </ITVTMT940KeyField33>
            <ITVTMT940KeyField34>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField34)"/>
            </ITVTMT940KeyField34>
            <ITVTMT940KeyField60>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField60)"/>
            </ITVTMT940KeyField60>
            <ITVTMT940KeyField61>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField61)"/>
            </ITVTMT940KeyField61>
            <ITVTMT940KeyField62>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField62)"/>
            </ITVTMT940KeyField62>
            <ITVTMT940KeyField63>
              <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField63)"/>
            </ITVTMT940KeyField63>
            <!-- Stop - Added for TKINF -->
          </BankStatementLineEntity>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <BankStatementLineEntity>
          <DocumentLineNum>
            <xsl:value-of select ="normalize-space($DocumentLineNum)"/>
          </DocumentLineNum>
          <StatementLineNum>
            <xsl:value-of select ="normalize-space($StmtLineNum)"/>
          </StatementLineNum>
          <StatementLineLineNum>
            <xsl:value-of select ="normalize-space($StatementLineLineNum)"/>
          </StatementLineLineNum>
          <AccountServicerReference>
            <xsl:value-of select ="normalize-space($AccountServicerReference)"/>
          </AccountServicerReference>
          <AdditionalEntryInformation>
            <xsl:value-of select ="normalize-space($AdditionalEntryInformation)"/>
          </AdditionalEntryInformation>
          <LineAmount>
            <xsl:value-of select ="normalize-space($LineAmount)"/>
          </LineAmount>
          <AmountCreditDebitIndicator>
            <xsl:value-of select ="normalize-space($AmountCreditDebitIndicator)"/>
          </AmountCreditDebitIndicator>
          <BankDocumentNumber>
            <xsl:value-of select ="normalize-space($BankDocumentNumber)"/>
          </BankDocumentNumber>
          <BankStatementCounterCurrency>
            <xsl:value-of select ="normalize-space($BankStatementCounterCurrency)"/>
          </BankStatementCounterCurrency>
          <BankStatementCounterCurrencyAmount>
            <xsl:value-of select ="normalize-space($BankStatementCounterCurrencyAmount)"/>
          </BankStatementCounterCurrencyAmount>
            <BankStatementCounterExchangeRate>
            <xsl:value-of select ="normalize-space($BankStatementCounterExchangeRate)"/>
          </BankStatementCounterExchangeRate>
          <BankStatementLineStatus>
            <xsl:value-of select ="normalize-space($BankStatementLineStatus)"/>
          </BankStatementLineStatus>
          <BookingDateTime>
            <xsl:value-of select ="bs:trimDateTime($BookingDateTime)"/>
          </BookingDateTime>
          <EntryReference>
            <xsl:value-of select ="normalize-space($EntryReference)"/>
          </EntryReference>
          <ProprietaryBankTransactionCode>
            <xsl:value-of select ="normalize-space($ProprietaryBankTransactionCode)"/>
          </ProprietaryBankTransactionCode>
          <ReferenceNumber>
            <xsl:value-of select ="normalize-space($ReferenceNumber)"/>
          </ReferenceNumber>
          <RelatedBankAccount>
            <xsl:value-of select ="normalize-space($RelatedBankAccount)"/>
          </RelatedBankAccount>
          <RelatedBankName>
            <xsl:value-of select ="normalize-space($RelatedBankName)"/>
          </RelatedBankName>
          <ReversalIndicator>
            <xsl:value-of select ="normalize-space($ReversalIndicator)"/>
          </ReversalIndicator>
          <ReportEntryTradingPartyName>
            <xsl:value-of select ="normalize-space($ReportEntryTradingPartyName)"/>
          </ReportEntryTradingPartyName>
          <ReportEntryTradingPartyId>
            <xsl:value-of select ="normalize-space($ReportEntryTradingPartyId)"/>
          </ReportEntryTradingPartyId>
          <BankStatementInstructedCurrency>
            <xsl:value-of select ="normalize-space($BankStatementInstructedCurrency)"/>
          </BankStatementInstructedCurrency>
          <BankStatementInstructedCurrencyAmt>
            <xsl:value-of select ="normalize-space($BankStatementInstructedCurrencyAmt)"/>
          </BankStatementInstructedCurrencyAmt>
          <BankStatementInstructedExchangeRate>
            <xsl:value-of select ="normalize-space($BankStatementInstructedExchangeRate)"/>
          </BankStatementInstructedExchangeRate>
          <CreditorReferenceInformation>
            <xsl:value-of select ="normalize-space($CreditorReferenceInformation)"/>
          </CreditorReferenceInformation>
          <AmountLineNum>0</AmountLineNum>
          <AmountActualDate></AmountActualDate>
          <AmountLineAmount></AmountLineAmount>
          <AmountNumberOfDays></AmountNumberOfDays>
          <!-- Start - Added for TKINF -->
          <ITVTMT940KeyField00>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField00)"/>
          </ITVTMT940KeyField00>
          <ITVTMT940KeyField10>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField10)"/>
          </ITVTMT940KeyField10>
          <ITVTMT940KeyField20>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField20)"/>
          </ITVTMT940KeyField20>
          <ITVTMT940KeyField21>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField21)"/>
          </ITVTMT940KeyField21>
          <ITVTMT940KeyField22>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField22)"/>
          </ITVTMT940KeyField22>
          <ITVTMT940KeyField23>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField23)"/>
          </ITVTMT940KeyField23>
          <ITVTMT940KeyField24>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField24)"/>
          </ITVTMT940KeyField24>
          <ITVTMT940KeyField25>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField25)"/>
          </ITVTMT940KeyField25>
          <ITVTMT940KeyField26>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField26)"/>
          </ITVTMT940KeyField26>
          <ITVTMT940KeyField27>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField27)"/>
          </ITVTMT940KeyField27>
          <ITVTMT940KeyField28>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField28)"/>
          </ITVTMT940KeyField28>
          <ITVTMT940KeyField29>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField29)"/>
          </ITVTMT940KeyField29>
          <ITVTMT940KeyField30>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField30)"/>
          </ITVTMT940KeyField30>
          <ITVTMT940KeyField31>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField31)"/>
          </ITVTMT940KeyField31>
          <ITVTMT940KeyField32>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField32)"/>
          </ITVTMT940KeyField32>
          <ITVTMT940KeyField33>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField33)"/>
          </ITVTMT940KeyField33>
          <ITVTMT940KeyField34>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField34)"/>
          </ITVTMT940KeyField34>
          <ITVTMT940KeyField60>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField60)"/>
          </ITVTMT940KeyField60>
          <ITVTMT940KeyField61>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField61)"/>
          </ITVTMT940KeyField61>
          <ITVTMT940KeyField62>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField62)"/>
          </ITVTMT940KeyField62>
          <ITVTMT940KeyField63>
            <xsl:value-of select="normalize-space(bs:ITVTMT940KeyField63)"/>
          </ITVTMT940KeyField63>
          <!-- Stop - Added for TKINF -->
        </BankStatementLineEntity>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Start - Added for TKINF -->
  <xsl:template name="References">
    <xsl:param name="DocumentLineNum" ></xsl:param>
    <xsl:param name="StmtLineNum" ></xsl:param>
    <xsl:param name="StatementLineLineNum" ></xsl:param>
    <ReferenceValues>
      <Key>
        <xsl:value-of select="normalize-space(bs:Key)"/>
      </Key>
      <KeyValue>
        <xsl:value-of select="normalize-space(bs:KeyValue)"/>
      </KeyValue>
    </ReferenceValues>
    
  </xsl:template>
  <!-- Stop - Added for TKINF -->
  
  <xsl:template name="Balance">
    <xsl:param name="DocumentNumber" ></xsl:param>
    <xsl:param name="StmtNumber" ></xsl:param>
    <xsl:for-each select="bs:AccountStatementCashBalance">
      <xsl:call-template name="Balance_Availibility">
        <xsl:with-param name ="DocumentLineNum" select ="$DocumentNumber"></xsl:with-param>
        <xsl:with-param name ="StmtLineNum" select ="$StmtNumber"></xsl:with-param>
        <xsl:with-param name ="BalanceLineNum" select ="position()"></xsl:with-param>
        <xsl:with-param name ="BalanceType" select ="normalize-space(bs:BankStatementBalanceType)"></xsl:with-param>
        <xsl:with-param name ="BalanceIndicator" select="normalize-space(bs:AmountCreditDebitIndicator)"></xsl:with-param>
        <xsl:with-param name ="BalanceAmount" select="normalize-space(bs:CashBalanceAmount)"></xsl:with-param>
        <xsl:with-param name ="BalanceItemCount" select="normalize-space(bs:ItemCount)"></xsl:with-param>
        <xsl:with-param name ="BalanceTypeCode" select="normalize-space(bs:TypeCode)"></xsl:with-param>
        <xsl:with-param name ="BalanceFundsType" select="normalize-space(bs:FundsType)"></xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="Balance_Availibility">
    <xsl:param name="DocumentLineNum" ></xsl:param>
    <xsl:param name="StmtLineNum" ></xsl:param>
    <xsl:param name="BalanceLineNum" ></xsl:param>
    <xsl:param name="BalanceType" ></xsl:param>
    <xsl:param name="BalanceIndicator"></xsl:param>
    <xsl:param name="BalanceAmount"></xsl:param>
    <xsl:param name="BalanceItemCount"></xsl:param>
    <xsl:param name="BalanceTypeCode"></xsl:param>
    <xsl:param name="BalanceFundsType"></xsl:param>
    <xsl:choose>
      <xsl:when test="bs:CashBalanceCashBalAvl">
      <xsl:for-each select="bs:CashBalanceCashBalAvl">
        <BankStatementBalanceEntity>
          <DocumentLineNum>
            <xsl:value-of select ="normalize-space($DocumentLineNum)"/>
          </DocumentLineNum>
          <StatementLineNum>
            <xsl:value-of select ="normalize-space($StmtLineNum)"/>
          </StatementLineNum>
          <BalanceLineNum>
            <xsl:value-of select ="normalize-space($BalanceLineNum)"/>
          </BalanceLineNum>
          <BalanceType>
            <xsl:value-of select ="normalize-space($BalanceType)"/>
          </BalanceType>
          <BalanceIndicator>
            <xsl:value-of select ="normalize-space($BalanceIndicator)"/>
          </BalanceIndicator>
          <BalanceAmount>
            <xsl:value-of select ="normalize-space($BalanceAmount)"/>
          </BalanceAmount>
          <BalanceItemCount>
            <xsl:value-of select ="normalize-space($BalanceItemCount)"/>
          </BalanceItemCount>
          <BalanceTypeCode>
            <xsl:value-of select ="normalize-space($BalanceTypeCode)"/>
          </BalanceTypeCode>
          <BalanceFundsType>
            <xsl:value-of select ="normalize-space($BalanceFundsType)"/>
          </BalanceFundsType>
          <AvailibilityLineNum>
            <xsl:value-of select="position()" />
          </AvailibilityLineNum>
          <AvailibilityActualDate>
            <xsl:value-of select ="bs:trimDateTime(bs:ActualDate)"/>
          </AvailibilityActualDate>
          <AvailibilityAmount>
            <xsl:value-of select ="normalize-space(bs:Amount)"/>
          </AvailibilityAmount>
          <AvailibilityNumberOfDays>
            <xsl:value-of select ="normalize-space(bs:NumberOfDays)"/>
          </AvailibilityNumberOfDays>
        </BankStatementBalanceEntity>
      </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <BankStatementBalanceEntity>
          <DocumentLineNum>
            <xsl:value-of select ="normalize-space($DocumentLineNum)"/>
          </DocumentLineNum>
          <StatementLineNum>
            <xsl:value-of select ="normalize-space($StmtLineNum)"/>
          </StatementLineNum>
          <BalanceLineNum>
            <xsl:value-of select ="normalize-space($BalanceLineNum)"/>
          </BalanceLineNum>
          <BalanceType>
            <xsl:value-of select ="normalize-space($BalanceType)"/>
          </BalanceType>
          <BalanceIndicator>
            <xsl:value-of select ="normalize-space($BalanceIndicator)"/>
          </BalanceIndicator>
          <BalanceAmount>
            <xsl:value-of select ="normalize-space($BalanceAmount)"/>
          </BalanceAmount>
          <BalanceItemCount>
            <xsl:value-of select ="normalize-space($BalanceItemCount)"/>
          </BalanceItemCount>
          <BalanceTypeCode>
            <xsl:value-of select ="normalize-space($BalanceTypeCode)"/>
          </BalanceTypeCode>
          <BalanceFundsType>
            <xsl:value-of select ="normalize-space($BalanceFundsType)"/>
          </BalanceFundsType>
          <AvailibilityLineNum>0</AvailibilityLineNum>
          <AvailibilityActualDate></AvailibilityActualDate>
          <AvailibilityAmount></AvailibilityAmount>
          <AvailibilityNumberOfDays></AvailibilityNumberOfDays>
        </BankStatementBalanceEntity>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <msxsl:script language="C#" implements-prefix="bs">
    <![CDATA[
     public string trimDateTime(string strDate)
     {
        if (strDate == "") return "1900-01-01 00:00:00";
        DateTime dateTime = DateTime.ParseExact(strDate, "yyyy-MM-ddTHH:mm:ssZ", System.Globalization.DateTimeFormatInfo.InvariantInfo);
        return dateTime.ToString("yyyy-MM-dd HH:mm:ss");    
     }
     ]]>
  </msxsl:script>
</xsl:stylesheet>