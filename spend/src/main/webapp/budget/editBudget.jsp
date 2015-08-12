<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
$(function(){
	window.setTimeout(function() {
		parent.$.messager.progress("close");
	    //设置类型
    	$("#budget_editBudget_typeId").combotree({
    		parentField : 'pid',
    		lines : true,
    		url:"${pageContext.request.contextPath}/typeAction!tree.action",
    		required: true,
	  	    onSelect: function(node){
	  	    	var isLeaf = $(this).tree("isLeaf",node.target);
	  	    	if(!isLeaf){
	  	    		$.messager.alert("警告","只能选择最下级的类别","error");
	  	    		//找不到值为0的时候，会默认选择上次的值
	  	    		$(this).combotree("setValue", 0);
	  	    	}
	  	    }
    	});
	    //设置金额格式
	   $("#budget_editBudget_budgetAmount").numberbox({precision:2});
	}, 1);
	$("#budget_editBudget_form").form({
		url : "${pageContext.request.contextPath}/budgetAction!editBudget.action",
		onSubmit : function() {
			//验证结束日期不能小于开始日期
			if($("#budget_editBudget_endDate").val()<=$("#budget_editBudget_startDate").val()){
				$.messager.alert("警告","结束日期不能小于开始日期!","warning");
				return false;
			}
			parent.$.messager.progress({
				title : "提示",
				text : "数据处理中，请稍后...."
			});
			var isValid = $(this).form("validate");
			if (!isValid) {
				parent.$.messager.progress("close");
			}
			return isValid;
		},
		success : function(result) {
			parent.$.messager.progress("close");
			result = $.parseJSON(result);
			if (result.success) {
				parent.$.modalDialog.openner_datagrid.datagrid("reload",{
					
				});
				parent.$.modalDialog.handler.dialog("close");
			} else {
				parent.$.messager.alert("错误", result.msg, "error");
			}/**/
		}
	});
});
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;">
		<form id="budget_editBudget_form" method="post">
		  <table>
		    <tr>
		      <td nowrap="nowrap">开始时间：</td>
		      <td nowrap="nowrap">
	          <input type="text" class="easyui-validatebox" data-options="required:true" name="startDate" id="budget_editBudget_startDate" onClick="WdatePicker({dateFmt:'yyyy-MM-dd'})" readonly="true"/></td>
	          <input type="hidden" name="budgetId" id="budget_editBudget_budgetId"">
		      <td nowrap="nowrap">结束时间：</td>
		      <td nowrap="nowrap">
	          <input type="text" class="easyui-validatebox" data-options="required:true" name="endDate" id="budget_editBudget_endDate" onClick="WdatePicker({dateFmt:'yyyy-MM-dd'})" readonly="true"/></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap">
		        <input type="text" name="typeId" id="budget_editBudget_typeId" /></td>
		      <td nowrap="nowrap">预算金额：</td>
		      <td nowrap="nowrap">
		        <input type="text" class="easyui-validatebox" data-options="required:true" name="budgetAmount" id="budget_editBudget_budgetAmount" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">备注：</td>
		      <td colspan="3" nowrap="nowrap">
		        <input name="remarks" type="text" id="budget_editBudget_remarks" size="55" /></td>
	        </tr>
	      </table>
		</form>
	</div>
</div>
