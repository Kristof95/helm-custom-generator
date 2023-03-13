#!/bin/bash

FOUR_SPACE="    "
TWO_SPACE="  "
NEW_LINE="\n"

apps=( `ls -1 apps/` )
for app in ${apps[@]}
do
    echo "------------------------ $app ------------------------"
    source ./apps/$app
    global_app_configs=""
    app_configs="" 
    app_config_len=${#APP_CONFIG_MAP[@]}

    global_app_secrets=""
    app_secrets=""
    app_secrets_len=${#APP_SECRET_MAP[@]}

    echo "$APP_NAME CONFIGS:"
    cat ./apps/$app

    CHARTS_VALUES="charts/values.yaml"
    CHARTS_DUMMY="charts/dummy"
    GENERATED_SOURCES_VALUES="generated-sources/charts/values.yaml"
      
    if [[ $app_config_len > 0 ]];
    then
        echo "[DEBUG] Append configs to $GENERATED_SOURCES_VALUES"
        app_configs="\n"
        global_app_configs="\n"
        for config in "${APP_CONFIG_MAP[@]}"; do
            KEY="${config%%:*}"
            VALUE="${config##*:}"
            app_configs+="$TWO_SPACE$KEY: $VALUE$NEW_LINE"
            global_app_configs+="$FOUR_SPACE$KEY: $VALUE$NEW_LINE"
        done
    else 
        echo "[DEBUG] Skip configs append..."
        app_configs="{}"
        global_app_configs="{}"
    fi


    if [[ $app_secrets_len > 0 ]];
    then
        echo "[DEBUG] Append secrets to $GENERATED_SOURCES_VALUES"
        global_app_secrets="\n"
        app_secrets="\n"
        for secret in "${APP_SECRET_MAP[@]}"; do
            KEY="${secret%%:*}"
            VALUE="${secret##*:}"
            global_app_secrets+="$FOUR_SPACE$KEY: $VALUE$NEW_LINE"
            app_secrets+="$TWO_SPACE$KEY: $VALUE$NEW_LINE"
        done
    else 
        echo "[DEBUG] Skip secrets append..."
        app_secrets="{}"
        global_app_secrets={}
    fi

    if [[ ! -d "generated-sources/charts/$APP_NAME" ]];
    then
        mkdir -p generated-sources/charts/$APP_NAME
        cp -r $CHARTS_DUMMY/* generated-sources/charts/$APP_NAME

        echo "[CHECK] Check if $GENERATED_SOURCES_VALUES exists"
        if [[ -f "$GENERATED_SOURCES_VALUES" ]];
        then
            echo "[DEBUG] Append charts/values.yaml content to $CHARTS_VALUES"
            cat $CHARTS_VALUES >> $GENERATED_SOURCES_VALUES
        else
            echo "[DEBUG] Copying charts/values.yaml to generated-sources folder"
            cp $CHARTS_VALUES generated-sources/charts
        fi

####################INTERNAL####################
        APP_INTERNAL_VALUES="generated-sources/charts/$APP_NAME/values.yaml"
        echo "[DEBUG] Replace placeholders at $APP_INTERNAL_VALUES"
        find generated-sources/charts/$APP_NAME -type f -exec sed -i "s/dummy/$APP_NAME/g" {} \;
        sed -i "s/DUMMY_APP_NAME/$APP_NAME/g" $APP_INTERNAL_VALUES
        sed -i "s/DUMMY_IMAGE_REPOSITORY/$APP_IMAGE_REPOSITORY/g" $APP_INTERNAL_VALUES
        sed -i "s/DUMMY_IMAGE_TAG/$APP_IMAGE_TAG/g" $APP_INTERNAL_VALUES
        sed -i "s/DUMMY_SERVICE_PPORT/$APP_SERVICE_PORT/g" $APP_INTERNAL_VALUES
        sed -i "s/DUMMY_INGRESS_PLACEHOLDER/$APP_INGRESS_URL/g" $APP_INTERNAL_VALUES
        sed -i "s/DUMMY_CONFIGURATION/$app_configs/g" $APP_INTERNAL_VALUES
        sed -i "s/DUMMY_SECRETS/$app_secrets/g" $APP_INTERNAL_VALUES
        sed -i "s/DUMMY_RESOURCE_LIMIT_CPU/$APP_RESOURCE_LIMIT_CPU/g" $APP_INTERNAL_VALUES
        sed -i "s/DUMMY_RESOURCE_LIMIT_MEMORY/$APP_RESOURCE_LIMIT_MEMORY/g" $APP_INTERNAL_VALUES
        sed -i "s/DUMMY_RESOURCE_REQUEST_CPU/$APP_RESOURCE_REQUEST_CPU/g" $APP_INTERNAL_VALUES
        sed -i "s/DUMMY_RESOURCE_REQUEST_MEMORY/$APP_RESOURCE_REQUEST_MEMORY/g" $APP_INTERNAL_VALUES

####################GLOBAL####################     
        echo "[DEBUG] Replace placeholders at $GENERATED_SOURCES_VALUES"
        sed -i "s/DUMMY_APP_NAME/$APP_NAME/g" $GENERATED_SOURCES_VALUES
        sed -i "s/DUMMY_IMAGE_REPOSITORY/$APP_IMAGE_REPOSITORY/g" $GENERATED_SOURCES_VALUES
        sed -i "s/DUMMY_IMAGE_TAG/$APP_IMAGE_TAG/g" $GENERATED_SOURCES_VALUES
        sed -i "s/DUMMY_SERVICE_PPORT/$APP_SERVICE_PORT/g" $GENERATED_SOURCES_VALUES
        sed -i "s/DUMMY_INGRESS_PLACEHOLDER/$APP_INGRESS_URL/g" $GENERATED_SOURCES_VALUES
        sed -i "s/DUMMY_CONFIGURATION/$global_app_configs/g" $GENERATED_SOURCES_VALUES
        sed -i "s/DUMMY_SECRETS/$global_app_secrets/g" $GENERATED_SOURCES_VALUES
        sed -i "s/DUMMY_RESOURCE_LIMIT_CPU/$APP_RESOURCE_LIMIT_CPU/g" $GENERATED_SOURCES_VALUES
        sed -i "s/DUMMY_RESOURCE_LIMIT_MEMORY/$APP_RESOURCE_LIMIT_MEMORY/g" $GENERATED_SOURCES_VALUES
        sed -i "s/DUMMY_RESOURCE_REQUEST_CPU/$APP_RESOURCE_REQUEST_CPU/g" $GENERATED_SOURCES_VALUES
        sed -i "s/DUMMY_RESOURCE_REQUEST_MEMORY/$APP_RESOURCE_REQUEST_MEMORY/g" $GENERATED_SOURCES_VALUES
    else
        echo "[CHECK] generated-sources/charts/$APP_NAME already existing!"
    fi
    echo "------------------------ DONE ------------------------"
    echo -e "\n"
done

