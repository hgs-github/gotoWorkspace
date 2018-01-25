#!/bin/bash

#보기, 쓰기, 수정, 삭제

#기본 goto

#list 보기 = list show
#list 추가 = list add   추가할메뉴
#list 수정 = list edit  수정할 번호  수정할 내용
#list 삭제 = list del   삭제할 번호

#select 보기     = select show
#select 업데이트 = select up   업데이트할 List의 번호


##############################전역변수

path=$(dirname $(echo $BASH_SOURCE))

list=$path/list

select=$path/select
selectValue=`cat $select`

targetPath=""
arrShowList=()

##############################유틸리티

function numberFilter() {
	local v=$1
	r=${v#-}
	r=${v//[0-9]/}

	if [ -z "$r" ]; then
		echo true
	else
		echo false
	fi
}

function arrShowListadd() {
  for elem in `cat $list`
  do
   arrShowList+=($elem)
  done 
}




function showList() {
	local num=0
	local listLineCount=`wc -l $list | awk '{print $1}'`

	if [ $listLineCount -eq 0 ]; then
		emptyArrShowListMessage

	else
	  for elem in `cat $list`
	  do
	    ((num++))
	    if [ $# == 0 ]; then
		    echo $num. $elem
	    else
		if [ $elem == $1 ] && [ -n $1 ]; then
			echo $num. $elem "<---"
		else
			echo $num. $elem
		fi
	    fi
	  done
	fi



}


function findArrList() {
	local find=0
	local num=0
	for elem in ${arrShowList[@]}
	do
		if [ $elem == $1 ]; then
			find=$num
			break
		else
			find=false
		fi
		((num++))
	done
	echo $find
}








function listSelecter() {
	# 인자 값 유무
	if [ -z $1 ]; then
		echo "삭제할 번호를 넣어주세요."
		return 1


	elif [ `numberFilter $1` == true ]; then
		# 성공했을 때
		if [ ${#arrShowList[@]} -gt `expr $1 - 1` ]; then
			local i=`expr $1 - 1`
			echo ${arrShowList[$i]}
			return 2

		# 인자 값이 list의 엘리먼트 갯수보다 클 때
		else
			echo "list에 들어있는 최대 값은 ${#arrShowList[@]} 입니다."
			return 3
		fi

	#인자 값이 숫자가 아닐 때
	else
		echo "인자 값은 숫자만 넣을 수 있음"
		return 4
	fi

}


function showSelected() {
	line
	echo "현재 지정된 select 값은 아래와 같음"
	echo '--> '$selectValue
	line
	showList $selectValue
	echo -e '\n'
}

##############################메시지

function line() {
	echo "================================================"
}

function startMessage() {
	line
	echo "도움말 옵션 -help [ -h ]"
	echo "▼ 현재 select 값"
	echo $selectValue
	line
	showList $selectValue

}

function emptyArrShowListMessage() {
	echo "
	list에 아무런 값도 없습니다.
	list add 명령어를 사용하여
	항목을 추가하세요.
	"
}

function notFountAddListValueMessage() {
	echo "
	추가할 값을 다음 인자에 입력하세요.
	참고로 현제의 디렉토리를 추가 하고 싶다면
	다음 값으로 pwd 혹은 this를 입력하세요
	"

}

function listArgumentsNotFoundMessage() {
	line
	echo "show(보기), add(추가), edit(수정), del(삭제)"
	echo "list의 도움말 -help [ -h ]"
	line
}

function selectArgumentsNotFoundMessage() {
	line
	echo "show(보기), update 혹은 up (업데이트)"
	echo "select의 도움말 -help [ -h ]"
	line

}


function argumentsLimiterMessage() {
	echo "
	이 프로그램의 최대 인자값은 4개이며

	첫 번째 인자값
	list              : 주소 리스트들
	select [ sel ]    : 기본 주소
	root [r, 0]       : select된 주소로 이동

	두 번째 인자값
	list              : show, add, edit, del
	select [ sel ]  : show, up, goto
	"
}

function firstNotFindMessage() {
	echo "
	1.root [r, 0]       : select된 주소로 이동
	2.list의 index 번호 : 기록된 index 번호로 이동
	3.list              : list 보기, 추가, 수정, 삭제
	4.select [ sel ]    : select 보기, 업데이트
	"
}

function listUseHelpMessage() {
	echo "
	list에서 사용할 수 있는 옵션
	show(보기), add(추가), edit(수정), del(삭제)

	############### 사용법 ###############
	show  (옵션 없음)
	add   (추가할 값)
		> :
		add 값 다음 인자 값으로
		pwd와 this를 넣으면
		현재디렉토리 주소를 추가함

	edit  (수정할 list의 index) (내용)

	del   (삭제할 list의 index)
		> :
		다음 인자 값으로
		-a 혹은 -all을 넣으면
		list에 모든 값을 삭제함

	"

}

function selectUseHelpMessage() {
	echo "
	select에서 사용할 수 있는 옵션
	show(보기), update 혹은 up (업데이트)

	############### 사용법 ###############
	show        (옵션 없음)
	update [up] (list의 index 번호)

	"
}


function notFoundOptionMessage() {
		echo "
		그런 옵션은 없음
		"
}


function UnpredictableError() {
	echo "예측할 수 없는 오류"
}


##############################실행부분##############################

##############################goto 구현부분


function gotoSelected() {
		#showList $selectValue

		cd $(echo $(cat $path/select))
		echo "$selectValue 로 이동했습니다."
}


function gotoIndex() {


	listSelecter=`listSelecter $1`
	listSelecterReturn=$?

	# showList $listSelecter를 cd 밑으로 내리면
	# "cat: ./list: 그런 파일이나 디렉터리가 없습니다."
	# 라는 오류가 뜬다.
	showList $listSelecter

	if [ $listSelecterReturn -eq 2 ]; then

		echo "$listSelecter 로 이동"
		cd $listSelecter

	elif [ $listSelecterReturn -eq 3 ]; then
		echo "$listSelecter"

	else
		UnpredictableError
	fi

}


function gotoRun() {
	if [ $# == 0 ]; then
		startMessage

	elif [ $# == 1 ]; then
		if [ $1 == 0 ] || [ $1 == "root" ] || [ $1 == "r" ]; then
			gotoSelected
		else
			gotoIndex $1
		fi

	else
		echo "최대 인자값을 초과 했습니다."
	fi
}




##############################list 구현부분


function addList() {
	if [ -z $1 ]; then
		notFountAddListValueMessage

	else
		if [ `findArrList $1` == false ] || [ ${#arrShowList[@]} -eq 0 ]; then
			echo $1 >> $list
			line
			echo "$1를 리스트에 항목을 추가함"
			line
			showList $1

		else
			local findArrListNum=`findArrList $1`
			line
			echo `expr $findArrListNum + 1` "번에 값이 존재함"
			line

			showList ${arrShowList[findArrListNum]}
		fi
	fi


}




function editList() {
	listSelecter=`listSelecter $1`
	listSelecterReturn=$?

	if [ $listSelecterReturn -eq 1 ]; then
		echo $listSelecter

	elif [ $listSelecterReturn -eq 2 ]; then
		if [ -z $2 ]; then
			echo "바꿀 내용을 입력 해야함"

		else
			if [ `findArrList $2` == false ]; then
				line
				echo -e "###수정###\n$listSelecter\n▼ (수정성공)▼ \n$2"
				grep -nx $listSelecter $list | cut -d ':' -f1 | xargs -i sed -i '{} c '$2 $list
				line
				showList
				echo -e "\n"

			else
				local findArrListNum=`findArrList $2`
				line
				echo -e "${arrShowList[` expr $1 - 1`]} \n▽ (수정실패)▽ \n$2"
				echo `expr $findArrListNum + 1` "번에 값이 존재함"
				line
				showList ${arrShowList[findArrListNum]}
				echo -e "\n"
			fi
		fi

	elif [ $listSelecterReturn -eq 3 ]; then
		line
		echo $listSelecter
		line
		showList


	elif [ $listSelecterReturn -eq 4 ]; then
		echo $listSelecter

	else
		UnpredictableError
	fi
}


function delAllList() {

	if [ ${#arrShowList[@]} -eq 0 ]; then
		echo "list엔 아무것도 기록돼있지 않습니다."
	else
		sed -i 'd' $list
		echo "lsit에 있는 내용을 모두 삭제했습니다."
	fi


}

function delList() {
	listSelecter=`listSelecter $1`
	listSelecterReturn=$?

	if [ $listSelecterReturn -eq 1 ]; then
		echo $listSelecter

	elif [ $listSelecterReturn -eq 2 ]; then
		line
		echo $listSelecter
		# 정확히 일치만 삭제시켜야 하는데 일치라인은 모두 삭제하는 문제, 해결
		grep -nx $listSelecter $list | cut -d ':' -f1 | xargs -i sed -i '{} d' $list
		echo "삭제"
		line

	elif [ $listSelecterReturn -eq 3 ]; then
		line

		echo $listSelecter
		line

	elif [ $listSelecterReturn -eq 4 ]; then
		if [ $1 == "-a" ] || [ $1 == "-all" ]; then
			delAllList

		else
			echo $listSelecter
		fi

	else
		UnpredictableError

	fi

	showList $selectValue
}




function listRun() {
	if [ -z "$2" ]; then
		listArgumentsNotFoundMessage
		showList $selectValue

	elif [ $2 == "show" ]; then
		showSelected

	elif [ $2 == "add" ]; then
		if [ -z $3 ];then
			addList $3
		elif [ $3 == "pwd" ] || [ $3 == "this" ]; then
			addList `pwd`
		else
			addList $3
		fi


	elif [ $2 == "edit" ]; then
		editList $3 $4

	elif [ $2 == "del" ]; then
		delList $3


	elif [ $2 == "-help" ] || [ $2 == "-h" ]; then
		listUseHelpMessage
	else
		notFoundOptionMessage
		listUseHelpMessage

	fi
}





##############################select 구현부분



function updateSelected() {
	listSelecter=`listSelecter $1`
	listSelecterReturn=$?

	if [ $listSelecterReturn -eq 1 ]; then
		echo $listSelecter
		showList
		echo 이 중에서 하나 골라야함

	elif [ $listSelecterReturn -eq 2 ]; then
		if [ -z $1 ]; then
			echo "변경 내용을 입력 해야함"
		else
			line
			echo -e "###업데이트###\n$selectValue\n▼ \n$listSelecter"
			line
			echo $listSelecter > $select
			showList $listSelecter
			echo -e "\n"

		fi

	elif [ $listSelecterReturn -eq 3 ]; then
		line
		echo $listSelecter
		line
		showList

	elif [ $listSelecterReturn -eq 4 ]; then
		echo $listSelecter

	else
		UnpredictableError

	fi
}

function selectRun() {
	if [ -z "$2" ] ; then
		selectArgumentsNotFoundMessage
		showList $selectValue

	elif [ $2 == "show" ]; then
		showSelected
	elif [ $2 == "up" ] || [ $2 == "update" ]; then
		updateSelected $3

	elif [ $2 == "-help" ] || [ $2 == "-h" ]; then
		selectUseHelpMessage

	else
		notFoundOptionMessage
		selectUseHelpMessage

	fi
}





##############################main

function main() {
	arrShowListadd

	if [ $# == 0 ]; then
		gotoRun

	elif [ `numberFilter $1` == true ] || [ $1 == "root" ] || [ $1 == "r" ]; then
		gotoRun $1 $2


	elif [ $# -lt 5 ]; then
		if [ $1 == "list" ]; then
			listRun $1 $2 $3 $4

		elif [ $1 == "select" ] || [ $1 == "sel" ]; then
			selectRun $1 $2 $3

		elif [ $1 == "-help" ] || [ $1 == "-h" ]; then
			argumentsLimiterMessage
			listUseHelpMessage
			line
			selectUseHelpMessage

	echo "
	version    : gotoWorkspace v0.1.3
	developer  : TheName
	github     : https://github.com/hgs-github/gotoWorkspace
	github의 README에 더 자세한 설명이 돼있어요 : )
	"

		else
			firstNotFindMessage
		fi

	else
		argumentsLimiterMessage

	fi


}

main $1 $2 $3 $4 $5




#version    : gotoWorkspace v0.1.3
#developer  : TheName
#github     : https://github.com/hgs-github/gotoWorkspace
