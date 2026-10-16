output "datasets" {
  description = "Datasets BigQuery créés, par couche."
  value       = { for layer, dataset in google_bigquery_dataset.layer : layer => dataset.dataset_id }
}
