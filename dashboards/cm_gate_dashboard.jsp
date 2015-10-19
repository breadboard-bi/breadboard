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

<title>Breadboard BI Sample Case Management Gateway Dashboard</title>

</head>

	<body>

<%
	
	// Create the title for the top of the page
	String title = "Sample Gateway Dashboard";
%>

<table align="center">
<tr>
<td colspan="2">

<!-- Replace the src value so it points to your client's logo/banner. -->
<!-- include file="navBarTopSimple.html"  -->
 </td>
 </tr> 

<tr>
<td valign="top"></td>
<td></td>
</tr>

<tr>
<td valign="top" style="width: 50%">
<h4 style='font-family:Arial'><%= title %></h4>

</td>
<td> </td>
</tr>
	<tr>
		<td valign="top" style="width: 50%">
<!-- Top of 1 -->
<%
		// Make a pie chart showing the regions
		// create the parameres for the pie chart
	        SimpleParameterProvider parameters = new SimpleParameterProvider();
		// define the click url template
	        parameters.setParameter( "drill-url", "Pivot?solution=breadboard&path=customer_360/case_management/analysis&action=case_time_cube.xaction");
		// define the slices of the pie chart
	       parameters.setParameter( "inner-param", "quarter"); //$NON-NLS-1$ //$NON-NLS-2$
		// set the width and the height
	        parameters.setParameter( "image-width", "450"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
			StringBuffer content = new StringBuffer(); 
	        ArrayList messages = new ArrayList();
		// call the chart helper to generate the pie chart image and to get the HTML content
		// use the chart definition in 'samples/dashboard/regions.widget.xml'
        	ChartHelper.doChart( "breadboard", "customer_360/case_management/dashboards", "case_open_date.widget.xml", parameters, content, userSession, messages, null ); 
	%>
		<%= content.toString() %>	
<!-- Bottom of 1 -->
<br/>
		</td>	
			<td valign="top" style="width: 50%"><span style="font-family:Arial;font-weight:bold">
<!-- Top #2 -->
<%
		// Make a pie chart showing the regions
		// create the parameres for the pie chart
	        parameters = new SimpleParameterProvider();
		// define the click url template
	        parameters.setParameter( "drill-url", "Pivot?solution=breadboard&path=customer_360/case_management/analysis&action=case_category_cube.xaction");
		// define the slices of the pie chart
	       parameters.setParameter( "inner-param", "category"); //$NON-NLS-1$ //$NON-NLS-2$
		// set the width and the height
	        parameters.setParameter( "image-width", "450"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
			content = new StringBuffer(); 
	        messages = new ArrayList();
		// call the chart helper to generate the pie chart image and to get the HTML content
		// use the chart definition in 'samples/dashboard/regions.widget.xml'
        	ChartHelper.doChart( "breadboard", "customer_360/case_management/dashboards", "case_category_2.widget.xml", parameters, content, userSession, messages, null ); 
	%>
		<%= content.toString() %>
<!-- BOTTOM 2 -->
	<br/></td></tr>
	<tr>
<!--	<td colspan="2" valign="top" align="center" style="font-family:Arial;font-weight:bold"> -->
	<td valign="top" style="width: 50%">
<!-- Top 3 -->	
<%
			// Make a bar chart showing the department 
			// create the parameres for the bar chart
	        	parameters = new SimpleParameterProvider();
			// define the click url template
	        parameters.setParameter( "drill-url", "Pivot?solution=breadboard&path=customer_360/case_management/analysis&action=case_rep_cube.xaction");
	//		parameters.setParameter( "CATEGORY", category );
			// parameters.setParameter( "outer-params", "CATEGORY" );
		//	parameters.setParameter( "outer-params", "TYPE" );
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
	        	ChartHelper.doChart( "breadboard", "customer_360/case_management/dashboards", "case_type_1.widget.xml", parameters, content, userSession, messages, null ); 
	%>
			
			<%= content.toString() %>

<!-- Bottom of #3 -->
	</td>



		<td valign="top" style="font-family:Arial;font-weight:bold;width: 50%">
<!-- Top of #4 -->
	<%
			// Make a bar chart showing the department 
			// create the parameres for the bar chart
	        	parameters = new SimpleParameterProvider();
			// define the click url template
	        	parameters.setParameter( "drill-url", "Pivot?solution=breadboard&path=customer_360/case_management/analysis&action=case_status_cube.xaction");
	        										//   "BreadboardSampleDashboard.jsp?category="+category+"&amp;type={SERIES}" );
//			parameters.setParameter( "CATEGORY", category );
	//		parameters.setParameter( "TYPE", type );
		//	parameters.setParameter( "STATUS", type );
			parameters.setParameter( "outer-params", "CATEGORY" );
			// parameters.setParameter( "outer-params", "TYPE" );
	//		parameters.setParameter( "outer-params", "STATUS" );
			// define the category axis of the bar chart
        		parameters.setParameter( "inner-param", "STATUS"); //$NON-NLS-1$ //$NON-NLS-2$
			// set the width and the height
        		parameters.setParameter( "image-width", "450"); //$NON-NLS-1$ //$NON-NLS-2$
        		parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
				content = new StringBuffer(); 
        		messages = new ArrayList();
			// call the chart helper to generate the pie chart image and to get the HTML content
			// use the chart definition in 'samples/dashboard/regions.widget.xml'
	        	ChartHelper.doChart( "breadboard", "customer_360/case_management/dashboards", "case_status_2.widget.xml", parameters, content, userSession, messages, null ); 
	%>
			<%= content.toString() %>
<!-- BOTTOM 4 -->
		</td>
	</tr>
</table>


<BR><BR>
<center>Copyright © 2009 Breadboard BI, Inc. All rights reserved.</center>
</body>
</html>