/**
 * 首先，你需要引入JS，这个大家都知道
<script type="text/javascript" src="JS/countNum.js"></script>   
然后再额外赠送一个漂亮的字数样式表
.num    
{    
font: 26px/30px Georgia, Tahoma, Arial;    
padding: 0 5px;    
}  
下面是一些你需要在JS自行修改的参数，记得改哦，不然用不了
var txtobj={    
 divName:"msgBox", //外层容器的class    
 textareaName:"sent-text", //textarea的class    
 numName:"num", //数字的class    
 num:140 //数字的最大数目    
}   
 */
// JavaScript Document
  var txtobj={
   divName:"msgBox", //外层容器的class
   textareaName:"easyui-validatebox", //textarea的class
   numName:"num", //数字的class
   num:140 //数字的最大数目
  }
  
  var textareaFn=function(){
   //定义变量
   var $onthis;//指向当前
   var $divname=txtobj.divName; //外层容器的class
   var $textareaName=txtobj.textareaName; //textarea的class
   var $numName=txtobj.numName; //数字的class
   var $num=txtobj.num; //数字的最大数目
   
   function isChinese(str){  //判断是不是中文
    var reCh=/[u00-uff]/;
    return !reCh.test(str);
   }
   function numChange(){
    /*var strlen=0; //初始定义长度为0
    var txtval = $.trim($onthis.val());
    for(var i=0;i<txtval.length;i++){
     if(isChinese(txtval.charAt(i))==true){
      strlen=strlen+2;//中文为2个字符
     }else{
      strlen=strlen+1;//英文一个字符
     }
    }
    strlen=Math.ceil(strlen/2);//中英文相加除2取整数
    */
	
	//汉字的个数
	var str = ($onthis.val().replace(/\w/g,"")).length;
	//非汉字的个数
	var abcnum = $onthis.val().length-str;
	
	var strlen = str*2+abcnum;
	strlen=Math.ceil(strlen/2);//中英文相加除2取整数
	
    if($num-strlen<0){
     $par.html("已经超出限制 <b style='color:red;font-weight:lighter;' class="+$numName+">"+Math.abs($num-strlen)+"</b> 个字"); //超出的样式
    }
    else{
     $par.html("还可以输入 <b class="+$numName+">"+($num-strlen)+"</b> 个字"); //正常时候
    }
    $b.html($num-strlen);   
   }
   
   $("."+$textareaName).live("focus",function(){
    $b=$(this).parents("."+$divname).find("."+$numName); //获取当前的数字
    $par=$b.parent(); 
    $onthis=$(this); //获取当前的textarea
    var setNum=setInterval(numChange,500);    
   });
  }     
  textareaFn();