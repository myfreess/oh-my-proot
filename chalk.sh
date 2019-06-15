#!/data/data/com.termux/files/usr/bin/bash

# 全局变量：TREE NAME loginshell
#
# TREE指向Rootfs所在目录绝对路径
#
# NAME指向Rootfs所在目录名
#
#
# loginshell指向Rootfs内部可用的shell
#
#
#
function show_usage() {
cat <<EOF

chalk.sh -- Termux Proot script Generator

chalk是一个工作在Termux平台上的proot启动脚本模板生成工具。

请以Linux发行版的根目录名称为输入参数.

例子:

\$ pwd

/data/data/com.termux/files/home

for i in *; do
   if [ -d "\$i" ]; then
       echo \${i}/
   fi
done
----------------------
ubuntu/ debian/

chalk debian生成debian启动模板，chalk ubuntu则生成ubuntu启动模板。

Warning:不能使用补全功能去补全目录名!GNU readline的自动补全会为目录名加上'/'!


sqlmap与素描间一定有某种潜在联系……


EOF
exit 0
}

function add_dns_server {
		rm $TREE/etc/resolv.conf 2> /dev/null
		{
		echo "nameserver 8.8.8.8"
		echo "nameserver 1.1.1.1"
		} >> $TREE/etc/resolv.conf
}

function generate_script {

cat > $PREFIX/bin/start"$NAME" <<EOF
#!${PREFIX}/bin/bash

unset LD_PRELOAD
export PROOT_NO_SECCOMP=1

mkdir -p $TREE/home/workspace

exec proot -S $TREE \
--link2symlink \
-b /dev/ -b /sdcard -b /proc/ \
-w /home/workspace \
/usr/bin/env -i HOME=/root \
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin \
TERM=xterm-256color \
${loginshell}

EOF

chmod +x $PREFIX/bin/start$NAME
}

function check_loginshell {
		if [ -x $TREE/bin/bash ]; then
				loginshell="$TREE/bin/bash -l"
		elif [ -x $TREE/usr/bin/bash ]; then
				loginshell="$TREE/usr/bin/bash -l"
		elif [ -x $TREE/bin/busybox ]; then
				loginshell="$TREE/bin/busybox sh --login"
		else
				echo "未找到可用loginshell :("
				
				exit 1
		fi
		#增加变量：loginshell
		export loginshell
}

function setup_banner {
cat > $TREE/etc/profile <<EOF

cat <<EOM

Message by chalk.sh

                 (__)
                 (oo)
           /------\/
          / |    ||
         *  /\---/\
            ~~   ~~
..."Have you mooed today?"...

EOM

export USER=root

EOF

}

function main {

[ $# -eq 1 ] || show_usage

[ -d "$@" ] || show_usage

case "$@" in
		*/)
		show_usage
		;;
esac

#增加变量：TREE NAME
export TREE=$(realpath -- $@)
export NAME=$(basename $@)

if [ -d $TREE/etc ]; then
		printf "\nGenerate script..."
		for i in {1..10}; do
				sleep 0.1
				printf '.'
		done
		echo '.'
fi

check_loginshell

add_dns_server || exit 1

generate_script || exit 1

setup_banner

echo "完成，输入 start$NAME启动"
}

main $@
