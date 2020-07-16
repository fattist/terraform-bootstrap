variable "OPSGENIE_SRE_ENDPOINT" { type = string }
variable "PROFILE" { type = string }
variable "REGION" { type = string }

variable "SHORT_ENV" {
  type = object({
    development = string
    production = string
    qa = string
    staging = string
  })
  default = {
    development = "dev"
    production = "prod"
    qa = "qa"
    staging = "uat"
  }
}