variable "codepipeline-region" {
  type        = string
  description = "The codepipeline region"
}

variable "codepipeline-name" {
  type        = string
  description = "the name of the code pipeline"
}

variable "default_tags" {
  type        = map(string)
  description = "Default Tags assign to resouces"
}
