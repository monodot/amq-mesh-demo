# Mesh demo (instructions for OpenShift 3.11)

Create secrets (keys, certs, etc.):

    ./generate-keys.sh

Choose a project prefix so that your project name will not clash with other projects on a shared cluster:

    export PROJECT_BASE=xxxxx

## Building the Fuse receiver

Authenticate to the Red Hat container registry and create an imagestream for the Fuse image in your namespace (you won't need to do this if the Fuse 7 image streams are already installed in your cluster):

    export BUILD_PROJECT=${PROJECT_BASE}-build

    oc create secret docker-registry redhat-registry --docker-username=${RH_USERNAME} --docker-password=${RH_PASSWORD} --docker-server=registry.redhat.io -n ${BUILD_PROJECT}

    oc secrets link builder redhat-registry -n ${BUILD_PROJECT} --for=pull,mount

    oc import-image fuse7-java-openshift:1.3 -n ${BUILD_PROJECT} --from=registry.redhat.io/fuse7/fuse-java-openshift:1.3 --confirm

    mvn clean package -f remote-receiver/pom.xml

    oc apply -f build-binary.yml -n ${BUILD_PROJECT}

    oc start-build receiver-app -n ${BUILD_PROJECT} --from-file=remote-receiver/target/remote-receiver-1.0-SNAPSHOT.jar --follow

## Deploy the mesh router

Create router project, deploy secrets and a mesh router:

    export ROUTER_PROJECT=${PROJECT_BASE}-amqrouter1
    oc new-project ${ROUTER_PROJECT}

    oc create secret generic amq-external-client-certs \
        --from-file=ca.crt=certs/ca-cert.pem \
        --from-file=tls.crt=certs/client-cert.pem \
        --from-file=tls.key=certs/client-key.pem \
        -n ${ROUTER_PROJECT}

    oc create configmap mesh-router --from-file=qdrouterd.conf=mesh-demo/qdrouterd.mesh.conf --dry-run -o yaml | oc apply -n ${ROUTER_PROJECT} -f -

    oc process -f mesh-demo/amq-interconnect-1.3.yml \
        -p APPLICATION_NAME=mesh-router \
        -p BROKER_CERTS_SECRET=amq-external-client-certs \
        | oc apply -n ${ROUTER_PROJECT} -f -

## Deploying a region

Set the name of the region and create a project:

    export REGION=london
    oc new-project ${PROJECT_BASE}-${REGION}

Deploy remote secrets:

    oc create secret generic amq-external-client-certs \
        --from-file=ca.crt=certs/ca-cert.pem \
        --from-file=tls.crt=certs/client-cert.pem \
        --from-file=tls.key=certs/client-key.pem \
        -n ${PROJECT_BASE}-${REGION}

    oc create secret generic amqp-client-truststore \
        --from-file=client-jks.truststore=certs/client-jks.truststore \
        -n ${PROJECT_BASE}-${REGION}

    oc create secret generic amq-broker-keystore \
        --from-file=certs/broker.ks \
        -n ${PROJECT_BASE}-${REGION}

To stand up a broker & router:

    oc create service externalname mesh-router --external-name mesh-router.${ROUTER_PROJECT}.svc.cluster.local -n ${PROJECT_BASE}-${REGION}

    oc create configmap ${REGION}-broker --from-file=broker.xml=mesh-demo/configs/broker.${REGION}.xml --dry-run -o yaml | oc apply -n ${PROJECT_BASE}-${REGION} -f -

    oc process -f mesh-demo/amq-broker-73-ssl.yaml \
        -p AMQ_NAME=${REGION}-broker \
        -p APPLICATION_NAME=${REGION}-broker \
        -p AMQ_SECRET=amq-broker-keystore \
        | oc apply -n ${PROJECT_BASE}-${REGION} -f -

    oc create configmap ${REGION}-router --from-file=qdrouterd.conf=mesh-demo/configs/qdrouterd.${REGION}.conf --dry-run -o yaml | oc apply -n ${PROJECT_BASE}-${REGION} -f -

    oc process -f mesh-demo/amq-interconnect-1.3.yml \
        -p APPLICATION_NAME=${REGION}-router \
        -p BROKER_CERTS_SECRET=amq-external-client-certs \
        | oc apply -n ${PROJECT_BASE}-${REGION} -f -

## Deploying the receiver to a region

To deploy the receiver:

    oc policy add-role-to-user \
        system:image-puller system:serviceaccount:${PROJECT_BASE}-${REGION}:default \
        --namespace=${BUILD_PROJECT}

    oc process -f remote-receiver/deploy.yml -p APP_NAME=${REGION} -p IMAGE_STREAM_NAMESPACE=${BUILD_PROJECT} | oc apply -n ${PROJECT_BASE}-${REGION} -f -

Or you can use:

    oc create -f deploy.yml

Then use the web console to deploy.

Or if you want to use S2I build from GitHub:

    oc new-build https://github.com/monodot/amq-mesh-demo \
        --name=receiver-app \
        --context-dir=remote-receiver \
        --image-stream=fuse7-java-openshift:1.3
