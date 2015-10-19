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
org.pentaho.platform.uifoundation.chart.ChartHelper,
org.pentaho.platform.web.http.PentahoHttpSessionHelper,
org.pentaho.platform.engine.services.solution.SolutionHelper"

%>
<fmt:setBundle basename="order_capture_interactive_line_dashboard_2_jsp"/>
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

ResourceBundle rb = ResourceBundle.getBundle("order_capture_interactive_line_dashboard_2_jsp");
//ResourceBundle rb = new PropertyResourceBundle( getClass().getClassLoader().getResourceAsStream("order_capture_interactive_line_dashboard_2_jsp"));


////////////////////////////////////////////////////////////////////
//SET UP PARAMETERS/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
String temporal_value = ((request.getParameter("temporal_value")!=null)?request.getParameter("temporal_value"):"");
String temporal_cat = ((request.getParameter("temporal_cat")!=null)?request.getParameter("temporal_cat"):"");
String country = ((request.getParameter("country")!=null)?request.getParameter("country"):"");
String category = ((request.getParameter("category")!=null)?request.getParameter("category"):"");


String temporal_week_value =  "";
String temporal_month_value = "";
String temporal_year_value = "";
String temporal_day_value = "";
String temporal_quarter_value = "";
String sql = "";
String sql2 = "SELECT MAX(ORDER_CAPTURE_DATE) AS ORDER_DATE FROM FACT_ORDER_CAPTURE";
int myResolved = 0;
int mySLAcomp = 0;
String exceptionErrors = "";
String title = "Sample Dashboard - Select a country";
String report_title = "";
String dial_title = "";

//The following five constants are specific to Breadboard BI test data.
if (temporal_cat.length() < 1)
   temporal_cat = rb.getString("Month_of");
if (temporal_value.length() < 1)   
   temporal_value = "200604";
if (country.length() < 1)
   country = "USA";
if (country.length() < 1)
   country = "USA";
if (category.length() < 1)
   category = "Drink";
if (category.length() > 0) {
   title = rb.getString("Orders_by") + " " + temporal_value + " " + rb.getString("and") + " " + country + " " + rb.getString("and") + " " + category;
   report_title = rb.getString("Top_Products_by") + " " + temporal_value + " " + rb.getString("and") + " " + country + " " + rb.getString("and") + " " + category;
   dial_title = rb.getString("Period_Order_Trends_for") + " " + country + " " + rb.getString("and") + " " + category;
} else if ( country.length() > 0)  {
   title = rb.getString("Orders_by") + " " + temporal_value + " " + rb.getString("and") + " " + country;
   report_title = rb.getString("Top_Products_by") + " " + temporal_value + " " + rb.getString("and") + " " + country;
   dial_title = rb.getString("Period_Order_Trends_for") + " " + temporal_value + " " + rb.getString("and") + " " + country;
} else if (temporal_value.length() > 0)  {
   title = rb.getString("Orders_by") + " " + temporal_value;
   report_title = rb.getString("Orders_by") + " " + temporal_value;
   dial_title = rb.getString("Period_Order_Trends_for") + " " + temporal_value;
}
String order_date = "";
StringBuffer content_region = new StringBuffer();
StringBuffer content_country_vert_bar = new StringBuffer();
StringBuffer content_country_pcat_vert_bar = new StringBuffer();
StringBuffer content_order_trend_line = new StringBuffer();
ByteArrayOutputStream stream_interactive_line = new ByteArrayOutputStream();
int avg_trxn_price_amt = 0;
Context context = null;
DataSource dataSource = null;
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;







////////////////////////////////////////////////////////////////////
//SET UP SQL QUERY FOR DATABASE/////////////////////////////////////
////////////////////////////////////////////////////////////////////
   //Uncomment Below and edit relevant constants above - used to accommodate Breadboard BI Test Data
/*
if (temporal_value.length() < 1) {
   Date current_dt = new Date();
   SimpleDateFormat sdf_year = new SimpleDateFormat("yyyy");
   SimpleDateFormat sdf_month = new SimpleDateFormat("MM");
   temporal_value = sdf_year.format(current_dt)+sdf_month.format(current_dt);
}
*/

if (temporal_value.indexOf("W") >= 0) {
   temporal_cat = rb.getString("Week_of");
   sql  = "SELECT "+
          "MIN(DATE_SK) AS temporal_day_value, "+
          "MIN(WEEK_NAME) AS temporal_week_value, "+
          "MIN(MONTH_SK) AS temporal_month_value, "+
          "MIN(YEAR_SK) AS temporal_year_value, "+
          "MIN(YEAR_QUARTER_NAME) AS temporal_quarter_value "+
          "FROM "+
          "DIMENSION_DAY "+
          "WHERE "+
          "WEEK_NAME = ?";
} else if (temporal_value.indexOf("Q") >= 0) {
   temporal_cat = rb.getString("Quarter_of");
   sql  = "SELECT "+
          "MIN(DATE_SK) AS temporal_day_value, "+
          "MIN(WEEK_NAME) AS temporal_week_value, "+
          "MIN(MONTH_SK) AS temporal_month_value, "+
          "MIN(YEAR_SK) AS temporal_year_value, "+
          "MIN(YEAR_QUARTER_NAME) AS temporal_quarter_value "+
          "FROM "+
          "DIMENSION_DAY "+
          "WHERE "+
          "YEAR_QUARTER_NAME = ?";
} else if (temporal_value.length() == 6) {
   temporal_cat = rb.getString("Month_of");
   sql  = "SELECT "+
          "MIN(DATE_SK) AS temporal_day_value, "+
          "MIN(WEEK_NAME) AS temporal_week_value, "+
          "MIN(MONTH_SK) AS temporal_month_value, "+
          "MIN(YEAR_SK) AS temporal_year_value, "+
          "MIN(YEAR_QUARTER_NAME) AS temporal_quarter_value "+
          "FROM "+
          "DIMENSION_DAY WHERE MONTH_SK = ?";
} else if (temporal_value.length() == 4) {
   temporal_cat = rb.getString("Year_of");
   sql  = "SELECT "+
          "MIN(DATE_SK) AS temporal_day_value, "+
          "MIN(WEEK_NAME) AS temporal_week_value,"+
          "MIN(MONTH_SK) AS temporal_month_value, "+
          "MIN(YEAR_SK) AS temporal_year_value, "+
          "MIN(YEAR_QUARTER_NAME) AS temporal_quarter_value "+
          "FROM "+
          "DIMENSION_DAY "+
          "WHERE "+
          "YEAR_SK = ?";
} else if (temporal_value.length() == 8) {
   temporal_cat = rb.getString("Day_of");
   sql  = "SELECT "+
          "MIN(DATE_SK) AS temporal_day_value, "+
          "MIN(WEEK_NAME) AS temporal_week_value, "+
          "MIN(MONTH_SK) AS temporal_month_value, "+
          "MIN(YEAR_SK) AS temporal_year_value, "+
          "MIN(YEAR_QUARTER_NAME) AS temporal_quarter_value "+
          "FROM DIMENSION_DAY WHERE DATE_SK = ?";
} else {
   temporal_cat = "";
}






////////////////////////////////////////////////////////////////////
//GET CONNECTION TO DATABASE////////////////////////////////////////
////////////////////////////////////////////////////////////////////
//Replace with your client's connection code
context = new InitialContext();
dataSource = (DataSource)((Context)context.lookup("java:comp/env")).lookup("jdbc/mdw_mysql");

// dataSource = (DataSource)context.lookup("java:mdw_mysql");
// context.lookup("java:mdw_mysql")
// ((Context)context.lookup("java:comp/env")).lookup("jdbc/mdw_mysql")




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
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;



   //now get the second query results, String sql2
   ps = conn.prepareStatement(sql2);
   rs = ps.executeQuery();
   if (rs.next()) {
      order_date = rb.getString("Updated_with_order_data_as_of")+rs.getString("ORDER_DATE")+" PST";
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
//Format the data for charting//////////////////////////////////////
////////////////////////////////////////////////////////////////////

//Make a bar chart showing the REGIONS
//create the parameters for the bar chart
SimpleParameterProvider parameters = new SimpleParameterProvider();
if (temporal_cat == "Year of " || temporal_cat == "Quarter of ") {
   //define the click url template
   parameters.setParameter( "drill-url", "order_capture_interactive_line_dashboard.jsp?temporal_value={SERIES}" );
}
parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
//define the bars of the bar chart
parameters.setParameter( "inner-param", "temporal_value"); //$NON-NLS-1$ //$NON-NLS-2$
//set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
ArrayList messages = new ArrayList();
//call the chart helper to generate the bar chart image and to get the HTML content
//use the chart definition in 'breadboard/dashboard/billing_invoice_date_vert_bar.widget.xml'
ChartHelper.doChart("breadboard", "customer_360/sales_order_capture/dashboards",
                    "order_capture_period_vert_bar.widget.xml", parameters,
                    content_region, userSession, messages, null);



//Make a bar chart showing the product CATGEORY
//create the parameters for the bar chart
parameters = new SimpleParameterProvider();
//define the click url template
parameters.setParameter("drill-url", "order_capture_interactive_line_dashboard.jsp?temporal_value="
                        +temporal_value+"&amp;country={SERIES}" );
parameters.setParameter("COUNTRY", country);
parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
//define the country axis of the bar chart
parameters.setParameter( "inner-param", "COUNTRY"); //$NON-NLS-1$ //$NON-NLS-2$
//set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
//call the chart helper to generate the bar chart image and to get the HTML content
//use the chart definition in 'samples/dashboard/regions.widget.xml'
ChartHelper.doChart("breadboard", "customer_360/sales_order_capture/dashboards",
                    "order_capture_period_country_vert_bar.widget.xml", parameters,
                    content_country_vert_bar, userSession, messages, null );



// Make a bar chart showing the product category, default country USA
// create the parameters for the bar chart
parameters = new SimpleParameterProvider();
// define the click url template
parameters.setParameter( "drill-url", "order_capture_interactive_line_dashboard.jsp?temporal_value="+temporal_value
                         +"&amp;country="+country+"&amp;category={SERIES}" );
parameters.setParameter( "COUNTRY", country );
parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
parameters.setParameter( "outer-params", "CATEGORY" );
// define the country axis of the bar chart
parameters.setParameter( "inner-param", "CATEGORY"); //$NON-NLS-1$ //$NON-NLS-2$
// set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
 messages = new ArrayList();
//call the chart helper to generate the bar chart image and to get the HTML content
//use the chart definition in 'samples/dashboard/regions.widget.xml'
ChartHelper.doChart("breadboard", "customer_360/sales_order_capture/dashboards",
                    "order_capture_period_country_pcat_vert_bar.widget.xml", parameters,
                    content_country_pcat_vert_bar, userSession, messages, null );




// if the user has clicked on a bar of the bar chart we should have a year quarter, country and category
// run a report and embed the content into this page
// create an output stream for the report content
messages = new ArrayList();
// create the parameters for the report
parameters = new SimpleParameterProvider();
// pass the category, type, status parameters to the report
parameters.setParameter( "TEMPORAL_VALUE", temporal_value );
parameters.setParameter( "COUNTRY", country );
parameters.setParameter( "CATEGORY", category );
// run the action sequence 'breadboard/dashboard/report/order_capture_dashboard_report.xaction'
SolutionHelper.doAction("breadboard", "customer_360/sales_order_capture/dashboards/reports",
                     "order_capture_top_products_report.xaction", "order_capture_interactive_line_dashboard.jsp",
                     parameters, stream_interactive_line, userSession, messages, null );




if (country.length() > 0) {
// run a report and embed the content into this page
// create the parameters for the line chart
parameters = new SimpleParameterProvider();
parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
parameters.setParameter( "COUNTRY", country );
parameters.setParameter( "CATEGORY", category );
parameters.setParameter( "outer-params", "CATEGORY" );
  							
// define the category axis of the bar chart
parameters.setParameter( "inner-param", "CATEGORY"); //$NON-NLS-1$ //$NON-NLS-2$
// set the width and the height
parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
parameters.setParameter( "image-height", "275"); //$NON-NLS-1$ //$NON-NLS-2$
messages = new ArrayList();
// call the chart helper to generate the pie chart image and to get the HTML content
// use the chart definition in 'samples/dashboard/regions.widget.xml'
ChartHelper.doChart( "breadboard", "customer_360/sales_order_capture/dashboards", 
					  "order_capture_period_country_pcat_line.widget.xml", parameters, 
					  content_order_trend_line, userSession, messages, null ); 

}

%>


<!-- BEGIN HTML  -->
<html>
<head>
<title><fmt:message key="Breadboard_BI_Sample_Sales_Order_Capture_Dashboard"/></title>

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
 </td>
 </td>
 <td valign="top" style="width: 33%" align="right">
 <font style='font-family:Arial'>
<%= order_date %>
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

<form name="form1" action="order_capture_interactive_line_dashboard.jsp" method="GET">
<select name="temporal_value" onChange="submitNewoption(this)">
<option value= "<%= temporal_week_value %>" SELECTED><fmt:message key="Select_a_Time_Period"/></option>
<option value= "<%= temporal_day_value %>" ><fmt:message key="Daily"/></option>
<option value= "<%= temporal_week_value %>" ><fmt:message key="Weekly"/></option>
<option value= "<%= temporal_month_value %>" ><fmt:message key="Monthly"/></option>
<option value= "<%= temporal_quarter_value %>" ><fmt:message key="Quarterly"/></option>
<option value= "<%= temporal_year_value %>" ><fmt:message key="Yearly"/></option>
 </select>
<script type="text/javascript">

</script>

<INPUT name= "myDateFld" type="text" id="myDateFld" value="" onChange='isValidDate2(this)' SIZE="12" MAXLENGTH="10">
<!-- show_calendar('MForm.mydate3', 4, 2001, 'MM/DD/YYYY', null, 'CallFunction=SplitDate') -->
<!-- http://www.softricks.com/products/calendar/tutorial.html -->
 <a href="javascript:show_calendar('form1.myDateFld',3)"
 onmouseover="window.status='Date Picker';return true;"
 onmouseout="window.status='';return true;">
<img src='/pentaho/images/show-calendar.gif' width=24 height=22 border=0 alt=''>
</a>
<input type='button' name='dateBtn' value="Go" onClick='doDateChange()'>
Note:  test data available for 01/2006 - 06/2006.
</form>

</td>
</tr>
        <tr>
                <td valign="top" style="width: 33%">
<!-- Top of 1 -->
                <span style="font-family:Arial;font-weight:bold"><fmt:message key="Select_a_Period"/></span>
                <%= content_region.toString() %>
<!-- Bottom of 1 -->
<br/>
                </td>
                        <td valign="top" style="width: 33%">
                        <span style="font-family:Arial;font-weight:bold">
<!-- Top #2 -->
                <span style="font-family:Arial;font-weight:bold"><fmt:message key="Select_a_Country"/></span>
                <%= content_country_vert_bar.toString() %>

<!-- BOTTOM 2 -->
        </td>
        <td valign="top" style="width: 33%">
<!-- Top 3 -->        
        <span style="font-family:Arial;font-weight:bold"><fmt:message key="Select_a_Product_Category"/></span>
        <%= content_country_pcat_vert_bar.toString() %>
<!-- Bottom of #3 -->
        </td>
        </tr>
        <tr>
                <td valign="top" style="font-family:Arial;font-weight:bold"  colspan=2>
<!--			Click on an Order ID to drill to another page (not activated) -->
<BR>
<font style="font-family:Arial;font-weight:bold;font-size:14pt">
<%= report_title %>
</font>
                       <span style="font-family:Arial;font-weight:bold">  </span>
<!-- Top of #4 -->
                        <%= stream_interactive_line.toString() %>

<!-- BOTTOM 4 -->
                </td>

<!-- Top of #5 -->


        <td style="vertical-align: top;">
<BR>
<center>
<font style="font-family:Arial;font-weight:bold;font-size:14pt">
<%= dial_title %>
</font>
</center>
<!-- Top of #6 -->
<%= content_order_trend_line.toString() %>



<!-- BOTTOM 6 -->

</td>

</tr>
</table>

<BR><BR>
<center>Copyright © 2009 Breadboard BI, Inc. All rights reserved.</center>
</body>
</html>
