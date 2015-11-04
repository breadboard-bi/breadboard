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
 * This JSP is an example of how to use Pentaho components to build a dashboard.
 * The script in this file controls the layout and content generation of the dashboard.
 * See the document 'Dashboard Builder Guide' for more details
 */

	// set the character encoding e.g. UFT-8
	response.setCharacterEncoding(LocaleHelper.getSystemEncoding()); 

	// create a new Pentaho session 
	IPentahoSession userSession = PentahoHttpSessionHelper.getPentahoSession( request );
	%>
<html>
	<head>
		<title>Breadboard BI Sample Dashboard</title>
	</head>
	<body>

<%
	// See if we have a 'year quarter' parameter
	String year_quarter = request.getParameter("year_quarter");
	
	// See if we have a 'region' parameter
	String category = request.getParameter("category");

	// See if we have a 'department' parameter
	String type = request.getParameter("type");
	
	if( year_quarter == null ) 
	{
		year_quarter= "2006Q2";
	}
	if( category== null ) 
	{
		category= "WEB";
	} 
	
	
	// Create the title for the top of the page
	String title = "Sample Dashboard - Select a category";
	
	if( category != null ) {
		title = "Cases by " + year_quarter + " and " + category;
	} 
	
	else if ( year_quarter != null ) {
		title = "Case counts for " + year_quarter;
	}
	%>

<table align="center">
<tr>
<td colspan = "2" valign="top">

<!-- Replace the src value so it points to your client's logo/banner. -->
<!-- include file="navBarTopSimple.html"  -->
 </td>
 </tr> 

<tr>
 <td colspan = "2" valign="top" align="right">
 <font style='font-family:Arial'><B>Interdependent Widget Sample Dashboard</B><BR> </font></td>
 </tr> 

<tr>
<td valign="top" style="width: 50%">
<h4 style='font-family:Arial'><%= title %></h4>
</td>
<td valign="top" style="width: 50%"></td>
</tr>
	<tr>
		<td valign="top" style="width: 50%">
<!-- Top of 1 -->
		<span style="font-family:Arial;font-weight:bold">
		Select a Quarter By Clicking on the Bar Chart
		</span>
<%
		// Make a pie chart showing the regions
		// create the parameres for the pie chart
	        SimpleParameterProvider parameters = new SimpleParameterProvider();
		// define the click url template
	         parameters.setParameter( "drill-url", "BreadboardSampleDashboard_web.jsp?year_quarter={SERIES}" );
		// define the slices of the pie chart
	       parameters.setParameter( "inner-param", "quarter"); //$NON-NLS-1$ //$NON-NLS-2$
		// set the width and the height
	        parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "250"); //$NON-NLS-1$ //$NON-NLS-2$
			StringBuffer content = new StringBuffer(); 
	        ArrayList messages = new ArrayList();
		// call the chart helper to generate the pie chart image and to get the HTML content
		// use the chart definition in 'samples/dashboard/regions.widget.xml'
        	ChartHelper.doChart( "breadboard", "customer_360/case_management/dashboards", "case_open_date_vert_bar.widget.xml", parameters, content, userSession, messages, null ); 
	%>
		<%= content.toString() %>	
<!-- Bottom of 1 -->
<br/>
		</td>	
			<td valign="top" style="width: 50%">
			<span style="font-family:Arial;font-weight:bold">
<!-- Top #2 -->
		<span style="font-family:Arial;font-weight:bold">
		Select a Category By Clicking on the Bar Chart
		</span>

	<%
		// Make a pie chart showing the regions
		// create the parameres for the pie chart
	        parameters = new SimpleParameterProvider();
		// define the click url template
	        parameters.setParameter( "drill-url", "BreadboardSampleDashboard_web.jsp?year_quarter="+year_quarter+"&amp;category={SERIES}" );
		// define the slices of the pie chart
		parameters.setParameter( "YEAR_QUARTER", year_quarter);
	        parameters.setParameter( "inner-param", "CATEGORY"); //$NON-NLS-1$ //$NON-NLS-2$
		// set the width and the height
	        parameters.setParameter( "image-width", "400"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "250"); //$NON-NLS-1$ //$NON-NLS-2$
			content = new StringBuffer(); 
	        messages = new ArrayList();
		// call the chart helper to generate the pie chart image and to get the HTML content
		// use the chart definition in 'samples/dashboard/regions.widget.xml'
        	ChartHelper.doChart( "breadboard", "customer_360/case_management/dashboards", "case_category_vert_bar.widget.xml", parameters, content, userSession, messages, null ); 
	%>

		<%= content.toString() %>
<!-- BOTTOM 2 -->
	</td>
	</tr>
<!-- Start JSP to access database value -->

<% 
int myIntIwantToset = 0;

Connection conn = null;
Context context = new InitialContext();
DataSource dataSource = (DataSource)((Context)context.lookup("java:comp/env")).lookup("jdbc/mdw_mysql");
int myResolved = 0;
int mySLAcomp = 0;
String exceptionErrors = "";

try {

conn = dataSource.getConnection();

String sql = "SELECT (ROUND(AVG(NVL(F.CASE_CLOSED_DATE,SYSDATE) - F.CASE_OPEN_DATE),0)) AS punta_id, round(sum(F.sla_response_compliance_qty*100)/count(F.case_sk),0) as sla_compliance_pct,round(sum(F.case_resolved_qty*100)/count(F.case_sk),0) as resolved_pct FROM FACT_CASE F, DIMENSION_CASE C, DIMENSION_DAY D WHERE F.CASE_SK = C.CASE_SK AND F.CASE_OPEN_DATE_SK = D.DATE_SK AND D.YEAR_QUARTER_NAME = ? AND C.CASE_SOURCE_NAME = ?";


   PreparedStatement ps = conn.prepareStatement(sql);

String myYearQuarter = year_quarter;
ps.setString(1, myYearQuarter);

String myCat = category;
ps.setString(2, myCat);


   ResultSet rs = ps.executeQuery();

   if (rs.next()) {

    myIntIwantToset = rs.getInt("punta_id");
	myResolved = rs.getInt("resolved_pct");
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
	<tr>
		<td valign="top" style="font-family:Arial;font-weight:bold;width: 50%">
<!-- Top of #4 -->
	<%
		if( year_quarter != null ) {

			int dialValue = myIntIwantToset;
		    messages = new ArrayList();
        	parameters = new SimpleParameterProvider();
        	parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
			parameters.setParameter( "value", ""+dialValue );
			parameters.setParameter( "title", "Avg Open Case Age (days)" );
			content = new StringBuffer(); 
        	ChartHelper.doDial( "breadboard", "customer_360/case_management/dashboards", "sample_dial.widget.xml", parameters, content, userSession, messages, null ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
%>
<%= content.toString() %>
<%
	}
%>
<!-- BOTTOM 4 -->
		</td>
		<td valign="top" style="font-family:Arial;font-weight:bold;width: 50%">
<!-- Top of #5 -->
	<%
		if( year_quarter != null ) {

			int dialValue = myResolved;
		    messages = new ArrayList();
        	parameters = new SimpleParameterProvider();
        	parameters.setParameter( "image-width", "105"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "105"); //$NON-NLS-1$ //$NON-NLS-2$
			parameters.setParameter( "value", ""+dialValue );
			parameters.setParameter( "title", "Percent Cases Resolved" );
			content = new StringBuffer(); 
        	ChartHelper.doDial( "breadboard", "customer_360/case_management/dashboards", "sample_dial_pct.widget.xml", parameters, content, userSession, messages, null ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
%>
<%= content.toString() %>
<%
	}
%>
<!-- BOTTOM 5 -->		
		
		
		</td>

</tr>
</table>

<BR><BR>
<center>Copyright © 2009 Breadboard BI, Inc. All rights reserved.</center>

</body>
</html>