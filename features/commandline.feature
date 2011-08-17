Feature: Command Line Tool
  As a new rets4r user
  I want a tool to show how to use my data

  Background:
    Given a file named "settings.yml" with:
      """
      development:
        url:  http://www.dis.com:6103/rets/login
        username: Joe
        password: Schmoe
        select:
          MLSNUM: :mls
          AGENTLIST_FULLNAME: :agent_full_name
          LISTPRICE: :list_price
      """
    Given a file named "search_compact.xml" with:
      """
      <RETS ReplyCode="0" ReplyText="SUCCESS">
      <COUNT Records="4"/>
      <DELIMITER value="09" />
      <COLUMNS>	MLSNUM	LISTPRICE	AGENTLIST_FULLNAME	</COLUMNS>
      <DATA>	1	2	Steve</DATA>
      <DATA>	4	5	Bill</DATA>
      <MAXROWS/>
      </RETS>
      """

  Scenario: parse
    When I run `rets4r parse search_compact.xml`
    Then the output should contain:
      """
      AGENTLIST_FULLNAME: Steve, LISTPRICE: 2, MLSNUM: 1
      AGENTLIST_FULLNAME: Bill, LISTPRICE: 5, MLSNUM: 4
      """

  Scenario: Map
    When I run `rets4r map search_compact.xml`
    Then the output should contain:
      """
      agent_full_name: Steve, list_price: 2, mls: 1
      agent_full_name: Bill, list_price: 5, mls: 4
      """
  
  Scenario: Login
    When I run `rets4r login`
    Then the output should contain:
      """
      We successfully logged into the RETS server!
      nil
      We just logged out of the server.
      """