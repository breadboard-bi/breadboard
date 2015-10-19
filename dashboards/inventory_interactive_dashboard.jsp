<%@ taglib prefix='c' uri='http://java.sun.com/jstl/core' %>

<%@ taglib uri="http://java.sun.com/jstl/fmt" prefix="fmt" %>

<%@ page language="java"
        import="javax.naming.*,
        javax.sql.DataSource,
        java.util.ArrayList,
        java.util.Date,
        java.text.DateFormat,
        java.text.SimpleDateFormat,
        java.io.ByteArrayOutputStream,
        java.io.*,
        java.sql.*,
        java.util.*,
        org.pentaho.platform.util.web.SimpleUrlFactory,
        org.pentaho.platform.web.jsp.messages.Messages,
        org.pentaho.platform.engine.core.system.PentahoSystem,
        org.pentaho.platform.uifoundation.chart.DashboardWidgetComponent,
        org.pentaho.platform.web.http.request.HttpRequestParameterProvider,
        org.pentaho.platform.web.http.session.HttpSessionParameterProvider,
        org.pentaho.platform.api.engine.IPentahoSession,
        org.pentaho.platform.web.http.WebTemplateHelper,
        org.pentaho.platform.util.VersionHelper,
        org.pentaho.platform.util.messages.LocaleHelper,
        org.pentaho.platform.engine.services.actionsequence.ActionResource,
        org.pentaho.platform.api.engine.IActionSequenceResource,
        org.pentaho.platform.engine.core.solution.SimpleParameterProvider,
        org.pentaho.platform.uifoundation.chart.ChartHelper,org.pentaho.platform.web.http.PentahoHttpSessionHelper,org.pentaho.platform.engine.services.solution.SolutionHelper"
%>

<fmt:setBundle basename="inventory_interactive_dashboard_jsp"/>

<%!
public String getTimeStamp() {
   Calendar date = Calendar.getInstance();
   String ts = (date.get(date.MONTH)+1) + "/" +date.get(date.DATE)+ "/" + date.get(date.YEAR)+
                    ":" +date.get(date.HOUR_OF_DAY)
                    +":"+date.get(date.MINUTE)+":"+ date.get(date.SECOND);
   return(ts);
}
%>


<%    
/*
*  Copyright 2008 Breadboard BI, Inc.  All rights reserved.
*
*  Version 1.0 Beta
*
*  This software was developed by Breadboard BI and is provided under license. You may
*  not use this file except in compliance with the license. This software is distributed
*  on an AS IS basis, WITHOUT WARRANTY OF ANY KIND, neither expressed nor implied.
*
*  Please send bug fixes and enhancement requests to submit@breadboardbi.com
*/

/*
 * This JSP is an example of how to combine Breadboard BI content with Pentaho components to build a dashboard.
 * The script in this file controls the layout and content generation of the dashboard.
 * See the Pentho document 'Dashboard Builder Guide' for more details.
 * Ideally, the Java code would be in a class that is imported.  Here, we put the
 * the Java code inline to make it easier to edit and understand.  This example is part of a basic "Model 1" type
 * web application with the Java code directly in the page.
 * It is only intended as a simplified example of making dynamic reports.  
 * As a service to a our clients, we would provide a
 * customized interface, error handling, and security among other features.
 */

ResourceBundle rb = ResourceBundle.getBundle("inventory_interactive_dashboard_jsp");

// set the character encoding e.g. UFT-8
response.setCharacterEncoding(LocaleHelper.getSystemEncoding());
// create a new Pentaho session
IPentahoSession userSession = PentahoHttpSessionHelper.getPentahoSession( request );




////////////////////////////////////////////////////////////////////
//SET UP PARAMETERS/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

String msgs = "Start Time = " +getTimeStamp();
boolean debugMode = false;
if (request.getParameter("show") != null)
   debugMode = true;

// Drop-down Variables
String selObj_product = "";
String product_sk = ((request.getParameter("product_sk")!=null)?request.getParameter("product_sk"):"");
String selObj_business_unit = "";
String  business_unit_sk = ((request.getParameter("business_unit_sk")!=null)?request.getParameter("business_unit_sk"):"");
String selObj_supplier = "";
String supplier_sk = ((request.getParameter("supplier_sk")!=null)?request.getParameter("supplier_sk"):"");
String selObj_warehouse = "";
String warehouse_sk = ((request.getParameter("warehouse_sk")!=null)?request.getParameter("warehouse_sk"):"");

// Dial Widget Variables
int AVG_REQUISITION_WR_DAY_QTY = 0;
int AVG_REQUISITION_PO_DAY_QTY = 0;
int AVG_PO_SHIP_DAY_QTY = 0;
int AVG_SHIP_WR_DAY_QTY = 0;

String default_product_sk = "";
String default_business_unit_sk = "";
String default_warehouse_sk = "";
String default_supplier_sk = "";

String sql = "";
String sql1 = "SELECT "+
          "CAST(MAX(F.PRODUCT_SK) AS CHAR) AS DEFAULT_PRODUCT_SK, "+
          "CAST(MAX(F.BUSINESS_UNIT_SK) AS CHAR) AS DEFAULT_BUSINESS_UNIT_SK, "+
          "CAST(MAX(F.WAREHOUSE_SK) AS CHAR) AS DEFAULT_WAREHOUSE_SK, "+
          "CAST(MAX(F.SUPPLIER_SK) AS CHAR) AS DEFAULT_SUPPLIER_SK "+
          "FROM "+
          "FACT_PHYSICAL_INVENTORY F "+
          "WHERE F.PRODUCT_SK > 0 AND F.BUSINESS_UNIT_SK > 0 AND F.WAREHOUSE_SK > 0  AND F.SUPPLIER_SK > 0";
                  
String sql2 = "SELECT MAX(DW_LOAD_DATE) AS DW_LOAD_DATE FROM FACT_PHYSICAL_INVENTORY";
String sql3 = "SELECT "+
          "ROUND(AVG(DATEDIFF(F.WAREHOUSE_RECEIPT_DATE,F.REQUISITION_DATE))) AS AVG_REQUISITION_WR_DAY_QTY, "+
          "ROUND(AVG(DATEDIFF(F.PURCHASE_ORDER_DATE,F.REQUISITION_DATE))) AS AVG_REQUISITION_PO_DAY_QTY, "+
          "ROUND(AVG(DATEDIFF(F.SHIP_DATE,F.PURCHASE_ORDER_DATE))) AS AVG_PO_SHIP_DAY_QTY, "+
          "ROUND(AVG(DATEDIFF(F.WAREHOUSE_RECEIPT_DATE,F.SHIP_DATE))) AS AVG_SHIP_WR_DAY_QTY "+
          "FROM "+
          "FACT_PROCUREMENT F, DIMENSION_PRODUCT I "+
          "WHERE "+
          "F.PRODUCT_SK = I.PRODUCT_SK "+
          "AND I.PRODUCT_SK = ? ";
//Oracle
//String sql3 = "SELECT "+
//          "ROUND(AVG(F.WAREHOUSE_RECEIPT_DATE - F.REQUISITION_DATE)) AS AVG_REQUISITION_WR_DAY_QTY, "+
//          "ROUND(AVG(F.PURCHASE_ORDER_DATE - F.REQUISITION_DATE)) AS AVG_REQUISITION_PO_DAY_QTY, "+
//          "ROUND(AVG(F.SHIP_DATE - F.PURCHASE_ORDER_DATE)) AS AVG_PO_SHIP_DAY_QTY, "+
//          "ROUND(AVG(F.WAREHOUSE_RECEIPT_DATE - F.SHIP_DATE)) AS AVG_SHIP_WR_DAY_QTY "+
//          "FROM "+
//          "FACT_PROCUREMENT F, DIMENSION_PRODUCT I "+
//          "WHERE "+
//          "F.PRODUCT_SK = I.PRODUCT_SK "+
//          "AND I.PRODUCT_SK = ? ";     
     
String sql4 = "SELECT DISTINCT PRODUCT_NAME AS PRODUCT_NAME FROM DIMENSION_PRODUCT WHERE PRODUCT_SK = ? ";         
            
String sql_prod = "SELECT DISTINCT D.PRODUCT_SK AS table_id, D.PRODUCT_NAME AS name FROM DIMENSION_PRODUCT D, FACT_PHYSICAL_INVENTORY F WHERE F.PRODUCT_SK = D.PRODUCT_SK ORDER BY D.PRODUCT_NAME";
ArrayList item_ids = new ArrayList();
ArrayList item_names = new ArrayList();

String sql_bu = "SELECT DISTINCT D.BUSINESS_UNIT_SK AS bu_table_id, D.BUSINESS_UNIT_NAME AS bu_name FROM DIMENSION_BUSINESS_UNIT D, FACT_PHYSICAL_INVENTORY F WHERE F.BUSINESS_UNIT_SK = D.BUSINESS_UNIT_SK AND F.PRODUCT_SK = ? ORDER BY D.BUSINESS_UNIT_NAME";
ArrayList bu_ids = new ArrayList();
ArrayList bu_names = new ArrayList();

String sql_supplier = "SELECT DISTINCT D.SUPPLIER_SK AS supplier_table_id, D.SUPPLIER_NAME AS supplier_name FROM DIMENSION_SUPPLIER D, FACT_PHYSICAL_INVENTORY F WHERE F.SUPPLIER_SK = D.SUPPLIER_SK AND F.PRODUCT_SK = ? ORDER BY D.SUPPLIER_NAME";
ArrayList supplier_ids = new ArrayList();
ArrayList supplier_names = new ArrayList();

String sql_warehouse = "SELECT DISTINCT D.WAREHOUSE_SK AS warehouse_table_id, D.WAREHOUSE_NAME AS warehouse_name FROM DIMENSION_WAREHOUSE D, FACT_PHYSICAL_INVENTORY F WHERE F.WAREHOUSE_SK = D.WAREHOUSE_SK AND F.PRODUCT_SK = ? ORDER BY D.WAREHOUSE_NAME";
ArrayList warehouse_ids = new ArrayList();
ArrayList warehouse_names = new ArrayList();

int myResolved = 0;
int mySLAcomp = 0;
String exceptionErrors = "";
String title = "";
String dial_title = "";
String product_name = "";

String DW_LOAD_DATE = "";
StringBuffer content_product = new StringBuffer();
StringBuffer content_product_bu = new StringBuffer();
StringBuffer content_product_ware = new StringBuffer();
StringBuffer content_product_supplier = new StringBuffer();
StringBuffer content_inventory_dial1 = new StringBuffer();
StringBuffer content_inventory_dial2 = new StringBuffer();
StringBuffer content_inventory_dial3 = new StringBuffer();
StringBuffer content_inventory_dial4 = new StringBuffer();

Context context = null;
DataSource dataSource = null;
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;







////////////////////////////////////////////////////////////////////
//SET UP SQL QUERY FOR DATABASE/////////////////////////////////////
////////////////////////////////////////////////////////////////////








////////////////////////////////////////////////////////////////////
//GET CONNECTION TO DATABASE////////////////////////////////////////
////////////////////////////////////////////////////////////////////
//Replace with your client's connection code
context = new InitialContext();
dataSource = (DataSource)((Context)context.lookup("java:comp/env")).lookup("jdbc/mdw_mysql");








////////////////////////////////////////////////////////////////////
//QUERY THE DATABASE////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

try {
   conn = dataSource.getConnection();

   if (debugMode) msgs += "  START-->Query 0= " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql1
   ps = conn.prepareStatement(sql1);
   rs = ps.executeQuery();
   if (rs.next()) {
      default_product_sk = rs.getString("DEFAULT_PRODUCT_SK");
      default_business_unit_sk = rs.getString("DEFAULT_BUSINESS_UNIT_SK");
      default_warehouse_sk = rs.getString("DEFAULT_WAREHOUSE_SK");
      default_supplier_sk = rs.getString("DEFAULT_SUPPLIER_SK");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;
   if (product_sk.length() < 1) {product_sk = default_product_sk;}
   if (business_unit_sk.length() < 1) {business_unit_sk = default_business_unit_sk;}
   if (warehouse_sk.length() < 1) {warehouse_sk = default_warehouse_sk;}
   if (supplier_sk.length() < 1) {supplier_sk = default_supplier_sk;}

   if (debugMode) msgs += "  START-->Query 1= " +getTimeStamp()+ "<br>";
   //get the first query results, String sql2
   ps = conn.prepareStatement(sql2);
   rs = ps.executeQuery();
   if (rs.next()) {
     DW_LOAD_DATE = rb.getString("Updated_with_data_as_of")+rs.getString("DW_LOAD_DATE")+" PST";
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;

 
    if (debugMode) msgs += "  START-->Query 2= " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql4
   ps = conn.prepareStatement(sql4);
   ps.setString(1, product_sk);
   rs = ps.executeQuery();
   if (rs.next()) {
      product_name = rs.getString("PRODUCT_NAME");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;
   title = rb.getString("Inventory_Metrics_for") + " " + product_name;
   dial_title = product_name + " " + rb.getString("Pipeline_Metrics");
 
   if (debugMode) msgs += "  START-->Query 3= " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql_prod
   ps = conn.prepareStatement(sql_prod);
   rs = ps.executeQuery();
   while (rs.next()) {
    String id = ((rs.getString("table_id")!=null)?rs.getString("table_id"):"");
    String name= ((rs.getString("name")!=null)?rs.getString("name"):"");
	item_ids.add(id);
	item_names.add(name);
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;

   if (debugMode) msgs += "  START-->Query 4= " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql_bu
   ps = conn.prepareStatement(sql_bu);
   ps.setString(1, product_sk);
   rs = ps.executeQuery();
   while (rs.next()) {
    String id = ((rs.getString("bu_table_id")!=null)?rs.getString("bu_table_id"):"");
    String name= ((rs.getString("bu_name")!=null)?rs.getString("bu_name"):"");
	bu_ids.add(id);
	bu_names.add(name);
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;


   if (debugMode) msgs += "  START-->Query 5= " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql_supplier
   ps = conn.prepareStatement(sql_supplier);
   ps.setString(1, product_sk);
   rs = ps.executeQuery();
   while (rs.next()) {
    String id = ((rs.getString("supplier_table_id")!=null)?rs.getString("supplier_table_id"):"");
    String name= ((rs.getString("supplier_name")!=null)?rs.getString("supplier_name"):"");
	supplier_ids.add(id);
	supplier_names.add(name);
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;


   if (debugMode) msgs += "  START-->Query 6= " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql_warehouse
   ps = conn.prepareStatement(sql_warehouse);
   ps.setString(1, product_sk);
   rs = ps.executeQuery();
   while (rs.next()) {
    String id = ((rs.getString("warehouse_table_id")!=null)?rs.getString("warehouse_table_id"):"");
    String name= ((rs.getString("warehouse_name")!=null)?rs.getString("warehouse_name"):"");
	warehouse_ids.add(id);
	warehouse_names.add(name);
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;


   if (debugMode) msgs += "  START-->Query 7= " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql3
   ps = conn.prepareStatement(sql3);
   ps.setString(1, product_sk);
   rs = ps.executeQuery();
   if (rs.next()) {
      AVG_REQUISITION_WR_DAY_QTY = rs.getInt("AVG_REQUISITION_WR_DAY_QTY");
      AVG_REQUISITION_PO_DAY_QTY = rs.getInt("AVG_REQUISITION_PO_DAY_QTY");
      AVG_PO_SHIP_DAY_QTY = rs.getInt("AVG_PO_SHIP_DAY_QTY");
      AVG_SHIP_WR_DAY_QTY = rs.getInt("AVG_SHIP_WR_DAY_QTY");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;


} catch (Exception e) {
   StringWriter writer = new StringWriter();
   e.printStackTrace(new PrintWriter(writer));
   System.out.println("Exception while connecting to db and reading = " +writer.getBuffer());
   exceptionErrors  = writer.getBuffer().toString();
}
//close connection
if (conn != null) conn.close(); conn = null;
if (debugMode) msgs += "  END-->Queries= " +getTimeStamp()+ "<br>";







////////////////////////////////////////////////////////////////////
//Format the data for charting//////////////////////////////////////
////////////////////////////////////////////////////////////////////

if (debugMode) msgs += "  START-->Chart 1= " +getTimeStamp()+ "<br>";
//Make a bar chart showing the Product Metrics
//create the parameters for the bar chart
SimpleParameterProvider parameters = new SimpleParameterProvider();
parameters.setParameter( "PRODUCT_SK", product_sk);
//define the bars of the bar chart
parameters.setParameter( "inner-param", "product_sk"); //$NON-NLS-1$ //$NON-NLS-2$
//set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
ArrayList messages = new ArrayList();
//call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart("breadboard", "supply_chain/inventory/dashboards",
                    "inventory_product_vert_bar.widget.xml", parameters,
                    content_product, userSession, messages, null);


if (debugMode) msgs += "  START-->Chart 2= " +getTimeStamp()+ "<br>";
//Make a bar chart showing the product business unit
//create the parameters for the bar chart
parameters = new SimpleParameterProvider();
parameters.setParameter( "PRODUCT_SK", product_sk);
parameters.setParameter( "BUSINESS_UNIT_SK", business_unit_sk);
//define the business_unit axis of the bar chart
parameters.setParameter( "inner-param", "BUSINESS_UNIT_SK"); //$NON-NLS-1$ //$NON-NLS-2$
//set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
//call the chart helper to generate the bar chart image and to get the HTML content
//use the chart definition in 'samples/dashboard/regions.widget.xml'
ChartHelper.doChart("breadboard", "supply_chain/inventory/dashboards",
                    "inventory_product_bu_vert_bar.widget.xml", parameters,
                    content_product_bu, userSession, messages, null );


if (debugMode) msgs += "  START-->Chart 3= " +getTimeStamp()+ "<br>";
// Make a bar chart showing the product category, default business_unit Store 9
// create the parameters for the bar chart
parameters = new SimpleParameterProvider();
parameters.setParameter( "PRODUCT_SK", product_sk);
parameters.setParameter( "WAREHOUSE_SK", warehouse_sk);
// define the business_unit axis of the bar chart
parameters.setParameter( "inner-param", "WAREHOUSE_SK"); //$NON-NLS-1$ //$NON-NLS-2$
// set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
 messages = new ArrayList();
//call the chart helper to generate the bar chart image and to get the HTML content
//use the chart definition in 'samples/dashboard/regions.widget.xml'
ChartHelper.doChart("breadboard", "supply_chain/inventory/dashboards",
                    "inventory_product_ware_vert_bar.widget.xml", parameters,
                    content_product_ware, userSession, messages, null );




// Make a bar chart showing the warehouse, default business_unit Store9
// create the parameters for the bar chart
parameters = new SimpleParameterProvider();
parameters.setParameter( "PRODUCT_SK", product_sk);
parameters.setParameter( "SUPPLIER_SK", supplier_sk);
parameters.setParameter( "outer-params", "SUPPLIER_SK" );
// define the business_unit axis of the bar chart
parameters.setParameter( "inner-param", "SUPPLIER_SK"); //$NON-NLS-1$ //$NON-NLS-2$
// set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
 messages = new ArrayList();
//call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart("breadboard", "supply_chain/inventory/dashboards",
                    "inventory_product_supplier_vert_bar.widget.xml", parameters,
                    content_product_supplier, userSession, messages, null );





  messages = new ArrayList();
   parameters = new SimpleParameterProvider();
   parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "value", ""+AVG_REQUISITION_WR_DAY_QTY );
   parameters.setParameter( "title", rb.getString("Avg_Days_Requisition_to_Warehouse") );
   ChartHelper.doDial("breadboard", "supply_chain/inventory/dashboards", "inventory_dial.widget.xml",
                      parameters, content_inventory_dial1, userSession, messages, null); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$




  messages = new ArrayList();
   parameters = new SimpleParameterProvider();
   parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "value", ""+AVG_REQUISITION_PO_DAY_QTY  );
   parameters.setParameter( "title", rb.getString("Avg_Days_Requisition_to_PO") );
   ChartHelper.doDial("breadboard", "supply_chain/inventory/dashboards", "inventory_dial.widget.xml",
                      parameters, content_inventory_dial2, userSession, messages, null); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$



  messages = new ArrayList();
   parameters = new SimpleParameterProvider();
   parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "value", ""+AVG_PO_SHIP_DAY_QTY );
   parameters.setParameter( "title", rb.getString("Avg_Days_PO_to_Ship") );
   ChartHelper.doDial("breadboard", "supply_chain/inventory/dashboards", "inventory_dial.widget.xml",
                      parameters, content_inventory_dial4, userSession, messages, null); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$



  messages = new ArrayList();
   parameters = new SimpleParameterProvider();
   parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "value", ""+AVG_SHIP_WR_DAY_QTY );
   parameters.setParameter( "title", rb.getString("Avg_Days_Ship_to_Warehouse") );
   ChartHelper.doDial("breadboard", "supply_chain/inventory/dashboards", "inventory_dial.widget.xml",
                      parameters, content_inventory_dial4, userSession, messages, null); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$



if (debugMode) msgs += "  END-->Charts = " +getTimeStamp()+ "<br><br><br>Sql1 = " 
                       +sql+ "<br><br>Sql2 = " +sql2+ "<br><br>Sql3 = " +sql3+ "<br><br>";

 


////////////////////////////////////////////////////////////////////
//Build dynamic drop down menu options//////////////////////////////
////////////////////////////////////////////////////////////////////
for (int i =0; i <  item_ids.size(); i++) {
	String item_name = (String)item_names.get(i);
	String item_id = (String)item_ids.get(i);
	selObj_product += "<option value=\"" +item_id+ "\">" +item_name+ "</option>\n";
}

for (int i =0; i <  bu_ids.size(); i++) {
	String bu_name = (String)bu_names.get(i);
	String bu_id = (String)bu_ids.get(i);
	selObj_business_unit += "<option value=\"" +bu_id+ "\">" +bu_name+ "</option>\n";
}

for (int i =0; i <  supplier_ids.size(); i++) {
	String supplier_name = (String)supplier_names.get(i);
	String supplier_id = (String)supplier_ids.get(i);
	selObj_supplier += "<option value=\"" +supplier_id+ "\">" +supplier_name+ "</option>\n";
}

for (int i =0; i <  warehouse_ids.size(); i++) {
	String warehouse_name = (String)warehouse_names.get(i);
	String warehouse_id = (String)warehouse_ids.get(i);
	selObj_warehouse += "<option value=\"" +warehouse_id+ "\">" +warehouse_name+ "</option>\n";
}

%>


<!-- BEGIN HTML  -->
<html>
<head>
<title><fmt:message key="Breadboard_BI_Sample_Inventory_Dashboard"/></title>


<script type='text/javascript'>
 function submitNewoption_product(selObj_product) {
    document.form1.submit();
 }
 function submitNewoption_bu(selObj_bu) {
    document.form2.submit();
 }
  function submitNewoption_warehouse(selObj_warehouse) {
    document.form3.submit();
 }
  function submitNewoption_supplier(selObj_supplier) {
    document.form4.submit();
 }
</script>
<body>


<table align="center">
<tr>
<td colspan ="2" valign="top" style="width: 66%">

<!-- Replace the src value so it points to your client's logo/banner. -->
<!-- include file="navBarTopSimple.html"  -->
 </td>
 <td valign="top" style="width: 33%" align="right">
 <font style='font-family:Arial'>
<%= DW_LOAD_DATE %>
 </font>
 </td>
 </tr>

<tr>
<td valign="top">
<h3 style='font-family:Arial'><%= title %></h3>
</td>
<td>
<form name="form1" action="inventory_interactive_dashboard.jsp" method="GET">
<select name="product_sk" onChange="submitNewoption_product(this)">
<option value="<%= product_sk %>"><fmt:message key="Select_a_Product"/></option>
<%= selObj_product %>
</select>
<INPUT TYPE=HIDDEN NAME="business_unit_sk" value="<%= business_unit_sk %>">
<INPUT TYPE=HIDDEN NAME="warehouse_sk" value="<%= warehouse_sk %>">
<INPUT TYPE=HIDDEN NAME="supplier_sk" value="<%= supplier_sk %>">
</form>
</td>
<td></td>
</tr>

<tr>
<td valign="bottom" style="width: 33%">
<!-- Top of 1 -->
<span style="font-family:Arial;font-weight:bold">
</span>
<%= content_product.toString() %>
<!-- Bottom of 1 -->
<br/>
</td>
<!-- Top #2 -->
<td valign="top" style="width: 33%">
<span style="font-family:Arial;font-weight:bold">
</span>

<%= content_product_bu.toString() %>

<!-- BOTTOM 2 -->
</td>

<!-- Top 3 -->
<td valign="top" style="width: 33%" rowspan=4>
<br>

<table>
<tr>
<td>
<span style="font-family:Arial;font-size:20">
<center>
<%= dial_title %>
</center>
</span>
<br>
</td></tr>
<tr><td>
<%= content_inventory_dial1.toString() %>
</td></tr>
<tr><td>
<%= content_inventory_dial2.toString() %>
</td></tr>
<tr><td>
<%= content_inventory_dial3.toString() %>
</td></tr>
<tr><td>
<%= content_inventory_dial4.toString() %>
<!-- Bottom of #3 -->
</td></tr>
</table>

</td>
</tr>

<tr>
<td valign="bottom" align="center">
</td>
<td valign="bottom" align="center">
<form name="form2" action="inventory_interactive_dashboard.jsp" method="GET">
<select name="business_unit_sk" onChange="submitNewoption_bu(this)">
<option value="<%= business_unit_sk %>"><fmt:message key="Select_a_Store"/></option>
<%= selObj_business_unit %>
</select>
<INPUT TYPE=HIDDEN NAME="product_sk" value="<%= product_sk %>">
<INPUT TYPE=HIDDEN NAME="warehouse_sk" value="<%= warehouse_sk %>">
<INPUT TYPE=HIDDEN NAME="supplier_sk" value="<%= supplier_sk %>">
</form>
</td>
</tr>

<tr>
<!-- Top of #4 -->
<td valign="top" align="left">
<span style="font-family:Arial;font-weight:bold">
</span>
<%= content_product_ware.toString() %>
</td>
<!-- BOTTOM 4 -->
<!-- Top of #5 -->
<td valign="top" align = "center">
<%= content_product_supplier.toString() %>
</td>
</tr>

<tr>
<td valign="bottom" align="center">
<form name="form3" action="inventory_interactive_dashboard.jsp" method="GET">
<select name="warehouse_sk" onChange="submitNewoption_warehouse(this)">
<option value="<%= warehouse_sk %>"><fmt:message key="Select_a_Warehouse"/></option>
<%= selObj_warehouse %>
</select>
<INPUT TYPE=HIDDEN NAME="product_sk" value="<%= product_sk %>">
<INPUT TYPE=HIDDEN NAME="business_unit_sk" value="<%= business_unit_sk %>">
<INPUT TYPE=HIDDEN NAME="supplier_sk" value="<%= supplier_sk %>">
</form>
</td>
<td valign="bottom" align="center">
<form name="form4" action="inventory_interactive_dashboard.jsp" method="GET">
<select name="supplier_sk" onChange="submitNewoption_supplier(this)">
<option value="<%= supplier_sk %>"><fmt:message key="Select_a_Supplier"/></option>
<%= selObj_supplier %>
</select>
<INPUT TYPE=HIDDEN NAME="product_sk" value="<%= product_sk %>">
<INPUT TYPE=HIDDEN NAME="business_unit_sk" value="<%= business_unit_sk %>">
<INPUT TYPE=HIDDEN NAME="warehouse_sk" value="<%= warehouse_sk %>">
</form>
</td>
</tr>
</table>



<BR><BR>
<center>Copyright © 2009 Breadboard BI, Inc. All rights reserved.</center>
</body>
</html>
