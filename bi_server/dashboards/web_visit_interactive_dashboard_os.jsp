<%@ page language="java" 
	import="java.util.ArrayList,
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
 * This JSP is a very simple example of how to combine Breadboard BI content with Pentaho components to build a dashboard.
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
	<title>Breadboard BI Sample Web Visit Dashboard</title>
<!-- Change to your client's .css file -->
<link rel="stylesheet" type="text/css" href="http://www.breadboardbi.com/style.css">

	</head>
	<body>
<%
	// See if we have a 'month of year' parameter
	String month_of_year = request.getParameter("month_of_year");
	
	// See if we have a 'country' parameter
	String country = request.getParameter("country");

	// See if we have a 'region' parameter
	String region = request.getParameter("region");
	
	// Change these default values to suite your data set.
	if( month_of_year == null ) 
	{
		month_of_year= "200710";
	}
	if( country == null ) 
	{
		country= "US";
	} 
	if( country == "US" ) 
	{
		if (region == null)
			region = "California";
	} 

 	
	// Create the title for the top of the page
	String title = "";

	if( region != null ) {
		title = "Visits by " + month_of_year + " and " + country + " and " + region;
	} 
	else if( country != null ) {
		title = "Visits by " + month_of_year + " and " + country;
	} 
	else if ( month_of_year != null ) {
		title = "Visits for " + month_of_year;
	}
	%>

<!-- Replace the src value so it points to your client's logo/banner. -->
<a href="http://www.breadboardbi.com/index.html"><img src="http://www.breadboardbi.com/images/logo.gif" alt="Breadboardbi" width="174" height="39" border="0"></a>


<table align="center">
<tr>
 <td valign="top" >
 </td>
 <td valign="top" align="right" colspan="2">
 </td>
 </tr> 

<tr>
<td valign="top"></td>
<td></td><td></td>
</tr>

<tr>
<td valign="top">
<h4 style='font-family:Arial'><%= title %></h4>
</td>
<td valign="top"></td>
<td valign="top"></td>
</tr>
	<tr>
		<td valign="top">
<!-- Top of 1 -->
		<span style="font-family:Arial;font-weight:bold">
		<small>Click a bar to select a month of the year (YYYY + 01-12)</small>
		</span>
<%
		// Make a bar chart
		// create the parameters for the bar chart
	        SimpleParameterProvider parameters = new SimpleParameterProvider();

		// define the click url template
	         parameters.setParameter( "drill-url", "web_visit_interactive_dashboard_os.jsp?month_of_year={SERIES}" );

		// define the bars of the bar chart
	       	parameters.setParameter( "inner-param", "month"); //$NON-NLS-1$ //$NON-NLS-2$

		// set the width and the height
	        parameters.setParameter( "image-width", "375"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
			StringBuffer content = new StringBuffer(); 
	        ArrayList messages = new ArrayList();

		// call the chart helper to generate the bar chart image and to get the HTML content
        	ChartHelper.doChart( "breadboard", "customer_360/web_analytics_open_source/dashboard", "web_visit_date_vert_bar.widget.xml", parameters, content, userSession, messages, null); 
	%>
		<%= content.toString() %>	
<!-- Bottom of 1 -->
<br/>
		</td>	
			<td valign="top">
			<span style="font-family:Arial;font-weight:bold">
<!-- Top #2 -->
		<span style="font-family:Arial;font-weight:bold">
		<small>Click a bar to select a top ranked country</small>
		</span>

	<%
		// Make a bar chart showing the top countries
		// create the parameters for the bar chart
	        parameters = new SimpleParameterProvider();

		// define the click url template
	        parameters.setParameter( "drill-url", "web_visit_interactive_dashboard_os.jsp?month_of_year="+month_of_year+"&amp;country={SERIES}" );

		// define the bars of the bar chart
			parameters.setParameter( "MONTH_OF_YEAR", month_of_year);
	    	parameters.setParameter( "inner-param", "COUNTRY"); //$NON-NLS-1$ //$NON-NLS-2$

		// set the width and the height
	        parameters.setParameter( "image-width", "375"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
			content = new StringBuffer(); 
	        messages = new ArrayList();

		// call the chart helper to generate the bar chart image and to get the HTML content
        	ChartHelper.doChart( "breadboard", "customer_360/web_analytics_open_source/dashboard", "web_visit_country_vert_bar.widget.xml", parameters, content, userSession, messages, null ); 
	%>

		<%= content.toString() %>

<!-- BOTTOM 2 -->
	</td>
	<td valign="top"><span style="font-family:Arial;font-weight:bold">
<!-- Top 3 -->	

	<%
		if( country != null ) {
	%>
			<small>Click a bar to select a region</small>
	<%
		// Make a bar chart showing the regions
		// create the parameters for the bar chart
	        parameters = new SimpleParameterProvider();

		// define the click url template
			parameters.setParameter("drill-url","web_visit_interactive_dashboard_os.jsp?month_of_year="+month_of_year+"&amp;country="+country+"&amp;region={SERIES}" );
			parameters.setParameter( "COUNTRY", country );
			parameters.setParameter( "MONTH_OF_YEAR", month_of_year);
			parameters.setParameter( "outer-params", "REGION" );
        	parameters.setParameter( "inner-param", "REGION"); //$NON-NLS-1$ //$NON-NLS-2$
		// set the width and the height
        	parameters.setParameter( "image-width", "375"); //$NON-NLS-1$ //$NON-NLS-2$
        	parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
			content = new StringBuffer(); 
        	messages = new ArrayList();
		// call the chart helper to generate the bar chart image and to get the HTML content
	        ChartHelper.doChart( "breadboard", "customer_360/web_analytics_open_source/dashboard", "web_visit_country_region_vert_bar.widget.xml", parameters, content, userSession, messages, null ); 
	%>
			</span>
			
			<%= content.toString() %>
	<%
		}
	%>
<!-- Bottom of #3 -->
	</td>
	</tr>
	<tr>
		<td valign="top" style="font-family:Arial;font-weight:bold" colspan=2>
<!-- Top of #4 -->


	<%
		if( region != null ) {
		// run a report and embed the content into this page

		// create the parameters for the report
	        parameters = new SimpleParameterProvider();
		// pass the parameters to the report
			parameters.setParameter( "MONTH_OF_YEAR", month_of_year );
			parameters.setParameter( "COUNTRY", country );
			parameters.setParameter( "REGION", region );
		// create an output stream for the report content 
			ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        	messages = new ArrayList();
        	SolutionHelper.doAction( "breadboard", "customer_360/web_analytics_open_source/dashboard/report", "web_visit_dashboard_report.xaction", "web_visit_interactive.jsp", parameters, outputStream , userSession, messages, null ); 
		// write the report content into this page
	%>
			</span>
			<BR><BR>
			<% out.write( outputStream.toString() ); %>
	<%
		}
	%>


<!-- BOTTOM 4 -->
		</td>



		
<!-- Top of #5 -->


<!--
<td valign="top" style="font-family:Arial;font-weight:bold">
</td>
-->
<!-- BOTTOM 5 -->		


		
<!-- Top of #6 -->
	<td style="font-family:Arial;font-weight:bold;text-align: left; vertical-align: top;">

	<%
  				if( region != null ) {
  		
  			// create the parameters for the line chart
  				parameters = new SimpleParameterProvider();
  				parameters.setParameter( "COUNTRY", country );
				parameters.setParameter( "MONTH_OF_YEAR", month_of_year);
				parameters.setParameter( "REGION", region );
  							
  			// set the width and the height
  				parameters.setParameter( "image-width", "450"); //$NON-NLS-1$ //$NON-NLS-2$
  				parameters.setParameter( "image-height", "300"); //$NON-NLS-1$ //$NON-NLS-2$
  				content = new StringBuffer(); 
  				messages = new ArrayList();
  			// call the chart helper to generate the bar chart image and to get the HTML content
  				ChartHelper.doChart( "breadboard", "customer_360/web_analytics_open_source/dashboard", "web_visit_country_region_by_month_line.widget.xml", parameters, content, userSession, messages, null ); 
  	%>
  		
  		<span style="font-family:Arial;font-weight:bold"></span>
  		
  		<%= content.toString() %>
  	<%
  		}
  	%>	

</td>

<!-- BOTTOM 6 -->

</tr>
</table>
<BR>This product includes GeoLite data created by MaxMind, available from <a href="http://www.maxmind.com/?rId=breadboad
">http://www.maxmind.com</a>.
<BR><BR>
<center>Copyright © 2007 Breadboard BI, Inc. All rights reserved.</center>
</body>
</html>