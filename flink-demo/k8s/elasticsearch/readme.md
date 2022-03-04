### Configurations taken from elasticsearch website
[Installation Guide](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.html)

1. Install custom resource definitions

kubectl create -f https://download.elastic.co/downloads/eck/2.0.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.0.0/operator.yaml

2. Monitor operator logs

kubectl -n elastic-system logs -f statefulset.apps/elastic-operator

>> kubectl create -f https://download.elastic.co/downloads/eck/2.0.0/crds.yaml
customresourcedefinition.apiextensions.k8s.io/agents.agent.k8s.elastic.co created
customresourcedefinition.apiextensions.k8s.io/apmservers.apm.k8s.elastic.co created
customresourcedefinition.apiextensions.k8s.io/beats.beat.k8s.elastic.co created
customresourcedefinition.apiextensions.k8s.io/elasticmapsservers.maps.k8s.elastic.co created
customresourcedefinition.apiextensions.k8s.io/elasticsearches.elasticsearch.k8s.elastic.co created
customresourcedefinition.apiextensions.k8s.io/enterprisesearches.enterprisesearch.k8s.elastic.co created
customresourcedefinition.apiextensions.k8s.io/kibanas.kibana.k8s.elastic.co created

>> ubectl apply -f https://download.elastic.co/downloads/eck/2.0.0/operator.yaml
namespace/elastic-system created
serviceaccount/elastic-operator created
secret/elastic-webhook-server-cert created
configmap/elastic-operator created
clusterrole.rbac.authorization.k8s.io/elastic-operator created
clusterrole.rbac.authorization.k8s.io/elastic-operator-view created
clusterrole.rbac.authorization.k8s.io/elastic-operator-edit created
clusterrolebinding.rbac.authorization.k8s.io/elastic-operator created
service/elastic-webhook-server created
statefulset.apps/elastic-operator created
validatingwebhookconfiguration.admissionregistration.k8s.io/elastic-webhook.k8s.elastic.co created

>> kubectl get elasticsearch 

kubectl get elasticsearch,kibana
kubectl delete elasticsearch quickstart
kubectl delete elasticsearch minicluster
kubectl delete kibana quickstart



  - name: masters
    count: 1
    config:
      # On Elasticsearch versions before 7.9.0, replace the node.roles configuration with the following:
      # node.master: true
      node.roles: ["master"]
      xpack.ml.enabled: true
      #node.remote_cluster_client: false


curl  -u "elastic:$PASSWORD" -k -v -XGET -H 'Content-Type: application/json'  "https://localhost:9200/_cluster/state?pretty" 
curl -u "elastic:$PASSWORD" -k "https://localhost:9200/_cluster/state?pretty" 

curl -u "minicluster-es-elastic-user:$PASSWORD" -H 'Content-Type: application/json' -k "https://localhost:9200/_cluster/state?pretty" 

curl -H 'Content-Type: application/json' -k -X PUT "https://localhost:9200/test?pretty" -d'
{
 "settings": {
    "number_of_shards": 1
  },
  "mappings": {
    "properties": {
      "field1": { "type": "text" }
    }
  }
}'

escurl -u "elastic:$(kubectl get secret minicluster-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')" \
-X PUT "https://localhost:9200/test?pretty" -d'
{
 "settings": {
    "number_of_shards": 1
  },
  "mappings": {
    "properties": {
      "field1": { "type": "text" }
    }
  }
}'
