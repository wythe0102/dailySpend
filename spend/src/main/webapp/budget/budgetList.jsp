<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
var bDatagrid;
$(function(){	
	bDatagrid=$("#budget_budgetList_bListTable").datagrid({   
	    url:"${pageContext.request.contextPath}/budgetAction!datagrid.action",
	    animate:true,
	    loadMsg:"加载中。。。。",
		rownumbers:true,
		sortName:"lastUpdate",
		sortOrder:"asc",
		fit:true,
		remoteSort:true,
	    fitColumns:true,
	    showFooter:true,
	    singleSelect: true,
	    pagination:true,
	    pageNumber:1,
	    pageSize:10,
	    pageList:[20,50,100,500],
	    columns:[[  
			{title:"自增长Id",field:"budgetId",hidden:true},
			{title:"类别Id",field:"typeId",hidden:true},
			{title:"用户Id",field:"userId",hidden:true},
	        {title:"开始时间",field:"startDate",width:100,sortable:true,formatter:function(value,row,index){
	        	if(value=="" || value == undefined)
	        		return ""
	        	else
	        		return value.substr(0,10);
        	}},
        	{title:"结束时间",field:"endDate",width:100,sortable:true,formatter:function(value,row,index){
	        	if(value=="" || value == undefined)
	        		return ""
	        	else
	        		return value.substr(0,10);
        	}},
	        {title:"类别名称",field:"typeName",width:100},  
	        {title:"预算金额",field:"budgetAmount",sortable:true,width:100},
	        {title:"实际金额",field:"realAmount",sortable:true,width:100,formatter:function(value,row,index){
	        	if(value=="" || value == undefined){
	        		return "0";
	        	}
	        	if(value>row.budgetAmount)
	        	{
	        		return "<a href=\"javascript:budgetOpenDailySpend('"+row.startDate.substr(0,10)+"','"+row.endDate.substr(0,10)+"','"+row.typeId+"');\"><span style='color:red'>"+value+"</span></a>";
	        	}
	        	else
	        	{
	        		return "<a href=\"javascript:budgetOpenDailySpend('"+row.startDate.substr(0,10)+"','"+row.endDate.substr(0,10)+"','"+row.typeId+"');\">"+value+"</a>";;
	        	}
	        }},
	        {title:"差额",field:"difference",sortable:true,width:100},
	        {title:"实际消费占百分比",field:"realPercent",sortable:true,width:100,formatter:function(value,row,index){
	        	if(value>100){
	        		return "<span style='color:red'>"+value+"%</span>";
	        	}else{
	        		return value+"%";
	        	}
	        }},
	        {title:"备注",field:"remarks",width:100}
	    ]],
	    toolbar:[
		{
			text:"增加",
			iconCls:"icon-add",
			handler:function(){
				addBudget();
			}
		},"-",
		{
			text:"修改",
			iconCls:"icon-edit",
			handler:function(){
				var selectedRows = $("#budget_budgetList_bListTable").datagrid("getSelections");
	    	
				if(selectedRows.length==0)
				{
					$.messager.alert("提示","请选择要编辑的行");
					return false;
				}
				if(selectedRows.length>1)
				{
					$.messager.alert("提示","只能选择一行");
					return false;
				}
				parent.$.modalDialog({
					title : "修改类别",
					width : 600,
					height : 180,
					href : "${pageContext.request.contextPath}/budget/editBudget.jsp",
					buttons : [ {
						text : "修改",
						handler : function() {
							parent.$.modalDialog.openner_datagrid = bDatagrid;//因为添加成功之后，需要刷新这个dataGrid，所以先预定义好
							var f = parent.$.modalDialog.handler.find("#budget_editBudget_form");
							f.submit();
						}
					} ],
					onLoad:function(){
						$("#budget_editBudget_form").form("load",{
							startDate : selectedRows[0].startDate.substr(0,10),
							endDate : selectedRows[0].endDate.substr(0,10),
							remarks : selectedRows[0].remarks,
							budgetAmount : selectedRows[0].budgetAmount,
							budgetId : selectedRows[0].budgetId,
							typeId : selectedRows[0].typeId
						});
					}
				});	
			}
		},"-",
		{
			text:"删除",
			iconCls:"icon-remove",
			handler:function(){
				var selectedRows = $("#budget_budgetList_bListTable").datagrid("getSelections");
				if(selectedRows.length==0)
				{
					$.messager.alert("提示","请选择要删除的行");
					return false;
				}
				$.messager.confirm("确定", "确定要删除这些记录吗", function(r){
					if (r){
						$.messager.progress({
							title : "提示",
							text : "数据处理中，请稍后...."
						});	
						$.post("${pageContext.request.contextPath}/budgetAction!deleteBudget.action",{
							budgetId : selectedRows[0].budgetId
						},function(result){
							$.messager.show({
								title:"消息",
								msg:result.msg,
								timeout:3000,
								showType:"fade"
							});
							$.messager.progress("close");
							bDatagrid.datagrid("reload");
						},"json");
					}
				});
			}
		},"-"
	]
	});  
	
	$("#budget_budgetList_btnSearch").bind("click",function(){
		bDatagrid.datagrid("load",{
			startDate: $("#budget_budgetList_startDate").val(),
			endDate: $("#budget_budgetList_endDate").val()
		});
	});
	$("#budget_budgetList_btnClear").bind("click",function(){
			$("#budget_budgetList_startDate").val("");
			$("#budget_budgetList_endDate").val("");
	});
});
function addBudget(){
	parent.$.modalDialog({
		title : "添加预算",
		width : 600,
		height : 180,
		href : "${pageContext.request.contextPath}/budget/addBudget.jsp",
		buttons : [ {
			text : "添加",
			handler : function() {
				parent.$.modalDialog.openner_datagrid = bDatagrid;//因为添加成功之后，需要刷新这个dataGrid，所以先预定义好
				var f = parent.$.modalDialog.handler.find("#budget_addBudget_form");
				f.submit();
			}
		} ]
	});
}
function budgetOpenDailySpend(sDate,eDate,tId){
	//因为日常记账已经固定了，所以不需要判断是否存在
	$("#centerTab").tabs("select","日常记账");
	$("#dailySpend_dailySpendList_dsListTable").datagrid("load",{
		startDate: sDate,
		endDate: eDate,
		typeId:tId
	});
}
</script>
<div id="budget_budgetList_dsListLayOut" class="easyui-layout" data-options="fit:true">    
    <div data-options="region:'north',title:'查询',border:false" style="height:60px">
		<table border="0">
		  	<tr>
               <td nowrap>开始时间：</td>
		    <td>
		    	<input type="text" id="budget_budgetList_startDate" onClick="WdatePicker({dateFmt:'yyyy-MM-dd',onpicked:function(){$('#budget_budgetList_endDate').val($(this).val());}})" readonly="true">
		    </td>
		    <td nowrap>结束时间：</td>
		    <td>
		    	<input type="text" id="budget_budgetList_endDate" onClick="WdatePicker({dateFmt:'yyyy-MM-dd'})" readonly="true">
		    </td>
		    <td>
		      <a id="budget_budgetList_btnSearch" class="easyui-linkbutton" data-options="iconCls:'icon-search'">查询</a>
		      <a id="budget_budgetList_btnClear" class="easyui-linkbutton" data-options="iconCls:'icon-search'">清空条件</a>
		    </td>
		  </tr>
		</table>
	</div>
    <div data-options="region:'center'">
    	<table id="budget_budgetList_bListTable"></table>  
    </div>  
</div> 
