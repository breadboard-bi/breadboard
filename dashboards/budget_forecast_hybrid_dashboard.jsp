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

// Drop-down Variables
String selObj_fiscal_period = "";
String fiscal_period_sk = ((request.getParameter("fiscal_period_sk")!=null)?request.getParameter("fiscal_period_sk"):"");


String msgs = "Start Time = " +getTimeStamp();
boolean debugMode = false;
if (request.getParameter("show") != null)
   debugMode = true;

String sql = "";
String sql2 = "SELECT MAX(DW_LOAD_DATE) AS DW_LOAD_DATE FROM FACT_BUDGET_FORECAST";
String sql_default_fiscal_period_sk = "SELECT CAST(MAX(D.FISCAL_PERIOD_SK)AS CHAR) AS DEFAULT_FISCAL_PERIOD_SK FROM FACT_BUDGET_FORECAST F, DIMENSION_FISCAL_PERIOD D WHERE F.FISCAL_PERIOD_SK = D.FISCAL_PERIOD_SK"; 
String sql_fiscal_period = "SELECT DISTINCT D.FISCAL_PERIOD_SK AS fiscal_period_table_id, D.FISCAL_PERIOD_ID AS fiscal_period_name FROM DIMENSION_FISCAL_PERIOD D, FACT_BUDGET_FORECAST F WHERE F.FISCAL_PERIOD_SK = D.FISCAL_PERIOD_SK ORDER BY D.FISCAL_PERIOD_NAME";
ArrayList fiscal_period_ids = new ArrayList();
ArrayList fiscal_period_names = new ArrayList();

String sql_fiscal_period_name = "SELECT DISTINCT FISCAL_PERIOD_ID AS FISCAL_PERIOD FROM DIMENSION_FISCAL_PERIOD WHERE FISCAL_PERIOD_SK = ? ";                     

int myResolved = 0;
int mySLAcomp = 0;
String exceptionErrors = "";

String dashboard_title; 
String widget_1_title = "";
String widget_2_title = "";
String widget_3_title = "";
String widget_4_title = "";
String trend_line_order_budget_actual = "";
String trend_line_manufacturing_budget_actual = "";
String default_fiscal_period_sk = "";
String fiscal_period = "";
String dw_load_date = "";
StringBuffer content_period = new StringBuffer();
StringBuffer content_account_type = new StringBuffer();
StringBuffer content_bu_type = new StringBuffer();
StringBuffer content_country = new StringBuffer();
StringBuffer content_line1 = new StringBuffer();
StringBuffer content_line2 = new StringBuffer();

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
if (debugMode) msgs += "<br>  START-->Get DB connection = " +getTimeStamp()+ "<br>";
context = new InitialContext();
dataSource = (DataSource)((Context)context.lookup("java:comp/env")).lookup("jdbc/mdw_mysql");
if (debugMode) msgs += "  END-->Get DB connection = " +getTimeStamp()+ "<br>";





////////////////////////////////////////////////////////////////////
//QUERY THE DATABASE////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
if (debugMode) msgs += "  START-->Query 1= " +getTimeStamp()+ "<br>";

try {
   //get the first query results, String sql_fiscal_period
   conn = dataSource.getConnection(); 
   ps = conn.prepareStatement(sql_default_fiscal_period_sk);
   rs = ps.executeQuery();
   if (rs.next()) {
      default_fiscal_period_sk = rs.getString("DEFAULT_FISCAL_PERIOD_SK");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;
   if( fiscal_period_sk.length()<1) fiscal_period_sk = default_fiscal_period_sk; 


   if (debugMode) msgs += "  START-->Query Budget Forecast= " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql_fiscal_period
   ps = conn.prepareStatement(sql_fiscal_period);
   rs = ps.executeQuery();
   while (rs.next()) {
    String id = ((rs.getString("fiscal_period_table_id")!=null)?rs.getString("fiscal_period_table_id"):"");
    String name= ((rs.getString("fiscal_period_name")!=null)?rs.getString("fiscal_period_name"):"");
	fiscal_period_ids.add(id);
	fiscal_period_names.add(name);
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;


    if (debugMode) msgs += "  START-->Query Budget Forecast Name = " +getTimeStamp()+ "<br>";
   //now get the next query results, String sql_fiscal_period_name
   ps = conn.prepareStatement(sql_fiscal_period_name);
   ps.setString(1, fiscal_period_sk);
   rs = ps.executeQuery();
   if (rs.next()) {
      fiscal_period = rs.getString("FISCAL_PERIOD");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;


   if (debugMode) msgs += "  START-->Query 2= " +getTimeStamp()+ "<br>";
   //now get the second query results, String sql2
   ps = conn.prepareStatement(sql2);
   rs = ps.executeQuery();
   if (rs.next()) {
      dw_load_date = "Updated with data as of "+rs.getString("DW_LOAD_DATE")+" PST";
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



dashboard_title = "Budget Forecast Dashboard";
widget_1_title = "Budget Amounts for All Fiscal Periods";
widget_2_title = "Products Category Budget Amounts for Fiscal Period "+fiscal_period;
widget_3_title = "Business Unit Type Budget Amounts for Fiscal Period "+fiscal_period;
widget_4_title = "Customer Country Budget Amounts for Fiscal Period "+fiscal_period;


trend_line_order_budget_actual = "Order Budget v. Actuals for All Periods";
trend_line_manufacturing_budget_actual = "Manufacturing Budget v. Actuals for All Periods"; 


////////////////////////////////////////////////////////////////////
//Format the data for charting//////////////////////////////////////
////////////////////////////////////////////////////////////////////

// Make a bar chart showing the periods
// create the parameters for the bar chart
if (debugMode) msgs += "  START-->Chart 1= " +getTimeStamp()+ "<br>";
SimpleParameterProvider parameters = new SimpleParameterProvider();
// define the click url template
parameters.setParameter( "drill-url", "Pivot?solution=breadboard&path=finance/budget_forecast/analysis&action=budget_forecast_time_cube.xaction" );
// parameters.setParameter( "FISCAL_PERIOD_SK", fiscal_period_sk );
// parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
// define the bars of the bar chart
parameters.setParameter( "inner-param", "FISCAL_PERIOD_SK"); //$NON-NLS-1$ //$NON-NLS-2$
// set the width and the height
parameters.setParameter( "image-width", "350"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "250"); //$NON-NLS-1$ //$NON-NLS-2$
ArrayList messages = new ArrayList();
// call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart( "breadboard", "finance/budget_forecast/dashboards", 
					"budget_forecast_period_vert_bar.widget.xml", parameters, 
					content_period, userSession, messages, null); 




// Make a bar chart showing the products
// create the parameters for the bar chart
if (debugMode) msgs += "  START-->Chart 2= " +getTimeStamp()+ "<br>";
parameters = new SimpleParameterProvider();
// define the click url template
   parameters.setParameter( "drill-url", "Pivot?solution=breadboard&path=finance/budget_forecast/analysis&action=budget_forecast_product_cube.xaction" );
// define the bars of the bar chart
   parameters.setParameter( "FISCAL_PERIOD_SK", fiscal_period_sk );
// parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
parameters.setParameter( "inner-param", "FISCAL_PERIOD_SK"); //$NON-NLS-1$ //$NON-NLS-2$
// set the width and the height
parameters.setParameter( "image-width", "350"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "250"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
// call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart( "breadboard", "finance/budget_forecast/dashboards",
 					"budget_forecast_period_product_vert_bar.widget.xml", parameters, 
 					content_account_type, userSession, messages, null ); 




// Make a bar chart showing the business unit types 
// create the parameters for the bar chart
if (debugMode) msgs += "  START-->Chart 3= " +getTimeStamp()+ "<br>";
parameters = new SimpleParameterProvider();
// define the click url template
parameters.setParameter( "drill-url", "Pivot?solution=breadboard&path=finance/budget_forecast/analysis&action=budget_forecast_bu_cube.xaction" );
parameters.setParameter( "FISCAL_PERIOD_SK", fiscal_period_sk );
// parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
// parameters.setParameter( "outer-params", "BU_TYPE" );
// define the account_type axis of the bar chart
parameters.setParameter( "inner-param", "BU_TYPE"); //$NON-NLS-1$ //$NON-NLS-2$
// set the width and the height
parameters.setParameter( "image-width", "350"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "250"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
// call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart( "breadboard", "finance/budget_forecast/dashboards", 
					"budget_forecast_period_bu_type_vert_bar.widget.xml", parameters, 
					content_bu_type, userSession, messages, null ); 




// Make a bar chart showing the customer country 
// create the parameters for the bar chart
if (debugMode) msgs += "  START-->Chart 3= " +getTimeStamp()+ "<br>";
parameters = new SimpleParameterProvider();
// define the click url template
parameters.setParameter( "drill-url", "Pivot?solution=breadboard&path=finance/budget_forecast/analysis&action=budget_forecast_customer_cube.xaction" );
parameters.setParameter( "FISCAL_PERIOD_SK", fiscal_period_sk );
// parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
// parameters.setParameter( "outer-params", "BU_TYPE" );
// define the account_type axis of the bar chart
parameters.setParameter( "inner-param", "BU_TYPE"); //$NON-NLS-1$ //$NON-NLS-2$
// set the width and the height
parameters.setParameter( "image-width", "350"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "250"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
// call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart( "breadboard", "finance/budget_forecast/dashboards", 
					"budget_forecast_period_country_vert_bar.widget.xml", parameters, 
					content_country, userSession, messages, null ); 




// Make a line showing the order forecast v. actuals.
// create the parameters for the line chart
if (debugMode) msgs += "  START-->Chart 4= " +getTimeStamp()+ "<br>";
parameters = new SimpleParameterProvider();
// parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
// parameters.setParameter( "FISCAL_PERIOD_SK", fiscal_period_sk );
// parameters.setParameter( "outer-params", "BU_TYPE" );
// define the category axis of the bar chart
parameters.setParameter( "inner-param", "BU_TYPE"); //$NON-NLS-1$ //$NON-NLS-2$
// set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "200"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
// call the chart helper to generate the pie chart image and to get the HTML content
ChartHelper.doChart( "breadboard", "finance/budget_forecast/dashboards", 
				"budget_forecast_budget_period_line.widget.xml", parameters, 
				content_line1, userSession, messages, null ); 



// Make another line showing the manufacturing forecast v. actuals.
// create the parameters for the line chart
parameters = new SimpleParameterProvider();
//parameters.setParameter( "FISCAL_PERIOD_SK", fiscal_period_sk );
//parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
//parameters.setParameter( "outer-params", "FISCAL_PERIOD_SK" );		
// define the category axis of the bar chart
//parameters.setParameter( "inner-param", "FISCAL_PERIOD_SK"); //$NON-NLS-1$ //$NON-NLS-2$
// set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "200"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
// call the chart helper to generate the pie chart image and to get the HTML content
// use the chart definition in 'samples/dashboard/regions.widget.xml'
ChartHelper.doChart( "breadboard", "finance/budget_forecast/dashboards",
 			"budget_forecast_manufacturing_period_line.widget.xml", parameters, 
 			content_line2, userSession, messages, null ); 




if (debugMode) msgs += "  END-->Charts = " +getTimeStamp()+ "<br><br><br>Sql1 = " 
                       +sql+ "<br><br>Sql2 = " +sql2+ "<br><br>Sql3 = ";




////////////////////////////////////////////////////////////////////
//Build dynamic drop down menu options//////////////////////////////
////////////////////////////////////////////////////////////////////
for (int i =0; i <  fiscal_period_ids.size(); i++) {
	String fiscal_period_id = (String)fiscal_period_ids.get(i);
	String fiscal_period_name = (String)fiscal_period_names.get(i);
	selObj_fiscal_period += "<option value=\"" +fiscal_period_id+ "\">" +fiscal_period_name+ "</option>\n";
}

%>



   




<!-- BEGIN HTML  -->
<html>
<head>
<title>Breadboard BI Sample Budget Forecast Dashboard</title>


<script type='text/javascript'>
 function submitNewoption(selObj) {
    document.form1.submit();
 }

  function submitNewoption_budget_forecast(selObj_fiscal_period) {
    document.form1.submit();
 }
</script>
</head>

<body>

<% if (debugMode) { %> <%= msgs %> <%}%>

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
<%= dw_load_date %>
 </font>
 </td>
 </tr>

<tr>
<td valign="top" colspan="3">

<h3 style='font-family:Arial'><%= dashboard_title %></h3>
</td>
</tr>

<tr>
<td valign="top"></td>
<td valign="top" colspan="2">
<form name="form1" action="budget_forecast_hybrid_dashboard.jsp" method="GET">

<select name="fiscal_period_sk" onChange="submitNewoption_budget_forecast(this)">
<option value="<%= fiscal_period_sk %>">Select a Fiscal Period</option>
<%= selObj_fiscal_period %>
</select>

</form>

</td>
</tr>

<tr>
<td valign="top" style="width: 33%;font-family:Arial;font-weight:bold;">
<!-- Top of 1 -->
<%= widget_1_title %><br>
<small>click on a bar to open an Analysis cube</small>
<%= content_period.toString() %>
<!-- Bottom of 1 -->
</td>

<td valign="top" style="width: 33%;font-family:Arial;font-weight:bold;">
<!-- Top #2 -->
<%= widget_2_title %><br>
<small>click on a bar to open an Analysis cube</small>
<%= content_account_type.toString() %>
<!-- BOTTOM 2 -->
</td>

<!-- Top 3 -->        
<td valign="top" style="width: 33%;font-family:Arial;font-weight:bold;">
<%= widget_3_title %><br>
<small>click on a bar to open an Analysis cube</small>
<%= content_bu_type.toString() %>
<!-- Bottom of #3 -->
</td>
</tr>

<tr>
<td valign="top" style="font-family:Arial;font-weight:bold">
<br>
<%= widget_4_title %>
<BR>
<small>click on a bar to open an Analysis cube</small>
<%= content_country.toString() %>
<!-- Top of #4 -->
<!-- BOTTOM 4 -->
</td>

<!-- Top of #5 -->
<td style="vertical-align: top;font-family:Arial;font-weight:bold;">
<br>
<%= trend_line_order_budget_actual %>
<br>
<%= content_line1.toString() %>
</td>    

<td style="vertical-align: top;font-family:Arial;font-weight:bold;">
<br>
<%= trend_line_manufacturing_budget_actual %>
<br>
<%= content_line2.toString() %>  
<!-- Bottom of #3 -->
</td>

</tr>
</table>

<BR><BR>
<center>Copyright © 2009 Breadboard BI, Inc. All rights reserved.</center>
</body>

</html>
