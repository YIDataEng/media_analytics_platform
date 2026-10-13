# Media Analytics Platform

Pipeline ELT qui réunit les performances publicitaires de Meta Ads et de Google Ads dans BigQuery, et produit avec dbt des tables d'analyse fiables, lues dans un tableau de bord Looker Studio.

## Problème

Une agence marketing pilote ses campagnes sur Meta et sur Google. Chaque plateforme a son format, ses noms de colonnes et ses corrections tardives.

- Le même indicateur est recalculé différemment d'un tableau de bord à l'autre.
- Comparer les deux plateformes demande un retraitement à la main.
- Relancer une extraction duplique des lignes, et gonfle les dépenses et les conversions.

## Action

Une seule chaîne, de l'API jusqu'au tableau de bord :

```
Meta Ads (API réelle) ─┐
                       ├─► validation ─► BigQuery (raw) ─► dbt : staging ─► intermediate ─► marts ─► Looker Studio
Google Ads (simulé) ───┘
```

| Étape | Ce qui est fait | État |
|---|---|---|
| Environnement | Python géré par uv, versions verrouillées, ruff à chaque commit, intégration continue | fait |
| Infrastructure | Projet GCP, datasets BigQuery et droits d'accès décrits avec Terraform | prévu |
| Ingestion | Un connecteur par plateforme, avec la même interface, pour en ajouter d'autres sans toucher au reste | prévu |
| Validation | Chaque lot est contrôlé contre un contrat de données ; un lot invalide n'est pas chargé | prévu |
| Chargement | Remplacement d'une fenêtre de dates dans une transaction : rejouer un chargement donne le même résultat | prévu |
| Transformation | dbt en trois couches, un grain unique (campagne × jour × plateforme), indicateurs définis une seule fois | prévu |
| Tests | Tests Python, tests de données dbt exécutés sur BigQuery | prévu |
| Déploiement | Image Docker exécutée chaque jour par Cloud Run Jobs, enchaînée par Cloud Workflows | prévu |
| Restitution | Tableau de bord Looker Studio branché sur les tables finales : rentabilité par campagne, comparaison Meta / Google | prévu |

Les données Google Ads sont simulées et étiquetées comme telles dans chaque table. Les données Meta Ads viennent de l'API réelle.

## Stack technique

| Domaine | Outils |
|---|---|
| Langages | Python 3.14, SQL |
| Entrepôt de données | BigQuery |
| Transformation | dbt |
| Restitution | Looker Studio |
| Infrastructure | Terraform, Google Cloud |
| Exécution | Docker, Cloud Run Jobs, Cloud Workflows |
| Intégration continue | GitHub Actions |
| Qualité | ruff, sqlfluff, pytest, pre-commit |
| Gestion du projet Python | uv |

## Installation

```bash
git clone https://github.com/YIDataEng/media_analytics_platform.git
cd media_analytics_platform
uv sync --all-groups
uv run pre-commit install
cp .env.example .env
```

`uv` installe Python et les bibliothèques aux versions exactes du fichier `uv.lock`.
