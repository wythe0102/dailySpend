<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
var dwDatagrid;
$(function(){	
	dwDatagrid=$("#dailyWeight_dailyWeightList_dwListTable").datagrid({   
	    url:"${pageContext.request.contextPath}/dailyWeightAction!datagrid.action",
	    animate:true,
	    loadMsg:"加载中。。。。",
		rownumbers:true,
		sortName:"time",
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
			{title:"自增长Id",field:"weightId",hidden:true},
			{title:"用户Id",field:"userId",hidden:true},
	        {title:"人名",field:"userName",width:100,sortable:true},
	        {title:"重量",field:"weightAmount",width:100,sortable:true},
	        {title:"时间",field:"time",width:100,sortable:true}
	    ]],
	    toolbar:[
		{
			text:"增加",
			iconCls:"icon-add",
			handler:function(){
				addDailyWeight();
			}
		},"-",
		{
			text:"修改",
			iconCls:"icon-edit",
			handler:function(){
				var selectedRows = $("#dailyWeight_dailyWeightList_dwListTable").datagrid("getSelections");
	    	
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
					width : 280,
					height : 170,
					href : "${pageContext.request.contextPath}/dailyWeight/editDailyWeight.jsp",
					buttons : [ {
						text : "修改",
						handler : function() {
							parent.$.modalDialog.openner_datagrid = dwDatagrid;//因为添加成功之后，需要刷新这个dataGrid，所以先预定义好
							var f = parent.$.modalDialog.handler.find("#dailyWeight_editDailyWeight_form");
							f.submit();
						}
					} ],
					onLoad:function(){
						$("#dailyWeight_editDailyWeight_form").form("load",{
							userId : selectedRows[0].userId,
							weightAmount : selectedRows[0].weightAmount,
							weightId : selectedRows[0].weightId
						});
					}
				});	
			}
		},"-",
		{
			text:"删除",
			iconCls:"icon-remove",
			handler:function(){
				var selectedRows = $("#dailyWeight_dailyWeightList_dwListTable").datagrid("getSelections");
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
						$.post("${pageContext.request.contextPath}/dailyWeightAction!deleteDailyWeight.action",{
							weightId : selectedRows[0].weightId
						},function(result){
							$.messager.show({
								title:"消息",
								msg:result.msg,
								timeout:3000,
								showType:"fade"
							});
							$.messager.progress("close");
							dwDatagrid.datagrid("reload");
						},"json");
					}
				});
			}
		},"-"
	]
	});  
	
	$("#dailyWeight_dailyWeightList_btnSearch").bind("click",function(){
		dwDatagrid.datagrid("load",{
			startDate: $("#dailyWeight_dailyWeightList_startDate").val(),
			endDate: $("#dailyWeight_dailyWeightList_endDate").val()
		});
	});
	$("#dailyWeight_dailyWeightList_btnClear").bind("click",function(){
			$("#dailyWeight_dailyWeightList_startDate").val("");
			$("#dailyWeight_dailyWeightList_endDate").val("");
	});
});
function addDailyWeight(){
	parent.$.modalDialog({
		title : "添加日常消费",
		width : 280,
		height : 170,
		href : "${pageContext.request.contextPath}/dailyWeight/addDailyWeight.jsp",
		buttons : [ {
			text : "添加",
			handler : function() {
				parent.$.modalDialog.openner_datagrid = dwDatagrid;//因为添加成功之后，需要刷新这个dataGrid，所以先预定义好
				var f = parent.$.modalDialog.handler.find("#dailyWeight_addDailyWeight_form");
				f.submit();
			}
		} ]
	});
}
function dailyWeightOpenDailySpend(sDate,eDate,tId){
	//因为日常记账已经固定了，所以不需要判断是否存在
	$("#centerTab").tabs("select","日常记账");
	$("#dailySpend_dailySpendList_dsListTable").datagrid("load",{
		startDate: sDate,
		endDate: eDate,
		typeId:tId
	});
}
</script>
<div id="dailyWeight_dailyWeightList_dsListLayOut" class="easyui-layout" data-options="fit:true">    
    <div data-options="region:'north',title:'查询',border:false" style="height:60px">
		<table border="0">
		  	<tr>
               <td nowrap>开始时间：</td>
		    <td>
		    	<input type="text" id="dailyWeight_dailyWeightList_startDate" onClick="WdatePicker({dateFmt:'yyyy-MM-dd',onpicked:function(){$('#dailyWeight_dailyWeightList_endDate').val($(this).val());}})" readonly="true">
		    </td>
		    <td nowrap>结束时间：</td>
		    <td>
		    	<input type="text" id="dailyWeight_dailyWeightList_endDate" onClick="WdatePicker({dateFmt:'yyyy-MM-dd'})" readonly="true">
		    </td>
		    <td>
		      <a id="dailyWeight_dailyWeightList_btnSearch" class="easyui-linkbutton" data-options="iconCls:'icon-search'">查询</a>
		      <a id="dailyWeight_dailyWeightList_btnClear" class="easyui-linkbutton" data-options="iconCls:'icon-search'">清空条件</a>
		    </td>
		  </tr>
		</table>
	</div>
    <div data-options="region:'center'">
    	<table id="dailyWeight_dailyWeightList_dwListTable"></table>  
    </div>  
</div> 
