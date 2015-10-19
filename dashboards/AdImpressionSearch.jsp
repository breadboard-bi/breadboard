<%@page language="java"  import="com.breadboardbi.general.utils.*,java.sql.*,java.util.*"%>
<%@page import="java.net.URLEncoder"%>
<%

// CJL - Changed com.catzilla.utils to com.breadboard.utils

// CJL - Changed CATZILLA_DEV to mdw_mysql.


String report_title = "Sample Online Campaign Report Dashboard";

DBConnection dbConn = new DBConnection("MDW_MYSQL",request);
ResultSet rs=null;
PreparedStatement ps=null;

String customer_sk = request.getParameter("customer_sk");
customer_sk = (customer_sk==null)?"":customer_sk;

// CJL - Added .jsp suffix (temp)
String url="/pentaho/AdImpressionSearch.jsp";
if(customer_sk.length()>0)url+="?customer_sk="+customer_sk;

StringBuffer advertiser_dropdown=new StringBuffer("<select onChange=\"changeCustomer(this.value)\" name='customer_sk' id='customer_sk'><option value=''>All</option>");
StringBuffer advertiser_js=new StringBuffer("var advertiser_js = new Array();\n");
String adgroup_sql="select distinct c.CUSTOMER_SK, c.CUSTOMER_NAME from dimension_customer c, fact_advertisement_impression f where f.customer_sk = c.customer_sk and c.CUSTOMER_NAME IS NOT NULL ";
rs  = dbConn.executeQuery(adgroup_sql,ps);
while(rs!=null && rs.next()){
	String customer = rs.getString("CUSTOMER_NAME");
	String customer_sk_ = rs.getString("CUSTOMER_SK");
	String selected = (customer_sk_.equals(customer_sk))?" selected ":"";
	advertiser_dropdown.append("<option value='"+customer_sk_+"' "+selected+">"+customer+"</option>");
	advertiser_js.append("advertiser_js["+customer_sk_+"]='"+customer+"';\n");
}


advertiser_dropdown.append("</select>");
if(rs!=null)rs.close();rs=null;
if(ps!=null)ps.close();ps=null;

StringBuffer campaign_dropdown=new StringBuffer("<select name='campaign_id'  id='campaign_id'><option value=''>All</option>");
StringBuffer campaign_js=new StringBuffer("var campaign_js = new Array();\n");
String campaign_id_sql="select DISTINCT W.CAMPAIGN_WAVE_NAME AS CAMPAIGN_NAME, w.CAMPAIGN_WAVE_SK AS CAMPAIGN_ID FROM dimension_campaign_wave w, fact_advertisement_impression f WHERE w.campaign_wave_sk = f.campaign_wave_sk and w.CAMPAIGN_NAME IS NOT NULL ";
if(customer_sk.length()>0)campaign_id_sql+=" AND f.CUSTOMER_SK="+customer_sk;
System.out.println(campaign_id_sql);
rs  = dbConn.executeQuery(campaign_id_sql,ps);
while(rs!=null && rs.next()){
	String campaign_id = rs.getString("CAMPAIGN_ID");
	String campaign_name = rs.getString("CAMPAIGN_NAME");
	campaign_dropdown.append("<option value=\""+campaign_id+"\">"+campaign_name+"</option>");
	campaign_js.append("campaign_js["+campaign_id+"]='"+campaign_name+"';\n");
}
campaign_dropdown.append("</select>");
if(rs!=null)rs.close();rs=null;
if(ps!=null)ps.close();ps=null;

StringBuffer ad_network_dropdown=new StringBuffer("<select name='source_id' id='source_id'><option value=''>All</option>");
StringBuffer adnetwork_js=new StringBuffer("var adnetwork_js = new Array();\n");
String source_id_sql="select distinct s.SOURCE_SYSTEM_NAME,s.SOURCE_SYSTEM_ID FROM dimension_source_system s, fact_advertisement_impression f WHERE s.source_system_sk = f.source_system_sk and s.SOURCE_SYSTEM_NAME IS NOT NULL ";

// CJL Added line below.
if(customer_sk.length()>0)source_id_sql+=" AND f.CUSTOMER_SK="+customer_sk;

rs  = dbConn.executeQuery(source_id_sql,ps);
while(rs!=null && rs.next()){
	String source_system_id = rs.getString("SOURCE_SYSTEM_ID");
	String source_system_name = rs.getString("SOURCE_SYSTEM_NAME");
	ad_network_dropdown.append("<option value=\""+source_system_id+"\">"+source_system_name+"</option>");
	adnetwork_js.append("adnetwork_js["+source_system_id+"]='"+source_system_name+"';\n");
}
ad_network_dropdown.append("</select>");
if(rs!=null)rs.close();rs=null;
if(ps!=null)ps.close();ps=null;

Calendar cal = Calendar.getInstance();
int year = cal.get(Calendar.YEAR);
int month = cal.get(Calendar.MONTH)+1;
int day = cal.get(Calendar.DAY_OF_MONTH);


String month_to_date_start = ""+month+"/01/"+year;
String month_to_date_end   = ""+month+"/"+day+"/"+year;

cal.add(Calendar.MONTH,-1);
year = cal.get(Calendar.YEAR);
month = cal.get(Calendar.MONTH)+1;
day = cal.getActualMaximum(Calendar.DAY_OF_MONTH);



String prior_month_start =  ""+month+"/01/"+year;
String prior_month_end =  ""+month+"/"+day+"/"+year;







dbConn.close();
dbConn=null;
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">



<head>

<title>Breadboard BI Online Marketing Report Generator</title>
<script language="javascript" type="text/javascript" src="/pentaho/js/show-calendar.gif"></script>
<script language="javascript" type="text/javascript" src="/pentaho/js/bbbijs/common.js"></script>
<script language="javascript" type="text/javascript" src="/pentaho/js/bbbijs/date.js"></script>



 	
<script language='javascript'>
	function changeCustomer(val){
		window.location.href='/pentaho/AdImpressionSearch.jsp?customer_sk='+val;
	}
	<%=advertiser_js.toString()%>
	<%=campaign_js.toString()%>
	<%=adnetwork_js%>
function checkSubmit(){
var advert_dd=document.getElementById('customer_sk');
var val = advert_dd.value;
if (val.length > 0)
document.getElementById('advertiser_name').value= advertiser_js[val];
else
document.getElementById('advertiser_name').value = 'All';

var camp_dd=document.getElementById('campaign_id');
val = camp_dd.value;
if (val.length > 0)
document.getElementById('campaign_name').value = campaign_js[val];
else
document.getElementById('campaign_name').value = 'All';

var source_dd=document.getElementById('source_id');
val = source_dd.value;
if (val.length > 0)
document.getElementById('ad_network_name').value= adnetwork_js[val];
else
document.getElementById('ad_network_name').value = 'All';

return true;
}

		var month_to_date_start='<%=month_to_date_start%>';
		var month_to_date_end = '<%=month_to_date_end%>';		
		var prior_month_start = '<%=prior_month_start%>';	
		var prior_month_end = '<%=prior_month_end%>';	






	function changeDate(val){
			if(val=='m2date'){
				document.getElementById('hideme').style.display='none';
				document.getElementById('date_start').value=month_to_date_start;
				document.getElementById('date_end').value=month_to_date_end;
				document.getElementById('datedisplay').innerHTML=document.getElementById('date_start').value+'-'+document.getElementById('date_end').value;
			}
			if(val=='pmonth'){
				document.getElementById('hideme').style.display='none';
				document.getElementById('date_start').value=prior_month_start;
				document.getElementById('date_end').value=prior_month_end;
				document.getElementById('datedisplay').innerHTML=document.getElementById('date_start').value+'-'+document.getElementById('date_end').value;
			}
			if(val=='custom'){
				document.getElementById('date_start').value='';
				document.getElementById('date_end').value='';
				document.getElementById('hideme').style.display='';
				document.getElementById('datedisplay').innerHTML='';
			}
		
	}
	
</script>

</head>



<body>
<!-- Replace the src value so it points to your client's logo/banner. -->
<!-- include file="navBarTopSimple.html"  -->
<font style="font-family:Arial;font-weight:bold;font-size:14pt">
<BR>
<%= report_title %>
<BR>
</font>

<!-- CJL changed solution and path values -->
				<form name="form1" method="GET" action="/pentaho/ViewAction" onsubmit="return checkSubmit();">
					<input type='hidden' name='solution' value='breadboard'>
					<input type='hidden' name='path' value='customer_360/marketing/dashboards/reports'>
					<input type='hidden' name='ad_network_name' id='ad_network_name'>
					<input type='hidden' name='advertiser_name' id='advertiser_name'>
					<input type='hidden' name='campaign_name' id='campaign_name'>
					
				 <table border="0" cellspacing="3" cellpadding="3" width="99%">
				 <tbody>
								<tr><td colspan="2">
<!-- <center><img src="/pentaho/images/logo-default.jpg"><img src="/pentaho/images/headerright-bg.gif"></center> -->

</td></tr>
								<tr>
									<td align="right"><strong>Advertiser</strong></td>
									<td width="60%" valign="top" style="padding-left: 9px"><%=advertiser_dropdown.toString() %></td>
								</tr>
								<tr>
									<td align="right"><strong>Campaign</strong></td>
									<td width="60%" valign="top" style="padding-left: 9px"><%=campaign_dropdown.toString() %></td>
								</tr>
								<tr>
									<td align="right"><strong>Ad Network</strong></td>
									<td width="60%" valign="top" style="padding-left: 9px"><%=ad_network_dropdown.toString() %></td>
								</tr>
<tr>
<td align="right"><strong>Date Range <i><font color='red'>(mm/dd/yyyy)</font></i></strong></td>
<td width="60%" valign="top" style="padding-left: 9px" nowrap>
<select name='datepicker' onchange='changeDate(this.value)'>
<option value='m2date' selected>Month to date</option>
<option value='pmonth'>Prior Month</option>
<option value='custom'>Custom Dates</option>
</select>
<font color='red'><span id='datedisplay'><%=month_to_date_start%>-<%=month_to_date_end%></span></font>
<div id='hideme' style='display: none'>
From: <input type='text' name='date_start' id='date_start' size='10' value='<%=month_to_date_start%>' onChange='isValidDate2(this)'>
<a href="javascript:show_calendar('form1.date_start')" 
onmouseover="window.status='Date Picker';return true;"
onmouseout="window.status='';return true;">
<img src='/pentaho/js/show-calendar.gif' width=24 height=22 border=0>
</a>&nbsp;&nbsp;
To:
<input type='text' name='date_end' id='date_end' size='10' value='<%=month_to_date_end%>' onChange='isValidDate2(this)'>
<a href="javascript:show_calendar('form1.date_end')" 
onmouseover="window.status='Date Picker';return true;"
onmouseout="window.status='';return true;">
<img src='/pentaho/js/show-calendar.gif' width=24 height=22 border=0>
</a>
</div>
</td>
</tr>
								<tr>
									<td align="right"><strong>Report</strong></td>
									<td width="60%" valign="top" style="padding-left: 9px">
					<!-- CJL Changed .xaction names -->
													<select name='action'>
														<option value='day_report.xaction'>By Day</option>
														<option value='adgroup_report.xaction'>By Ad Group</option>
														<option value='source_report.xaction'>By Ad Network</option>
														<option value='day_customer_facing_report.xaction'>By Day - Guaranteed Cost Per Click</option>
														<option value='adgroup_customer_facing_report.xaction'>By Ad Group - Guaranteed Cost Per Click</option>
														<option value='source_customer_facing_report.xaction'>By Ad Network - Guaranteed Cost Per Click</option>
													</select>
									</td>
								</tr>
								<tr>
									<td valign="top" style="padding-left: 9px" align="right"><strong>Report Output Format</strong></td>
									<td width="60%" valign="top" style="padding-left: 9px">
													<select name='outputType'>
														<option value='html'>HTML</option>
														<option value='pdf'>PDF</option>
														<option value='xls'>Excel</option>
													</select>
									</td>
								</tr>
								<tr>
									<td valign="top" style="padding-left: 9px" align="right"><input type="submit" name="sbm" value="CREATE REPORT" >  <input type="RESET" name="sbm" value="RESET" ></td>
									<td width="60%" valign="top" style="padding-left: 9px">&nbsp;</td>
								</tr>
				 	</tbody>
				 	</table>
					</form>
					

</body>



</html><!-- 1203874725 -->