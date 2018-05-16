#!/bin/bash -e

PERMISSIONS_OK=0

if [ ! -r "$GF_PATHS_CONFIG" ]; then
    echo "GF_PATHS_CONFIG='$GF_PATHS_CONFIG' is not readable."
    PERMISSIONS_OK=1
fi

if [ ! -w "$GF_PATHS_DATA" ]; then
    echo "GF_PATHS_DATA='$GF_PATHS_DATA' is not writable."
    PERMISSIONS_OK=1
fi

if [ ! -r "$GF_PATHS_HOME" ]; then
    echo "GF_PATHS_HOME='$GF_PATHS_HOME' is not readable."
    PERMISSIONS_OK=1
fi

if [ $PERMISSIONS_OK -eq 1 ]; then
    echo "You may have issues with file permissions, more information here: http://docs.grafana.org/installation/docker/#migration-from-a-previous-version-of-the-docker-container-to-5-1-or-later"
fi

if [ ! -d "$GF_PATHS_PLUGINS" ]; then
    mkdir "$GF_PATHS_PLUGINS"
fi



# cat $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
if [[ -z "${DS_NAME}" ]]; then
    echo "Variable: DS_NAME not set"
else
#     cat $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
    sed -i -e "s#name:.*#name: $DS_NAME#" $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml   
fi


if [[ -z "${DS_ACCESS}" ]]; then
    echo "Variable: DS_ACCESS not set"
else
#     cat $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
    sed -i -e "s#access:.*#access: $DS_ACCESS#" $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
fi

if [[ -z "${DS_TYPE}" ]]; then
    echo "Variable: DS_TYPE not set"
else
#     cat $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
    sed -i -e "s#type:.*#type: $DS_TYPE#" $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
fi

if [[ -z "${DS_DATABASE}" ]]; then
    echo "Variable: DS_DATABASE not set"
else
#     cat $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
    sed -i -e "s#database:.*#database: $DS_DATABASE#" $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
fi

if [[ -z "${DS_USER}" ]]; then
    echo "Variable: DS_USER not set"
else
#     cat $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
    sed -i -e "s#user:.*#user: $DS_USER#" $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
fi

if [[ -z "${DS_PASSWORD}" ]]; then
    echo "Variable: DS_PASSWORD not set"
else
#     cat $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
    sed -i -e "s#password:.*#password: $DS_PASSWORD#" $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
fi

if [[ -z "${DS_URL}" ]]; then
    echo "Variable: DS_URL not set"
else
#     cat $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
    sed -i -e "s#url:.*#url: $DS_URL#" $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml
fi

cat $GF_PATHS_PROVISIONING/datasources/influxDB_datasource.yaml



if [ ! -z ${GF_AWS_PROFILES+x} ]; then
    > "$GF_PATHS_HOME/.aws/credentials"

    for profile in ${GF_AWS_PROFILES}; do
        access_key_varname="GF_AWS_${profile}_ACCESS_KEY_ID"
        secret_key_varname="GF_AWS_${profile}_SECRET_ACCESS_KEY"
        region_varname="GF_AWS_${profile}_REGION"

        if [ ! -z "${!access_key_varname}" -a ! -z "${!secret_key_varname}" ]; then
            echo "[${profile}]" >> "$GF_PATHS_HOME/.aws/credentials"
            echo "aws_access_key_id = ${!access_key_varname}" >> "$GF_PATHS_HOME/.aws/credentials"
            echo "aws_secret_access_key = ${!secret_key_varname}" >> "$GF_PATHS_HOME/.aws/credentials"
            if [ ! -z "${!region_varname}" ]; then
                echo "region = ${!region_varname}" >> "$GF_PATHS_HOME/.aws/credentials"
            fi
        fi
    done

    chmod 600 "$GF_PATHS_HOME/.aws/credentials"
fi

if [ ! -z "${GF_INSTALL_PLUGINS}" ]; then
  OLDIFS=$IFS
  IFS=','
  for plugin in ${GF_INSTALL_PLUGINS}; do
    IFS=$OLDIFS
    grafana-cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install ${plugin}
  done
fi

exec grafana-server                                         \
  --homepath="$GF_PATHS_HOME"                               \
  --config="$GF_PATHS_CONFIG"                               \
  "$@"                                                      \
  cfg:default.log.mode="console"                            \
  cfg:default.paths.data="$GF_PATHS_DATA"                   \
  cfg:default.paths.logs="$GF_PATHS_LOGS"                   \
  cfg:default.paths.plugins="$GF_PATHS_PLUGINS"             \
  cfg:default.paths.provisioning="$GF_PATHS_PROVISIONING"