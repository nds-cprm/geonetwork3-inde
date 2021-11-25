FROM geonetwork:3.10.2

ARG GEONETWORK_MODS_DOWNLOAD_URL=https://metadados.inde.gov.br/downloads/alteracoes-geonetwork-20210423.zip
ARG MGB2_DOWNLOAD_URL=https://metadados.inde.gov.br/downloads/perfil-mgb2-20210527.zip
ARG MGB_LEGADO_DOWNLOAD_URL=https://metadados.inde.gov.br/downloads/perfis-mgb-20210527.zip

RUN set -xe && \
    apt-get -y update && \
    apt-get -y install locales wget unzip && \
    sed -i '/pt_BR.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LC_ALL=pt_BR.UTF-8 \
    LANG=pt_BR.UTF-8 \
    LANGUAGE=pt_BR:pt \
    CATALINA_OPS="-Xms2048m -Xmx2048m -XX:NewRatio=2 -XX:SurvivorRatio=10"

WORKDIR /tmp

# Modificações Geonetwork
RUN set -xe && \    
    wget -O alteracoes-geonetwork.zip ${GEONETWORK_MODS_DOWNLOAD_URL} && \
    unzip -qo alteracoes-geonetwork.zip -d ${CATALINA_HOME}/webapps && \
    rm -rf alteracoes-geonetwork.zip

# Instalação do legado
RUN set -xe && \    
    wget -O mgb-legado.zip ${MGB_LEGADO_DOWNLOAD_URL} && \
    unzip -q mgb-legado.zip || test $? -le 1 && \
    cp -rfpv mgb/iso19139* ${CATALINA_HOME}/webapps/geonetwork/WEB-INF/data/config/schema_plugins && \
    cp -rfpv mgb/config-spring-mgb.xml ${CATALINA_HOME}/webapps/geonetwork/WEB-INF && \
    sed -i '49i <import resource="config-spring-mgb.xml"/>' ${CATALINA_HOME}/webapps/geonetwork/WEB-INF/config-spring-geonetwork.xml && \
    rm -rf mgb-legado.zip mgb/

# Instalação do MGB 2
RUN set -xe && \    
    wget -O mgb2.zip ${MGB2_DOWNLOAD_URL} && \
    unzip -q mgb2.zip || test $? -le 1 && \
    cp -rfpv mgb2/iso19115* ${CATALINA_HOME}/webapps/geonetwork/WEB-INF/data/config/schema_plugins && \
    cp -rfpv mgb2/config-spring-mgb-2.xml ${CATALINA_HOME}/webapps/geonetwork/WEB-INF && \
    sed -i '49i <import resource="config-spring-mgb-2.xml"/>' $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-spring-geonetwork.xml && \
    rm -rf mgb2.zip mgb2/

# TODO: Habilitar o driver do Postgis no Geonetwork3
# sed -i 's/config-db\/postgres\.xml/config-db\/postgres\-postgis\.xml/g' $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-node/srv.xml 

WORKDIR ${CATALINA_HOME}
   
