/**
 * Central Logging Solution using Elasticsearch, Fluentbit, and Kibana
 */

variable "name" {}

variable "namespace" {
  default = "default"
}

variable "storage_class_name" {}
variable "storage" {}

variable "es_replicas" {}

module "elasticsearch" {
  source             = "git::https://github.com/mingfang/terraform-provider-k8s.git//modules/elasticsearch"
  name               = "${var.name}-es"
  namespace          = "${var.namespace}"
  image              = "docker.elastic.co/elasticsearch/elasticsearch:6.5.0"
  replicas           = "${var.es_replicas}"
  storage_class_name = "${var.storage_class_name}"
  storage            = "${var.storage}"
}

module "fluentbit-es" {
  source                    = "git::https://github.com/mingfang/terraform-provider-k8s.git//modules/fluentbit-es"
  name                      = "${var.name}-fluentbit"
  namespace                 = "${var.namespace}"
  fluent_elasticsearch_host = "${module.elasticsearch.name}"
  fluent_elasticsearch_port = "${module.elasticsearch.port}"
}

module "kibana" {
  source            = "git::https://github.com/mingfang/terraform-provider-k8s.git//modules/kibana"
  name              = "${var.name}-kibana"
  namespace         = "${var.namespace}"
  image             = "registry.rebelsoft.com/kibana"
  elasticsearch_url = "http://${module.elasticsearch.name}:${module.elasticsearch.port}"
}

output "elasticsearch_name" {
  value = "${module.elasticsearch.name}"
}

output "elasticsearch_port" {
  value = "${module.elasticsearch.port}"
}

output "kibana_name" {
  value = "${module.kibana.name}"
}

output "kibana_port" {
  value = "${module.kibana.port}"
}