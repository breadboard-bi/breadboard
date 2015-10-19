<%@ page language="java" 
	import="org.pentaho.core.system.PentahoSystem,
			org.pentaho.core.session.IPentahoSession,
			org.pentaho.core.util.XmlHelper,
	        org.pentaho.messages.Messages,
			org.pentaho.core.util.UIUtil,
			org.pentaho.messages.util.LocaleHelper,
			org.pentaho.util.VersionHelper,
			org.pentaho.ui.component.INavigationComponent,
    		org.pentaho.ui.component.NavigationComponentFactory,
    		org.pentaho.core.ui.SimpleUrlFactory,
			org.pentaho.core.solution.SimpleParameterProvider,
			org.dom4j.*,
			org.pentaho.core.solution.ActionResource,
			org.pentaho.core.solution.IActionResource,
			org.pentaho.core.util.IUITemplater,
			org.pentaho.core.solution.SimpleOutputHandler,
			org.pentaho.core.services.BaseRequestHandler,
			org.pentaho.core.runtime.IRuntimeContext,
			org.pentaho.core.connection.IPentahoResultSet,
			org.pentaho.ui.ChartHelper,
			javax.naming.*,
	        javax.sql.DataSource,
			java.sql.*,
			java.io.*,
			java.util.*,
			java.util.Date,
        	java.text.DateFormat,
			java.text.SimpleDateFormat" %><%
	
			
			

/*
 * Copyright 2006 Pentaho Corporation.  All rights reserved. 
 * This software was developed by Pentaho Corporation and is provided under the terms 
 * of the Mozilla Public License, Version 1.1, or any later version. You may not use 
 * this file except in compliance with the license. If you need a copy of the license, 
 * please go to http://www.mozilla.org/MPL/MPL-1.1.txt. The Original Code is the Pentaho 
 * BI Platform.  The Initial Developer is Pentaho Corporation.
 *
 * Software distributed under the Mozilla Public License is distributed on an "AS IS" 
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. Please refer to 
 * the license for the specific language governing your rights and limitations.
 *
 * @created Jul 23, 2005 
 * @author James Dixon
 * 
 */


////////////////////////////////////////////////////////////////////
//SET UP PARAMETERS/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
String temporal_value = ((request.getParameter("temporal_value")!=null)?request.getParameter("temporal_value"):"");
String temporal_cat = ((request.getParameter("temporal_cat")!=null)?request.getParameter("temporal_cat"):"");
String source_system_sk = ((request.getParameter("source_system_sk")!=null)?request.getParameter("source_system_sk"):"");
String user_name = ((request.getRemoteUser()!=null)?request.getRemoteUser():"");

String title = "Web Visit Google Map Dashboard";
String map_title = "";

String default_source_system_sk = "";

if( temporal_value.length() < 1) 
{
Date current_dt = new Date();	
SimpleDateFormat sdf_year = new SimpleDateFormat("yyyy");
SimpleDateFormat sdf_month = new SimpleDateFormat("MM"); 
SimpleDateFormat sdf_day = new SimpleDateFormat("dd"); 
// temporal_value = sdf_year.format(current_dt)+sdf_month.format(current_dt);
temporal_value = sdf_year.format(current_dt)+sdf_month.format(current_dt)+sdf_day.format(current_dt);
temporal_cat = "Day of ";
}

// Get user name from session, if NULL use 0 (demo user)
// String user_name = ""; //request.getRemoteUser();
if( user_name.length() < 1) {user_name = "demo";}
String hosted_client_sk = "";
String user_desc = "";

 // End Temporary

map_title = "Visits for " + temporal_cat + " " + temporal_value;

String sql_user = "SELECT USER_DESC, HOSTED_CLIENT_SK FROM ADMIN_USER WHERE USER_NAME = ?";
String sql_default_source = "SELECT DISTINCT PARENT_SOURCE_SYSTEM_SK AS DEFAULT_SOURCE_SYSTEM_SK FROM DIMENSION_SOURCE_SYSTEM WHERE DEFAULT_WEB_SOURCE_IND = 'Y' AND HOSTED_CLIENT_SK = ?";
String sql2 = "SELECT MAX(REQUEST_DATE) AS REQUEST_DATE FROM FACT_WEB_PAGE_VIEW WHERE HOSTED_CLIENT_SK = ?";

int myResolved = 0;
int mySLAcomp = 0;
String exceptionErrors = "";

String update_date = "";
Context context = null;
DataSource dataSource = null;
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;




////////////////////////////////////////////////////////////////////
//GET CONNECTION TO DATABASE////////////////////////////////////////
////////////////////////////////////////////////////////////////////
//Replace with your client's connection code
context = new InitialContext();
dataSource = (DataSource)context.lookup("java:mdw_mysql");


////////////////////////////////////////////////////////////////////
//QUERY THE DATABASE////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

try {
   //get the query results, String sql_user
   conn = dataSource.getConnection();
   ps = conn.prepareStatement(sql_user);
   ps.setString(1, user_name);
   rs = ps.executeQuery();
   if (rs.next()) {
      hosted_client_sk = ((rs.getString("HOSTED_CLIENT_SK")!=null)?rs.getString("HOSTED_CLIENT_SK"):"");
      user_desc = ((rs.getString("USER_DESC")!=null)?rs.getString("USER_DESC"):"");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;
 
 
    //get the next query results, String sql2
   conn = dataSource.getConnection();
   ps = conn.prepareStatement(sql2);
   ps.setString(1, hosted_client_sk);
   rs = ps.executeQuery();
   if (rs.next()) {
      update_date = "Updated "+((rs.getString("REQUEST_DATE")!=null)?rs.getString("REQUEST_DATE"):"")+" PST";
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null; 
 
 
    //get the next query results, sql_default_source
   conn = dataSource.getConnection();
   ps = conn.prepareStatement(sql_default_source);
   ps.setString(1, hosted_client_sk);
   rs = ps.executeQuery();
   if (rs.next()) {
      default_source_system_sk = ((rs.getString("DEFAULT_SOURCE_SYSTEM_SK")!=null)?rs.getString("DEFAULT_SOURCE_SYSTEM_SK"):"");
   }
   if (rs != null) rs.close(); rs = null;
   if (ps != null) ps.close(); ps = null;  
   
   
   
   
 
} catch (Exception e) {
   StringWriter writer = new StringWriter();
   e.printStackTrace(new PrintWriter(writer));
   exceptionErrors  = writer.getBuffer().toString();
}
//close connection
if (conn != null) conn.close(); conn = null;




////////////////////////////////////////////////////////////////////
//Assign Various Values/////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

if( source_system_sk.length() < 1) {source_system_sk = default_source_system_sk;}

// Resume Original
 
	response.setCharacterEncoding(LocaleHelper.getSystemEncoding());
 	String baseUrl = PentahoSystem.getApplicationContext().getBaseUrl();
 
	String path = request.getContextPath();

	IPentahoSession userSession = UIUtil.getPentahoSession( request );

//	int topthreshold = 1000;
//	int bottomthreshold = 1;
	
	String intro = "";
	String footer = "";
//	IUITemplater templater = PentahoSystem.getUITemplater( userSession );
	boolean defaultKeyInvalid = false;
	String serverName = request.getServerName();
	int serverPort = request.getServerPort();
//	if( templater != null ) {
	
// 		ActionResource resource = new ActionResource( "", IActionResource.SOLUTION_FILE_RESOURCE, "text/xml", "system/custom/template-document.html" ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

//		String template = null;
//  		try {
//    			template = PentahoSystem.getSolutionRepository(userSession).getResourceAsString( resource );
//    		} catch (Throwable t) {
//    		}

//		String googleMapsApiKey = PentahoSystem.getSystemSetting("google/googlesettings.xml", "google_maps_api_key", null); 
//		if( ( !serverName.equals( "localhost" ) || serverPort != 8080 ) && googleMapsApiKey.equals( "john" ) ) {
//			defaultKeyInvalid = true;
//		} else {
		// Here is the source of the problem, i tried to add your common.js here, plus the longer scripts with functions to the common.js file
		//	 template = template.replaceAll( "\\{header-content\\}", "	<script language=\"javascript\" src=\"js/pentaho-ajax.js\"></script>\n<script src=\"http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAAVEsd_PewHCVlvm4rSngrxTnOozB7iwMIqikf58bunauQPdBNhSt3AV4Hxq6L7VS3909XLazGEVaAw\" type=\"text/javascript\"></script>\n<script language=\"javascript\" src=\"js/web_visit_google_demo.js\"></script>\n<script src=\"/pentaho/js/common.js\" type=\"text/javascript\"></script>\n" ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
		//	 template = template.replaceAll( "\\{body-tag\\}", "onload=\"load()\" onunload=\"GUnload()\"" ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
//		}
		// Title
//		String sections[] = templater.breakTemplateString( template, "Breadboard BI Web Visit Google Maps Dashboard", userSession ); //$NON-NLS-1$ //$NON-NLS-2$
//		if( sections != null && sections.length > 0 ) {
//			intro = sections[0];
//		}
//		if( sections != null && sections.length > 1 ) {
//			footer = sections[1];
//		}
//	} else {
//		intro = Messages.getString( "UI.ERROR_0002_BAD_TEMPLATE_OBJECT" );
//	}

		SimpleParameterProvider parameters = new SimpleParameterProvider();
		ArrayList messages = new ArrayList();

		IPentahoResultSet results = null;
        IRuntimeContext runtime = null;
        parameters.setParameter( "TEMPORAL_VALUE", temporal_value);
        parameters.setParameter( "HOSTED_CLIENT_SK", hosted_client_sk);
		parameters.setParameter( "SOURCE_SYSTEM_SK", source_system_sk);
		parameters.setParameter( "USER_DESC", user_desc);
        try {
			runtime = ChartHelper.doAction( "breadboard", "customer_360/web_analytics/dashboards/google",  "web_visit_google_map.xaction",  "web_visit_google_map_dashboard.jsp",  parameters,  userSession,  messages,  null );
            if( runtime != null ) {
				if( runtime.getStatus() == IRuntimeContext.RUNTIME_STATUS_SUCCESS ) {
					if( runtime.getOutputNames().contains("data") ) {
						results = (IPentahoResultSet) runtime.getOutputParameter( "data" ).getValue();
					}
				}
            }
        } finally {
            if (runtime != null) {
                runtime.dispose();
            }
        }

		String customerNum = "";
		String customer = "";
		String city = "";
		String state = "";
		String zip = "";
		String value = "";

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- This page is an early WIP -->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

	<title>Breadboard BI Web Visit Google Map Dashboard</title>
    <!--    <link href="/pentaho-style/styles-new.css" rel="stylesheet" type="text/css" /> -->
	<!-- link rel="stylesheet" type="text/css" href="/pentaho-style/active/default.css" / -->

	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<link rel="shortcut icon" href="/pentaho-style/favicon.ico" />

<script language="javascript" src="/pentaho-style/pentaho.js"></script>
<script language="javascript" src="js/pentaho-ajax.js"></script>
<script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAAVEsd_PewHCVlvm4rSngrxTnOozB7iwMIqikf58bunauQPdBNhSt3AV4Hxq6L7VS3909XLazGEVaAw" type="text/javascript"></script>
<script language="javascript" src="js/web_visit_google_demo.js"></script>
<script src="/pentaho/js/common.js" type="text/javascript"></script>

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
<!-- Change to your client's .css file -->
<link rel="stylesheet" type="text/css" href="http://www.breadboardbi.com/style.css">
</head>

<body onload="load()" onunload="GUnload()">

<!-- <body class="body_document" dir="LTR" onload="load()" onunload="GUnload()"> -->

<table align="center">
<tr>
<td valign="top" style="width: 33%">

<!-- Replace the src value so it points to your client's logo/banner. -->
<!-- include file="navBarTopSimple.html"  -->

 </td>
 <td valign="top" style="width: 33%"></td>
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
</td>
<tr>
<td valign="top" colspan="3" align="left">
<h3 style='font-family:Arial'><%= map_title %></h3>
Click the items to view additional details
</td>
</tr>
</table>
<%= intro %>


<% if( defaultKeyInvalid ) { %>

The Google Maps API key that ships with the Pentaho Pre-Configured Installation will only work with a server address of 'http://localhost:8080'. 
<p/> 
To use Google Maps with this server address ( <%= serverName %>:<%= serverPort %> ) you need to apply to Google for a new key.
<p/>
Once you have the new key you need to add it to the Google settings file in the Pentaho system (.../pentaho-solutions/system/google/googlesettings.xml)
<p/>
<a target='google-map-api-key' href='http://www.google.com/apis/maps/signup.html'>Click here</a> to get a Google Maps API Key for this server.

<% } else { %>

    <script type="text/javascript">

    //<![CDATA[

	function addPoints() {
      if (GBrowserIsCompatible()) {
	<%
	int n = results.getRowCount();
	for( int row=0; row<n; row++ ) {
		customerNum = results.getValueAt( row, 0 ).toString();
		customer = (String) results.getValueAt( row, 1 );
		city = (String) results.getValueAt( row, 2 );
		state = (String) results.getValueAt( row, 3 );
		zip = (String) results.getValueAt( row, 4 );
		value = results.getValueAt( row, 5 ).toString();
			%>
			try {
				showAddress( "<%= city %>,<%= state %>", "<%= customer %>", "<%= customerNum %>", <%= value %>, false );
			} catch (e) {}
			<%
	}
	%>

     }
    }

    //]]>
    </script>
    <div id="selections" style="position:absolute;width: 345px; height: 200px;top:40px; left:5px; border:0px">
		<form name="mapform" action="web_visit_google_map.jsp" method="get">
		<input name="customer" id="customer" value="" type="hidden"/>
		<input name="zoom" id="zoom" value="" type="hidden"/>
		<input name="lat" id="lat" value="" type="hidden"/>
		<input name="long" id="long" value="" type="hidden"/>

<br/>
<!--
					<center>
						<img border="0" src="/pentaho-style/images/branding_home.png" style="padding-top:5px"/>
					</center>
-->
<!--		</form> -->

</div>

<!--    <div id="details-div" style="position:absolute;width: 320px; xheight: 500px;top:135px; left:30px; border:0px;display:none;overflow: none;"> -->

    <div id="details-div" style="width: 320px; height: 500px;top:135px; left:30px; border:0px;display:none;">

<table border="0" cellpadding="0" cellspacing="0" width="100%" xheight="470">
  <tr>
    <td valign="top">
      <table border="0" cellpadding="0" cellspacing="0" width="100%" xheight="470" style="margin:0px; padding:0px">
          <tr>
            <td colspan="2"  valign="top" style="background-color: #e5e5e5;"><table width="100%" border="0" cellspacing="1" cellpadding="0" height="100%">
                <tr style="background-color: #e5e5e5;">
                  <td style="background-image: url(/pentaho-style/images/fly-left1.png); background-repeat: repeat-y; height: 10px; padding: 0px 5px 0px 0px;">
					&nbsp;</td>
					<td valign="top" style="padding: 0px 0px 0px 0px;">
					<div id="details-cell1" style="padding: 0px 0px 0px 0px;height: 250px; overflow: auto; ">
					</div
					</td>
                </tr>
                <tr style="background-color: #e5e5e5;">
                  <td style="background-image: url(/pentaho-style/images/fly-left1.png); background-repeat: repeat-y; padding: 0px 5px 0px 0px;">
					&nbsp;</td>
					<td valign="top" style="padding: 10px 0px 0px 0px;height: 113px; overflow: auto; font: normal 1.1em Tahoma, 'Trebuchet MS', Arial;">
						<center>
							Visitor History
						</center>
					<div id="details-cell2" style="padding: 0px 0px 0px 0px;height: 113px; overflow: auto; ">
					</div>
					</td>
                </tr>
            </table></td>
          </tr>
          <tr>
            <td style="height: 25px; width: 25px;"><img border="0" src="/pentaho-style/images/fly-bot-left1.png" /></td>
            <td  style="background-image: url(/pentaho-style/images/fly-bot1.png); background-repeat: repeat-x">&nbsp;</td>
          </tr>
      </table>
      </td>
    <td valign="top" style="padding: 0px 0px 0px 0px; font-size: .85em;">
	</td>
  </tr>
</table>
<!--
					<center>
						<img border="0" src="/pentaho-style/images/branding_home.png" style="padding-top:5px"/>
					</center>
-->
</div>
<center></center>
    <div id="map" style="position:absolute;width: 640px; height: 580px;top:135px;left:350px;border:1px solid #808080"></div>

<% } %>
<div id="foot" style="position:absolute;width: 640px; height: 20px;top:720px;left:350px;border:0px solid #808080">
<BR><BR>
<center>Copyright © 2007 Breadboard BI, Inc. All rights reserved.<BR><BR>
client=<%=hosted_client_sk %>; src=<%=source_system_sk %>; def-src=<%=default_source_system_sk %>; temporal=<%=temporal_value %></center>
</div>
</body>
</html>