<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
var treegrid;
$(function(){
	treegrid=$("#type_typeList_typeListTable").treegrid({   
	    url:"${pageContext.request.contextPath}/typeAction!treegrid.action",   
	    idField:"typeId",   
	    animate:true,
	    treeField:"name",
	    loadMsg:"加载中。。。。",
		rownumbers:true,
		sortName:"typeId",
		sortOrder:"asc",
		fit:true,
		remoteSort:false,
	    fitColumns:true,
	    columns:[[  
			{title:"类别名称",field:"typeId",hidden:true},
	        {title:"类别名称",field:"name",width:100},   
	        {title:"类别编码",field:"code",width:100},   
	        {title:"添加时间",field:"addDate",width:100},
	        {title:"_parentId",field:"_parentId",hidden:true}
	    ]],
	    toolbar:[
		{
			text:"增加",
			iconCls:"icon-add",
			handler:function(){
				addType();
			}
		},"-",
		{
			text:"修改",
			iconCls:"icon-edit",
			handler:function(){
				var selectedRows = $("#type_typeList_typeListTable").treegrid("getSelections");
	    	
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
					width : 300,
					height : 200,
					href : "${pageContext.request.contextPath}/type/editType.jsp",
					buttons : [ {
						text : "修改",
						handler : function() {
							parent.$.modalDialog.openner_treegrid = treegrid;//因为添加成功之后，需要刷新这个dataGrid，所以先预定义好
							var f = parent.$.modalDialog.handler.find("#type_editType_form");
							f.submit();
						}
					} ],
					onLoad:function(){
						if(selectedRows[0]._parentId==''){
							selectedRows[0]._parentId=1;
						}
						$("#type_editType_form").form("load",{
							name:selectedRows[0].name,
							typeId:selectedRows[0].typeId,
							code:selectedRows[0].code,
							_parentId:selectedRows[0]._parentId
						});
					}
				});	
			}
		},"-",
		{
			text:"删除",
			iconCls:"icon-remove",
			handler:function(){
				var selectedRows = $("#type_typeList_typeListTable").treegrid("getSelections");
	    	
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
						$.post("${pageContext.request.contextPath}/typeAction!delete.action",{
							typeId : selectedRows[0].typeId
						},function(){
							$.messager.progress("close");
							treegrid.treegrid("reload");
						},"json");
					}
				});
			}
		},"-"
	]
	});  
});
function addType(){
	parent.$.modalDialog({
		title : "添加类别",
		width : 300,
		height : 200,
		href : "${pageContext.request.contextPath}/type/addType.jsp",
		buttons : [ {
			text : "添加",
			handler : function() {
				parent.$.modalDialog.openner_treegrid = treegrid;//因为添加成功之后，需要刷新这个dataGrid，所以先预定义好
				var f = parent.$.modalDialog.handler.find("#type_addType_form");
				f.submit();
			}
		} ]
	});
}
</script>
<div id="type_typeList_typeListLayOut" class="easyui-layout" data-options="fit:true">    
    <div data-options="region:'center',title:'类别列表'">
    	<table id="type_typeList_typeListTable"></table>  
    </div>  
</div> 
