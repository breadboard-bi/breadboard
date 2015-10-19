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
			java.io.*,
			java.util.*" %><%

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
 
	response.setCharacterEncoding(LocaleHelper.getSystemEncoding());
 	String baseUrl = PentahoSystem.getApplicationContext().getBaseUrl();
 
	String path = request.getContextPath();

	IPentahoSession userSession = UIUtil.getPentahoSession( request );

	int topthreshold = 1000;
	int bottomthreshold = 1;
	
	String intro = "";
	String footer = "";
	IUITemplater templater = PentahoSystem.getUITemplater( userSession );
	boolean defaultKeyInvalid = false;
	String serverName = request.getServerName();
	int serverPort = request.getServerPort();
	if( templater != null ) {
	
   		ActionResource resource = new ActionResource( "", IActionResource.SOLUTION_FILE_RESOURCE, "text/xml", "system/custom/template-document.html" ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

		String template = null;
  		try {
    			template = PentahoSystem.getSolutionRepository(userSession).getResourceAsString( resource );
    		} catch (Throwable t) {
    		}

		String googleMapsApiKey = PentahoSystem.getSystemSetting("google/googlesettings.xml", "google_maps_api_key", null); 
		if( ( !serverName.equals( "localhost" ) || serverPort != 8080 ) && googleMapsApiKey.equals( "john" ) ) {
			defaultKeyInvalid = true;
		} else {
			template = template.replaceAll( "\\{header-content\\}", "	<script language=\"javascript\" src=\"js/pentaho-ajax.js\"></script>\n<script src=\"http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAAVEsd_PewHCVlvm4rSngrxTnOozB7iwMIqikf58bunauQPdBNhSt3AV4Hxq6L7VS3909XLazGEVaAw\" type=\"text/javascript\"></script>\n<script language=\"javascript\" src=\"js/order_capture_google_demo.js\"></script>\n" ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
			template = template.replaceAll( "\\{body-tag\\}", "onload=\"load()\" onunload=\"GUnload()\"" ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
		}
		// Title
		String sections[] = templater.breakTemplateString( template, "Order Capture Google Maps Dashboard", userSession ); //$NON-NLS-1$ //$NON-NLS-2$
		if( sections != null && sections.length > 0 ) {
			intro = sections[0];
		}
		if( sections != null && sections.length > 1 ) {
			footer = sections[1];
		}
	} else {
		intro = Messages.getString( "UI.ERROR_0002_BAD_TEMPLATE_OBJECT" );
	}

		SimpleParameterProvider parameters = new SimpleParameterProvider();
		ArrayList messages = new ArrayList();

		IPentahoResultSet results = null;
        IRuntimeContext runtime = null;
        try {
			runtime = ChartHelper.doAction( "breadboard", "customer_360/sales_order_capture/dashboards/google",  "order_capture_google_map.xaction",  "order_capture_google_map.jsp",  parameters,  userSession,  messages,  null );
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

<!-- Replace the src value so it points to your client's logo/banner. -->
<!-- include file="navBarTopSimple.html"  -->


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
    <div id="selections" style="position:absolute;width: 345px; height: 200px;top:70px; left:5px; border:0px">
		<form name="mapform" action="order_capture_google_map.jsp" method="get">
		<input name="customer" id="customer" value="" type="hidden"/>
		<input name="zoom" id="zoom" value="" type="hidden"/>
		<input name="lat" id="lat" value="" type="hidden"/>
		<input name="long" id="long" value="" type="hidden"/>

<table border="0" cellpadding="0" cellspacing="0" width="100%" >
  <tr>
    <td valign="top">
      <table border="0" cellpadding="0" cellspacing="0" width="100%" style="margin:0px; padding:0px">
          <tr>
            <td style="height: 25px; width: 25px;"><img border="0" src="/pentaho-style/images/fly-top-left1.png" /></td>
            <td style="background-image: url(/pentaho-style/images/fly-top1.png); background-repeat: repeat-x; height: 25px; margin:0px; padding:0px ">
				<span class="a" style="">Select Sales Thresholds</span>
			</td>
          </tr>
          <tr>
            <td colspan="2" style="background-color: #e5e5e5;"><table width="100%" border="0" cellspacing="1" cellpadding="0" height="100%">
			
			<tr>
                  <td style="background-image: url(/pentaho-style/images/fly-left1.png); background-repeat: repeat-y; height: 10px; padding: 0px 5px 0px 0px;">
					&nbsp;</td>
				<td colspan="2">
			View: <a href="javascript:void" onclick="map.setCenter( new GLatLng(35.55, -119.268 ), 6); return false;">West Coast</a> | 
			<a href="javascript:void" onclick="map.setCenter( new GLatLng(41.4263, -73.1799 ), 7); return false;">East Coast</a>

				</td>
			</tr>
			
                <tr style="background-color: #e5e5e5;">
                  <td style="background-image: url(/pentaho-style/images/fly-left1.png); background-repeat: repeat-y; height: 10px; padding: 0px 5px 0px 0px;">
					&nbsp;</td>
					<td valign="top" style="padding: 0px 0px 0px 0px;">

		<table>
			<tr>
				<td>
					<img border="0" src="http://labs.google.com/ridefinder/images/mm_20_red.png"/>
				</td>
				<td>
					< 
		<select id="bottomthreshold" onchange="update(false)">
	<%
	for( int idx=0; idx<=20; idx++ ) {
		if( idx == (bottomthreshold/100) ) {
			%>
			<option value="<%= idx*100 %>" selected><%= idx*100 %></option>
			<%
		} else {
			%>
			<option value="<%= idx*100 %>"><%= idx*100 %></option>
			<%
		}
	}
	%>
		</select> <
				</td>
				<td>
					<img border="0" src="http://labs.google.com/ridefinder/images/mm_20_yellow.png"/>
				</td>
				<td>
				<
		<select id="topthreshold" onchange="update(true)">
	<%
	for( int idx=0; idx<=20; idx++ ) {
		if( idx == (topthreshold/100) ) {
			%>
			<option value="<%= idx*100 %>" selected><%= idx*100 %></option>
			<%
		} else {
			%>
			<option value="<%= idx*100 %>"><%= idx*100 %></option>
			<%
		}
	}
	%>
		</select> <
				</td>
				<td>
					<img border="0" src="http://labs.google.com/ridefinder/images/mm_20_green.png"/>
				</td>
			</tr>
		</table>
		
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
<br/>
					<center>
						<img border="0" src="/pentaho-style/images/branding_home.png" style="padding-top:5px"/>
					</center>
		</form>

</div>

<!--    <div id="details-div" style="position:absolute;width: 320px; xheight: 500px;top:135px; left:30px; border:0px;display:none;overflow: none;"> -->

    <div id="details-div" style="position:absolute;width: 320px; height: 500px;top:135px; left:30px; border:0px;display:none;">

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
							Sales History
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
					<center>
						<img border="0" src="/pentaho-style/images/branding_home.png" style="padding-top:5px"/>
					</center>

</div>

    <div id="map" style="position:absolute;width: 640px; height: 580px;top:40px;left:350px;border:1px solid #808080"></div>

<% } %>


