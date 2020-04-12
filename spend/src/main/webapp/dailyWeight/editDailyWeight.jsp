<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
$(function(){
	window.setTimeout(function() {
		parent.$.messager.progress("close");
		$("#dailyWeight_editDailyWeight_userId").combobox({   
	  	    url:"${pageContext.request.contextPath}/userAction!combobox.action",   
	  	    valueField:"id",   
	  	    textField:"text",
	  	    required:true,  
	  	   	panelHeight:"150"
		});
	    //设置重量格式
	   $("#dailyWeight_editDailyWeight_weightAmount").numberbox({precision:2});
	}, 1);
	$("#dailyWeight_editDailyWeight_form").form({
		url : "${pageContext.request.contextPath}/dailyWeightAction!editDailyWeight.action",
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
				parent.$.modalDialog.openner_datagrid.datagrid("reload");
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
		<form id="dailyWeight_editDailyWeight_form" method="post">
		  <table>
		    <tr>
		      <td nowrap="nowrap"><span class="itemMust">*</span>用户：</td>
		      <td>
		      <input name="userId" id="dailyWeight_editDailyWeight_userId" />
		      <input type="hidden" name="weightId" id="dailyWeight_editDailyWeight_weightId">
		      </td>
		    </tr>
		    <tr>
		      <td nowrap="nowrap">重量：</td>
		      <td nowrap="nowrap">
		        <input type="text" class="easyui-validatebox" data-options="required:true" name="weightAmount" id="dailyWeight_editDailyWeight_weightAmount" /></td>
	        </tr>
	      </table>
		</form>
	</div>
</div>
