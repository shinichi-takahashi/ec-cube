#!/bin/sh

######################################################################
#
# EC-CUBE のインストールを行う shell スクリプト
#
#
# #処理内容
# 1. パーミッション変更
# 2. html/install/sql 配下の SQL を実行
# 3. 管理者権限をアップデート
# 4. data/config/config.php を生成
#
# 使い方
# Configurationの内容を自分の環境に併せて修正
# PostgreSQLの場合は、DBユーザーを予め作成しておいて
# # ./ec_cube_install.sh pgsql
# MySQLはMYSQLのRoot以外のユーザーで実行する場合は、128行目をコメントアウトして
# # ./ec_cube_install.sh mysql
#
#
# 開発コミュニティの関連スレッド
# http://xoops.ec-cube.net/modules/newbb/viewtopic.php?topic_id=4918&forum=14&post_id=23090#forumpost23090
#
#######################################################################

#######################################################################
# Configuration
#-- Shop Configuration
CONFIG_PHP="app/config/eccube/config.php"
CONFIG_YML="app/config/eccube/config.yml"
ADMIN_MAIL=${ADMIN_MAIL:-"admin@example.com"}
SHOP_NAME=${SHOP_NAME:-"EC-CUBE SHOP"}
HTTP_URL=${HTTP_URL:-"http://test.local/"}
HTTPS_URL=${HTTPS_URL:-"http://test.local/"}
ROOT_URLPATH=${ROOT_URLPATH:-"/"}
DOMAIN_NAME=${DOMAIN_NAME:-""}
ADMIN_DIR=${ADMIN_DIR:-"admin"}

DBSERVER=${DBSERVER-"127.0.0.1"}
DBNAME=${DBNAME:-"cube3_dev"}
DBUSER=${DBUSER:-"cube3_dev_user"}
DBPASS=${DBPASS:-"password"}

ADMINPASS="f6b126507a5d00dbdbb0f326fe855ddf84facd57c5603ffdf7e08fbb46bd633c"
AUTH_MAGIC="droucliuijeanamiundpnoufrouphudrastiokec"

DBTYPE=$1;

case "${DBTYPE}" in
"pgsql" )
    #-- DB Seting Postgres
    PSQL=psql
    PGUSER=postgres
    DROPDB=dropdb
    CREATEDB=createdb
    DBPORT=5432
    DBDRIVER=pdo_pgsql
;;
"mysql" )
    #-- DB Seting MySQL
    MYSQL=mysql
    ROOTUSER=root
    ROOTPASS=$DBPASS
    DBSERVER=$DBSERVER
    DBPORT=3306
    DBDRIVER=pdo_mysql
;;
* ) echo "ERROR:: argument is invaid"
exit
;;
esac


#######################################################################
# Functions

adjust_directory_permissions()
{
    chmod -R go+w "./html"
    chmod go+w "./app"
    chmod -R go+w "./app/template"
    chmod -R go+w "./app/cache"
    chmod -R go+w "./app/config"
    chmod -R go+w "./app/download"
    chmod -R go+w "./app/downloads"
    chmod go+w "./app/font"
    chmod go+w "./app/fonts"
    chmod go+w "./app/log"
    chmod go+w "./app/logs"
    chmod go+w "./app/upload"
    chmod go+w "./app/upload/csv"
}

create_sequence_tables()
{
    SEQUENCES="
dtb_best_products_best_id_seq
dtb_category_category_id_seq
dtb_class_name_class_name_id_seq
dtb_class_category_class_category_id_seq
dtb_csv_no_seq
dtb_csv_sql_sql_id_seq
dtb_customer_customer_id_seq
dtb_delivery_delivery_id_seq
dtb_delivery_fee_fee_id_seq
dtb_delivery_time_time_id_seq
dtb_holiday_holiday_id_seq
dtb_kiyaku_kiyaku_id_seq
dtb_mail_history_send_id_seq
dtb_maker_maker_id_seq
dtb_member_member_id_seq
dtb_module_update_logs_log_id_seq
dtb_news_news_id_seq
dtb_order_order_id_seq
dtb_order_detail_order_detail_id_seq
dtb_other_deliv_other_deliv_id_seq
dtb_payment_payment_id_seq
dtb_product_class_product_class_id_seq
dtb_product_product_id_seq
dtb_review_review_id_seq
dtb_send_history_send_id_seq
dtb_shipping_shipping_id_seq
dtb_shipment_item_item_id_seq
dtb_mailmaga_template_template_id_seq
dtb_plugin_plugin_id_seq
dtb_plugin_hookpoint_plugin_hookpoint_id_seq
dtb_api_config_api_config_id_seq
dtb_api_account_api_account_id_seq
dtb_tax_rule_tax_rule_id_seq
"

    comb_sql="";
    for S in $SEQUENCES; do
        case ${DBTYPE} in
            pgsql)
                sql=$(echo "SELECT SETVAL ('${S}', 10000);")
            ;;
            mysql)
                sql=$(echo "CREATE TABLE ${S} (
                        sequence int(11) NOT NULL AUTO_INCREMENT,
                        PRIMARY KEY (sequence)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
                    LOCK TABLES ${S} WRITE;
                    INSERT INTO ${S} VALUES (10000);
                    UNLOCK TABLES;")
            ;;
        esac

        comb_sql=${comb_sql}${sql}
    done;

    case ${DBTYPE} in
        pgsql)
            echo ${comb_sql} | sudo -u ${PGUSER} ${PSQL} -U ${DBUSER} ${DBNAME}
        ;;
        mysql)
            echo ${comb_sql} | ${MYSQL} -u ${DBUSER} ${PASSOPT} ${DBNAME}
        ;;
    esac
}

get_optional_sql()
{
    echo "INSERT INTO dtb_member (member_id, login_id, password, salt, work, del_flg, authority, creator_id, rank, update_date, create_date) VALUES (2, 'admin', '${ADMINPASS}', '${AUTH_MAGIC}', 1, 0, 0, 1, 1, current_timestamp, current_timestamp);"
    echo "INSERT INTO dtb_base_info (id, shop_name, email01, email02, email03, email04, update_date, point_rate, welcome_point) VALUES (1, '${SHOP_NAME}', '${ADMIN_MAIL}', '${ADMIN_MAIL}', '${ADMIN_MAIL}', '${ADMIN_MAIL}', current_timestamp, 0, 0);"
}

create_config_php()
{
    cat > "./${CONFIG_PHP}" <<__EOF__
<?php
define('ECCUBE_INSTALL', 'ON');
define('HTTP_URL', '${HTTP_URL}');
define('HTTPS_URL', '${HTTPS_URL}');
define('ROOT_URLPATH', '${ROOT_URLPATH}');
define('DOMAIN_NAME', '${DOMAIN_NAME}');
define('DB_TYPE', '${DBTYPE}');
define('DB_USER', '${DBUSER}');
define('DB_PASSWORD', '${CONFIGPASS:-$DBPASS}');
define('DB_SERVER', '${DBSERVER}');
define('DB_NAME', '${DBNAME}');
define('DB_PORT', '${DBPORT}');
define('ADMIN_DIR', '${ADMIN_DIR}/');
define('ADMIN_FORCE_SSL', FALSE);
define('ADMIN_ALLOW_HOSTS', 'a:0:{}');
define('AUTH_MAGIC', '${AUTH_MAGIC}');
define('PASSWORD_HASH_ALGOS', 'sha256');
define('MAIL_BACKEND', 'mail');
define('SMTP_HOST', '');
define('SMTP_PORT', '');
define('SMTP_USER', '');
define('SMTP_PASSWORD', '');

__EOF__
}

create_config_yml()
{
    cat > "./${CONFIG_YML}" <<__EOF__
database:
    driver: ${DBDRIVER}
    host: ${DBSERVER}
    dbname: ${DBNAME}
    port: ${DBPORT}
    user: ${DBUSER}
    password : ${CONFIGPASS:-$DBPASS}
    charset: utf8
mail:
    host: localhost
    port: 25
    username: 
    password: 
    encryption: 
    auth_mode: 
delivery_address: 
auth_magic: ${AUTH_MAGIC}
password_hash_algos: sha256
root: ${ROOT_URLPATH}
admin_dir: /${ADMIN_DIR}
tpl: ${ROOT_URLPATH}user_data/packages/default/
admin_tpl: ${ROOT_URLPATH}user_data/packages/${ADMIN_DIR}/
image_path: /upload/save_image/
shop_name: ${SHOP_NAME}
release_year: 2015
mail_cc:
    - ${ADMIN_MAIL}
ECCUBE_VERSION: 3.0.0-dev
customer_confirm_mail: false

form_country_enable: false
default_password: '******'

target_id_unused: 0
target_id_left: 1
target_id_main_head: 2
target_id_right: 3
target_id_main_foot: 4
target_id_top: 5
target_id_bottom: 6
target_id_head: 7
target_id_head_top: 8
target_id_footer_bottom: 9
target_id_header_internal: 10
__EOF__
}


#######################################################################
# Install

#-- Update Permissions
echo "update permissions..."
adjust_directory_permissions



#-- Setup Initial Data
echo "copy images..."
cp -rv "./html/install/save_image" "./html/upload/"

echo "creating ${CONFIG_PHP}..."
create_config_php

echo "creating ${CONFIG_YML}..."
create_config_yml

echo "get composer..."
curl -sS https://getcomposer.org/installer | php

echo "install composer..."
php ./composer.phar install --dev --no-interaction



#-- Setup Database
SQL_DIR="./html/install/sql"

case "${DBTYPE}" in
"pgsql" )
    # PostgreSQL
    echo "dropdb..."
    sudo -u ${PGUSER} ${DROPDB} ${DBNAME}

    echo "createdb..."
    sudo -u ${PGUSER} ${CREATEDB} -U ${DBUSER} ${DBNAME}

    echo "create table..."
    ./vendor/bin/doctrine orm:schema-tool:create

    echo "insert data..."
    sudo -u ${PGUSER} ${PSQL} -U ${DBUSER} -f ${SQL_DIR}/insert_data_pgsql.sql ${DBNAME}

    echo "create sequence..."
    create_sequence_tables

    echo "execute optional SQL..."
    get_optional_sql | sudo -u ${PGUSER} ${PSQL} -U ${DBUSER} ${DBNAME}
;;
"mysql" )
    DBPASS=`echo $DBPASS | tr -d " "`
    if [ -n ${DBPASS} ]; then
        PASSOPT="--password=$DBPASS"
        CONFIGPASS=$DBPASS
    fi

    # MySQL
    echo "dropdb..."
    ${MYSQL} -u ${ROOTUSER} ${PASSOPT} -e "drop database \`${DBNAME}\`"

    echo "createdb..."
    ${MYSQL} -u ${ROOTUSER} ${PASSOPT} -e "create database \`${DBNAME}\` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"

    #echo "grant user..."
    #${MYSQL} -u ${ROOTUSER} ${PASSOPT} -e "GRANT ALL ON \`${DBNAME}\`.* TO '${DBUSER}'@'%' IDENTIFIED BY '${DBPASS}'"

    echo "create table..."
    ./vendor/bin/doctrine orm:schema-tool:create

    echo "insert data..."
    ${MYSQL} -u ${DBUSER} ${PASSOPT} --default-character-set=utf8  ${DBNAME} < ${SQL_DIR}/insert_data_mysql.sql

    echo "execute optional SQL..."
    get_optional_sql | ${MYSQL} -u ${DBUSER} ${PASSOPT} ${DBNAME}
;;
esac

# DB migrator
php app/console migrations:migrate  --no-interaction

echo "Finished Successful!"
