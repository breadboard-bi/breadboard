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

<%    
/*
*  Copyright 2008 Breadboard BI, Inc.  All rights reserved.
*
*  Version 2.0 Beta
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
String temporal_value = ((request.getParameter("temporal_value")!=null)?request.getParameter("temporal_value"):"");
String temporal_cat = ((request.getParameter("temporal_cat")!=null)?request.getParameter("temporal_cat"):"");
String source_system_sk = ((request.getParameter("source_system_sk")!=null)?request.getParameter("source_system_sk"):"");
String keyword = ((request.getParameter("keyword")!=null)?request.getParameter("keyword"):"");
String referer = ((request.getParameter("referer")!=null)?request.getParameter("referer"):"");

// Get user name from session, if NULL use 0 (demo user)
// String user_name = ""; //request.getRemoteUser();
String user_name = ((request.getRemoteUser()!=null)?request.getRemoteUser():"");
if( user_name.length() < 1) {user_name = "demo";}
String hosted_client_sk = "";
String user_desc = "";

String default_source_system_sk = "";
String selObj_source_system = "";
String temporal_week_value =  "";
String temporal_month_value = "";
String temporal_year_value = "";
String temporal_day_value = "";
String temporal_quarter_value = "";

// String temporal_week_prev_value =  "";
// String temporal_month_prev_value = "";
// String temporal_year_prev_value = "";
// String temporal_day_prev_value = "";
// String temporal_quarter_prev_value = "";

String sql_user = "SELECT USER_DESC, HOSTED_CLIENT_SK FROM ADMIN_USER WHERE USER_NAME = ?";
String sql_default_source = "SELECT DISTINCT PARENT_SOURCE_SYSTEM_SK AS SOURCE_SYSTEM_SK FROM DIMENSION_SOURCE_SYSTEM WHERE DEFAULT_WEB_SOURCE_IND = 'Y' AND HOSTED_CLIENT_SK = ?";
String sql = "";
String sql2 = "SELECT MAX(REQUEST_DATE) AS REQUEST_DATE FROM FACT_WEB_PAGE_VIEW WHERE HOSTED_CLIENT_SK = ?";
// Oracle - String sql2 = "SELECT TO_CHAR(MAX(REQUEST_DATE),'MM-DD-YYYY HH24:MI:SS') AS REQUEST_DATE FROM FACT_WEB_PAGE_VIEW WHERE HOSTED_CLIENT_SK = ?";
// Non Oracle - String sql2 = "SELECT MAX(REQUEST_DATE) AS REQUEST_DATE FROM FACT_WEB_PAGE_VIEW WHERE HOSTED_CLIENT_SK = ?";

String sql_sys = "SELECT DISTINCT D.PARENT_SOURCE_SYSTEM_SK AS table_id, D.PARENT_SOURCE_SYSTEM_NAME AS name FROM DIMENSION_SOURCE_SYSTEM D, FACT_WEB_PAGE_VIEW F WHERE D.HOSTED_CLIENT_SK = ? AND F.SOURCE_SYSTEM_SK = D.SOURCE_SYSTEM_SK";
ArrayList sys_ids = new ArrayList();
ArrayList sys_names = new ArrayList();
int myResolved = 0;
int mySLAcomp = 0;
String exceptionErrors = "";
String title = "";
String report_title = "";
String click_instructions="";

String update_date = "";
StringBuffer content_1 = new StringBuffer(); 
StringBuffer content_2 = new StringBuffer(); 
StringBuffer content_3 = new StringBuffer(); 
ByteArrayOutputStream report_1 = new ByteArrayOutputStream();
StringBuffer content_4 = new StringBuffer(); 

Context context = null;
DataSource dataSource = null;
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;







////////////////////////////////////////////////////////////////////
//SET UP SQL QUERY FOR DATABASE/////////////////////////////////////
////////////////////////////////////////////////////////////////////
if (temporal_value.length() < 1) {
//used for test data, uncomment to default to current month.
temporal_cat = "Quarter of ";
temporal_value = "2007Q1";
// temporal_cat = "Month of ";
// Date current_dt = new Date();	
// SimpleDateFormat sdf_year = new SimpleDateFormat("yyyy");
// SimpleDateFormat sdf_month = new SimpleDateFormat("MM"); 
// temporal_value = sdf_year.format(current_dt)+sdf_month.format(current_dt);
}

if (temporal_value.indexOf("W") >= 0) {
   temporal_cat = "Week of ";
   sql  = "SELECT "+
          "MIN(D.DATE_SK) AS temporal_day_value, "+
          "MIN(D.WEEK_NAME) AS temporal_week_value, "+
          "MIN(D.MONTH_SK) AS temporal_month_value, "+
          "MIN(D.YEAR_SK) AS temporal_year_value, "+
          "MIN(D.YEAR_QUARTER_NAME) AS temporal_quarter_value "+
//          "MIN(P.DATE_SK) AS temporal_day_prev_value, "+
//          "MIN(P.WEEK_NAME) AS temporal_week_prev_value, "+
//          "MIN(P.MONTH_SK) AS temporal_month_prev_value, "+
//          "MIN(P.YEAR_SK) AS temporal_year_prev_value, "+
//          "MIN(P.YEAR_QUARTER_NAME) AS temporal_quarter_prev_value "+          
          "FROM "+
          "DIMENSION_DAY D "+
          "WHERE "+
          "D.WEEK_NAME = ?";
} else if (temporal_value.indexOf("Q") >= 0) {
   temporal_cat = "Quarter of ";
   sql  = "SELECT "+
          "MIN(D.DATE_SK) AS temporal_day_value, "+
          "MIN(D.WEEK_NAME) AS temporal_week_value, "+
          "MIN(D.MONTH_SK) AS temporal_month_value, "+
          "MIN(D.YEAR_SK) AS temporal_year_value, "+
          "MIN(D.YEAR_QUARTER_NAME) AS temporal_quarter_value "+
//          "MIN(P.DATE_SK) AS temporal_day_prev_value, "+
//          "MIN(P.WEEK_NAME) AS temporal_week_prev_value, "+
//          "MIN(P.MONTH_SK) AS temporal_month_prev_value, "+
//          "MIN(P.YEAR_SK) AS temporal_year_prev_value, "+
//          "MIN(P.YEAR_QUARTER_NAME) AS temporal_quarter_prev_value "+          
          "FROM "+
          "DIMENSION_DAY D "+
          "WHERE "+        
          "D.YEAR_QUARTER_NAME = ?";
} else if (temporal_value.length() == 6) {
   temporal_cat = "Month of ";
   sql  = "SELECT "+
          "MIN(D.DATE_SK) AS temporal_day_value, "+
          "MIN(D.WEEK_NAME) AS temporal_week_value, "+
          "MIN(D.MONTH_SK) AS temporal_month_value, "+
          "MIN(D.YEAR_SK) AS temporal_year_value, "+
          "MIN(D.YEAR_QUARTER_NAME) AS temporal_quarter_value "+
//          "MIN(P.DATE_SK) AS temporal_day_prev_value, "+
//          "MIN(P.WEEK_NAME) AS temporal_week_prev_value, "+
//          "MIN(P.MONTH_SK) AS temporal_month_prev_value, "+
//          "MIN(P.YEAR_SK) AS temporal_year_prev_value, "+
//          "MIN(P.YEAR_QUARTER_NAME) AS temporal_quarter_prev_value "+
          "FROM "+
          "DIMENSION_DAY D "+
          "WHERE "+ 
          "D.MONTH_SK = ?";
} else if (temporal_value.length() == 4) {
   temporal_cat = "Year of ";
   sql  = "SELECT "+
          "MIN(D.DATE_SK) AS temporal_day_value, "+
          "MIN(D.WEEK_NAME) AS temporal_week_value,"+
          "MIN(D.MONTH_SK) AS temporal_month_value, "+
          "MIN(D.YEAR_SK) AS temporal_year_value, "+
          "MIN(D.YEAR_QUARTER_NAME) AS temporal_quarter_value "+
//          "MIN(P.DATE_SK) AS temporal_day_prev_value, "+
//          "MIN(P.WEEK_NAME) AS temporal_week_prev_value, "+
//          "MIN(P.MONTH_SK) AS temporal_month_prev_value, "+
//          "MIN(P.YEAR_SK) AS temporal_year_prev_value, "+
//          "MIN(P.YEAR_QUARTER_NAME) AS temporal_quarter_prev_value "+  
          "FROM "+
          "DIMENSION_DAY D "+
          "WHERE "+         
          "D.YEAR_SK = ?";
} else if (temporal_value.length() == 8) {
   temporal_cat = "Day of ";
   sql  = "SELECT "+
          "MIN(D.DATE_SK) AS temporal_day_value, "+
          "MIN(D.WEEK_NAME) AS temporal_week_value, "+
          "MIN(D.MONTH_SK) AS temporal_month_value, "+
          "MIN(D.YEAR_SK) AS temporal_year_value, "+
          "MIN(D.YEAR_QUARTER_NAME) AS temporal_quarter_value "+
//          "MIN(P.DATE_SK) AS temporal_day_prev_value, "+
//          "MIN(P.WEEK_NAME) AS temporal_week_prev_value, "+
//          "MIN(P.MONTH_SK) AS temporal_month_prev_value, "+
//          "MIN(P.YEAR_SK) AS temporal_year_prev_value, "+
//          "MIN(P.YEAR_QUARTER_NAME) AS temporal_quarter_prev_value "+  
          "FROM "+
          "DIMENSION_DAY D "+
          "WHERE "+ 
          "D.DATE_SK = ?";
}




////////////////////////////////////////////////////////////////////
//GET CONNECTION TO DATABASE////////////////////////////////////////
////////////////////////////////////////////////////////////////////
//Replace with your client's connection code
context = new InitialContext();
dataSource = (DataSource)((Context)context.lookup("java:comp/env")).lookup("jdbc/mdw_mysql");
// MySQL = mdw_mysql







////////////////////////////////////////////////////////////////////
//QUERY THE DATABASE////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
try {
   //get the first query results, String sql
   conn = dataSource.getConnection();
   ps = conn.prepareStatement(sql);
   ps.setString(1, temporal_value);
   rs = ps.executeQuery();
   if (rs.next()) {
      temporal_week_value = ((rs.getString("temporal_week_value")!=null)?rs.getString("temporal_week_value"):"");
      temporal_month_value = ((rs.getString("temporal_month_value")!=null)?rs.getString("temporal_month_value"):"");
      temporal_year_value = ((rs.getString("temporal_year_value")!=null)?rs.getString("temporal_year_value"):"");
      temporal_day_value = ((rs.getString("temporal_day_value")!=null)?rs.getString("temporal_day_value"):"");
      temporal_quarter_value = ((rs.getString("temporal_quarter_value")!=null)?rs.getString("temporal_quarter_value"):"");
     
//      temporal_week_prev_value = ((rs.getString("temporal_week_prev_value")!=null)?rs.getString("temporal_week_prev_value"):"");
//      temporal_month_prev_value = ((rs.getString("temporal_month_prev_value")!=null)?rs.getString("temporal_month_prev_value"):"");
//      temporal_year_prev_value = ((rs.getString("temporal_year_prev_value")!=null)?rs.getString("temporal_year_prev_value"):"");
//      temporal_day_prev_value = ((rs.getString("temporal_day_prev_value")!=null)?rs.getString("temporal_day_prev_value"):"");
//      temporal_quarter_prev_value = ((rs.getString("temporal_quarter_prev_value")!=null)?rs.getString("temporal_quarter_prev_value"):"");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;




   //get the next query results, String sql_user
   ps = conn.prepareStatement(sql_user);
   ps.setString(1, user_name);
   rs = ps.executeQuery();
   if (rs.next()) {
      hosted_client_sk = ((rs.getString("HOSTED_CLIENT_SK")!=null)?rs.getString("HOSTED_CLIENT_SK"):"");
      user_desc = ((rs.getString("USER_DESC")!=null)?rs.getString("USER_DESC"):"");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;





   //get the next query results, sql_default_source
   ps = conn.prepareStatement(sql_default_source);
   ps.setString(1, hosted_client_sk);
   rs = ps.executeQuery();
   if (rs.next()) {
      default_source_system_sk = ((rs.getString("SOURCE_SYSTEM_SK")!=null)?rs.getString("SOURCE_SYSTEM_SK"):"");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;





   //now get the next query results, String sql2
   ps = conn.prepareStatement(sql2);
   ps.setString(1, hosted_client_sk);
   rs = ps.executeQuery();
   if (rs.next()) {
      update_date = "Updated with visit data as of "+((rs.getString("REQUEST_DATE")!=null)?rs.getString("REQUEST_DATE"):"")+" PST";
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;






   //now get the next query results, String sql_sys
   ps = conn.prepareStatement(sql_sys);
   ps.setString(1, hosted_client_sk);
   rs = ps.executeQuery();
   while (rs.next()) {
    String id = ((rs.getString("table_id")!=null)?rs.getString("table_id"):"");
    String name= ((rs.getString("name")!=null)?rs.getString("name"):"");
	sys_ids.add(id);
	sys_names.add(name);
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





////////////////////////////////////////////////////////////////////
//Assign Various Values/////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

title = "Keyword Driven Visits for the " + temporal_cat + " " + temporal_value;
click_instructions = "Click an organization to view detail.";
report_title = "Top Keyword Referrals for the " + temporal_cat + " " + temporal_value;
if (source_system_sk.length() < 1)
	source_system_sk = default_source_system_sk;
if( referer.length() < 1) 
	referer = "google";





////////////////////////////////////////////////////////////////////
//Format the data for charting//////////////////////////////////////
////////////////////////////////////////////////////////////////////

// Make a bar chart showing the periods
// create the parameters for the bar chart
SimpleParameterProvider parameters = new SimpleParameterProvider();
// define the click url template
parameters.setParameter( "drill-url", "web_keyword_interactive_dashboard.jsp?source_system_sk="+source_system_sk+"&amp;temporal_value={SERIES}" );
parameters.setParameter( "inner-param", "temporal_value"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
parameters.setParameter( "HOSTED_CLIENT_SK", hosted_client_sk);
parameters.setParameter( "SOURCE_SYSTEM_SK", source_system_sk);	       	
// set the width and the height
parameters.setParameter( "image-width", "375"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
ArrayList messages = new ArrayList();
// call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart( "breadboard", "customer_360/web_analytics/dashboards", 
					 "keyword_web_visit_period_vert_bar.widget.xml", parameters, content_1, 
					 userSession, messages, null); 




// Make a bar chart showing the top keywords
// create the parameres for the bar chart
parameters = new SimpleParameterProvider();
// define the click url template, uncomment to activate
// parameters.setParameter( "drill-url", "web_keyword_interactive_dashboard.jsp?source_system_sk="+source_system_sk+"&amp;temporal_value="+temporal_value+"&amp;keyword={SERIES}" );
parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
parameters.setParameter( "SOURCE_SYSTEM_SK", source_system_sk);
parameters.setParameter( "HOSTED_CLIENT_SK", hosted_client_sk);
parameters.setParameter( "inner-param", "KEYWORD"); //$NON-NLS-1$ //$NON-NLS-2$
// set the width and the height
parameters.setParameter( "image-width", "375"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
// call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart( "breadboard", "customer_360/web_analytics/dashboards", 
					 "keyword_period_vert_bar.widget.xml", parameters, content_2, 
					 userSession, messages, null ); 




// Make a bar chart showing the referers 
// create the parameters for the bar chart
parameters = new SimpleParameterProvider();
parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
parameters.setParameter( "HOSTED_CLIENT_SK", hosted_client_sk);
parameters.setParameter( "REFERER", referer );
parameters.setParameter( "SOURCE_SYSTEM_SK", source_system_sk);
parameters.setParameter( "inner-param", "REFERER"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "outer-params", "REFERER" );
// define the click url template, uncomment to activate cube drill-through
// parameters.setParameter("drill-url","Pivot?solution=breadboard&path=customer_360/web_analytics/analysis&action=web_site_referral_cube.xaction&referer=.["+referer+"]" );
// set the width and the height
parameters.setParameter( "image-width", "375"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
// call the chart helper to generate the bar chart image and to get the HTML content
ChartHelper.doChart( "breadboard", "customer_360/web_analytics/dashboards", 
					  "keyword_period_referer_vert_bar.widget.xml", parameters, content_3, 
					  userSession, messages, null ); 




// run a report and embed the content into this page
// create the parameters for the report
parameters = new SimpleParameterProvider();
// pass the parameters to the report
parameters.setParameter( "TEMPORAL_VALUE", temporal_value );
parameters.setParameter( "HOSTED_CLIENT_SK", hosted_client_sk);
parameters.setParameter( "SOURCE_SYSTEM_SK", source_system_sk);
// parameters.setParameter( "KEYWORD", keyword );
// create an output stream for the report content 
messages = new ArrayList();
// run the action sequence.
SolutionHelper.doAction( "breadboard", "customer_360/web_analytics/dashboards/report", 
					   "keyword_referer_report.xaction", "web_keyword_interactive_dashboard.jsp", 
					   parameters, report_1 , userSession, messages, null );




// create the parameters for the line chart
parameters = new SimpleParameterProvider();
// parameters.setParameter( "KEYWORD", keyword );
parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
parameters.setParameter( "HOSTED_CLIENT_SK", hosted_client_sk);
parameters.setParameter( "SOURCE_SYSTEM_SK", source_system_sk);
// set the width and the height
parameters.setParameter( "image-width", "450"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
// call the chart helper to generate the pie chart image and to get the HTML content
ChartHelper.doChart( "breadboard", "customer_360/web_analytics/dashboards", 
					 "keyword_period_referer_line.widget.xml", parameters, content_4, 
					 userSession, messages, null );
					 
					 






////////////////////////////////////////////////////////////////////
//Build dynamic drop down menu options//////////////////////////////
////////////////////////////////////////////////////////////////////
for (int i =0; i <  sys_ids.size(); i++) {
	String sys_name = (String)sys_names.get(i);
	String sys_id = (String)sys_ids.get(i);
	selObj_source_system += "<option value=\"" +sys_id+ "\">" +sys_name+ "</option>\n";
}

%>



   




<!-- BEGIN HTML  -->
<html>
<head>
<title>Breadboard BI Sample Web Keyword Dashboard</title>

<script type='text/javascript'>
 function submitNewoption(selObj) {
    document.form1.submit();
 }

function doDateChange() {
   //date in mm/dd/yyyy format
   var newDate = "";
   var date2 = document.form1.myDateFld.value;
   newDate = date2.substring(date2.lastIndexOf("/")+1, date2.length);
   newDate += date2.substring(0, date2.indexOf("/"));
   newDate += date2.substring(date2.indexOf("/")+1,
   date2.lastIndexOf("/"));
   var selObj = document.form1.temporal_value;
   doSelObjLookUpAdd(selObj, newDate);
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
<%= update_date %>
 </font>
 </td>
 </tr>

<tr>
<td valign="top" colspan="3">

<h3 style='font-family:Arial'><%= title %></h3>

</td>
</tr>

<tr>
<td valign="top" colspan="3">

<form name="form1" action="web_keyword_interactive_dashboard.jsp" method="GET">

<select name="source_system_sk">
<option value="<%= source_system_sk %>">Select a Data Source</option>
<%= selObj_source_system %>
</select>

<select name="temporal_value">
<option value= "<%= temporal_month_value %>" SELECTED>Select a Time Period</option>
<option value= "<%= temporal_day_value %>" >Day</option>
<option value= "<%= temporal_week_value %>" >Week</option>
<option value= "<%= temporal_month_value %>" >Month</option>
<option value= "<%= temporal_quarter_value %>" >Quarter</option>
<option value= "<%= temporal_year_value %>" >Year</option>
 </select>
<script>
function doDateChange() {
   //date in mm/dd/yyyy format
   var newDate = "";
   var date2 = document.form1.myDateFld.value;
   //put code here to change format, eg if you want yyyy/mm
   newDate = date2.substring(date2.lastIndexOf("/")+1, date2.length);
   newDate += date2.substring(0, date2.indexOf("/"));
   newDate += date2.substring(date2.indexOf("/")+1, 
   date2.lastIndexOf("/"));
   var selObj = document.form1.temporal_value;
   doSelObjLookUpAdd(selObj, newDate);

   //submit form
   document.form1.submit();
}
</script>

<INPUT name= "myDateFld" type="text" id="myDateFld" value="" onChange='isValidDate2(this)' SIZE="12" MAXLENGTH="10">
 <a href="javascript:show_calendar('form1.myDateFld')" 
 onmouseover="window.status='Date Picker';return true;"
 onmouseout="window.status='';return true;">
<img src='/pentaho/images/show-calendar.gif' width=24 height=22
border=0>
</a>
<input type='button' name='dateBtn' value="Go" 
onClick='doDateChange()'>
</form>
</td>
</tr>
        <tr>
                <td valign="top" style="width: 33%">
<!-- Top of 1 -->
                <span style="font-family:Arial;font-weight:bold"></span>
                <%= content_1.toString() %>
<!-- Bottom of 1 -->
<br/>
                </td>
                <td valign="top" style="width: 33%">
                  <span style="font-family:Arial;font-weight:bold">
<!-- Top #2 -->
                <span style="font-family:Arial;font-weight:bold"></span>
                <%= content_2.toString() %>

<!-- BOTTOM 2 -->
                 </td>
<!-- Top 3 -->
                 <td valign="top" style="width: 33%">
             	  <span style="font-family:Arial;font-weight:bold"></span>
                  <%= content_3.toString() %>
<!-- Bottom of #3 -->
        		 </td>
        </tr>
        <tr>
                <td valign="top" style="font-family:Arial;font-weight:bold"  colspan=2>
<BR>
<font style="font-family:Arial;font-weight:bold;font-size:14pt">
<%= report_title %>
</font>
                       <span style="font-family:Arial;font-weight:bold">  </span>
<!-- Top of #4 -->
                        <%= report_1.toString() %>
<!-- BOTTOM 4 -->
                </td>

<!-- Top of #5 -->


        <td style="vertical-align: top;">
<font style="font-family:Arial;font-weight:bold;font-size:14pt">
</font>
<!-- Top of #6 -->
<%= content_4.toString() %>

<!-- BOTTOM 6 -->

</td>

</tr>
</table>

<BR><BR>
<center>Copyright � 2009 Breadboard BI, Inc. All rights reserved.</center>
</body>
</html>
