<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="<%=basePath%>">
    
    <title>首页</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<!-- 导入easyui包 -->
	<script type="text/javascript" src="jslib/jquery-easyui-1.3.3/jquery-1.8.0.min.js"></script>
    <script type="text/javascript" src="jslib/jquery-easyui-1.3.3/jquery.easyui.min.js"></script>
   	<script type="text/javascript" src="jslib/jquery-easyui-1.3.3/locale/easyui-lang-zh_CN.js"></script>
 	<script type="text/javascript" src="jslib/jquery-easyui-1.3.3/jquery.easyui.validatebox.extend.js"></script>
    <script type="text/javascript" src="jslib/My97DatePicker/WdatePicker.js"></script>
    
    <link type="text/css" rel="stylesheet" href="jslib/jquery-easyui-1.3.3/themes/default/easyui.css"></link>
    <link rel="stylesheet" href="jslib/jquery-easyui-1.3.3/themes/icon.css" type="text/css"></link>
    
    <!-- 导入highCharts包 -->
    <script type="text/javascript" src="jslib/highCharts/highcharts.js"></script>
	<script type="text/javascript" src="jslib/highCharts/modules/exporting.js"></script>
	<!-- 自己扩展 -->
	<link rel="stylesheet" href="css/common.css" type="text/css"></link>
	<script type="text/javascript" src="jslib/extBrowser.js"></script>
	<script type="text/javascript" src="jslib/extEasyUI.js"></script>
	<script type="text/javascript" src="jslib/extJquery.js"></script>
	<script type="text/javascript" src="jslib/common.js"></script>
  <script type="text/javascript">
  	$(document).ready(function(){
		//加载中间tabs
		$("#centerTab").tabs({
			fit:true
		});
		$("#centerTab").tabs("add",{
			title: "日常记账",
			href: "dailySpend/dailySpendList.jsp",
			closable: false
		});
		//加载菜单树
		$("#menu").tree({  
		    url: "menu.json",
		    onClick:function(node){
		    	
		    	//取得节点的dom节点
		    	var dnode = $("#menu").tree("find",node.id);
		    	var clen=$("#menu").tree("getChildren",dnode.target).length;
		    	if(clen<=0)
		    	{
		    		openTab(node.text,node.attributes.url);
		    	}
		    	else//非叶子节点，点击后，展开或者收起
		    	{
		    		$("#menu").tree("toggle",dnode.target);
		    	}
		    }
		});  
	});
  	//打开tab页，写成函数是为了后面子页面也可以直接用到
	function openTab(title,url){
		if($("#centerTab").tabs("exists",title)){
			$("#centerTab").tabs("select",title);
		}
		else{
			$("#centerTab").tabs("add",{
				title: title,
				href:url,
				closable: true
			});
		}
	}
	function updateTab(title,url){
		if($("#centerTab").tabs("exists",title)){
			var allTabs = $("#centerTab").tabs("tabs");
			for(var i=0; i<allTabs.length; i++){
				if(allTabs[i].panel('options').title == title){
					$("#centerTab").tabs("select",title);
					allTabs[i].panel('refresh', url);
					
				}
			}
		} else {
			openTab(title,url);
		}
	}
  </script>
  </head>
  
  <body class="easyui-layout">
	<!--上-->
	<div data-options="region:'north',border:false" style="height:35px; font-size:24px; text-align:center; padding:3px; background:#A9FACD;">
		龙珊记账系统
	</div>
	<!--左-->
    <div data-options="region:'west',split:true,collapse:true,title:'菜单'" style="width:150px;">
    	<ul id="menu"></ul>
    </div>
	<!--右-->
    <!--<div data-options="region:'east',split:true,collapsed:true,title:'属性'" style="width:100px;padding:10px;">右</div>-->
	<!--下-->
    <div data-options="region:'south',border:false" style="height:20px;background:#A9FACD;padding:3px; text-align:center;">
    	Copyright @2013-2013 Hu Wei Corporation, All Rights Reserved
    </div>
	<!--中-->
    <div data-options="region:'center'">
    	<div id="centerTab"></div>
    </div>
	</body>
</html>
