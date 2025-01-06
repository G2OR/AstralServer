#!/bin/bash
#進入軟件的制定安裝目錄
echo "進入目錄/usr/local，下載pgsql文件"
cd /usr/local
#判斷是否有postgre版本的安裝包
if [ -d post* ]
then
        rm -rf /usr/local/post*
        echo "安裝包刪除成功"
fi
#開始下載pgsql版本10.5並解壓
if [ ! -d /usr/local/src ]
then
        mkdir /usr/local/src
fi
cd /usr/local/src
wget https://ftp.postgresql.org/pub/source/v10.5/postgresql-10.5.tar.gz
if [ $? == 0 ]
then
        tar -zxf postgresql-10.5.tar.gz -C /usr/local/
fi
echo "pgsql文件解壓成功"
#判斷用戶是否存在
id $postgres >& /dev/null
echo "用戶postgres已存在"
if [ $? -ne 0 ]
then
        echo "用戶不存在，開始創建postgres用戶"
        groupadd postgres
        useradd -g postgres postgres
fi
echo "重命名postgresql並且進入安裝目錄"
mv /usr/local/post* /usr/local/pgsql
cd /usr/local/pgsql
#-------------------------------安裝pgsql------------------------------------
echo "安裝一些庫文件"
yum install -y zlib zlib-devel >& /del/null
echo "開始執行configure步驟"
./configure --prefix=/usr/local/pgsql --without-readline
if [ $? == 0 ]
then
        echo "configure配置通過，開始進行make編譯"
        make
        if [ $? == 0 ]
        then
                echo "make編譯通過，開始進行make install安裝步驟"
                make install
                if [ $? != 0 ];then
                        echo "make install安裝失敗"
                fi
                echo "安裝成功"
        else
                echo "make編譯失敗，檢查錯誤。"
        fi
else
        echo "configure檢查配置失敗，請查看錯誤進行安裝庫文件"
fi
echo "開始進行pgsql的配置"
echo "給pgsql創建data目錄"
mkdir -p /usr/local/pgsql/data
echo "修改用戶組"
chown -R postgres:postgres /usr/local/pgsql
echo "添加環境變量,進入postgres用戶的家目錄"
cd /home/postgres
if [ -f .bash_profile ] ;then
        cp .bash_profile .bash_profile.bak
        echo "export PGHOME=/usr/local/pgsql" >> .bash_profile
        echo "export PGDATA=/usr/local/pgsql/data" >> .bash_profile
        echo "PATH=$PGHOME/bin:$PATH" >> .bash_profile
        echo "MANPATH=$PGHOME/share/man:$MANPATH" >> .bash_profile
        echo "LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH" >> .bash_profile
fi
alias pg_start='pg_ctl -D $PGDATA -l /usr/local/pgsql/logfile start'
alias ps_stop='pg_ctl -D $PGDATA -l /usr/local/pgsql/logfile stop'
echo "切換至postgres用戶來初始化數據庫"
su - postgres -c "/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data"
echo "---------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------"
echo "----------------------------SUCCESS INSTALLATION OF POSTGRESQL-------------------------" 
