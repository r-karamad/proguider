resource "aws_cognito_user_pool" "this" {
  name = "proguider"

  alias_attributes = ["email"]
  auto_verified_attributes = ["email"]

  email_verification_subject = "Verify your email"

  password_policy {
    minimum_length = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers = true
    require_symbols = true
  }

  admin_create_user_config {
    invite_message_template {
    }
  }
}