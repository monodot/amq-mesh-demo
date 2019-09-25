router {
    mode: interior
    id: ${HOSTNAME}
}

listener {
    host: 0.0.0.0
    port: amqp
    authenticatePeer: no
    saslMechanisms: ANONYMOUS
}

listener {
    host: 0.0.0.0
    port: 55672
    role: inter-router
    authenticatePeer: no
    saslMechanisms: ANONYMOUS
}

sslProfile {
    name: service_tls
    caCertFile: /etc/broker-client-certs/ca.crt
    certFile: /etc/broker-client-certs/tls.crt
    privateKeyFile: /etc/broker-client-certs/tls.key
}

listener {
    host: 0.0.0.0
    port: amqps
    authenticatePeer: no
    saslMechanisms: ANONYMOUS
    sslProfile: service_tls
}

listener {
    host: 0.0.0.0
    port: 8672
    authenticatePeer: no
    saslMechanisms: ANONYMOUS
    sslProfile: service_tls
    http: true
    httpRootDir: /usr/share/qpid-dispatch/console
}

## LOCAL_BROKER_CONNECTOR ##

## MESH_ROUTER_CONNECTOR ##

## WAYPOINT ##

## AUTOLINKS_IN ##

## AUTOLINKS_OUT ##

log {
    module: ROUTER_CORE
    enable: info+
    includeTimestamp: yes
}
