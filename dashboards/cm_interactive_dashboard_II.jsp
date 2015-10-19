<%@ page language="java" 
	import="java.util.ArrayList,
	java.util.Date,
	java.io.ByteArrayOutputStream,
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
	org.pentaho.platform.uifoundation.chart.ChartHelper,org.pentaho.platform.web.http.PentahoHttpSessionHelper,org.pentaho.platform.engine.services.solution.SolutionHelper,
	java.io.*"
	 %><%

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
	// See if we have a 'region' parameter
	String category = request.getParameter("category");

	// See if we have a 'department' parameter
	String type = request.getParameter("type");

	// See if we have a 'status' parameter
	String status = request.getParameter("status");
	
	if( category== null ) 
	{
		category= "WEB";
	} 
	if( type== null ) 
	{
		type= "QUESTION";
	} 
	if( status== null ) 
	{
		status= "SOLVED";
	} 
	
	
	// Create the title for the top of the page
	String title = "Sample Dashboard - Select a category";
	if( status != null ) {
		title = "Cases by " + category + " and " + type + " and " + status;
	} 
	else if( type != null ) {
		title = "Cases by " + category + " and " + type;
	} 
	else if ( category != null ) {
		title = "Case counts for " + category;
	}
	%>

<table align="center">
<tr>
<td colspan ="2" valign="top">
<!-- Replace the src value so it points to your client's logo/banner. -->
<!-- include file="navBarTopSimple.html"  -->
 </td>
 </tr> 

<tr>
<td valign="top" style="width: 50%">
<h4 style='font-family:Arial'><%= title %></h4>

</td>
<td> </td>
</tr>
	<tr>
		<td valign="top" style="width: 50%">
		<span style="font-family:Arial;font-weight:bold">
		Select a Category By Clicking on the Pie Chart
		</span>

	<%
		// Make a pie chart showing the regions
		// create the parameres for the pie chart
	        SimpleParameterProvider parameters = new SimpleParameterProvider();
		// define the click url template
	        parameters.setParameter( "drill-url", "cm_interactive_dashboard_II.jsp?category={CATEGORY}" );
		// define the slices of the pie chart
	        parameters.setParameter( "inner-param", "CATEGORY"); //$NON-NLS-1$ //$NON-NLS-2$
		// set the width and the height
	        parameters.setParameter( "image-width", "450"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
		StringBuffer content = new StringBuffer(); 
	        ArrayList messages = new ArrayList();
		// call the chart helper to generate the pie chart image and to get the HTML content
		// use the chart definition in 'samples/dashboard/regions.widget.xml'
        	ChartHelper.doPieChart( "breadboard", "customer_360/case_management/dashboards", "regions.widget.xml", parameters, content, userSession, messages, null ); 
	%>

		<%= content.toString() %>
<br/>
		</td>	
			<td valign="top" style="width: 50%"><span style="font-family:Arial;font-weight:bold">
<!-- Top #2 -->
	<%
		if( category != null ) {
			// if the user has clicked on a slice of the pie chart we should have a category to work with
	%>
			Select a Type By Clicking on the Bar Chart
	<%
			// Make a bar chart showing the department 
			// create the parameres for the bar chart
	        	parameters = new SimpleParameterProvider();
			// define the click url template
	        parameters.setParameter( "drill-url", "cm_interactive_dashboard_II.jsp?category="+category+"&amp;type={SERIES}" );
			parameters.setParameter( "CATEGORY", category );
			// parameters.setParameter( "outer-params", "CATEGORY" );
			parameters.setParameter( "outer-params", "TYPE" );
			// parameters.setParameter( "outer-params", "STATUS" );
			// define the category axis of the bar chart
        		parameters.setParameter( "inner-param", "TYPE"); //$NON-NLS-1$ //$NON-NLS-2$
			// set the width and the height
        		parameters.setParameter( "image-width", "450"); //$NON-NLS-1$ //$NON-NLS-2$
        		parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
			content = new StringBuffer(); 
        		messages = new ArrayList();
			// call the chart helper to generate the pie chart image and to get the HTML content
			// use the chart definition in 'samples/dashboard/regions.widget.xml'
	        	ChartHelper.doChart( "breadboard", "customer_360/case_management/dashboards", "departments.widget.xml", parameters, content, userSession, messages, null ); 
	%>
			</span>
			
			<%= content.toString() %>
	<%
		}
	%>
<!-- BOTTOM 2 -->
	<br/>
	</td>
	</tr>
	<tr>
<!--	<td colspan="2" valign="top" align="center" style="font-family:Arial;font-weight:bold"> -->
	<td valign="top" style="width: 50%"><span style="font-family:Arial;font-weight:bold">
<!-- Top 3 -->	
	<%
		if( type != null ) {
			// if the user has clicked on a slice of the previous bar then we should have a type to work with
	%>
			Select a Status by Clicking on the Bar Chart
	<%
			// Make a bar chart showing the department 
			// create the parameres for the bar chart
	        	parameters = new SimpleParameterProvider();
			// define the click url template
	        	parameters.setParameter( "drill-url", "cm_interactive_dashboard_II.jsp?category="+category+"&amp;type="+type+"&amp;status={SERIES}" );
	        										//   "cm_interactive_dashboard_II.jsp?category="+category+"&amp;type={SERIES}" );
			parameters.setParameter( "CATEGORY", category );
			parameters.setParameter( "TYPE", type );
			parameters.setParameter( "STATUS", type );
			// parameters.setParameter( "outer-params", "CATEGORY" );
			// parameters.setParameter( "outer-params", "TYPE" );
			parameters.setParameter( "outer-params", "STATUS" );
			// define the category axis of the bar chart
        		parameters.setParameter( "inner-param", "STATUS"); //$NON-NLS-1$ //$NON-NLS-2$
			// set the width and the height
        		parameters.setParameter( "image-width", "450"); //$NON-NLS-1$ //$NON-NLS-2$
        		parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
			content = new StringBuffer(); 
        		messages = new ArrayList();
			// call the chart helper to generate the pie chart image and to get the HTML content
			// use the chart definition in 'samples/dashboard/regions.widget.xml'
	        	ChartHelper.doChart( "breadboard", "customer_360/case_management/dashboards", "case_status.widget.xml", parameters, content, userSession, messages, null ); 
	%>
			</span>
			<%= content.toString() %>
	<%
		}
	%>
<!-- Bottom of #3 -->
	</td>



		<td valign="top" style="font-family:Arial;font-weight:bold;width: 50%">
<!-- Top of #4 -->
	<%
		if( status != null ) {
			// if the user has clicked on a bar of the bar chart we should have a region and department to work with
			// run a report and embed the content into this page

			// create the parameters for the report
	        parameters = new SimpleParameterProvider();
			// pass the category, type, status parameters to the report
			parameters.setParameter( "CATEGORY", category );
			parameters.setParameter( "TYPE", type );
			parameters.setParameter( "STATUS", status );
			// create an output stream for the report content 
			ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        		messages = new ArrayList();
			// run the action sequence.
        		SolutionHelper.doAction( "breadboard", "customer_360/case_management/dashboards/reports", "case_dashboard_report.xaction", "cm_interactive_dashboard_II.jsp", parameters, outputStream , userSession, messages, null ); 
			// write the report content into this page
	%>

			Click on a Case ID to drill to another page (not activated)
			</span>
			<BR><BR>
			<% out.write( outputStream.toString() ); %>
	<%
		}
	%>
<!-- BOTTOM 4 -->
		</td>
	</tr>
</table>

	
<BR><BR>
<center>Copyright © 2009 Breadboard BI, Inc. All rights reserved.</center>

</body>
</html>