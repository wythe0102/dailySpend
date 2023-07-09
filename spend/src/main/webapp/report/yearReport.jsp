<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
$(function() {
	window.setTimeout(function() {
		var today=new Date();
		var year=today.getFullYear();
		$("#report_yearReport_year").combobox("setValue",year);
		loadData();
	});
	$("#report_yearReport_year").combobox({
		onSelect:function(record){
			loadData();
		}
	});
	
});
function loadData(){
	$.ajax({
		type : "post",//使用get方法访问后台
		url : "${pageContext.request.contextPath}/dailySpendAction!dataLineChartsYear.action",//要访问的后台地址
		dataType:"json",
		data : {
			year: $("#report_yearReport_year").combobox("getValue"),  
		},//要发送的数据
		complete : function() {
			
		},//AJAX请求完成时
		success : function(msg) {//msg为返回的数据，在这里做数据绑定
			var aa = msg.categories;
			var bb = msg.series;
			yearLineChart(aa,bb);
		},
		error : function(XMLHttpRequest, textStatus, errorThrown) {
			//返回错误信息
			$.messager.alert('错误',XMLHttpRequest.responseText);
		}
	});
}
function yearLineChart(aa,bb){
	$("#report_yearReport_container").highcharts({
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
		xAxis : {
			categories:aa,
			labels: {
                format: '{value} 月'
            }
		},
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
                        	var year = $("#report_yearReport_year").combobox("getValue");
                        	updateTab("月报表","report/monthReport.jsp?year=" + year + "&month=" + this.category);
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

</script>
<div style="margin:0 auto; width:800px">
	</br>
	<select id="report_yearReport_year" class="easyui-combobox" style="width:60px;">  
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
		<option value="2030">2030</option>
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
</div>
</br>
<div id="report_yearReport_container" style="min-width: 400px; height: 450px; margin: 0 auto"></div>