variable "project_id" {
  description = "Identifiant du projet Google Cloud."
  type        = string
}

variable "region" {
  description = "Région de toutes les ressources. Celle d'un dataset BigQuery ne se change plus après sa création."
  type        = string
  default     = "europe-west1"
}

variable "dataset_prefix" {
  description = "Préfixe des datasets BigQuery (ads_raw, ads_staging, ads_marts)."
  type        = string
  default     = "ads"
}
