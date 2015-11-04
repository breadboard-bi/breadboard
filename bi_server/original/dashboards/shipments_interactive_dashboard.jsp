<%@ page language="java" 
	import="javax.naming.*,
	javax.sql.DataSource,
	java.util.ArrayList,
	java.util.Date,
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
*  Version 1.1
*
*  This software was developed by Breadboard BI and is provided under license. You may 
*  not use this file except in compliance with the license. This software is distributed 
*  on an AS IS basis, WITHOUT WARRANTY OF ANY KIND, neither express nor implied.
*
*  Please send bug fixes and enhancement requests to submit@breadboardbi.com
*/

/*
 * This JSP is an example of how to combine Breadboard BI content with Pentaho components to build a dashboard.
 * The script in this file controls the layout and content generation of the dashboard.
 * See the Pentho document 'Dashboard Builder Guide' for more details
 */

	// set the character encoding e.g. UFT-8
	response.setCharacterEncoding(LocaleHelper.getSystemEncoding()); 

	// create a new Pentaho session 
	IPentahoSession userSession = PentahoHttpSessionHelper.getPentahoSession( request );
	%>
<html>
	<head>
	<title>Breadboard BI Sample Shipments Interactive Dashboard</title>
	</head>
	<body>

<%
	// See if we have a 'year quarter' parameter
	String year_quarter = request.getParameter("year_quarter");
	
	// See if we have a 'country' parameter
	String country = request.getParameter("country");

	// See if we have a 'category' parameter
	String category = request.getParameter("category");
	
	if( year_quarter == null ) 
	{
		year_quarter= "2005Q3";
	}
	if( country== null ) 
	{
		country= "USA";
	} 
	if( category== null ) 
	{
		category= "Food";
	}
	
	
	// Create the title for the top of the page
	String title = "Sample Dashboard - Select a country";
	if( category != null ) {
		title = "Shipments by " + year_quarter + " and " + country + " and " + category;
	} 
	else if( country != null ) {
		title = "Shipments by " + year_quarter + " and " + country;
	} 
	
	else if ( year_quarter != null ) {
		title = "Shipments for " + year_quarter;
	}
	%>

<!-- Start JSP to access database value -->
<!-- Replace with your client's connection information -->
<% 
int OrderDeliverDays = 0;
int OrderShipDays = 0;
int AskShipDays = 0;
int ScheduleShipDays = 0;

Connection conn = null;
Context context = new InitialContext();
DataSource dataSource = (DataSource)((Context)context.lookup("java:comp/env")).lookup("jdbc/mdw_mysql");
int myResolved = 0;
int mySLAcomp = 0;
String exceptionErrors = "";

try {

conn = dataSource.getConnection();

String sql = "SELECT ROUND(AVG(SHIP_TO_ORDER_DAY_QTY)) AS order_to_ship_days,ROUND(AVG(DATEDIFF(SHIP_DATE,SCHEDULE_DATE))) AS schedule_to_ship_days,ROUND(AVG(DATEDIFF(ORDER_CAPTURE_DATE,DELIVER_DATE))) AS order_to_deliver_days,ROUND(AVG(DATEDIFF(SHIP_DATE,DEMAND_DATE))) AS ask_to_ship_days FROM FACT_SHIPMENT F,DIMENSION_PRODUCT P,DIMENSION_DAY D, DIMENSION_CUSTOMER C WHERE D.YEAR_QUARTER_NAME = ? AND C.COUNTRY_NAME = ? AND P.PARENT_PRODUCT_CATEGORY_NAME = ? AND F.PRODUCT_SK = P.PRODUCT_SK AND F.SHIP_DATE_SK = D.DATE_SK AND F.SHIP_CUSTOMER_SK = C.CUSTOMER_SK";

PreparedStatement ps = conn.prepareStatement(sql);

String myYearQuarter = year_quarter;
ps.setString(1, myYearQuarter);

String myCountry = country;
ps.setString(2, myCountry);

String myCat = category;
ps.setString(3, myCat);

ResultSet rs = ps.executeQuery();

if (rs.next()) {
    OrderDeliverDays = rs.getInt("order_to_deliver_days");
    OrderShipDays = rs.getInt("order_to_ship_days");
    ScheduleShipDays = rs.getInt("schedule_to_ship_days");
    AskShipDays = rs.getInt("ask_to_ship_days");
   }

   if (rs != null) rs.close(); rs = null;

   if (ps != null) ps.close(); ps = null;

   if (conn != null) conn.close();

} 

catch (Exception e) {

  StringWriter writer = new StringWriter();

  e.printStackTrace(new PrintWriter(writer));

  System.out.println("Exception while connecting to db and reading = " +writer.getBuffer());

  exceptionErrors  = writer.getBuffer().toString();

  if (conn != null) conn.close();

 }

%>
<!-- Bottom of JSP to access database -->	


















<table align="center">
<tr>
<td colspan ="2" valign="top" style="width: 66%">

<!-- Replace the src value so it points to your client's logo/banner. -->
<!-- include file="navBarTopSimple.html"  -->
 </td>
 <td valign="top" style="width: 33%" align="right">
 <font style='font-family:Arial'>
 <B>Interdependent Widget Sample Dashboard</B>
 <BR>  
 <I>Gateway sample dashboard examples are also available.</I>
 </font>
 </td>
 </tr> 

<tr>
<td valign="top" style="width: 33%"></td>
<td></td><td></td>
</tr>

<tr>
<td valign="top" style="width: 33%">
<h4 style='font-family:Arial'><%= title %></h4>
</td>
<td valign="top" style="width: 33%"></td>
<td valign="top" style="width: 33%"></td>
</tr>
	<tr>
		<td valign="top" style="width: 33%">
<!-- Top of 1 -->
		<span style="font-family:Arial;font-weight:bold">
		Select a Quarter
		</span>
<%
		// Make a bar chart showing the regions
		// create the parameters for the bar chart
	        SimpleParameterProvider parameters = new SimpleParameterProvider();

		// define the click url template
	         parameters.setParameter( "drill-url", "shipments_interactive_dashboard.jsp?year_quarter={SERIES}" );

		// define the bars of the bar chart
	       	parameters.setParameter( "inner-param", "quarter"); //$NON-NLS-1$ //$NON-NLS-2$

		// set the width and the height
	        parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
			StringBuffer content = new StringBuffer(); 
	        ArrayList messages = new ArrayList();

		// call the chart helper to generate the bar chart image and to get the HTML content
		// use the chart definition in 'breadboard/dashboard/billing_invoice_date_vert_bar.widget.xml'
        	ChartHelper.doChart( "breadboard", "supply_chain/shipments/dashboards", "shipments_date_vert_bar.widget.xml", parameters, content, userSession, messages, null); 
	%>
		<%= content.toString() %>	
<!-- Bottom of 1 -->
<br/>
		</td>	
			<td valign="top" style="width: 33%">
			<span style="font-family:Arial;font-weight:bold">
<!-- Top #2 -->
		<span style="font-family:Arial;font-weight:bold">
		Select a Customer Ship To Country
		</span>

	<%
		// Make a bar chart showing the countrys
		// create the parameres for the bar chart
	        parameters = new SimpleParameterProvider();

		// define the click url template
	        parameters.setParameter( "drill-url", "shipments_interactive_dashboard.jsp?year_quarter="+year_quarter+"&amp;country={SERIES}" );

		// define the bars of the bar chart
			parameters.setParameter( "YEAR_QUARTER", year_quarter);
	        parameters.setParameter( "inner-param", "COUNTRY"); //$NON-NLS-1$ //$NON-NLS-2$

		// set the width and the height
	        parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
			content = new StringBuffer(); 
	        messages = new ArrayList();

		// call the chart helper to generate the bar chart image and to get the HTML content
		// use the chart definition in 'samples/dashboard/regions.widget.xml'
        	ChartHelper.doChart( "breadboard", "supply_chain/shipments/dashboards", "shipments_country_vert_bar.widget.xml", parameters, content, userSession, messages, null ); 
	%>

		<%= content.toString() %>

<!-- BOTTOM 2 -->
	</td>
	<td valign="top" style="width: 33%"><span style="font-family:Arial;font-weight:bold">
<!-- Top 3 -->	

	<%
		if( country != null ) {
			// if the user has clicked on a bar of the bar chart we should have a country to work with
	%>
			Select a Product Category
	<%
			// Make a bar chart showing the product category 
			// create the parameters for the bar chart
	        	parameters = new SimpleParameterProvider();

			// define the click url template
		        parameters.setParameter( "drill-url", "shipments_interactive_dashboard.jsp?year_quarter="+year_quarter+"&amp;country="+country+"&amp;category={SERIES}" );
				parameters.setParameter( "COUNTRY", country );
				parameters.setParameter( "YEAR_QUARTER", year_quarter);
				parameters.setParameter( "outer-params", "CATEGORY" );
			// define the country axis of the bar chart
        		parameters.setParameter( "inner-param", "CATEGORY"); //$NON-NLS-1$ //$NON-NLS-2$
			// set the width and the height
        		parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
        		parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
				content = new StringBuffer(); 
        		messages = new ArrayList();
			// call the chart helper to generate the bar chart image and to get the HTML content
			// use the chart definition in 'samples/dashboard/regions.widget.xml'
	        	ChartHelper.doChart( "breadboard", "supply_chain/shipments/dashboards", "shipments_pcat_vert_bar.widget.xml", parameters, content, userSession, messages, null ); 
	%>
			</span>
			
			<%= content.toString() %>
	<%
		}
	%>
<!-- Bottom of #3 -->
	</td>
	</tr>
</table>

<!-- Top of #4 -->
<table width = "100%">
<tr>
<td style="width: 25%">
<%
		if( year_quarter != null ) {

		int dialValue = OrderDeliverDays;
		messages = new ArrayList();
        parameters = new SimpleParameterProvider();
        parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
        parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
		parameters.setParameter( "value", ""+dialValue );
		parameters.setParameter( "title", "Avg. Order to Deliver Days" );
		content = new StringBuffer(); 
        ChartHelper.doDial( "breadboard", "supply_chain/shipments/dashboards", "shipment_dial.widget.xml", parameters, content, userSession, messages, null ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
%>
<%= content.toString() %>
<%
	}
%>

</td>

<td style="width: 25%">

<%
		if( year_quarter != null ) {

		int dialValue = ScheduleShipDays;
		messages = new ArrayList();
        parameters = new SimpleParameterProvider();
        parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
        parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
		parameters.setParameter( "value", ""+dialValue );
		parameters.setParameter( "title", "Avg. Schedule to Actual Ship Days" );
		content = new StringBuffer(); 
        ChartHelper.doDial( "breadboard", "supply_chain/shipments/dashboards", "shipment_dial.widget.xml", parameters, content, userSession, messages, null ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
%>
<%= content.toString() %>
<%
	}
%>

</td>
<td style="width: 25%">

<%
		if( year_quarter != null ) {

		int dialValue = OrderShipDays;
		messages = new ArrayList();
        parameters = new SimpleParameterProvider();
        parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
        parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
		parameters.setParameter( "value", ""+dialValue );
		parameters.setParameter( "title", "Avg. Order to Ship Days" );
		content = new StringBuffer(); 
        ChartHelper.doDial( "breadboard", "supply_chain/shipments/dashboards", "shipment_dial.widget.xml", parameters, content, userSession, messages, null ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
%>
<%= content.toString() %>
<%
	}
%>






</td>

<td style="width: 25%">

<%
		if( year_quarter != null ) {

		int dialValue = AskShipDays;
	
		messages = new ArrayList();
        parameters = new SimpleParameterProvider();
        parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
        parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
		parameters.setParameter( "value", ""+dialValue );
		parameters.setParameter( "title", "Avg. Ask to Ship Days" );
		content = new StringBuffer(); 
        ChartHelper.doDial( "breadboard", "supply_chain/shipments/dashboards", "shipment_dial.widget.xml", parameters, content, userSession, messages, null ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
%>
<%= content.toString() %>
<%
	}
%>
</td>
</tr>
</table>

<BR><BR>
<center>Copyright © 2009 Breadboard BI, Inc. All rights reserved.</center>
</body>
</html>