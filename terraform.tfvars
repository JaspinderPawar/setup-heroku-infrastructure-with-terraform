# terraform variables values, update this file with your own values
heroku_account_email = "heroku_account_email"

heroku_api_key = "heroku_api_key"

heroku_pipeline_name = "heroku-terraform"

heroku_staging_app = "heroku-terraform-staging"

heroku_production_app = "heroku-terraform-production"

heroku_region = "us"


heroku_staging_database = "heroku-postgresql:hobby-dev"
heroku_staging_newrelic = "newrelic:wayne"
heroku_staging_papertrail= "papertrail:choklad"
heroku_staging_rollbar = "rollbar:free"


heroku_production_database = "heroku-postgresql:hobby-dev"
heroku_production_newrelic = "newrelic:wayne"
heroku_production_papertrail= "papertrail:choklad"
heroku_production_rollbar = "rollbar:free"


heroku_app_buildpacks = [
  "heroku/nodejs",
]
