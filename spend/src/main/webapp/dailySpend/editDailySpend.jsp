<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
$(function(){
	window.setTimeout(function() {
		$("#dailySpend_editDailySpend_userId").combobox({   
	  	    url:"${pageContext.request.contextPath}/userAction!combobox.action",   
	  	    valueField:"id",   
	  	    textField:"text",
	  	    required:true,  
	  	   	panelHeight:"150"
		});
		$("#dailySpend_editDailySpend_typeId").combotree({
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
		parent.$.messager.progress("close");
	}, 1);
	$("#dailySpend_editDailySpend_form").form({
		url : "${pageContext.request.contextPath}/dailySpendAction!editDailySpend.action",
		onSubmit : function() {
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
			result = result.replace(/<audio.+audio>/, "");//升级chrome后，会在返回的结果后加上<audio controls="controls" style="display: none;"></audio>
			result = $.parseJSON(result);
			if (result.success) {
				parent.$.modalDialog.openner_datagrid.datagrid("reload");//之所以能在这里调用到parent.$.modalDialog.openner_dataGrid这个对象，是因为user.jsp页面预定义好了
				parent.$.modalDialog.handler.dialog("close");
			} else {
				alert('sd');
				parent.$.messager.alert("错误", result.msg, "error");
			}
		}
	});
});
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;">
		<form id="dailySpend_editDailySpend_form" method="post">
		<input type="hidden" name="spendDetailId">
		  <table>
		    <tr>
		      <td nowrap="nowrap"><span class="itemMust">*</span>用户：</td>
		      <td><input name="userId" id="dailySpend_editDailySpend_userId" /></td>
		      <td nowrap="nowrap"><span class="itemMust">*</span>类别：</td>
		      <td><input name="typeId" id="dailySpend_editDailySpend_typeId" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap"><span class="itemMust">*</span>日期：</td>
		      <td><input type="text" name="date" id="dailySpend_editDailySpend_date" onClick="WdatePicker({dateFmt:'yyyy-MM-dd'})" readonly="true" class="easyui-validatebox" data-options="required:true"/></td>
		      <td nowrap="nowrap"><span class="itemMust">*</span>金额：</td>
		      <td><input name="amount" id="dailySpend_editDailySpend_amount" class="easyui-validatebox" data-options="required:true" /></td>
	        </tr>
		    <tr>
		      <td noWrap>备注：</td>
		      <td colspan="3"><input name="demo" id="dailySpend_editDailySpend_demo" size="54" /></td>
	        </tr>
	      </table>
		</form>
	</div>
</div>
