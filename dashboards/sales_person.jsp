<%@ taglib prefix='c' uri='http://java.sun.com/jstl/core' %>
<%@ taglib uri="http://java.sun.com/jstl/fmt" prefix="fmt" %>

<%@ 
	page language="java" 
	import="org.pentaho.platform.engine.core.system.PentahoSystem,
			org.pentaho.platform.api.engine.IPentahoSession,
			org.pentaho.platform.util.xml.XmlHelper,
			org.pentaho.platform.web.jsp.messages.Messages,
			org.pentaho.platform.web.http.WebTemplateHelper,
			org.pentaho.platform.api.engine.IUITemplater,
			org.pentaho.platform.util.messages.LocaleHelper,
			org.pentaho.platform.util.VersionHelper,
			org.pentaho.platform.api.ui.INavigationComponent,
			org.pentaho.platform.uifoundation.component.xml.NavigationComponent,
			org.pentaho.platform.uifoundation.component.HtmlComponent,
			org.pentaho.platform.util.web.SimpleUrlFactory,
			org.pentaho.platform.engine.core.solution.SimpleParameterProvider,
			org.pentaho.platform.uifoundation.chart.ChartHelper,org.pentaho.platform.web.http.PentahoHttpSessionHelper,org.pentaho.platform.engine.services.solution.SolutionHelper,
			org.dom4j.*,
			org.pentaho.platform.engine.services.actionsequence.ActionResource,
			org.pentaho.platform.api.engine.IActionSequenceResource,
			java.io.*,
			java.sql.Connection,
			java.sql.DriverManager,
			java.sql.SQLException,
			java.util.*" %>
			
<fmt:setBundle basename="sales_person_jsp"/>	
			
<%
 
	response.setCharacterEncoding(LocaleHelper.getSystemEncoding());
 	String baseUrl = PentahoSystem.getApplicationContext().getBaseUrl();
 
	String path = request.getContextPath();

	IPentahoSession userSession = PentahoHttpSessionHelper.getPentahoSession( request );

	String intro = "";
	String footer = "";
%>

<title>Eugenio Branco Sales Person Dashboard</title>

<!-- Replace the src value so it points to your client's logo/banner. -->
<!-- include file="navBarTopSimple.html"  -->

	<%= intro %>
	<center>
	
	</center>

<%
    ResourceBundle rb = ResourceBundle.getBundle("sales_person_jsp",request.getLocale());
    String vendedor ;
    String mes1;
	String ano1;
	String sale;
    
   if (request.getParameter("vendedor")==null) {
		vendedor="Children";
		
	} else {
		vendedor=request.getParameter("vendedor");
	}
	if (request.getParameter("ano")==null) {
		ano1="2006";
	} else {
		ano1=request.getParameter("ano");
	}
	if (request.getParameter("num_mes")==null)  {
		mes1="Children";
		
	} else {
		mes1=request.getParameter("num_mes");
	}
	if (request.getParameter("sale")==null)  {
		sale="Sale Revenue";
		
	} else {
		sale=request.getParameter("sale");
	}
	
	//ComboBox para listar vendedores
	
	SimpleParameterProvider parameters4 = new SimpleParameterProvider();
	ArrayList messages4 = new ArrayList();
   	
    org.pentaho.core.connection.IPentahoResultSet listar_vendedor=null;
    String optionsSelect="";
    String optionsSelect1="";
    String optionsSelect2="";
    
    org.pentaho.platform.api.engine.IRuntimeContext context4=SolutionHelper.doAction("breadboard", "customer_360/sales_order_capture/dashboards/Sales_Person", "listarVendedores.xaction", "breadboard", parameters4, userSession, messages4, null);
    String numero_vendedor="";
    String nome_vendedor="";
    
   try{
  	
  	
  	listar_vendedor=context4.getOutputParameter("vendedores").getValueAsResultSet();
  	Object totalVendedores[]=null;
  	if( totalVendedores!=null && totalVendedores.length>0 && totalVendedores[0]!=null && totalVendedores[1]!=null ){
	  	numero_vendedor=(String)totalVendedores[0];
	  	nome_vendedor=(String)totalVendedores[1];	
	  }
   Object linha[];
   optionsSelect=optionsSelect+"<option "+ (vendedor.equals(nome_vendedor)?"selected='true'":"") +"value=Children>"+rb.getString("All_Sellers")+"" + "</option>";
    while ((linha=listar_vendedor.next())!=null) {
    	String codigo="" +linha[1];
    	String nome="" +linha[0];
   	    //System.out.println("codigo " + codigo + " vendedor " +nome );
    	optionsSelect=optionsSelect+"<option "+ (vendedor.equals(codigo)?"selected='true'":"") + " value='"+codigo+"'>"+ linha[0] + "</option>";
   	}
    
   
    }finally{
    	if(listar_vendedor!=null) listar_vendedor.closeConnection();
    }
    
    	
    //ComboBox para listar ano
    
	SimpleParameterProvider parameters5 = new SimpleParameterProvider();
	parameters5.setParameter("vendedor", vendedor);
	ArrayList messages5 = new ArrayList();
   	
    org.pentaho.core.connection.IPentahoResultSet listar_mes_ano=null;
    
    org.pentaho.platform.api.engine.IRuntimeContext context5=SolutionHelper.doAction("breadboard", "customer_360/sales_order_capture/dashboards/Sales_Person", "vendedorAnosDisponiveis.xaction", "breadboard", parameters5, userSession, messages5, null);
    String ano="";
    try{
   	listar_mes_ano=context5.getOutputParameter("anos_disponiveis").getValueAsResultSet();
  	Object total_mes_ano[]=null;
  	if( total_mes_ano!=null && total_mes_ano.length>0 && total_mes_ano[0]!=null ){
	  	ano=(String)total_mes_ano[0];
	  	}
	 Object linha1[];
	 while ((linha1=listar_mes_ano.next())!=null) {
    	ano="" + linha1[0];
    	optionsSelect1=optionsSelect1+"<option "+(ano1.equals(ano)?"selected='true'":"") +" value='"+ano+"'>"+ linha1[0] + "</option>";
    }
    }finally{
    	if(listar_mes_ano!=null) listar_mes_ano.closeConnection();
   	}
    
    	
   
    	

    
    
    

	String pie1 = "";
	String pie2 = "";
	String chart = "";
	String chart1="";
	String chart2="";
	
	
	
	
	
	//formatação do parametro periodo actual e periodo anterior
	
	
	int ano_ant=(Integer.parseInt(ano1)-1);
	String periodo_actual, periodo_anterior;
	String children="Children";
	if (mes1.equals(children)){
		periodo_actual= "["+ano1+"]";
		periodo_anterior="["+ano_ant+"]";
		
		}
	else{
		periodo_actual= "["+ano1+"].["+mes1+"]";
		periodo_anterior="["+ano_ant+"].["+mes1+"]";
		}
	
	
	
	// Grafico Vendas Cidade
	
	SimpleParameterProvider parameters = new SimpleParameterProvider();
	parameters.setParameter( "outputType", "html");
	parameters.setParameter("vendedor", vendedor);
	parameters.setParameter("periodo_actual",periodo_actual);
	parameters.setParameter("sale", sale);
	parameters.setParameter("mes", mes1);
	ArrayList messages = new ArrayList();
	ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
	SolutionHelper.doAction( "breadboard", "customer_360/sales_order_capture/dashboards/Sales_Person", "vendasZonaPie.xaction","breadboard", parameters, outputStream, userSession, messages, null );
	
	pie1 = outputStream.toString();
	
	
	
    // Grafico Top 10 Clientes - Ano actual / Ano anterior
    
	SimpleParameterProvider parameters1 = new SimpleParameterProvider();
	parameters1.setParameter( "outputType", "html");
	parameters1.setParameter("vendedor", vendedor);
	parameters1.setParameter("periodo_actual",periodo_actual);
	parameters1.setParameter("periodo_ant",periodo_anterior);
	parameters1.setParameter("sale", sale);
	parameters1.setParameter("mes", mes1);
	ArrayList messages1 = new ArrayList();
	outputStream = new ByteArrayOutputStream();
	SolutionHelper.doAction( "breadboard", "customer_360/sales_order_capture/dashboards/Sales_Person", "top10_clientes.xaction","breadboard", parameters1, outputStream, userSession, messages1, null );
	
	chart = outputStream.toString();
	
	
	
	// Grafico Top 10 Produtos - Ano actual / Ano anterior
	
	SimpleParameterProvider parameters2 = new SimpleParameterProvider();
	parameters2.setParameter( "outputType", "html");
	parameters2.setParameter( "vendedor", vendedor );
	parameters2.setParameter( "periodo_actual", periodo_actual);	
	parameters2.setParameter("periodo_ant",periodo_anterior);
	parameters2.setParameter("sale", sale);
	parameters2.setParameter("mes", mes1);
	ArrayList messages2 = new ArrayList();
	outputStream = new ByteArrayOutputStream();
	SolutionHelper.doAction( "breadboard", "customer_360/sales_order_capture/dashboards/Sales_Person", "top10_produtos.xaction","breadboard", parameters2, outputStream, userSession, messages2, null );
	
	chart1 = outputStream.toString();
	
	
	
	// Grafico Vendas Mes - Ano actual / Ano anterior
	
	SimpleParameterProvider parameters3 = new SimpleParameterProvider();
	parameters3.setParameter( "outputType", "html");
	parameters3.setParameter( "vendedor", vendedor );
	parameters3.setParameter( "ano_actual", ano1 );	
	parameters3.setParameter("ano_antes", ano_ant);
	parameters3.setParameter("mes", mes1);
	parameters3.setParameter("sale", sale);
	ArrayList messages3 = new ArrayList();
	outputStream = new ByteArrayOutputStream();
	SolutionHelper.doAction( "breadboard", "customer_360/sales_order_capture/dashboards/Sales_Person", "GraficoLinhasVendasMes.xaction","breadboard", parameters3, outputStream, userSession, messages3, null );
 	
	chart2 = outputStream.toString();
	
	
	
	// Grafico Familia Produto
	 
	SimpleParameterProvider parameters7 = new SimpleParameterProvider();
	parameters7.setParameter( "outputType", "html");
	parameters7.setParameter("vendedor", vendedor);
	parameters7.setParameter("periodo_actual",periodo_actual);
	parameters7.setParameter("sale", sale);
	parameters7.setParameter("mes", mes1);
	ArrayList messages7 = new ArrayList();
	outputStream = new ByteArrayOutputStream();
	SolutionHelper.doAction( "breadboard", "customer_360/sales_order_capture/dashboards/Sales_Person", "ListarBrandProduto.xaction","breadboard", parameters7, outputStream, userSession, messages7, null );
	
	pie2 = outputStream.toString();
	
%>

	<center>		
			<table style="width:1000" border="0">
			<tr>
				<!-- td>
					
				</td -->
				<td colspan='2' class='content_pagehead'>
					
				</td>
			</tr>
		</table>
	

  	        
		<h2><fmt:message key="Sales_Person"/> <h2>
		 <form method="GET" ACTION="sales_person.jsp" name="dados">
	        
	         <select name="vendedor" onchange="javascript: document.forms['dados'].submit()">
	         <%=optionsSelect%>
	         </select>
           
           
	         <select name="ano"  onchange="javascript: document.forms['dados'].submit()">
	            <%=optionsSelect1%>
	         </select>
      
          	
	         <select name="num_mes" onchange="javascript: document.forms['dados'].submit()">
	            <option <%= (mes1.equals("Children")?"selected='true'":"") %> value="Children" SELECTED style="font-weight: bold"><%=rb.getString("All_Months") %> </option>
	            <option value="Children">----------------------------------</option>
	            <option <%= mes1.equals("Q1")?"selected='true'":""%> value="Q1" style="font-weight: bold"><fmt:message key="First_Quarter"/></option>
	            <option <%= mes1.equals("January")?"selected='true'":""%> value="January" ><fmt:message key="January"/>
	            <option <%= mes1.equals("February")?"selected='true'":""%> value="February" ><fmt:message key="February"/>
	            <option <%= mes1.equals("March")?"selected='true'":""%> value="March" ><fmt:message key="March"/>
	            <option value="Children">----------------------------------</option>
	            <option <%= mes1.equals("Q2")?"selected='true'":""%> value="Q2" style="font-weight: bold" ><fmt:message key="Second_Quarter"/>
	            <option <%= mes1.equals("April")?"selected='true'":""%> value="April" ><fmt:message key="April"/>
	            <option <%= mes1.equals("May")?"selected='true'":""%> value="May" ><fmt:message key="May"/>
	            <option <%= mes1.equals("June")?"selected='true'":""%> value="June" ><fmt:message key="June"/>
	            <option value="Children">----------------------------------</option>
	            <option <%= mes1.equals("Q3")?"selected='true'":""%> value="Q3" style="font-weight: bold"><fmt:message key="Third_Quarter"/>
	            <option <%= mes1.equals("July")?"selected='true'":""%> value="July" ><fmt:message key="July"/>
	            <option <%= mes1.equals("August")?"selected='true'":""%> value="August" ><fmt:message key="August"/>
	            <option <%= mes1.equals("Setember")?"selected='true'":""%> value="Setember" ><fmt:message key="Setember"/>
	            <option value="Children">----------------------------------</option>
	            <option <%= mes1.equals("Q4")?"selected='true'":""%> value="Q4" style="font-weight: bold" ><fmt:message key="Fourth_Quarter"/>
	            <option <%= mes1.equals("October")?"selected='true'":""%> value="October" ><fmt:message key="October"/>
	            <option <%= mes1.equals("November")?"selected='true'":""%> value="November" ><fmt:message key="November"/>
	            <option <%= mes1.equals("December")?"selected='true'":""%> value="December" ><fmt:message key="December"/>   
	         </select>
	         
	         <select name="sale" onchange="javascript: document.forms['dados'].submit()">
               <option <%= sale.equals("Sale Revenue")?"selected='true'":""%> value="Sale Revenue" ><fmt:message key="Sale_Revenue"/>
               <option <%= sale.equals("Sale Quantity")?"selected='true'":""%> value="Sale Quantity" ><fmt:message key="Sale_Quantity"/>
              </select>

	         
	         
           </form>
         
     <table style="text-align: left; border:1px solid FFFFFF" celpadding="0" cellspacing="0" border="0" >
		<tr>
			<td valign="top" align="center">
				<%= chart2 %>
			</td>
			 
			<td valign="top" align="center">
				<%= chart %>
			</td>
	   </tr>
	   
	</table>
	<br>
    <table style="text-align: left; border:1px solid #FFFFFF" celpadding="0" cellspacing="0" border="0"  >
	<tr>			
			<td valign="top" align="center"> 
				<%= pie2 %>
			</td>
			
			<td valign="top" align="center"> 
				<%= chart1 %>
			</td>
	</tr>
	</table>
    </center>
    <table style="text-align: left; border:1px solid #FFFFFF" celpadding="0" cellspacing="0" border="0" WIDTH=48% >
			
			<td valign="top" align="right"> 
			<%= pie1 %>
			</td>
		
	
	</table>

	
  
  
	<%= footer %>