# Manage Heroku Infrastructure with Terraform

## Terraform
Terraform is an open source tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned. Terraform enables you to safely and predictably create, change, and improve your infrastructure.

Apart from the simplicity of Terraform, this tool can be used with different providers making it the best choice when working with different service. It also embraces the separation of concern (modularity), which makes it easy to break down the infrastructure into small components that can be re-used and easily maintained. You can find more details on Terraform on the official website.

## Heroku and Terraform
Terraform works seamlessly with Heroku API. It simplifies how we interact with Heroku, making provisioning of Heroku infrastructure as simple as running terraform apply. Through its declarative language HCL, we can express the resources we need and terraform will take care of creating them for us.

## What we will be building
 We will be building a simple Heroku infrastructure as a demonstration. Below are the services we will be provisioning.


  - Pipeline
  - 2 apps ( staging, production)
  - Add ons(database, papertrail, newrelic, rollbar)
    
## Terraform Installation
  [Install Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)

## Setting up the project
At this point, you should have a Heroku account set up, and terraform binaries installed on your machine. To confirm that terraform has been correctly installed, run terraform version from the command line. You should get a response similar to the one below.
```
C:\terraform>terraform version
Terraform v0.12.2
```
The version may be different from mine depending on what version you have installed, nevertheless, the functionality will still be the same. Run the command below to create a working directory and initial terraform files.

Create `heroku-terraform` dirctory and add the following files
```
-addons.tf
-apps.tf
-main.tf
-pipeline.tf
-variables.tf
```


## Setting up Heroku Provider
Terraform is agnostic to the underlying platforms by supporting providers. A provider is responsible for communication with the API and exposing resources. Terraform supports a lot of providers which can be found in the providers’ section of the documentation.

In our case, we will be using the heroku provider which will be responsible for communicating our intent to through the Heroku API. Heroku provider docs can be found at the Heroku section under providers.

The snippet below shows the syntax of creating a Heroku provider, and it to the `main.tf` file.
```
# Configure heroku provider

provider "heroku" {
  email   = "${var.heroku_account_email}"
  api_key = "${var.heroku_api_key}"
}

```
Providers are defined using the providerkeyword followed by the name of the provider in this case heroku. The Heroku provider requires two arguments email and api_key in order to communicate with your Heroku account.

We have used variable interpolation to dynamically pass this values to the provider. This not only makes our scripts dynamic it enables us to not expose sensitive values to the world. All variables used must be declared prior to being used.
For more information refer to terraform [variables](https://www.terraform.io/docs/configuration/variables.html) documentation

## Create Heroku Pipeline
Heroku pipelines allow us to group our application environments. This means you can have your dev, staging and production apps grouped in the same place. This setup provides a much easier way to manage your applications, especially if you have many applications in one account.

Traditionally you will have to navigate through the Heroku dashboard to create a pipeline, which might take 2–3 minutes. But with terraform, it gets easier.

Add the code snippet below to `pipeline.tf`
```
# Heroku pipeline

resource "heroku_pipeline" "pipeline" {
  name = "${var.heroku_pipeline_name}"
}

resource "heroku_pipeline_coupling" "staging" {
  app      = "${heroku_app.staging.name}"
  pipeline = "${heroku_pipeline.pipeline.id}"
  stage    = "staging"
}

resource "heroku_pipeline_coupling" "production" {
  app      = "${heroku_app.production.name}"
  pipeline = "${heroku_pipeline.pipeline.id}"
  stage    = "production"
}

```
Update the `variables.tf` file with the newly added pipeline variable.
```
# Heroku Provider variables
variable "heroku_account_email" {}

variable "heroku_api_key" {}


# Pipeline variables
variable "heroku_pipeline_name" {}


# Apps variables
variable "heroku_staging_app" {}
variable "heroku_production_app" {}
variable "heroku_region" {}

variable "heroku_app_buildpacks" {
  type = "list"
}


# Addons variable staging
variable "heroku_staging_database" {}
variable "heroku_staging_newrelic" {}
variable "heroku_staging_papertrail" {}
variable "heroku_staging_rollbar" {}

# Addons variable production
variable "heroku_production_database" {}
variable "heroku_production_newrelic" {}
variable "heroku_production_papertrail" {}
variable "heroku_production_rollbar" {}

```
Add the code snippet below to your `apps.tf` file.
```
# Heroku apps

resource "heroku_app" "staging" {
  name   = "${var.heroku_staging_app}"
  region = "${var.heroku_region}"

  #set config variables
  config_vars = {
    APP_ENV = "staging"
  }

  buildpacks = "${var.heroku_app_buildpacks}"
}

resource "heroku_app" "production" {
  name   = "${var.heroku_production_app}"
  region = "${var.heroku_region}"

  #set config variables
  config_vars = {
    APP_ENV = "production"
  }

  buildpacks = "${var.heroku_app_buildpacks}"
}

```



