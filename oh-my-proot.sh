function oh-my-proot-main {
unset LD_PRELOAD

mkdir -p ${TREE}/home/workspace

exec proot -S $TREE \
--link2symlink \
-b /dev/ -b /sdcard -b /proc/ \
-w /home/workspace \
/usr/bin/env -i HOME=/root \
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin \
TERM=xterm-256color \
${loginshell}
}

function show_usage {

echo "--------oh-my-proot----------"
echo "|  example    &     action  |"
echo "|  omp debian               |"
echo "| 启动目录'debian'内的发行版|"
echo "-----------------------------"

exit 0

}


function command-line-interface {

[ $# -eq 1 ] || show_usage

[ -d "$@" ] || show_usage

case "$@" in
		*/)
		show_usage
		;;
esac

#增加变量：TREE
export TREE=$(realpath -- $@)

rm $TREE/etc/resolv.conf 2> /dev/null
{
echo "nameserver 8.8.8.8"
echo "nameserver 1.1.1.1"
} >> $TREE/etc/resolv.conf || exit 1


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


oh-my-proot-main

}

command-line-interface $@
