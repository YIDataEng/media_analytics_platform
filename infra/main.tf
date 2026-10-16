provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  # Une entrée par couche : la clé donne le nom du dataset, la valeur sa description.
  datasets = {
    raw     = "Données brutes des plateformes publicitaires, telles qu'extraites."
    staging = "Données typées et dédupliquées, une table par source (dbt)."
    marts   = "Tables d'analyse lues par Looker Studio (dbt)."
  }

  labels = {
    projet   = "media-analytics-platform"
    gere_par = "terraform"
  }
}

# API BigQuery : déjà active sur un nouveau projet, déclarée ici pour ne pas en dépendre.
resource "google_project_service" "bigquery" {
  service = "bigquery.googleapis.com"

  # Si la ressource est retirée de Terraform : l'oublier, sans couper l'API.
  disable_on_destroy = false
  deletion_policy    = "ABANDON"
}

resource "google_bigquery_dataset" "layer" {
  for_each = local.datasets

  dataset_id  = "${var.dataset_prefix}_${each.key}"
  location    = var.region
  description = each.value
  labels      = local.labels

  # Refuse de supprimer un dataset qui contient encore des tables.
  delete_contents_on_destroy = false

  depends_on = [google_project_service.bigquery]
}
