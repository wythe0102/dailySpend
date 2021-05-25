<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
var dsDatagrid;
$(function(){
	$("#dailySpend_dailySpendList_typeId").combotree({
		parentField : 'pid',
		lines : true,
		multiple : true,
		url:"${pageContext.request.contextPath}/typeAction!tree.action",
		required: false
	});
	$("#dailySpend_dailySpendList_userName").combobox({   
  	    url:"${pageContext.request.contextPath}/userAction!combobox.action",   
  	    valueField:"id",   
  	    textField:"text",
  	   	panelHeight:"150"
	});
	
	dsDatagrid=$("#dailySpend_dailySpendList_dsListTable").datagrid({   
	    url:"${pageContext.request.contextPath}/dailySpendAction!datagrid.action",
	    animate:true,
	    loadMsg:"加载中。。。。",
		rownumbers:true,
		sortName:"date",
		sortOrder:"desc",
		fit:true,
		remoteSort:true,
	    fitColumns:true,
	    showFooter:true,
	    singleSelect: true,
	    pagination:true,
	    pageNumber:1,
	    pageSize:10,
	    pageList:[20,50,100,500],
	    onBeforeLoad:function(param){
	    	//从别处页面跳转过来时，把查询参数显示出来
	    	$("#dailySpend_dailySpendList_startDate").val(param.startDate)
	    	$("#dailySpend_dailySpendList_endDate").val(param.endDate)
	    },
	    columns:[[  
			{title:"日常消费Id",field:"spendDetailId",hidden:true},
			{title:"类别Id",field:"typeId",hidden:true},
			{title:"用户Id",field:"userId",hidden:true},
	        {title:"日期",field:"date",width:100,sortable:true,formatter:function(value,row,index){
	        	if(value=="" || value == undefined)
	        		return ""
	        	else
	        		return value.substr(0,10);
        	}},
	        {title:"类别名称",field:"typeName",width:100},  
	        {title:"金额",field:"amount",sortable:true,width:100,formatter:function(value,row,index){
	        	if(value>100)
	        	{
	        		return "<span style='color:red'>"+value+"</span>";
	        	}
	        	else
	        	{
	        		return value;
	        	}
	        }},   
	        {title:"备注",field:"demo",width:100},
	        {title:"消费人",field:"userName",width:100}
	    ]],
	    toolbar:[
		{
			text:"增加",
			iconCls:"icon-add",
			handler:function(){
				adddailySpend();
			}
		},"-",
		{
			text:"修改",
			iconCls:"icon-edit",
			handler:function(){
				var selectedRows = $("#dailySpend_dailySpendList_dsListTable").datagrid("getSelections");
	    	
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
					width : 550,
					height : 200,
					href : "${pageContext.request.contextPath}/dailySpend/editDailySpend.jsp",
					buttons : [ {
						text : "修改",
						handler : function() {
							parent.$.modalDialog.openner_datagrid = dsDatagrid;//因为添加成功之后，需要刷新这个dataGrid，所以先预定义好
							var f = parent.$.modalDialog.handler.find("#dailySpend_editDailySpend_form");
							f.submit();
						}
					} ],
					onLoad:function(){
						if(selectedRows[0]._parentId==''){
							selectedRows[0]._parentId=1;
						}
						$("#dailySpend_editDailySpend_form").form("load",{
							amount : selectedRows[0].amount,
							demo : selectedRows[0].demo,
							date : selectedRows[0].date.substr(0,10),
							spendDetailId : selectedRows[0].spendDetailId,
							userId : selectedRows[0].userId,
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
				var selectedRows = $("#dailySpend_dailySpendList_dsListTable").datagrid("getSelections");
				if(selectedRows.length==0)
				{
					$.messager.alert("提示","请选择要删除的行");
					return false;
				}
				var ids="";
				for(var i=0;i<selectedRows.length;i++){
					if(i!=(selectedRows.length-1))
						ids=ids+selectedRows[i].spendDetailId+",";
					else
						ids=ids+selectedRows[i].spendDetailId;
				}
				$.messager.confirm("确定", "确定要删除这些记录吗", function(r){
					if (r){
						$.messager.progress({
							title : "提示",
							text : "数据处理中，请稍后...."
						});	
						$.post("${pageContext.request.contextPath}/dailySpendAction!delete.action",{
							dailySpendIds : ids
						},function(result){
							$.messager.show({
								title:"消息",
								msg:result.msg,
								timeout:3000,
								showType:"fade"
							});
							$.messager.progress("close");
							dsDatagrid.datagrid("reload");
						},"json");
					}
				});
			}
		},"-",
		{
			text:"同步",
			iconCls:"icon-reload",
			handler:function(){
				sync();
			}
		},"-"
	]
	});  
	
	$("#dailySpend_dailySpendList_btnSearch").bind("click",function(){
		//取得类型id组成的字符串
		var idArray=$("#dailySpend_dailySpendList_typeId").combotree("getValues");
		var ids="";
		for(var i=0;i<idArray.length;i++){
			ids=ids+idArray[i]+",";
		}
		ids=ids.substring(0,ids.length-1);
		dsDatagrid.datagrid("load",{
			userId: $("#dailySpend_dailySpendList_userName").combotree("getValue"),
			typeId: ids,
			startDate: $("#dailySpend_dailySpendList_startDate").val(),
			endDate: $("#dailySpend_dailySpendList_endDate").val()
		});
	});
	$("#dailySpend_dailySpendList_btnClear").bind("click",function(){
			$("#dailySpend_dailySpendList_userName").combobox("clear");
			$("#dailySpend_dailySpendList_typeId").combotree("clear");
			$("#dailySpend_dailySpendList_startDate").val("");
			$("#dailySpend_dailySpendList_endDate").val("");
	});
});
function sync() {
    $.get("${pageContext.request.contextPath}/dailySpendAction!sync.action",function(result){
        $.messager.show({
            title:"消息",
            msg:"同步成功",
            timeout:3000,
            showType:"fade"
        });
        $.messager.progress("close");
    },"json");
}
function adddailySpend(){
	parent.$.modalDialog({
		title : "添加日常消费",
		width : 1150,
		height : 540,
		href : "${pageContext.request.contextPath}/dailySpend/addDailySpend.jsp",
		buttons : [ {
			text : "添加",
			handler : function() {
				parent.$.modalDialog.openner_datagrid = dsDatagrid;//因为添加成功之后，需要刷新这个dataGrid，所以先预定义好
				var f = parent.$.modalDialog.handler.find("#dailySpend_addDailySpend_form");
				f.submit();
			}
		} ]
	});
}
</script>
<div id="dailySpend_dailySpendList_dsListLayOut" class="easyui-layout" data-options="fit:true">    
    <div data-options="region:'north',title:'查询',border:false" style="height:60px">
		<table border="0">
		  	<tr>
		    <td nowrap>姓名：</td>
		    <td>
		      <input type="text" id="dailySpend_dailySpendList_userName">
		    </td>
		    <td nowrap>类别：</td>
		    <td>
		      <input type="text" id="dailySpend_dailySpendList_typeId">
		    </td>
               <td nowrap>开始时间：</td>
		    <td>
		    	<input type="text" id="dailySpend_dailySpendList_startDate" onClick="WdatePicker({dateFmt:'yyyy-MM-dd',onpicked:function(){$('#dailySpend_dailySpendList_endDate').val($(this).val());}})" readonly="true">
		    </td>
		    <td nowrap>结束时间：</td>
		    <td>
		    	<input type="text" id="dailySpend_dailySpendList_endDate" onClick="WdatePicker({dateFmt:'yyyy-MM-dd'})" readonly="true">
		    </td>
		    <td>
		      <a id="dailySpend_dailySpendList_btnSearch" class="easyui-linkbutton" data-options="iconCls:'icon-search'">查询</a>
		      <a id="dailySpend_dailySpendList_btnClear" class="easyui-linkbutton" data-options="iconCls:'icon-search'">清空条件</a>
		    </td>
		  </tr>
		</table>
	</div>
    <div data-options="region:'center'">
    	<table id="dailySpend_dailySpendList_dsListTable"></table>  
    </div>  
</div> 
