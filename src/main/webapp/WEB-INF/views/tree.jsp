<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>
    <title></title>
    <script type="text/javascript" src="/resources/js/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.2.1/jstree.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.2.1/themes/default/style.min.css" />
    <link rel="stylesheet" href="/resources/css/bootstrap.min.css">
    <style>
        .jstree-search {
			/* js트리는 search를 이용해 찾은 요소에 italic이 적용돼있는데 구려서 적용해제시킴 */
    		font-style: normal !important;
    		/* 일단 예시로 빨간색을 줘봤는데 알아서 바꾸세용 */
    		color: red;
		}
    </style>
</head>
<body>
    <input type="text" name="keyword" id="keyword">
    <div id="tree"></div>
    <hr />
    <button class="ml-3 mb-3 btn btn-danger" id="delChart">삭제</button>
    <div>
        <div class="form-group col-md-6">
            <label for="organizationParentCode">상위조직 코드</label>
            <select class="form-control" name="organizationParentCode" id="organizationParentCode">
                <option value="">상위코드를 선택하세요.</option>
            </select>
        </div>
        <div class="form-group col-md-6">
            <label for="organizationCode">조직 코드</label>
            <input class="form-control" type="text" name="organizationCode" id="organizationCode">
        </div>
        <div class="form-group col-md-6">
            <label for="organizationName">조직 이름</label>
            <input class="form-control" type="text" name="organizationName" id="organizationName">
        </div>
        <button class="ml-3 btn btn-primary" id="addChart">추가</button>
    </div>
    <hr />
    <div id="updateForm"></div>

    <script type="text/javascript">
        $(function () {
        	
        	// 노드정보를 저장하기 위한 변수
        	var data = [];
        	
        	// 페이지 로딩시 tree구조 화면에 랜더링
        	renderTree();
        	
        	// 트리구조를 비동기통신 방식으로 서버에서 받아온 후 설정해주는 함수
        	function renderTree() {
                $.ajax({
                    url: "/tree/list",
                    contentType: "text/html; charset=UTF-8",
                    dataType: "json",
                    type: "get",
                    // 통신 성공시
                    success: (res) => {
                    	
                    	// 일단 가져온값 찍음
                    	console.log("renderTree()의 ajax의 return값 : ", res);
                    	
                    	// List로 가져와서 OrganizationChartVO의 개수만큼 반복
                        $.each(res, function (idx, chart) {
                        	
                        	// 트리뷰 한 줄에대한 정보를 tempObj에 저장
                            let tempObj = {
                        		// id에 자신의 코드 저장
                                id: chart.organizationCode,
                             	// parent에 부모의 코드 저장
                                parent: chart.organizationParentCode,
                                // text에 이름을 저장
                                text: chart.organizationName,
                                // 노트의 유형을 저장하는 부분
                            	// 아래에서 type을 설정한다음 값을 줄 수 있음
                            	// 아이콘 외에도 노드의 자식수 등 다양한 설정가능
                                type: "file"
                            };
                            
                        	// 만약 부모가 최상위 노드이면(DB에서 organizationCode의 이름참고)
                            if (tempObj.parent == "#") {
                                tempObj.state = {
                                	// 노드를 열어놓을지 닿아놓을지
                                    opened : true,
                                    // 노드를 활성화할지 비활성화할지
                                    disabled : false,
                                    // 노드가 선택된 상태일지 아닐지
                                    selected: false,
                                    // 노드가 체크된 상태일지 아닐지
                                    checked: false
                                };
                                tempObj.type = "folder";
                            }
                            
                        	// 노드를 추가할 때, 노드의 이름을 get방식으로 보내게 되는데
                        	// 서버에서 이 이름을 addAttribute로 그대로 다시 돌려준다
                        	// 만약 insertName이 있다는건 노드를 추가한 상태라는 말이고
                        	// 방금 추가된 노드를 오픈상태로 만들기 위해 아래 코드를 작성한 것
                            const insertName = "${nodeName}";
                            if (tempObj.text == insertName) {
                                data.forEach(item => {
                                    if (item.id == tempObj.parent) {
                                        item.state = {opened : true};
                                    }
                                });
                            }
                            
                           	// 이렇게 설정된 노드1개의 정보를 위에서 선언한 data배열에 추가
                            data.push(tempObj);
                        });
                        // foreach문 끝
                        
                        // jstree에서 사용되는 플러그인 및 유형을 설정하여 트리를 초기화
                        // 즉, 위에서 설정된 각각의 노드 1줄의 정보들의 배열인 data를 이용해 트리구조 생성
                        $("#tree").jstree({
                            core: {
                                data: data,
                                // 드래그 앤 드롭을 지원하기 위한 콜백함수
                                check_callback: true
                            },
                            // 트리에 적용할 플러그인을 설정
                            // dnd : 드래그 앤 드롭
                            // contextmenu : 우클릭시 메뉴바 활성화
                            // search : 검색
                            // checkbox : 체크박스 활성화
                            // types : 특정 노드의 유형을 커스터마이칭?처럼 설정할 수 있게하는듯
                            // wholerow : 트리 노드 전체 행에 대한 이벤트 처리 및 스타일링 제공
							// unique : 각 노드에 고유한 ID를 부여하고 중복된 ID를 방지
							// 등등 다양한 플러그인이 있으며 그 외의 설정과 자세한 설명은 https://www.jstree.com/plugins/ 여기 있음
                            plugins : ["dnd", "contextmenu", "search", "checkbox", "types"],
                            types : {
                                'folder' : {
                                    "icon" : "/resources/images/icon-folder.png",
                                },
                                'file' : {
                                    "icon" : "/resources/images/icon-file.png",
                                },
                                'injury' : {
                                    "icon" : "/resources/images/icon-injury.png",
                                },
                                'medicine' : {
                                    "icon" : "/resources/images/icon-medicine.png",
                                },
                                'treatment' : {
                                    "icon" : "/resources/images/icon-treatment.png",
                                },
                                'test' : {
                                    "icon" : "/resources/images/icon-test.png",
                                },
                                default: {
                                    "icon": "/resources/images/icon-file.png"
                                }
                            }
                        });
                    },
                });
            }
        	
        	
        	// 선택된 노드를 삭제해주는 함수
            $("#delChart").on("click", () => {
            	// 현재 선택한 모든 노드를 가져옴
            	// jstree의 내장 함수를 사용
                const delArr = $("#tree").jstree(true).get_selected(true);
            	// 삭제할 노드들의 정보를 담을 배열
                const data = [];
                
                // 선택된 각 노드에 대해 순회하며 처리
                delArr.forEach(delNode => {
                	// 해당 노드의 부모가 2개이상 존재할 때만 삭제
                	// 이 예제에선 '형택대학교' 라는 최상위 노드위 그 하위 노드인 학과의 삭제를 막아놓음
                	// 그 이상 혹은 이하로 노드의 삭제를 제어하고 싶다면 조건문을 변경하세용~
                    if (delNode.parents.length > 2) {
                    	// 조건에 맞는 노드를 data배열에 넣음
                        data.push({
                            organizationCode : delNode.id,
                            organizationParentCode : delNode.parent,
                            organizationName : delNode.text
                        });
                    }
                });
                
                // 서버와 통신해 db에서 제거 후 새로고침
                // 여기선 새로고침 했는데 그냥 동적으로 요소들을 제거해도 됩니다(이게 더 멋있음)
                $.ajax({
                    url: "/tree/delete",
                    contentType: "application/json; UTF-8",
                    dataType: "json",
                    data: JSON.stringify(data),
                    type: "post",
                    success: res => {
                        if (data.length == res) {
                            alert('삭제가 완료되었습니다.');
                            location.href = "/tree";
                        }
                    }
                });
            });

        	
        	// 노드 검색을 위한 함수, 노드 생성시 플러그인에서 search플러그인을 포함시켜줘야해용
        	// 검색창의 값이 입력될 때 마다 검색
            $("#keyword").on("input", function(event) {
            	// 입력된 값 가져오기
                let keyword = $(this).val();
				// jstree의 내장함수를 이용해 검색결과에 효과를 주는부분
				// 효과를 바꾸고 싶으면 위에 style부분 참고하세유
                $("#tree").jstree(true).search(keyword);
            });

        	
        	// 검색을 할 때 마다 실행되는 함수인데 추가적인 로직 넣으실분들은 넣어서 사용하세요
        	// 참고로 저는 input값이 바뀔 때 마다 검색기능을 넣은거라 console이 과도하게 찍힐텐데
        	// 추가적인 로직을 넣으실꺼면 저 위에 input대신 keydown 넣으시고
        	// if (event.originalEvent.code == "Enter" || event.originalEvent.code == "NumpadEnter")
        	// 위에 조건문 추가하셔서 엔터키 눌렀을 때만 검색 되도록 설정하세요
            $("#tree").on("search.jstree", function(e, data) {
                console.log("검색해서 가져온거 : ", data.nodes);
            });

        	
        	// jstree에서 노드를 선택할 때 발생되는 함수
            $("#tree").on("select_node.jstree", function(e, data) {
            	
            	// 선택된 노드의 정보 출력
                console.log("선택된 노드의 정보 : ", data);

            	// 해당 노드의 organizationCode를 이용해 detail을 통해 db에서 자세한 정보들을 가져온 다음 json형태로 가져옴니다
            	// 굳이 json으로 가져오는 이유 -> 데이터의 가공, 활용이 더 쉬워서 그런거같음
            	// 저희 프로젝트 같은 경우는 이렇게 누른 js트리의 정보를 화면에 그대로 옮겨야 되는데
            	// 이럴때 이제 이렇게 join 등을 써서 다양한 정보를 가져오면 예쁘게 활용할 수 있겠졍?ㅋㅋㅎ
                $.ajax({
                    url: "/tree/detail?organizationCode=" + data.node.id,
                    dataType: "json",
                    type: "get",
                    success: res => {
                    	
                    	// 데이터를 성공적으로 가져오면 가져온 데이터 출력
                        console.log("ajax를 통해 detail로 가져온 노드 정보 : ", res);
                        
                    	// 노드에 대한 부가적인 설명이 없으면 null대신 ""를 넣어줌니다
                    	// 저희는 어차피 다른정보 join으로 긁어올꺼니까 굳이 부가적인 설명은 필요없을듯용
                        if (res.organizationDescription == null) {
                        	res.organizationDescription = "";
                        }
                    	
                    	// 이렇게 가져온 노드의 정보를 동적으로 화면에 출력시키는 부분
                    	// 근데 제가볼땐 솔직히 모달로 띄우는게 더 깔끔하고 예쁠듯?
                        let str = `
                        	// 지금 구현이 덜 됐는데 암튼 이런식으로 노드의 상세목록을 수정 할 수 있고요
                        	// 구현하시려면 db에 노드 상세정보가 수정되도록 update문 간단하게 짜시면 됩니다
                            <form action="/tree/detail" method="post">
                                <div>
                                    <div class="form-group col-md-6">
                                        <label for="organizationParentCode">상위조직 코드</label>
                                        <input class="form-control" value="\${res.organizationParentCode}" type="text" name="organizationParentCode" id="organizationParentCode">
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="organizationCode">조직 코드</label>
                                        <input class="form-control" value="\${res.organizationCode}" type="text" name="organizationCode" id="organizationCode">
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="organizationName">조직 이름</label>
                                        <input class="form-control" value="\${res.organizationName}" type="text" name="organizationName" id="organizationName">
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="organizationDescription">상세 설명</label>
                                        <input class="form-control" value="\${res.organizationDescription}" type="text" name="organizationDescription" id="organizationDescription">
                                    </div>
                                    <button class="ml-3 btn btn-primary" type="submit">수정</button>
                                    <button class="ml-3 btn btn-warning" id="cancelChart">취소</button>
                                </div>
                            </form>
                        `;
                        $("#updateForm").html(str);
                    }
                });
            });

        	
        	// 바로 위에서 가져온 노드의 정보를 동적으로 출력시킬 때 취소를 누르면 사라짐
            $(document).on("click", "#cancelChart",  function() {
                $("#updateForm").html("");
            });

        	
        	
        	// 새로운 노드를 추가하는 부분
        	// 여기선 이런식으로 추가했는데 뭐 버튼클릭하면 모달이 뜬다던가 하는식으로
        	// 간지나게 할 수 있음
            $("#addChart").on("click", function() {
                const organizationParentCode = $("#organizationParentCode").val();
                const organizationCode = $("#organizationCode").val();
                const organizationName = $("#organizationName").val();
                let insertData = {
                    organizationParentCode : organizationParentCode,
                    organizationCode : organizationCode,
                    organizationName : organizationName
                };

                $.ajax({
                    url : "/tree/create",
                    contentType: "application/json; charset=UTF-8",
                    dataType: "json",
                    data: JSON.stringify(insertData),
                    type: "post",
                    async: false,
                    success: (res) => {
                        if (res) location.href="/tree/"+organizationName;
                    }
                });
            });
        });
    </script>
</body>
</html>
