<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    
    <title><s:message code="common.pageTitle"/></title>
    <link href="css/sb-admin/bootstrap.min.css" rel="stylesheet">
    <link href="css/sb-admin/metisMenu.min.css" rel="stylesheet">
    <link href="css/sb-admin/sb-admin-2.css" rel="stylesheet">
    <link href="css/sb-admin/font-awesome.min.css" rel="stylesheet" type="text/css">
	<link href="js/dynatree/ui.dynatree.css" rel="stylesheet" id="skinSheet"/>
    <link href="js/datepicker/datepicker.css" rel="stylesheet" type="text/css">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

    <script src="js/jquery-2.2.3.min.js"></script>
    <script src="css/sb-admin/bootstrap.min.js"></script>
    <script src="css/sb-admin/metisMenu.min.js"></script>
    <script src="css/sb-admin/sb-admin-2.js"></script>
	<script src="js/project9.js"></script>
    <script src="js/datepicker/bootstrap-datepicker.js"></script>
<style>
	.title {
		color:blue; 
		font-size: 12pt;
	}
	.row {
		margin-top: 5px
	}
	.field1 {
		margin-left: 10px
	}
	em {
		color:red; 
	}
	#page_div div {
		width: 30px;
	    height: 30px;
	    margin: 5px;
	    /* border: 1px solid; */
	    font-size: 20px; 
	    cursor: pointer;
    }
</style>
<script>
window.onload = function() {
    $('#searchTerm1').datepicker().on('changeDate', function(ev) {
        if (ev.viewMode=="days"){
            $('#searchTerm1').datepicker('hide');
        }
    });
    $('#searchTerm2').datepicker().on('changeDate', function(ev) {
        if (ev.viewMode=="days"){
            $('#searchTerm2').datepicker('hide');
        }
    });
}
var searchKeyword = "", currentPage=1, searchType = "";

function fn_fullTextSearch(page){
	var searchRange = "";
	$("#searchRange:checked").each(function() {
		searchRange += $(this).val() + ",";
  	});
	if (searchRange.length< 1) { 
		alert("?????? ????????? ???????????????.");
	}
	
	currentPage	  = page;	
    $.ajax({
    	url: "search4Ajax",
    	cache: false,
    	data: { searchKeyword : searchKeyword, page: page, searchType: searchType, searchRange:searchRange.substr(0, searchRange.length-1), 
    			searchTerm:$("#searchTerm:checked").val(), searchTerm1:$("#searchTerm1").val(), searchTerm2:$("#searchTerm2").val() }    	
    }).done(receiveData);	
}

function fn_formSubmit(){
	searchType = "";
	searchKeyword = $("#searchKeyword").val();
	fn_fullTextSearch(1);
}

function fn_page(page){
	fn_fullTextSearch(page);
}

function receiveData(data){
	if (!data) return;
	console.log(data);
	
	var hits = data.hits.hits;
	var $list_div = $("#list_div");
	$list_div.empty();
	
	hits.forEach(function(row){
		var brdwriter= row.highlight && row.highlight.brdwriter ? row.highlight.brdwriter : row._source.brdwriter;
		var brdtitle = row.highlight && row.highlight.brdtitle ? row.highlight.brdtitle : row._source.brdtitle;
		var brdmemo  = row.highlight && row.highlight.brdmemo ? row.highlight.brdmemo[0] : row._source.brdmemo;
		
		var childNode = $('<div  class="panel panel-default"/>'); 
        var html = '<div class="panel-body">' + 
				   '		<div class="col-lg-12 title"><a href="boardRead?brdno=' + row._source.brdno + '" target="_blank">' + brdtitle + '</a></div>' + 
				   '		<div class="col-lg-12 row">...' + brdmemo.substring(0, 200) + '...</div>' +  
				   '		<div class="col-lg-12 row">' + 
				   '        	<div class="pull-left">?????????: ' + brdwriter + '</div>' +  
				   '         	<div class="pull-left field1">?????????: ' + row._source.brddate+ ' ' + row._source.brdtime+ '</div>' + 
				   '		</div>' + 
			       '</div>';
		childNode.html(html)
        $list_div.append ( childNode );
	});
	/////////////////////////////////
	if (searchType==="") {		// ?????? ????????? ????????? ?????? ????????? ????????????
		"2,3".split(",").forEach(function(row){
			$("#cnt"+row).html(0);
		}); 

		var agg = data.aggregations; 
		var buckets = agg[Object.keys(agg)].buckets; 	// "lterms#gujc"??? "lterms#"??? ???????????? ????????? ????????? ??????;
		console.log(buckets);
		
		buckets.forEach(function(row){
			$("#cnt"+row.key).html(row.doc_count);
		});  
	
		$("#cnt").html(data.hits.total.value);
	}
	
	/////////////////////////////////
	var $page_div = $("#page_div");
	$page_div.empty();
	
	var totalPages = Math.ceil(data.hits.total.value / 5);
	if (totalPages===1) return;
	
	for (var i=1; i<=totalPages;i++){
		var $node = $('<div class="pull-left"/>');
		$node.click(function() {
			fn_page($(this).text());
		});

		$node.html(i);
		$page_div.append($node);
	}
}

function fn_fullTextSearchType(type) {
	searchType = type;
	fn_fullTextSearch(0);
}

function ev_checkAllField() {
	var chk = $("#searchRangeAll")[0].checked;
	$("input[id=searchRange]:checkbox").each(function() {
		$(this).prop("checked", chk);
	});
}
</script>
    
</head> 

<body>

    <div id="wrapper">
		<jsp:include page="../common/navigation.jsp" />
		
        <div id="page-wrapper">
            <div class="row">
                <div class="col-lg-12">
                    <h1 class="page-header"><i class="fa fa-gear fa-fw"></i> Elasticsearch ?????????</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>

				<div class="form-group">
					<div class="col-lg-1 pull-left"></div> 
                   	<div class="input-group custom-search-form col-lg-3">
                    	<input class="form-control" placeholder="Search..." type="text" id="searchKeyword" name="searchKeyword" onkeydown="if(event.keyCode == 13) { fn_formSubmit();}">
                        <span class="input-group-btn">
                              <button class="btn btn-default" onclick="fn_formSubmit()">
                                  <i class="fa fa-search"></i>
                              </button>
                        </span>
                    </div> 
				</div> 
	            <div class="row">
	                <div class="col-lg-1">????????????</div>
                 	<div class="col-lg-1"><label><input type="checkbox" id="searchTerm" value="a" checked >??????</label></div>
	                <div class="col-lg-2">
	                    <input class="form-control" size="16" id="searchTerm1" type="text" value="<c:out value="${today}"/>" readonly>
	                </div>
	                <div class="col-lg-2">
	                      <input class="form-control" size="16" id="searchTerm2" type="text" value="<c:out value="${today}"/>" readonly>
	                </div> 
	            </div>
	            <div class="row">
	                <div class="col-lg-1">????????????</div>
	                <div class="col-lg-1">
	                 	<label><input type="checkbox" id="searchRangeAll" value="" checked onchange="ev_checkAllField()">??????</label>
	                </div>
	                <div class="col-lg-10">
	                 	<label><input type="checkbox" id="searchRange" value="brdwriter" checked>?????????</label>
	                 	<label><input type="checkbox" id="searchRange" value="brdtitle" checked>??????</label>
	                 	<label><input type="checkbox" id="searchRange" value="brdmemo" checked>??????</label>
	                 	<label><input type="checkbox" id="searchRange" value="brdreply" checked>??????</label>
	                 	<label><input type="checkbox" id="searchRange" value="brdfiles" checked>????????????</label>
	                </div>
	            </div> 

	            <div class="row"> 
		            <div class="panel panel-default"> 
		            	<div class="panel-body">
			            	<div class="pull-left" onclick="fn_fullTextSearchType('')" style="cursor: pointer;">???????????? <span id="cnt" style="color:red">0</span></div>
			            	<div class="pull-left" onclick="fn_fullTextSearchType('3')" style="cursor: pointer;margin-left: 30px">?????? ?????????  <span id="cnt3" style="color:red">0</span></div>
			            	<div class="pull-left" onclick="fn_fullTextSearchType('2')" style="cursor: pointer;margin-left: 30px">???????????? <span id="cnt2" style="color:red">0</span></div> 
						</div>  
					</div>
				</div> 
								 
				<div id="list_div"></div>  
				<div id="page_div" class="col-lg-12">  
		        </div>  
        </div> 
        <!-- /#page-wrapper -->

    </div>
    <!-- /#wrapper -->
</body>

</html>
