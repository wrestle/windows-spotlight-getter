#!/bin/bash
# Created By WuShengXin @ 2016
# 这个脚本依赖 *nix 的 shell 执行环境，可以安装 git 或者 cygwin 来获取环境
# 当然也可以使用 Linux in Windows的功能解决，这个会是最好的解决办法。
#
# 修改这里，用来设定保存路径！修改引号内的内容即可，替换成你先要的存储路径
# 反斜杠记得要写两个
destination="E:\\User-wu\\Media\\Picture\\"
#
# 注: 可以通过传入参数的方式设置聚焦的文件夹路径，但是并不推荐这种做法。
# 除非你想用这个脚本做另外的事情。
# 当前由于 Bash On Windows 尚不完善，故这个脚本无法在其中使用，可以用上面提到的前两种环境运行。
echo "Created By WuShengXin @ 2016, Use it CAREFULLY! Read The Reference above it"
echo "You Can send a real Path to that Script by FIRST PARAMTER, But Not Recommend exclude the other using."
# 检测
cd $destination 2>&1 /dev/null
if [ $? -ne 0 ];
then
	# 这个存储路径是错误，尝试一下*nix格式的路径
	tmp=`echo ${destination/:/} | sed 's/\b[A-Z]/\L&/'`
	tmpcpy="/mnt/${tmp//\\/\/}"
	#echo "Final dest: $tmpcpy"
	if [ -d "$tmpcpy" ];
	then
		#echo "$tmpcpy Exist"
		destination=$tmpcpy
	else
		echo "Bad Destination-Path, Check For Real"
	fi
fi
if [[ $1 == "" ]];
then
    echo ""
else
    echo "Your Enter is : $1"
fi
# 源路径，即聚焦路径
dir=$1
solid=""
# 固有属性
presolidwin="C:/Users"
presolidnix="/mnt/c/Users"
suffsolid="AppData/Local/Packages"

# 查看系统运行的环境
# 如果是在 Win环境下
if [ -d "$presolidwin" ];
then
	solid="$presolidwin/`whoami`/$suffsolid"
# 如果是在 bash 中
elif [ -d "$presolidnix" ];
then
	for username in `ls $presolidnix`
	do
		solid="$presolidnix/$username/$suffsolid"
		#echo "FOR LOOP: $solid"
		if [ -d "$solid" ];
		then
			#echo ">>>$solid exist<<<"
			break
		fi
	done
# 位置系统环境，退出
else
	echo "Your System Seem to be Nothing with Windows spotlight Function!1"
	exit 1
fi
# 检测，如果是在 bash 中，那么是否有聚焦功能
if [ ! -d "$solid" ];
then
	echo "Your System Seem to be Nothing with Windows spotlight Function!2"
	exit 2 
fi
dirpossible=`ls $solid | grep -e "^Microsoft.Windows.ContentDeliveryManager_"`
# 是否有聚焦这个功能
if [[ $dirpossible == "" ]];
then
	echo "Your Windows Version Does Not Support That Function!"
	exit 1
fi

# 得到完整的聚焦图片存放路径
save=${dir:="$solid/$dirpossible/LocalState/Assets"}
# 进入聚焦文件夹
cd $dir
# 进入聚焦文件夹失败，退出脚本
if [ $? -ne 0 ];
then 
	echo "Bad Dir Path, Check For Real"
	exit 1
fi
# 遍历图片文件
echo ""
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Tring To rename the file which is Picture Before, Please Wait..."
echo "         Your Source Dir : $dir"
echo "         Destination Dir : $destination "
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
for file in `ls`
do
    # 测试是否有非标准聚焦存储格式的文件存在
    if [[ $file =~ "." ]];
    then
    	echo "Something Unknown has Been Detected: $file"
    else
        cp $file $file.jpg
		# 只要 1920 * 1080 的图片，其他分辨率的被本行过滤。
		# 注 由于 bash 子系统现在对命令的支持尚不完善，故现在无法在 bash 中使用，此处bash
		# 指的是 WSL(Windows Subsystem Linux/Bash on Windows)
		# 如果想在 WSL 中成功执行，注释掉这六行用来过滤分辨率的代码即可。
		return=`file $file.jpg | awk '{print $(NF-2)}' | grep -e "^1920"`
		if [[ "$return" == "" ]];
		then
			rm $file.jpg
			continue
		fi
		mv $file.jpg $destination
		echo "Success : $file.jpg"
    fi
done
echo "End The Task!"
