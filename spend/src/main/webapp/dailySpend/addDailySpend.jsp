<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
$(function(){
	window.setTimeout(function() {
		parent.$.messager.progress("close");
		//设置日期默认为今天
		$("input[name='dates']").each(function(i){
			$(this).click(function(){
				WdatePicker({dateFmt:'yyyy-MM-dd'});
			});
			$(this).attr("readonly","readonly"); 
			$(this).val(new Date().format("yyyy-MM-dd"));
		});
		//设置用户
		$("input[name='userIds']").each(function(i){
			$(this).combobox({   
		  	    url:"${pageContext.request.contextPath}/userAction!combobox.action",   
		  	    valueField:"id",   
		  	    textField:"text",
		  	   	panelHeight:"150",
		  	  	width:"70",
		  	  	onSelect: function(record){
		  	  		countTotal();
		  	  	}
			});
			
			if(i>=0 && i<=2)
			{
				$(this).combobox("select","2");
			}
			if(i>=3 && i<=5)
			{
				$(this).combobox("select","1");
			}
			if(i>=6 && i<=8){
				$(this).combobox("select","3");
			}
		});
	    //设置类型
	    $("input[name='typeIds']").each(function(i){
	    	$(this).combotree({
	    		parentField : 'pid',
	    		lines : true,
	    		url:"${pageContext.request.contextPath}/typeAction!tree.action",
	    		required: false,
	    		onChange: function(newValue, oldValue){
		  	  		countTotal();
		  	  	},
		  	    onSelect: function(node){
		  	    	var isLeaf = $(this).tree("isLeaf",node.target);
		  	    	if(!isLeaf){
		  	    		$.messager.alert("警告","只能选择最下级的类别","error");
		  	    		//找不到值为0的时候，会默认选择上次的值
		  	    		$(this).combotree("setValue", 0);
		  	    	}
		  	    }
	    	});
	    	switch (i)
	    	{
	    		case 0: $(this).combotree("setValue", 22);break;//早饭
	    		case 1: $(this).combotree("setValue", 23);break;//午饭
	    		case 2: $(this).combotree("setValue", 24);break;//晚饭
	    		case 3: $(this).combotree("setValue", 22);break;//早饭
	    		case 4: $(this).combotree("setValue", 23);break;//午饭
	    		case 5: $(this).combotree("setValue", 24);break;//晚饭
	    		case 6: $(this).combotree("setValue", 22);break;//早饭
	    		case 7: $(this).combotree("setValue", 23);break;//午饭
	    		case 8: $(this).combotree("setValue", 24);break;//晚饭
	    		default:
	    	}
	    });
	    //设置金额格式
	    $("input[name='amounts']").each(function(i){
	    	//$(this).width(80);
	    	$(this).numberbox({precision:2,
	    		onChange : function(newValue,oldValue){
	    			countTotal();
	    		}
	    	});  
	    });
	    //设置备注
	    $("input[name='demos']").each(function(i){
	    	$(this).width(200);
	    });
		//设置总金额
		$("#totalAmount").numberbox({precision:2});
		//为了补上以前的记账信息所需要的东西
		$("#oldDate").click(function(){
			WdatePicker({dateFmt:'yyyy-MM-dd',
						onpicked:function(){
							$("input[name='dates']").each(function(i){
								$(this).val($("#oldDate").val());
							});
						}});
		});
	}, 1);
	$("#dailySpend_addDailySpend_form").form({
		url : "${pageContext.request.contextPath}/dailySpendAction!addDailySpend.action",
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
			
			console.log(result);
			result = $.parseJSON(result);
			if (result.success) {
				parent.$.modalDialog.openner_datagrid.datagrid("reload",{
					startDate: $($("input[name='dates']")[0]).val(),
					endDate: $($("input[name='dates']")[0]).val()
				});//之所以能在这里调用到parent.$.modalDialog.openner_dataGrid这个对象，是因为user.jsp页面预定义好了
				parent.$.modalDialog.handler.dialog("close");
			} else {
				parent.$.messager.alert("错误", result.msg, "error");
			}/**/
		}
	});
});
function countTotal(){
	var count=0.0;
	 $("input[name='amounts']").each(function(i){
		//只有选择了用户和类别后的金额才是有意义的
		if($($("input[name='typeIds']")[i]).val()!='' && $($("input[name='userIds']")[i]).val()!='' && $(this).val()!=''){
			count = parseFloat(count) + parseFloat($(this).val());
			$("#totalAmount").numberbox("setValue",count);
		}
	 });
}
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;">
		<form id="dailySpend_addDailySpend_form" method="post">
		  <table width="100%">
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
	          <input type="text" name="dates" id="dates"/></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
	          <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
	          <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
	          <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
	          <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap">日期：</td>
		      <td nowrap="nowrap"><label for="date"></label>
		        <input type="text" name="dates" id="dates" /></td>
		      <td nowrap="nowrap">姓名：</td>
		      <td nowrap="nowrap"><label for="userId"></label>
		        <input type="text" name="userIds" id="userIds" /></td>
		      <td nowrap="nowrap">类别：</td>
		      <td nowrap="nowrap"><label for="typeId"></label>
		        <input type="text" name="typeIds" id="typeIds" /></td>
		      <td nowrap="nowrap">金额：</td>
		      <td nowrap="nowrap"><label for="amount"></label>
		        <input type="text" name="amounts" id="amounts" /></td>
		      <td nowrap="nowrap">备注：</td>
		      <td nowrap="nowrap"><label for="demo"></label>
		        <input type="text" name="demos" id="demos" /></td>
	        </tr>
		    <tr>
		      <td nowrap="nowrap"></td>
		      <td nowrap="nowrap"><input type="text" id="oldDate"/></td>
		      <td nowrap="nowrap"></td>
		      <td nowrap="nowrap"></td>
		      <td nowrap="nowrap"></td>
		      <td nowrap="nowrap"></td>
		      <td nowrap="nowrap">总计：</td>
		      <td nowrap="nowrap"><input type="text" id="totalAmount" /></td>
		      <td nowrap="nowrap"></td>
		      <td nowrap="nowrap"></td>
	        </tr>
	      </table>
		</form>
	</div>
</div>
