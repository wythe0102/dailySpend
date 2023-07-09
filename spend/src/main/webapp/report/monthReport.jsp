<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
$(function() {
	window.setTimeout(function() {
		var today=new Date();
		//先判断是否有传过来的参数，没有的话，显示当前月份
		var year = '${param.year}';
		var month = '${param.month}';
		if(year == ""){
			year=today.getFullYear();
			month = new Date().getMonth()+1;
		}
		$("#report_monthReport_year").combobox("setValue",year);
		$.ajax({
			type : "post",//使用get方法访问后台
			url : "${pageContext.request.contextPath}/dailySpendAction!dataLineCharts.action",//要访问的后台地址
			dataType:"json",
			data : {
				startDate: $("#report_monthReport_year").combobox("getValue")+"-"+month+"-01",  
        		endDate: $("#report_monthReport_year").combobox("getValue")+"-"+(parseInt(month) + 1)+"-01"
			},//要发送的数据
			complete : function() {
				
			},//AJAX请求完成时
			success : function(msg) {//msg为返回的数据，在这里做数据绑定
				var aa = {categories:msg.categories};
				var bb = msg.series;
				monthLineChart(aa,bb);
			},
			error : function(XMLHttpRequest, textStatus, errorThrown) {
				//返回错误信息
				$.messager.alert('错误',XMLHttpRequest.responseText);
			}
		});
	});
	$("a[id^='report_monthReport_btn']").each(function(i){
		$(this).bind("click",function(){
			$.ajax({
				type : "post",//使用get方法访问后台
				url : "${pageContext.request.contextPath}/dailySpendAction!dataLineCharts.action",//要访问的后台地址
				dataType:"json",
				data : {
					startDate: $("#report_monthReport_year").combobox("getValue")+"-"+$(this).attr("value")+"-01",  
	        		endDate: $("#report_monthReport_year").combobox("getValue")+"-"+(parseInt($(this).attr("value")) + 1)+"-01"
				},//要发送的数据
				complete : function() {
					
				},//AJAX请求完成时
				success : function(msg) {//msg为返回的数据，在这里做数据绑定
					var aa = {categories:msg.categories};
					var bb = msg.series;
					monthLineChart(aa,bb);
				},
				error : function(XMLHttpRequest, textStatus, errorThrown) {
					//返回错误信息
					$.messager.alert('错误',XMLHttpRequest.responseText);
				}
			});
		});
	});
});
function monthLineChart(aa,bb){
	aa.labels = {
		formatter : function () {
			return this.value.split("-")[2];
		}
	};
	$("#report_monthReport_container").highcharts({
		chart : {
			type : "line",
			marginRight : 130,
			marginBottom : 25
		},
		title : {
			text : "",
			x : -20
		//center
		},
		subtitle : {
			text : "",
			x : -20
		},
		xAxis : aa,
		yAxis : {
			title : {
				text : "金额  (元)"
			},
			plotLines : [ {
				value : 0,
				width : 1,
				color : "#808080"
			} ]
		},
		tooltip : {
			valueSuffix : "元"
		},
		plotOptions: {
            series: {
                cursor: 'pointer',
                point: {
                    events: {
                        click: function() {
                        	openDailySpend(this.category);
                        }
                    }
                }
            },
			line: {
				dataLabels: {
					// 开启数据标签
					enabled: true
				}
			}
        },
		legend : {
			layout : "vertical",
			align : "right",
			verticalAlign : "top",
			x : -10,
			y : 100,
			borderWidth : 0
		},
		series : bb
	});
}
function openDailySpend(value){
	//因为日常记账已经固定了，所以不需要判断是否存在
	$("#centerTab").tabs("select","日常记账");
	$("#dailySpend_dailySpendList_dsListTable").datagrid("load",{
		startDate: value,
		endDate: value
	});
}
</script>
<div style="margin:0 auto; width:800px">
	</br>
	<select id="report_monthReport_year" class="easyui-combobox" style="width:60px;">  
	    <option value="2013">2013</option>
	    <option value="2014">2014</option>
	    <option value="2015">2015</option>
	    <option value="2016">2016</option>
	    <option value="2017">2017</option>
	    <option value="2018">2018</option>
	    <option value="2019">2019</option>
	    <option value="2020">2020</option>
	    <option value="2021">2021</option>
	    <option value="2022">2022</option>
	    <option value="2023">2023</option>
	    <option value="2024">2024</option>
	    <option value="2025">2025</option>
	    <option value="2026">2026</option>
	    <option value="2027">2027</option>
	    <option value="2028">2028</option>
	    <option value="2029">2029</option>
	    <option value="2031">2031</option>
	    <option value="2032">2032</option>
	    <option value="2033">2033</option>
	    <option value="2034">2034</option>
	    <option value="2035">2035</option>
	    <option value="2036">2036</option>
	    <option value="2037">2037</option>
	    <option value="2038">2038</option>
	    <option value="2039">2039</option>
	    <option value="2040">2040</option>
	    <option value="2041">2041</option>
	    <option value="2042">2042</option>
	    <option value="2043">2043</option>
	    <option value="2044">2044</option>
	    <option value="2045">2045</option>
	    <option value="2046">2046</option>
	    <option value="2047">2047</option>
	    <option value="2048">2048</option>
	    <option value="2049">2049</option>
	</select>
	<a id="report_monthReport_btn1" class="easyui-linkbutton" value="01">1月</a> 
	<a id="report_monthReport_btn2" class="easyui-linkbutton" value="02">2月</a>
	<a id="report_monthReport_btn3" class="easyui-linkbutton" value="03">3月</a> 
	<a id="report_monthReport_btn4" class="easyui-linkbutton" value="04">4月</a>
	<a id="report_monthReport_btn5" class="easyui-linkbutton" value="05">5月</a> 
	<a id="report_monthReport_btn6" class="easyui-linkbutton" value="06">6月</a>
	<a id="report_monthReport_btn7" class="easyui-linkbutton" value="07">7月</a> 
	<a id="report_monthReport_btn8" class="easyui-linkbutton" value="08">8月</a>
	<a id="report_monthReport_btn9" class="easyui-linkbutton" value="09">9月</a> 
	<a id="report_monthReport_btn10" class="easyui-linkbutton" value="10">10月</a>
	<a id="report_monthReport_btn11" class="easyui-linkbutton" value="11">11月</a> 
	<a id="report_monthReport_btn12" class="easyui-linkbutton" value="12">12月</a> 
</div>
</br>
<div id="report_monthReport_container" style="min-width: 400px; height: 450px; margin: 0 auto"></div>