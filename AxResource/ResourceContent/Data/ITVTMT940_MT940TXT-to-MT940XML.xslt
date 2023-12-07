<!-- This stylesheet converts the root-tagged MT940 txt file into a flat XML file
where each txt record line is converted to its corresponding XML record structure. That
XML is then processed by another stylesheet to map to the AX Bank Statement Data Model
(BankStmtISO* set of tables).
	-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt"
xmlns:bsiso="http://schemas.microsoft.com/dynamics/2008/01/services/BankStmtISOService/" version="1.0">
  <xsl:output method="xml" version="1.1" encoding="utf-16"/>

  <!-- This is the entry point to the transform -->
  <xsl:template match ="/" >
    <BankStmtISO>
      <!-- Select all the text you need to PreProcess and send it to the PreProcessor  
			The PreProcessor returns the value in 'txtToProcess' -->
      <xsl:variable name="txtToPreProcess" select="/Batch"/>
      <xsl:variable name ="txtToProcess">
        <xsl:call-template name ="inputTxtPreprocessor">
          <xsl:with-param name ="inputTxt" select ="$txtToPreProcess"/>
        </xsl:call-template>
      </xsl:variable>

      <!-- Call the main template giving it the 'txtToProcess' as a parameter -->
      <xsl:call-template name="main" >
        <xsl:with-param name="txt"  select="$txtToProcess"/>
      </xsl:call-template>
    </BankStmtISO>
  </xsl:template>

  <!-- This template is similar to the 'main' function in X++. It partitions the file into records
	and gives the record to the 'rowToFields' template which further partitions it into the corresponding 
	fields. Parameters:
	1) rownum - to keep track of the rows parsed so far if required as part of some extension
	2) txt    - the text that would be handled by this template
	-->
  <xsl:template name="main">
    <xsl:param name="txt" select="''" />
    <xsl:variable name="rowSeperator">
      <xsl:value-of select="concat('&#xA;',':')"/>
    </xsl:variable>
    <xsl:variable name="left" select="substring-before($txt, $rowSeperator)" />
    <xsl:variable name="right" select="substring-after($txt, $rowSeperator)" />
    <xsl:if test="string-length($left)>0" >
      <xsl:call-template name="rowToFields" >
        <xsl:with-param name="txt" select="$left" />
        <xsl:with-param name="rem" select="$right" />
        <xsl:with-param name="accountGroup" select="0"/>
        <xsl:with-param name ="statementGroup" select ="0" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- This template partitions each record into the corresponding fields based on the record type.
	fields. It also keeps track of the structure of the bank statement by attaching the same 'accountGroup' 
	attribute to all accounts in that accountGroup and the same 'transactionGroup' attribute to all 
	transactions in the same Account. Parameters:
	
	1) txt    - the text that would be handled by this template
	2) rem    - to keep track of the text remaining after the current record
	3) accountGroup - the current account group being traversed to poplate the 'accountGroup' attribute
	4) transactionGroup - the current transaction group being traversed to poplate the 'transactionGroup' atribute
	-->

  <xsl:template name ="rowToFields" >
    <xsl:param name ="txt" select ="''" />
    <xsl:param name ="rem" select ="''" />
    <xsl:param name ="accountGroup" select ="0"/>
    <xsl:param name ="statementGroup" select="0"/>
    <xsl:param name ="rowNum" select="1"/>

    <xsl:variable name="rowSeperator">
      <xsl:value-of select="concat('&#xA;',':')"/>
    </xsl:variable>
    <xsl:variable name="rowTag" select="normalize-space(substring-before($txt, ':'))" />
    <xsl:variable name="rowContent" select="substring-after($txt, ':')" />
    <xsl:choose>
      <xsl:when test ="$rowTag = 20">
        <!-- Record Type '20' indicates Header Reference -->
        <HeaderReference>
          <xsl:call-template name="HeaderReference" >
            <xsl:with-param name ="StringToTransform" select ="$rowContent" />
          </xsl:call-template>
        </HeaderReference>
      </xsl:when>

      <!-- Record Type '25' indicates Header Account Identification -->
      <xsl:when test ="$rowTag = 25">
        <HeaderAcccount>
          <xsl:attribute name="accountGroup">
            <xsl:value-of select="$accountGroup + 1" ></xsl:value-of>
          </xsl:attribute>
          <xsl:call-template name="HeaderAccount" >
            <xsl:with-param name ="StringToTransform" select ="$rowContent" />
          </xsl:call-template>
        </HeaderAcccount>
      </xsl:when>

      <!-- Record Type '28C' indicates Statement Identification -->
      <xsl:when test ="contains($rowTag, '28C')">
        <StatementId>
          <xsl:attribute name="accountGroup">
            <xsl:value-of select="$accountGroup" ></xsl:value-of>
          </xsl:attribute>
          <xsl:attribute name="statementGroup">
            <xsl:value-of select="$statementGroup + 1" ></xsl:value-of>
          </xsl:attribute>
          <xsl:call-template name="StatementIdentification" >
            <xsl:with-param name ="StringToTransform" select ="$rowContent" />
          </xsl:call-template>
        </StatementId>
      </xsl:when>

      <!-- Record Type contains '60' indicates Statement Opening -->
      <xsl:when test ="contains($rowTag, '60')">
        <StatementOpening>
          <xsl:attribute name="accountGroup">
            <xsl:value-of select="$accountGroup" ></xsl:value-of>
          </xsl:attribute>
          <xsl:attribute name="statementGroup">
            <xsl:value-of select="$statementGroup" ></xsl:value-of>
          </xsl:attribute>
        <xsl:call-template name="StatementOpeningCLosing" >
          <xsl:with-param name ="StringToTransform" select ="$rowContent" />
        </xsl:call-template>
        </StatementOpening>
      </xsl:when>

      <!-- Record Type contains '62' indicates Statement Closing -->
      <xsl:when test ="contains($rowTag, '62')">
        <StatementClosing>
          <xsl:attribute name="accountGroup">
            <xsl:value-of select="$accountGroup" ></xsl:value-of>
          </xsl:attribute>
          <xsl:attribute name="statementGroup">
            <xsl:value-of select="$statementGroup" ></xsl:value-of>
          </xsl:attribute>
        <xsl:call-template name="StatementOpeningCLosing" >
          <xsl:with-param name ="StringToTransform" select ="$rowContent" />
        </xsl:call-template>
        </StatementClosing>
      </xsl:when>

      <!-- Record Type '61' indicates Transaction -->
      <xsl:when test ="$rowTag = 61">
        <Transaction>
          <xsl:attribute name="accountGroup">
            <xsl:value-of select="$accountGroup" ></xsl:value-of>
          </xsl:attribute>
          <xsl:attribute name="statementGroup">
            <xsl:value-of select="$statementGroup" ></xsl:value-of>
          </xsl:attribute>
        <xsl:call-template name="Transaction" >
          <xsl:with-param name ="StringToTransform" select ="$rowContent" />
        </xsl:call-template>
        </Transaction>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test ="$rowTag = 25">
        <!-- call rowToFields recursively for the next record -->
        <xsl:variable name="left" select="substring-before($rem, $rowSeperator)" />
        <xsl:variable name="right" select="substring-after($rem, $rowSeperator)" />
        <xsl:if test="string-length($left)>0" >
          <xsl:call-template name="rowToFields" >
            <xsl:with-param name="txt" select="$left" />
            <xsl:with-param name="rem" select="$right" />
            <xsl:with-param name="accountGroup" select="$accountGroup + 1"/>
            <xsl:with-param name ="statementGroup" select ="$statementGroup" />
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:when test ="$rowTag = '28C'">
        <!-- call rowToFields recursively for the next record -->
        <xsl:variable name="left" select="substring-before($rem, $rowSeperator)" />
        <xsl:variable name="right" select="substring-after($rem, $rowSeperator)" />
        <xsl:if test="string-length($left)>0" >
          <xsl:call-template name="rowToFields" >
            <xsl:with-param name="txt" select="$left" />
            <xsl:with-param name="rem" select="$right" />
            <xsl:with-param name="accountGroup" select="$accountGroup"/>
            <xsl:with-param name ="statementGroup" select ="$statementGroup + 1" />
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <!-- call rowToFields recursively for the next record -->
        <xsl:variable name="left" select="substring-before($rem, $rowSeperator)" />
        <xsl:variable name="right" select="substring-after($rem, $rowSeperator)" />
        <xsl:if test="string-length($left)>0" >
          <xsl:call-template name="rowToFields" >
            <xsl:with-param name="txt" select="$left" />
            <xsl:with-param name="rem" select="$right" />
            <xsl:with-param name="accountGroup" select="$accountGroup"/>
            <xsl:with-param name ="statementGroup" select ="$statementGroup" />
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="HeaderReference">
    <xsl:param name ="StringToTransform" select ="''" />
    <Reference>
      <xsl:value-of select="$StringToTransform"/>
    </Reference>
  </xsl:template>

  <xsl:template name="HeaderAccount">
    <xsl:param name ="StringToTransform" select ="''" />
    <xsl:choose>
      <xsl:when test="contains($StringToTransform, '/')">
        <BIC>
          <xsl:value-of select="substring-before($StringToTransform, '/')"/>
        </BIC>
        
        <xsl:variable name="AccountNumberFields">
          <xsl:value-of select="bsiso:splitNumberAndAlpha(substring-after($StringToTransform, '/'),';')"/>
        </xsl:variable>
        <AccountNumber>
          <xsl:variable name ="CurrentField">
            <xsl:value-of select="substring-before($AccountNumberFields,'1;')"/>
          </xsl:variable>
          <xsl:value-of select="$CurrentField"/>
        </AccountNumber>
        <AccountCurrency>
          <xsl:variable name ="CurrentField">
            <xsl:value-of select="substring-before(substring-after($AccountNumberFields,'1;'),'2;')"/>
          </xsl:variable>
          <xsl:value-of select="$CurrentField"/>
        </AccountCurrency>
      </xsl:when>
      <xsl:otherwise>
        <IBAN>
          <xsl:value-of select="$StringToTransform"/>
        </IBAN>
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:template>

  <xsl:template name="StatementIdentification">
    <xsl:param name ="StringToTransform" select ="''" />
    <Id>
      <xsl:value-of select="substring-before($StringToTransform, '/')"/>
    </Id>
    <SequenceNumber>
      <xsl:value-of select="substring-after($StringToTransform, '/')"/>
    </SequenceNumber>
  </xsl:template>

  <xsl:template name="StatementOpeningCLosing">
    <xsl:param name ="StringToTransform" select ="''" />
    <Direction>
      <xsl:value-of select="substring($StringToTransform,1,1)"/>
    </Direction>
    <Date>
      <xsl:value-of select="substring($StringToTransform,2,6)"/>
    </Date>
    <Currency>
      <xsl:value-of select="substring($StringToTransform,8,3)"/>
    </Currency>
    <Amount>
    <!-- TME
      <xsl:if test="contains($StringToTransform,'&#xA;-&#xA;')">
        <xsl:call-template name="remove">
          <xsl:with-param name="value" select="substring($StringToTransform,11)"></xsl:with-param>     
        </xsl:call-template>
      </xsl:if>,position(&#xA;)
      
      <xsl:if test="contains($StringToTransform,'&#xA;-&#xA;')">
      <xsl:call-template name="convertMT940Amount">
      <xsl:with-param name="OriginalAmount" select="substring-before(substring($StringToTransform,11),'&#xA;-&#xA;')"/>
        </xsl:call-template>
      </xsl:if>
      -->
      <xsl:choose>
        <xsl:when test="contains($StringToTransform,'&#xA;-&#xA;')">
          <xsl:call-template name="convertMT940Amount">
            <xsl:with-param name="OriginalAmount"
                            select="substring-before(substring($StringToTransform,11),'&#xA;-&#xA;')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="convertMT940Amount">
            <xsl:with-param name="OriginalAmount"
                            select="substring($StringToTransform,11)"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </Amount>
  </xsl:template>

  <xsl:template name="Transaction">
    <xsl:param name ="StringToTransform" select ="''" />
    <xsl:variable name ="Line">
      <xsl:choose>
        <xsl:when test="contains($StringToTransform,';')">
          <xsl:value-of select="substring-before($StringToTransform, ';')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$StringToTransform"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Start - Added for TKINF
    <xsl:variable name ="LineExtension" select="concat(substring-after($StringToTransform, ';'), '?')" />
    Stop - Added for TKINF-->
    
    <!-- Start - Added for TKINF-->
    <xsl:variable name ="LineExtensionOrig" select="concat(substring-after($StringToTransform, ';'), '?')" />
    <xsl:variable name="LineExtension" select="bsiso:removeLineBreaks($LineExtensionOrig)" />
    <xsl:variable name="Keys" select="$LineExtension" />
    <!-- Stop - Added for TKINF-->
        
    <xsl:variable name ="Fields">
      <xsl:value-of select="bsiso:splitMT940TransactionLine($Line)"/>
    </xsl:variable>
    <Date>
      <xsl:variable name ="CurrentField">
        <xsl:value-of select="substring-before($Fields, '1;')"/>
      </xsl:variable>
      <xsl:value-of select="substring($CurrentField, 1, 6)"/>
    </Date>
    <EntryDate>
      <xsl:variable name ="CurrentField">
        <xsl:value-of select="substring-before($Fields, '1;')"/>
      </xsl:variable>
      <xsl:value-of select="substring($CurrentField, 7)"/>
    </EntryDate>
    <FundsCode>
      <xsl:variable name ="CurrentField">
        <xsl:value-of select="substring-before(substring-after($Fields, '1;'),'2;')"/>
      </xsl:variable>
      <xsl:value-of select="$CurrentField"/>
    </FundsCode>
    <Amount>
      <xsl:variable name ="CurrentField">
        <xsl:value-of select="substring-before(substring-after($Fields, '2;'),'3;')"/>
      </xsl:variable>
      <xsl:call-template name="convertMT940Amount">
        <xsl:with-param name="OriginalAmount" select="$CurrentField"/>
      </xsl:call-template>
    </Amount>
    <TypeCode>
      <xsl:variable name ="CurrentField">
        <xsl:value-of select="substring-before(substring-after($Fields, '3;'),'4;')"/>
      </xsl:variable>
      <xsl:value-of select="substring($CurrentField, 1, 4)"/>
    </TypeCode>
    <AccountOwnerReference>
      <xsl:variable name ="CurrentField">
        <xsl:value-of select="substring-before(substring-after($Fields, '4;'),'5;')"/>
      </xsl:variable>
      <xsl:value-of select="$CurrentField"/>
    </AccountOwnerReference>
    <BankReference>
      <xsl:variable name ="CurrentField">
        <xsl:value-of select="substring-before(substring-after($Fields, '5;'),'6;')"/>
      </xsl:variable>
      <xsl:value-of select="$CurrentField"/>
    </BankReference>
    <TransactionDescription>
      <xsl:variable name ="CurrentField">
        <xsl:value-of select="substring-before(substring-after($Fields, '6;'),'7;')"/>
      </xsl:variable>
      <xsl:variable name ="CurrentField2">
        <xsl:value-of select="substring-before(substring-after($Fields, '7;'),'8;')"/>
      </xsl:variable>
      <xsl:if test="string-length($CurrentField) > 0">
        <xsl:call-template name="TransactionDetails">
          <xsl:with-param name="current" select="$CurrentField"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="string-length($CurrentField2) > 0">
        <xsl:call-template name="TransactionDetails">
          <xsl:with-param name="current" select="$CurrentField2"/>
        </xsl:call-template>
      </xsl:if>
    </TransactionDescription>

    <xsl:variable name ="LineExtensionSectionCount" select="bsiso:lineExtensionSectionCount($LineExtension)"/>
    
    <xsl:if test ="$LineExtensionSectionCount = 1 ">
      <TransactionText>
          <xsl:call-template name="strReplace">
            <xsl:with-param name="txt" select="$LineExtension" />
            <xsl:with-param name="strToBeReplaced" select="'?'" />
            <xsl:with-param name="strToReplace" select="' '"/>
          </xsl:call-template>
      </TransactionText>
    </xsl:if>

    <xsl:if test ="$LineExtensionSectionCount != 1 ">

      <xsl:variable name="StructuredLineExtension" select="substring($LineExtension, 4, 1)"/>
      <xsl:if test="$StructuredLineExtension != '?' ">
        <TransactionText>
          <xsl:call-template name="strReplace">
            <xsl:with-param name="txt" select="$LineExtension" />
            <xsl:with-param name="strToBeReplaced" select="'?'" />
            <xsl:with-param name="strToReplace" select="' '"/>
          </xsl:call-template>
        </TransactionText>
      </xsl:if>

      <xsl:if test="$StructuredLineExtension = '?' ">
        <xsl:variable name="IsIdentificationCodeSupported" select="bsiso:isIdentificationCodeSupported($LineExtension)"/>        
        <xsl:if test ="($IsIdentificationCodeSupported = 'No')">
          <xsl:variable name="StructuredButNotSupportedIdentificationCode" select="substring($LineExtension, 5)"/>
          <TransactionText>
            <xsl:call-template name="strReplace">
              <xsl:with-param name="txt" select="$StructuredButNotSupportedIdentificationCode" />
              <xsl:with-param name="strToBeReplaced" select="'?'" />
              <xsl:with-param name="strToReplace" select="' '"/>
            </xsl:call-template>
          </TransactionText>
        </xsl:if>
        <xsl:if test ="($IsIdentificationCodeSupported = 'Yes')">
          <TransactionCode>
            <xsl:value-of select="substring($LineExtension, 1, 3)"/>
          </TransactionCode>
          <xsl:call-template name="LineExtension">
            <xsl:with-param name="current" select="substring-before(substring-after($LineExtension,'?'),'?')"/>
            <xsl:with-param name="left" select="substring-after(substring-after($LineExtension,'?'),'?')"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <!--Start - Addd for TKINF-->
      <xsl:if test="$Keys != '' ">
        <!--<Keys>-->
          <xsl:call-template name="Keys">
            <xsl:with-param name="current" select="substring-before(substring-after($Keys,'?'),'?')"/>
            <xsl:with-param name="left" select="substring-after(substring-after($Keys,'?'),'?')"/>
          </xsl:call-template>
        <!--</Keys>-->
      </xsl:if>
    <!--Stop - Added for TKINF-->
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template name="TransactionDetails">
    <xsl:param name="current" select="''"/>
    <xsl:choose>
      <xsl:when test="contains($current, '/')">
        <xsl:variable name ="OrginalAmountOrChargeAmount">
          <xsl:value-of select="bsiso:splitBySpeartors($current,';','/','','')"/>
        </xsl:variable>
        <xsl:variable name ="OrginalAmountOrChargeAmountTag">
          <xsl:value-of select="substring-before(substring-after($OrginalAmountOrChargeAmount, '1;'),'2;')"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$OrginalAmountOrChargeAmountTag = 'CHGS'">
            <xsl:variable name ="CurrentField">
              <xsl:value-of select="substring-before(substring-after($OrginalAmountOrChargeAmount, '2;'),'3;')"/>
            </xsl:variable>
            <ChargeAmount>
              <xsl:call-template name="convertMT940Amount">
                <xsl:with-param name="OriginalAmount" select="substring($CurrentField, 4)"/>
              </xsl:call-template>
            </ChargeAmount>
            <ChargeCurrency>
              <xsl:value-of select="substring($CurrentField,1,3)"/>
            </ChargeCurrency>
          </xsl:when>
          <xsl:when test="$OrginalAmountOrChargeAmountTag = 'OCMT'">
            <xsl:variable name ="CurrentField">
              <xsl:value-of select="substring-before(substring-after($OrginalAmountOrChargeAmount, '2;'),'3;')"/>
            </xsl:variable>
            <CounterAmount>
              <xsl:call-template name="convertMT940Amount">
                <xsl:with-param name="OriginalAmount" select="substring($CurrentField, 4)"/>
              </xsl:call-template>
            </CounterAmount>
            <CounterCurrency>
              <xsl:value-of select="substring($CurrentField,1,3)"/>
            </CounterCurrency>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <TransactionDescription>
          <xsl:value-of select="$current"/>
        </TransactionDescription>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="LineExtension">
    <xsl:param name="current" select="''"/>
    <xsl:param name="left" select="''"/>
    <xsl:variable name="ExtensionTag" select="substring($current,1,2)"/>
    <xsl:choose>
      <xsl:when test="$ExtensionTag = 00">
        <TransactionText>
          <xsl:value-of select="substring($current,3)"/>
        </TransactionText>        
      </xsl:when>
      <!--
      <xsl:when test="$ExtensionTag &gt;= 20 and $ExtensionTag &lt;= 29">
        <PaymentReference>
          <xsl:value-of select="substring($current,3)"/>
        </PaymentReference>
      </xsl:when>
      -->
      <xsl:when test="$ExtensionTag = 31">
        <CustVendAccount>
          <xsl:value-of select="substring($current,3)"/>
        </CustVendAccount>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 32">
        <CustVendNameSender>
          <xsl:value-of select="substring($current,3)"/>
        </CustVendNameSender>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 33">
        <CustVendNameBeneficiary>
          <xsl:value-of select="substring($current,3)"/>
        </CustVendNameBeneficiary>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="string-length(substring-before($left,'?')) &gt; 0">
      <xsl:call-template name="LineExtension">
        <xsl:with-param name="current" select="substring-before($left,'?')"/>
        <xsl:with-param name="left" select="substring-after($left,'?')"/>     
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <!-- Start - Added for TKINF-->
      
      
  <xsl:template name="Keys">
    <xsl:param name="current" select="''"/>
    <xsl:param name="left" select="''"/>
    <xsl:variable name="ExtensionTag" select="substring($current,1,2)"/>
    <xsl:choose>
      <xsl:when test="$ExtensionTag = 00">
        <Key00>
          <xsl:value-of select="substring($current,3)"/>        
        </Key00>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 10">
        <Key10>
          <xsl:value-of select="substring($current,3)"/>        
        </Key10>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 20">
        <Key20>
          <xsl:value-of select="substring($current,3)"/>        
        </Key20>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 21">
        <Key21>
          <xsl:value-of select="substring($current,3)"/>        
        </Key21>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 22">
        <Key22>
          <xsl:value-of select="substring($current,3)"/>        
        </Key22>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 23">
        <Key23>
          <xsl:value-of select="substring($current,3)"/>        
        </Key23>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 24">
        <Key24>
          <xsl:value-of select="substring($current,3)"/>        
        </Key24>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 25">
        <Key25>
          <xsl:value-of select="substring($current,3)"/>        
        </Key25>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 26">
        <Key26>
          <xsl:value-of select="substring($current,3)"/>        
        </Key26>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 27">
        <Key27>
          <xsl:value-of select="substring($current,3)"/>        
        </Key27>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 28">
        <Key28>
          <xsl:value-of select="substring($current,3)"/>        
        </Key28>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 29">
        <Key29>
          <xsl:value-of select="substring($current,3)"/>        
        </Key29>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 30">
        <Key30>
          <xsl:value-of select="substring($current,3)"/>        
        </Key30>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 31">
        <Key31>
          <xsl:value-of select="substring($current,3)"/>        
        </Key31>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 32">
        <Key32>
          <xsl:value-of select="substring($current,3)"/>     
        </Key32>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 33">
        <Key33>
          <xsl:value-of select="substring($current,3)"/>        
        </Key33>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 34">
        <Key34>
          <xsl:value-of select="substring($current,3)"/>        
        </Key34>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 60">
        <Key60>
          <xsl:value-of select="substring($current,3)"/>        
        </Key60>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 61">
        <Key61>
          <xsl:value-of select="substring($current,3)"/>        
        </Key61>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 62">
        <Key62>
          <xsl:value-of select="substring($current,3)"/>        
        </Key62>
      </xsl:when>
      <xsl:when test="$ExtensionTag = 63">
        <Key63>
          <xsl:value-of select="substring($current,3)"/>        
        </Key63>
      </xsl:when>
      </xsl:choose>
    <xsl:if test="string-length(substring-before($left,'?')) &gt; 0">
      <xsl:call-template name="Keys">
        <xsl:with-param name="current" select="substring-before($left,'?')"/>
        <xsl:with-param name="left" select="substring-after($left,'?')"/>     
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <!-- Stop - Added for TKINF-->
  
  <!-- This template PreProcesses the input. PreProcessing involves:
	1) Ensuring that all continuation ('86') type records are correcly appended to their parent records
	2) Ensuring that all records end with a consistent '/' as the end of record indicator-->               
  <xsl:template name="inputTxtPreprocessor">
    <xsl:param name ="inputTxt"/>

    <!-- Ensure that all extra redundant spaces are filtered off.-->
    <xsl:variable name="txtSpaceFilteredRecords">
      <xsl:call-template name="filterChars">
        <xsl:with-param name="txt" select="$inputTxt" />
        <xsl:with-param name="charsToFilter" select="'&#32;&#xA;'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name ="txtCRFilteredRecords">
      <xsl:call-template name="filterChars">
        <xsl:with-param name="txt" select="$txtSpaceFilteredRecords" />
        <xsl:with-param name="charsToFilter" select="'&#xD;&#xA;'" />
      </xsl:call-template>
    </xsl:variable>
    <!-- Any records of type ':86:' with previous record ending with 'CRLF' are a continuation of
			the previous record-->
    <xsl:variable name="txtContinuousRecords">
      <xsl:call-template name="strReplace">
        <xsl:with-param name="txt" select="$txtCRFilteredRecords" />
        <xsl:with-param name="strToBeReplaced" select="concat('&#xA;',':86:')" />
        <xsl:with-param name="strToReplace" select="';'"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- Ajust end-->
    <xsl:variable name="txtEndAjustRecords">
      <xsl:value-of disable-output-escaping="yes" select="bsiso:addFileEnd($txtContinuousRecords)"/>
    </xsl:variable>

    <xsl:value-of select ="$txtEndAjustRecords"/>
  </xsl:template>
  
  <!-- Filter uncecessary characters around \n-->
  <xsl:template name="filterChars">
    <xsl:param name="txt" />
    <xsl:param name="charsToFilter" />
    <xsl:choose>
      <xsl:when test="contains($txt, $charsToFilter)">
        <xsl:call-template name="filterChars">
          <xsl:with-param name="txt" select="concat(substring-before($txt,$charsToFilter),'&#xA;')" />
          <xsl:with-param name="charsToFilter" select="$charsToFilter" />
        </xsl:call-template>
        <xsl:call-template name="filterChars">
          <xsl:with-param name="txt" select="substring-after($txt,$charsToFilter)" />
          <xsl:with-param name="charsToFilter" select="$charsToFilter" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise >
        <xsl:value-of select ="$txt"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- This is a simple string replacement helper template. It had to be written since AIF does not
	support XSLT 2.0 and XSLT 1.0 does not have this function built in.
	Parameters:
	txt				      = The text on which replacement is to be performed
	strToBeReplaced = The string in 'txt' that needs replacement
	strToReplace	  = The string that replaces 'strToBeReplaced' in 'txt'-->
  <xsl:template name="strReplace">
    <xsl:param name="txt" />
    <xsl:param name="strToBeReplaced" />
    <xsl:param name="strToReplace" />
    <xsl:choose>
      <xsl:when test="contains($txt, $strToBeReplaced)">
        <xsl:value-of select="substring-before($txt,$strToBeReplaced)" />
        <xsl:value-of select="$strToReplace" />
        <xsl:call-template name="strReplace">
          <xsl:with-param name="txt" select="substring-after($txt,$strToBeReplaced)" />
          <xsl:with-param name="strToBeReplaced" select="$strToBeReplaced" />
          <xsl:with-param name="strToReplace" select="$strToReplace" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$txt" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="convertMT940Amount">
    <xsl:param name="OriginalAmount"/>
    <xsl:call-template name="strReplace">
      <xsl:with-param name="txt" select="$OriginalAmount"/>
      <xsl:with-param name="strToBeReplaced" select="','"/>
      <xsl:with-param name="strToReplace" select="'.'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- This is a helper template that is used to skip records in a given line containing
	comma seperated fields. The parameters are:
	txt				    = The text to skip records in
	recordsToSkip	= The number of records to be skipped
	counter			  = A counter variable to keep track of currently skipped records 
					  in this recursive template. Helps us to get a base condition for recursion. -->
  <xsl:template name ="skipRecords">
    <xsl:param name="txt" select ="''"/>
    <xsl:param name ="recordsToSkip" select ="0"  />
    <xsl:param name ="counter" select ="1" />
    <xsl:choose>
      <xsl:when test="$counter &lt;= $recordsToSkip">
        <xsl:call-template name="skipRecords">
          <xsl:with-param name="txt" select="substring-after($txt,',')" />
          <xsl:with-param name="recordsToSkip" select="$recordsToSkip" />
          <xsl:with-param name="counter" select="$counter + 1" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$txt" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <msxsl:script language="C#" implements-prefix="bsiso">
    <![CDATA[
    
        public string removeLineBreaks(string input)
        {
          string replacedString = input.Replace("\n", "");
                    
          return replacedString;
        }
        
        public string isIdentificationCodeSupported(string input)
        {
          string isIdentificationCodeSupported = "No";

          bool answer = input.Contains("?00") 
            || input.Contains("?31")
            || input.Contains("?32")
            || input.Contains("?33");

          if (answer == true)
          {
            isIdentificationCodeSupported = "Yes";
          }

          return isIdentificationCodeSupported;
        }
        
        public string lineExtensionSectionCount(string input)
        {
            int count;
            
            count = input.Split('?').Length - 1;
            
            return count.ToString();
        }
    
        public string splitNumberAndAlpha(string originalLine, string seperator)
        {
            //split the string by number and alpha, return them sepearted by seperator, and end with seperator
            string result = string.Empty;
            int i = 1;

            if (originalLine == null || originalLine.Length == 0)
            {
                return "";
            }

            bool isLetter = Char.IsLetter(originalLine[0]);

            foreach (char c in originalLine)
            {
                bool isLetterCurrent;

                isLetterCurrent = Char.IsLetter(c);
                
                if (isLetterCurrent != isLetter)
                {
                    result += (i++) + seperator;
                    isLetter = isLetterCurrent;
                }
                result += c;
            }
            result += (i++) + seperator;

            return result;
        }
        
        public string splitMT940TransactionLine(string originalLine)
        {
            //split the string by number and alpha, return them sepearted by seperator, and end with seperator
            string result = string.Empty;
            int i = 1;
            int count = 0;
            bool isSkip = false;
            string seperator = ";";

            if (originalLine == null || originalLine.Length == 0)
            {
                return "";
            }

            bool isLetter = Char.IsLetter(originalLine[0]);

            foreach (char c in originalLine)
            {
                isSkip = false;

                if (i <= 3)
                {
                    bool isLetterCurrent;

                    isLetterCurrent = Char.IsLetter(c);

                    if (isLetterCurrent != isLetter)
                    {
                        result += (i++) + seperator;
                        isLetter = isLetterCurrent;
                    }
                }
                else if (i <= 4)
                {
                    if (count == 0)
                    {
                        count = 1;
                    }
                    count++;

                    if (count == 5)
                    {
                        result += (i++) + seperator;
                        count = 0;
                    }
                }
                else if (i<=5)
                {

                    if (c == '/')
                    {
                        isSkip = true;
                        count++;
                    }

                    if (count == 2)
                    {
                        result += (i++) + seperator;
                        count = 0;
                    }

                }
                else if (i <= 6)
                {
                    if (c == '\n')
                    {
                        isSkip = true;
                        result += (i++) + seperator;
                    }
                }
                else if (i <= 8)
                {
                    if (c == '/')
                    {
                        count++;
                    }

                    if (count == 4)
                    {
                        result += (i++) + seperator;
                        count = 0;
                    }
                }
                
                if (!isSkip)
                {
                    result += c;
                }
            }
            result += (i++) + seperator;

            return result;
        }
        
        public string addFileEnd(string lines)
        {
            int lastDataLine = lines.LastIndexOf("\n:");
            if (lastDataLine > 0)
            {
                int lastLine = lines.IndexOf("\n", lastDataLine + 1);
                if (lastLine > 0)
                {
                    lines = lines.Substring(0, lastLine + 1) + ":" + lines.Substring(lastLine + 1);
                }
                else
                {
                    lines = lines + "\n:";
                }
            }

            return lines;
        }
    ]]>
  </msxsl:script>

  <msxsl:script language="C#" implements-prefix="bsiso">
    <![CDATA[
          public string splitBySpeartors(string originalLine, string seperator, string originalSeperator1, string originalSeperator2 = "", string originalSeperator3 = "")
        {
            string line = originalLine;
            int i = 1;

            if (originalSeperator1 != null && originalSeperator1.Length > 0)
            {
                line = line.Replace(originalSeperator1, seperator);
            }
            if (originalSeperator2 != null && originalSeperator2.Length > 0)
            {
                line = line.Replace(originalSeperator2, seperator);
            }
            if (originalSeperator3 != null && originalSeperator3.Length > 0)
            {
                line = line.Replace(originalSeperator3, seperator);
            }

            if (seperator.Length == 0)
            {
                return line;
            }

            string result = string.Empty;
            foreach (char c in line)
            {
                if (c == seperator[0])
                {
                    result += i++;
                }

                result += c;
            }
            result += i++;
            result += seperator;

            return result;
        }
    
        ]]>
  </msxsl:script>
  
  
</xsl:stylesheet>
