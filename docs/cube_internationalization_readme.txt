1.  Place the local_XX.properties files in the folder with the mondrian.xml schema.
2.  Update the mondrian.rolap.localePropFile= path value in the mondrian.properties file located at <pentaho_server>/pentaho-solutions/system/mondrian/ to the path for the properties files.  
	Windows example = D:\\pentaho\\pentaho-solutions\\breadboard\\analysis\\locale.properties
	Linux example = /pentaho/pentaho-solutions/breadboard/analysis/locale.properties
3.  Make a change to your pivot.jsp file, specifically ensure dynResolver and dynLocale are set in the jp:mondrianQuery tag.  For example:

<jp:mondrianQuery id="<%=queryId%>" dataSource="<%=dataSource%>"

dynResolver="mondrian.i18n.LocalizingDynamicSchemaProcessor"

dynLocale="<%= userSession.getLocale().toString() %>"

catalogUri="<%=catalogUri%>">

<%=query%>

</jp:mondrianQuery>