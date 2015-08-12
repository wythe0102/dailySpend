<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
$(function(){
	$("#type_editType_parent").combotree({
		parentField : 'pid',
		lines : true,
		url:"${pageContext.request.contextPath}/typeAction!tree.action",
		required:true,
		onLoadSuccess:function(){
			parent.$.messager.progress("close");
		}
	});
	$("#type_editType_form").form({
		url : "${pageContext.request.contextPath}/typeAction!editType.action",
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
			result = $.parseJSON(result);
			if (result.success) {
				parent.$.modalDialog.openner_treegrid.treegrid("reload");//之所以能在这里调用到parent.$.modalDialog.openner_dataGrid这个对象，是因为user.jsp页面预定义好了
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
		<form id="type_editType_form" method="post">
		  <table>
		    <tr>
		      <td noWrap><span class="itemMust">*</span>类别名称：</td>
		      <td>
		      	<input type="text" name="name" id="type_editType_name" class="easyui-validatebox" data-options="required:true"/>
		      	<input type="hidden" name="typeId">
		      </td>
	        </tr>
		    <tr>
		      <td noWrap>类别编码：</td>
		      <td><input type="text" name="code" id="type_editType_code" data-options="required:true"/></td>
	        </tr>
		    <tr>
		      <td noWrap><span class="itemMust">*</span>上级类别</td>
		      <td><input name="_parentId" id="type_editType_parent"></td>
	        </tr>
	      </table>
		</form>
	</div>
</div>
