#!/bin/bash
thisPath=$(dirname $(echo $BASH_SOURCE))
userHomePath="/home/$USER"

bachrc="$userHomePath/.bashrc"
profile="$userHomePath/.profile"


function programPath() {
	if [ $thisPath  == '.' ]; then
		pwd
	else
		cd $thisPath
		pwd
	fi
}

#source /home/user/gotoWorksapce/run.sh root
function bachrcAddPathSource() {
	echo "source $(programPath)/run.sh root"
}


# $1 : aliasName
#alias goto="source /home/user/gotoWorksapce/run.sh"
function aliasAddPathSource() {
	if [ -z $1 ]; then
		echo "source $(programPath)/run.sh"

	else
		echo "alias $1='source $(programPath)/run.sh'"
	fi


}


##############################메시지

function installStartMessage() {
	echo "
	주의사항 :
		만약 ./install.sh로 입력하셔서
		이 화면에 진입한것이라면 ctrl + c 를 눌러서
		작업을 취소하시고
		source install.sh 입력하셔서 진행하세요.


	엔터를 누르면 바로 설치가 시작됩니다.
	원하시는 사항을 선택해 주세요.
	설치를 중지하려면 Ctrl+c를 누르세요

	1.설치
	2.삭제


	"
}
function checkExistBashrcAddSourceMessage() {
	echo "
	~/.bashrc 파일에
	$(bachrcAddPathSource)
	위의 경로가 이미 등록돼 있습니다.
	추가를 생략하고 다음으로 진행할께요.

	"
}

function setProfileAddSourceMessage() {
	echo "
	이제

	~/.profile에 alias 이름을 goto라고 등록할꺼에요.
	이게 마음에 드시면 그냥 엔터를 눌러주시고,

	그게 아니라면 사용하고싶은 alias 이름을 적어주세요.

	"
}


function checkExistProfileAddSourceMessage() {
	echo "
	입력하신 $1 값이 이미 ~/.profile에 alias값으로 등록 돼있네요.
	다른 이름을 입력하세요.

	"
}

function checkExistProfileAddSourceUseMessage() {
	echo "
	$1 로 ~/.profile에 alias 등록이 가능합니다.
	사용하시려면 엔터를 누르시고,
	이름을 다시 정하고 싶으면

	'y를 제외한' 아무 키를 입력하신 후 엔터를 누르세요
	"
}

function installCompleteMessage() {
	echo "
	설치가 끝났습니다.
	"

}
##############################기능구현

# .profile에 alias 중복 검사,
#   현제 디렉토리로 된 run.sh 파일이 등록돼 있는지 중복 검사
#


function setInput() {
	read -p "값을 입력하세요 : " input
	if [ -z $input ]; then
		echo $1
	else
		echo $input
	fi
}

function setBachrcAddPathSource() {
	echo -e "~/.bashrc에\n $(bachrcAddPathSource)\n 경로를 추가합니다."
	echo `bachrcAddPathSource` >> $bachrc
}

function checkExistBashrcAddSource() {
	echo "
	~/.bashrc파일에 추가할 문자열을 검사합니다.
	"
	local isBashrc=`grep -w $(programPath)/run.sh $bachrc | wc -l`

	if [ $isBashrc == 1 ]; then
		if [ $1 == "install" ]; then
			checkExistBashrcAddSourceMessage

		elif [ $1 == "unInstall" ]; then

			echo "~/.bashrc에 $(bachrcAddPathSource)/로 추가돼있는 소스를 제거합니다."

			grep -nx "$(bachrcAddPathSource)" $bachrc | cut -d ':' -f1 | xargs -i sed -i '{} d ' $bachrc

		fi


	else

		if [ $1 == "install" ]; then
			setBachrcAddPathSource

		elif [ $1 == "unInstall" ]; then

			echo "~/.bashrc에 $(programPath)/run.sh로 추가돼있는 소스가 없습니다."

		fi

	fi

}

function setProfileAddPathSource() {
	echo -e "~/.profile에\n $(aliasAddPathSource $1)\n 경로를 추가합니다."
	echo `aliasAddPathSource $1` >> $profile

}



# $i : aliasName
function checkExistProfileAddSource() {

	echo "
	~/.profile파일에 추가할 문자열을 검사합니다.
	"

	echo $2

	if [ -z $2 ]; then
		isAlias=`grep $(aliasAddPathSource) $profile | wc -l`
		echo "삭제로직"
	else
		isAlias=`grep -w "alias $2" $profile | wc -l`
		echo "추가로직"
	fi

	if [ $isAlias == 1 ]; then


		if [ $1 == "install" ]; then
			checkExistProfileAddSourceMessage $2
			checkExistProfileAddSource $1 "$(setInput "goto")"

		elif [ $1 == "unInstall" ]; then

			echo "~/.profile에 $(aliasAddPathSource) 소스를 제거합니다."

			grep -n "$(aliasAddPathSource)" $profile | cut -d ':' -f1 | xargs -i sed -i '{} d ' $profile

		fi

	else

		if [ $1 == "install" ]; then
			checkExistProfileAddSourceUseMessage $2

			if [ `setInput "y"`  == "y" ]; then


				setProfileAddPathSource $2
				installCompleteMessage

			else
				echo -e "\n이름을 다시 정의합니다. 사용하고싶은 alias 이름을 적어주세요.\n"
				checkExistProfileAddSource $1 "$(setInput "goto")"
			fi

		elif [ $1 == "unInstall" ]; then

			echo "~/.profile에 $(aliasAddPathSource)로 추가돼있는 소스가 없습니다."

		fi
	fi
}



##############################main

function main() {



	isInstallFile=`ls | grep "run.sh"`


	if [ $isInstallFile == "run.sh" ]; then
		installStartMessage

#		read -p "입력: " installType

		installType=`setInput 1`


		if [ -z $installType ] || [ $installType -eq 1 ]; then

			#~/.baschrc 추가 내용 중복 검사 및 소스 추가
			checkExistBashrcAddSource "install"


			#~/.profile 추가 내용 중복 검사 및 소스 추가

			setProfileAddSourceMessage
			checkExistProfileAddSource  "install" "$(setInput "goto")"


			echo /home/$USER > $thisPath/select

			source $profile

		elif [ $installType -eq 2 ]; then

			checkExistBashrcAddSource "unInstall"
			checkExistProfileAddSource  "unInstall"

			source $profile

			echo "
			끝.
			"


		fi

	echo "
	version    : gotoWorkspace v0.1.3
	developer  : TheName
	github     : https://github.com/hgs-github/gotoWorkspace
	"


	else
		echo "run.sh 파일이 없습니다"

	fi

}

main
