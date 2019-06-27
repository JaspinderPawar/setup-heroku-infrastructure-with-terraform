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

All terraform resources assume the following syntax.
```
resource "resource_name" "resource_identifier"{
    #argument
    
}
```

Update the `variables.tf` file and add variables.
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
## Create Heroku Apps
Now that we have our pipeline setup, let's create apps that will be attached to this pipeline. Terraform creates Heroku apps via `heroku_app` resource. This resource takes only one required argument `name` , however, you can pass other arguments to customize your app further if required.

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
Let's talk about what the code we have written above does. In `apps.tf` we have declared two apps resources identified as `heroku_staging_app, heroku_production_app`. Terraform will create two Heroku apps when this code block is executed.

## Attach Database Add-ons to the apps
Having setup up our apps, we need to create database add-ons that our deployed apps will use to persist data. To create a Heroku add-ons via Terraform we will use the heroku_addon resource. This resource takes three arguments app, plan and config . More information can be found on the Argument Reference section in the documentation.

Add the code snippet below to your `addons.tf` file.
```
# Addons

# Staging Addons
resource "heroku_addon" "database-staging" {
  app  = "${heroku_app.staging.name}"
  plan = "${var.heroku_staging_database}"
}
resource "heroku_addon" "newrelic-staging" {
  app = "${heroku_app.staging.name}"
  plan = "${var.heroku_staging_newrelic}"
}
resource "heroku_addon" "papertrail-staging" {
  app = "${heroku_app.staging.name}"
  plan = "${var.heroku_staging_papertrail}"
}
resource "heroku_addon" "rollbar-staging" {
  app = "${heroku_app.staging.name}"
  plan = "${var.heroku_staging_rollbar}"
}

# Production Addons
resource "heroku_addon" "database-production" {
  app  = "${heroku_app.production.name}"
  plan = "${var.heroku_production_database}"
}
resource "heroku_addon" "newrelic-production" {
  app  = "${heroku_app.production.name}"
  plan = "${var.heroku_production_newrelic}"
}
resource "heroku_addon" "papertrail-production" {
  app  = "${heroku_app.production.name}"
  plan = "${var.heroku_production_papertrail}"
}
resource "heroku_addon" "rollbar-production" {
  app  = "${heroku_app.production.name}"
  plan = "${var.heroku_production_rollbar}"
}
```
The code above creates `database`,`newrelic`, `papertrail` and `rollbar` add-ons and attaches them to the two apps we created earlier.You can add more add on if required.

## Attach Heroku Apps to Heroku Pipeline
Now that we have our apps, the only thing left is to attach them to the pipeline we created earlier. This is made possible by the heroku_pipeline_coupling resource. Once the apps have been created, they can be added to different stages in the pipeline

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
One thing you will notice that the app and pipeline arguments have been interpolated by variables we have not defined. This is because these values are outputs of other resources.

## Plan (Test) Changes
So far we have been writing code but we have not even tested if they work or not. Through terraform plan we can dry run our scripts against the provider and check if your scripts are okay. Lets to that

![alt text](https://cdn-images-1.medium.com/max/1600/1*mc6GrUwoFoYMe8bxD8iGSA.png)

The terraform init command is used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times.

When we run terraform plan, terraform will dry run your configuration against the provider API and verify whether what you have specified is possible. If what we declared is not possible you might get errors, which might range from the wrong resource to unique names such as Heroku apps.

Terraform plan also notifies us of how many resources will be created, updated or destroyed.

## Applying Changes
Once we are content with the changes, we can run terraform apply. This command will run the configuration against the provider and provision the resources for us.
![alt text](https://cdn-images-1.medium.com/max/1400/1*wE8_7fTdve5xZm8yteDgQg.png)
When terraform is applying your changes, it will report in real-time the progress of each resource declared. And once complete it also provides a report of resources created, changed, or destroyed.

Once the command has completed executing, visit your heroku dashboard, there should be a pipeline with three apps attached to it.

The pipeline.
![alt text](https://cdn-images-1.medium.com/max/1600/1*d6UN3YGCcxAie_vqPCFz3Q.png)

### The pipeline with 3 apps.
![alt text](https://github.com/JaspinderPawar/hello-chaos/blob/master/heroku-apps.png)

As you have noticed it took very little time from running the command to having your infrastructure up and running. As compared to the manual process. Since this scripts can versioned, we can quickly spin out the same infrastructure anytime and get the same results.

## Destroy Applied changes
In one way or the other, you might want to delete your infrastructure. Terraform provides you will a command terraform destroy. This command will nuke all the resources that were created by terraform apply command

![alt text](https://cdn-images-1.medium.com/max/800/1*GOHWpRkiH1A8OjuV-p4tMw.png)

## Conclusion
Automation is one of the key principles that DevOps engineers and Developers alike should learn to adopt it in their daily workflow. This approach helps to reduce the time spent on minor tasks and focus on improving and building products. It also introduces flexibility in that you can change and modify your infrastructure much easier as compared going the manual way.

Terraform works well with a lot of platforms and services, making it a perfect tool to use to manage your infrastructure. It can be used across most common services and cloud platforms.


