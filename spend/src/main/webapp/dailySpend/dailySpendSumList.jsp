<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
var sumdatagrid;
$(function(){
	//默认设置开始日期和结束日期分别为当前月份的第一天和最后一天
	setDate();
	//datagrid默认加载当月的记账信息
	sumdatagrid=$("#dailySpend_dailySpendSumList_dsListTable").datagrid({   
	    url:"${pageContext.request.contextPath}/dailySpendAction!dataSumGrid.action",
	    animate:true,
	    loadMsg:"加载中。。。。",
		rownumbers:true,
		sortName:"date",
		sortOrder:"asc",
		fit:true,
		remoteSort:true,
	    fitColumns:true,
	    showFooter:true,
	    singleSelect: true,
	    pagination:true,
	    pageNumber:1,
	    pageSize:10,
	    pageList:[31,50,100,500,1000],
	    queryParams: {
	    	startDate: $("#dailySpend_dailySpendSumList_startDate").val(),
			endDate: $("#dailySpend_dailySpendSumList_endDate").val()
		},
	    columns:[[  
			{title:"日常消费Id",field:"spendDetailId",hidden:true},
	        {title:"日期",field:"date",width:100,sortable:true,formatter:function(value,row,index){
	        	if(value=="" || value == undefined)
	        		return "总计："
	        	else
	        		return "<a href=\"javascript:openDailySpend('"+value.substr(0,10)+"');\">"+value.substr(0,10)+"</a>";
        	}}, 
	        {title:"日汇总金额",field:"sumAmount",sortable:true,width:100,formatter:function(value,row,index){
	        	if(value>100)
	        	{
	        		return "<span style='color:red'>"+value+"</span>";
	        	}
	        	else
	        	{
	        		return value;
	        	}
	        }}
	    ]],
	    toolbar:[]
	});  
	$("#dailySpend_dailySpendSumList_btnSearch").bind("click",function(){
		sumdatagrid.datagrid("load",{
			startDate: $("#dailySpend_dailySpendSumList_startDate").val(),
			endDate: $("#dailySpend_dailySpendSumList_endDate").val()
		});
	});
	$("#dailySpend_dailySpendSumList_btnClear").bind("click",function(){
			$("#dailySpend_dailySpendSumList_startDate").val("");
			$("#dailySpend_dailySpendSumList_endDate").val("");
	});
});
function openDailySpend(value){
	//因为日常记账已经固定了，所以不需要判断是否存在
	$("#centerTab").tabs("select","日常记账");
	$("#dailySpend_dailySpendList_dsListTable").datagrid("load",{
		startDate: value,
		endDate: value
	});
}
function setDate(){
	var today=new Date();
	var year=today.getFullYear();
	var month=today.getMonth()+1;
	var lastDay=new Date(year,month,0).getDate();
	$("#dailySpend_dailySpendSumList_startDate").val(year+'-'+month+'-1');
	$("#dailySpend_dailySpendSumList_endDate").val(year+'-'+month+'-'+lastDay);
}
</script>
<div id="dailySpend_dailySpendSumList_dsListLayOut" class="easyui-layout" data-options="fit:true">    
    <div data-options="region:'north',title:'查询',border:false" style="height:60px">
		<table border="0">
		  	<tr>
		   	<td nowrap>开始时间：</td>
		    <td>
		    	<input type="text" id="dailySpend_dailySpendSumList_startDate" onClick="WdatePicker({dateFmt:'yyyy-MM-dd',onpicked:function(){$('#dailySpend_dailySpendSumList_endDate').val($(this).val());}})" readonly="true">
		    </td>
		    <td nowrap>结束时间：</td>
		    <td>
		    	<input type="text" id="dailySpend_dailySpendSumList_endDate" onClick="WdatePicker({dateFmt:'yyyy-MM-dd'})" readonly="true">
		    </td>
		    <td>
		      <a id="dailySpend_dailySpendSumList_btnSearch" class="easyui-linkbutton" data-options="iconCls:'icon-search'">查询</a>
		      <a id="dailySpend_dailySpendSumList_btnClear" class="easyui-linkbutton" data-options="iconCls:'icon-search'">清空条件</a>
		    </td>
		  </tr>
		</table>
	</div>
    <div data-options="region:'center'">
    	<table id="dailySpend_dailySpendSumList_dsListTable"></table>  
    </div>  
</div> 
