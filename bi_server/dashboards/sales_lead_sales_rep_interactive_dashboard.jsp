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
String selObj_sales_rep = "";
String sales_representative_sk = ((request.getParameter("sales_representative_sk")!=null)?request.getParameter("sales_representative_sk"):"");

// Dial Widget Variables
int AVG_ASSIGNED_QUALIFIED_DAY_QTY = 0;
int AVG_ASSIGNED_DEAD_DAY_QTY = 0;
int AVG_ASSIGNED_INPROCESS_DAY_QTY = 0;
int AVG_INPROCESS_QUALIFIED_DAY_QTY = 0;

String default_sales_representative_sk = "";

String sql = "";
// For Oracle cast to varchar2 with precision
String sql1 = "SELECT "+
          "CAST(MAX(F.SALES_REPRESENTATIVE_SK) AS CHAR) AS DEFAULT_SALES_REPRESENTATIVE_SK "+
          "FROM "+
          "FACT_SALES_LEAD F"; 
String sql2 = "SELECT MAX(DW_LOAD_DATE) AS DW_LOAD_DATE FROM FACT_SALES_LEAD";
String sql3 = "SELECT "+
          "ROUND(AVG(DATEDIFF(F.QUALIFIED_DATE,F.ASSIGNED_DATE))) AS AVG_ASSIGNED_QUALIFIED_DAY_QTY, "+
          "ROUND(AVG(DATEDIFF(F.DEAD_DATE,F.ASSIGNED_DATE))) AS AVG_ASSIGNED_DEAD_DAY_QTY, "+
          "ROUND(AVG(DATEDIFF(F.IN_PROCESS_DATE,F.ASSIGNED_DATE))) AS AVG_ASSIGNED_INPROCESS_DAY_QTY, "+
          "ROUND(AVG(DATEDIFF(F.QUALIFIED_DATE,F.IN_PROCESS_DATE))) AS AVG_INPROCESS_QUALIFIED_DAY_QTY "+
          "FROM "+
          "FACT_SALES_LEAD F "+
          "WHERE "+
          "F.SALES_REPRESENTATIVE_SK = ? ";
// Oracle
//String sql3 = "SELECT "+
//          "ROUND(AVG(F.QUALIFIED_DATE - F.ASSIGNED_DATE)) AS AVG_ASSIGNED_QUALIFIED_DAY_QTY, "+
//          "ROUND(AVG(F.DEAD_DATE - F.ASSIGNED_DATE)) AS AVG_ASSIGNED_DEAD_DAY_QTY, "+
//          "ROUND(AVG(F.IN_PROCESS_DATE - F.ASSIGNED_DATE)) AS AVG_ASSIGNED_INPROCESS_DAY_QTY, "+
//          "ROUND(AVG(F.QUALIFIED_DATE - F.IN_PROCESS_DATE)) AS AVG_INPROCESS_QUALIFIED_DAY_QTY "+
//          "FROM "+
//          "FACT_SALES_LEAD F "+
//          "WHERE "+
//         "F.SALES_REPRESENTATIVE_SK = ? ";

String sql5 = "SELECT DISTINCT FULL_NAME AS FULL_NAME FROM DIMENSION_PERSON WHERE PERSON_SK = ? ";                     
String sql_sales_rep = "SELECT DISTINCT D.PERSON_SK AS table_id, D.FULL_NAME AS name FROM DIMENSION_PERSON D, FACT_SALES_LEAD F WHERE F.SALES_REPRESENTATIVE_SK = D.PERSON_SK ORDER BY D.FULL_NAME";
ArrayList sales_rep_ids = new ArrayList();
ArrayList sales_rep_names = new ArrayList();

int myResolved = 0;
int mySLAcomp = 0;
String exceptionErrors = "";
String title = "";
String full_name = "";
String product_name = "";
String dial_title = "Pipeline Time Metrics";

String DW_LOAD_DATE = "";
StringBuffer content_temporal = new StringBuffer();
StringBuffer content_product = new StringBuffer();
StringBuffer content_lead_status = new StringBuffer();
StringBuffer content_lead_country = new StringBuffer();
StringBuffer content_sales_lead_dial1 = new StringBuffer();
StringBuffer content_sales_lead_dial2 = new StringBuffer();
StringBuffer content_sales_lead_dial3 = new StringBuffer();
StringBuffer content_sales_lead_dial4 = new StringBuffer();

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
      default_sales_representative_sk = rs.getString("DEFAULT_SALES_REPRESENTATIVE_SK");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;
   if (sales_representative_sk.length() < 1) {sales_representative_sk = default_sales_representative_sk;}
 
 
   if (debugMode) msgs += "  START-->Query 1= " +getTimeStamp()+ "<br>";
   //get the first query results, String sql2
   ps = conn.prepareStatement(sql2);
   rs = ps.executeQuery();
   if (rs.next()) {
     DW_LOAD_DATE = "Updated as of "+rs.getString("DW_LOAD_DATE")+" PST";
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;


 
     if (debugMode) msgs += "  START-->Query 2.5= " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql5
   ps = conn.prepareStatement(sql5);
   ps.setString(1, sales_representative_sk);
   rs = ps.executeQuery();
   if (rs.next()) {
      full_name = rs.getString("FULL_NAME");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;
   title = "Sales Lead Metrics for " + full_name;
 
    if (debugMode) msgs += "  START-->Query 3= " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql_sales_rep
   ps = conn.prepareStatement(sql_sales_rep);
   rs = ps.executeQuery();
   while (rs.next()) {
    String id = ((rs.getString("table_id")!=null)?rs.getString("table_id"):"");
    String name= ((rs.getString("name")!=null)?rs.getString("name"):"");
	sales_rep_ids.add(id);
	sales_rep_names.add(name);
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;
 


   if (debugMode) msgs += "  START-->Query 7= " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql3
   ps = conn.prepareStatement(sql3);
   ps.setString(1, sales_representative_sk);
   rs = ps.executeQuery();
   if (rs.next()) {
      AVG_ASSIGNED_QUALIFIED_DAY_QTY = rs.getInt("AVG_ASSIGNED_QUALIFIED_DAY_QTY");
      AVG_ASSIGNED_QUALIFIED_DAY_QTY = rs.getInt("AVG_ASSIGNED_DEAD_DAY_QTY");
      AVG_ASSIGNED_INPROCESS_DAY_QTY = rs.getInt("AVG_ASSIGNED_INPROCESS_DAY_QTY");
      AVG_INPROCESS_QUALIFIED_DAY_QTY = rs.getInt("AVG_INPROCESS_QUALIFIED_DAY_QTY");
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
if (debugMode) msgs += "  START-->Chart 199= " +getTimeStamp()+ "<br>";
//Make a bar chart showing the Product Metrics
//create the parameters for the bar chart
SimpleParameterProvider parameters = new SimpleParameterProvider();
parameters.setParameter( "SALES_REPRESENTATIVE_SK", sales_representative_sk);
//define the bars of the bar chart
parameters.setParameter( "inner-param", "sales_representative_sk"); //$NON-NLS-1$ //$NON-NLS-2$
//set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
ArrayList messages = new ArrayList();
//call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart("breadboard", "customer_360/leads/dashboards",
                    "sales_lead_sales_rep_period_vert_bar.widget.xml", parameters,
                    content_temporal, userSession, messages, null);


if (debugMode) msgs += "  START-->Chart 1= " +getTimeStamp()+ "<br>";
//Make a bar chart showing the Product Metrics
//create the parameters for the bar chart
parameters = new SimpleParameterProvider();
parameters.setParameter( "SALES_REPRESENTATIVE_SK", sales_representative_sk);
//define the bars of the bar chart
parameters.setParameter( "inner-param", "sales_representative_sk"); //$NON-NLS-1$ //$NON-NLS-2$
//set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
//call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart("breadboard", "customer_360/leads/dashboards",
                    "sales_lead_sales_rep_product_vert_bar.widget.xml", parameters,
                    content_product, userSession, messages, null);


if (debugMode) msgs += "  START-->Chart 1= " +getTimeStamp()+ "<br>";
//Make a bar chart showing the Product Metrics
//create the parameters for the bar chart
parameters = new SimpleParameterProvider();
parameters.setParameter( "SALES_REPRESENTATIVE_SK", sales_representative_sk);
//define the bars of the bar chart
parameters.setParameter( "inner-param", "sales_representative_sk"); //$NON-NLS-1$ //$NON-NLS-2$
//set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
//call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart("breadboard", "customer_360/leads/dashboards",
                    "sales_lead_sales_rep_status_vert_bar.widget.xml", parameters,
                    content_lead_status, userSession, messages, null);

if (debugMode) msgs += "  START-->Chart 1= " +getTimeStamp()+ "<br>";
//Make a bar chart showing the Product Metrics
//create the parameters for the bar chart
parameters = new SimpleParameterProvider();
parameters.setParameter( "SALES_REPRESENTATIVE_SK", sales_representative_sk);
//define the bars of the bar chart
parameters.setParameter( "inner-param", "sales_representative_sk"); //$NON-NLS-1$ //$NON-NLS-2$
//set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
//call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart("breadboard", "customer_360/leads/dashboards",
                    "sales_lead_sales_rep_country_vert_bar.widget.xml", parameters,
                    content_lead_country, userSession, messages, null);






  messages = new ArrayList();
   parameters = new SimpleParameterProvider();
   parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "value", ""+AVG_ASSIGNED_QUALIFIED_DAY_QTY );
   parameters.setParameter( "title", "Avg Days Assigned to Qualified" );
   ChartHelper.doDial("breadboard", "customer_360/leads/dashboards", "sales_lead_dial.widget.xml",
                      parameters, content_sales_lead_dial1, userSession, messages, null); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$




  messages = new ArrayList();
   parameters = new SimpleParameterProvider();
   parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "value", ""+AVG_ASSIGNED_DEAD_DAY_QTY  );
   parameters.setParameter( "title", "Avg Days Assigned to Dead" );
   ChartHelper.doDial("breadboard", "customer_360/leads/dashboards", "sales_lead_dial.widget.xml",
                      parameters, content_sales_lead_dial2, userSession, messages, null); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$



  messages = new ArrayList();
   parameters = new SimpleParameterProvider();
   parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "value", ""+AVG_ASSIGNED_INPROCESS_DAY_QTY );
   parameters.setParameter( "title", "Avg Days Assigned to In Process" );
   ChartHelper.doDial("breadboard", "customer_360/leads/dashboards", "sales_lead_dial.widget.xml",
                      parameters, content_sales_lead_dial4, userSession, messages, null); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$



  messages = new ArrayList();
   parameters = new SimpleParameterProvider();
   parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
   parameters.setParameter( "value", ""+AVG_INPROCESS_QUALIFIED_DAY_QTY );
   parameters.setParameter( "title", "Avg Days In Process to Qualified" );
   ChartHelper.doDial("breadboard", "customer_360/leads/dashboards", "sales_lead_dial.widget.xml",
                      parameters, content_sales_lead_dial4, userSession, messages, null); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$


if (debugMode) msgs += "  END-->Charts = " +getTimeStamp()+ "<br><br><br>Sql1 = " 
                       +sql+ "<br><br>Sql2 = " +sql2+ "<br><br>Sql3 = " +sql3+ "<br><br>";

 


////////////////////////////////////////////////////////////////////
//Build dynamic drop down menu options//////////////////////////////
////////////////////////////////////////////////////////////////////
for (int i =0; i <  sales_rep_ids.size(); i++) {
	String sales_rep_name = (String)sales_rep_names.get(i);
	String sales_rep_id = (String)sales_rep_ids.get(i);
	selObj_sales_rep += "<option value=\"" +sales_rep_id+ "\">" +sales_rep_name+ "</option>\n";
}

%>


<!-- BEGIN HTML  -->
<html>
<head>
<title>Breadboard BI Sample Sales Lead Sales Representative Dashboard</title>

<script type='text/javascript'>
 function submitNewoption_product(selObj_sales_rep) {
    document.form1.submit();
 }
 
</script>

</head>


<body>


<table align="center">
<tr>
<td colspan ="2" valign="top" style="width: 66%">

<!-- Script to reference calendar.  This js would have to be put into your client's web application. -->
<script type="text/javascript" src="/pentaho/js/common.js"></script>

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
<form name="form1" action="sales_lead_sales_rep_interactive_dashboard.jsp" method="GET">
<select name="sales_representative_sk" onChange="submitNewoption_product(this)">
<option value="<%= sales_representative_sk %>">Select a Sales Representative</option>
<%= selObj_sales_rep %>
</select>
</form>
</td>
<td></td>
</tr>

<tr>
<td valign="bottom" style="width: 33%">
<!-- Top of 1 -->
<span style="font-family:Arial;font-weight:bold">
</span>
<%= content_temporal.toString() %>
<!-- Bottom of 1 -->
<br/>
</td>
<!-- Top #2 -->
<td valign="top" style="width: 33%">
<span style="font-family:Arial;font-weight:bold">
</span>

<%= content_product.toString() %>

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
<%= content_sales_lead_dial1.toString() %>
</td></tr>
<tr><td>
<%= content_sales_lead_dial2.toString() %>
</td></tr>
<tr><td>
<%= content_sales_lead_dial3.toString() %>
</td></tr>
<tr><td>
<%= content_sales_lead_dial4.toString() %>
<!-- Bottom of #3 -->
</td></tr>
</table>

</td>
</tr>

<tr>
<td valign="bottom" align="center">
</td>
<td valign="bottom" align="center">
</td>
</tr>

<tr>
<!-- Top of #4 -->
<td valign="top" align="left">
<span style="font-family:Arial;font-weight:bold">
</span>
<%= content_lead_status.toString() %>
</td>
<!-- BOTTOM 4 -->
<!-- Top of #5 -->
<td valign="top" align = "center">
<%= content_lead_country.toString() %>
</td>
</tr>

<tr>
<td valign="bottom" align="center">
</td>
<td valign="bottom" align="center">
</td>
</tr>
</table>



<BR><BR>
<center>Copyright © 2009 Breadboard BI, Inc. All rights reserved.</center>
</body>
</html>
