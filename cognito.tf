data "template_file" "invitation_email" {
  template = file("${path.module}/template/invitation.html")
}

resource "aws_cognito_user_pool" "this" {
  name              = "proguider"
  mfa_configuration = "OFF"

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  username_configuration {
    case_sensitive = false
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_uppercase = true
    require_symbols   = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
    invite_message_template {
      email_subject = "Invitation to proguider"
      email_message = data.template_file.invitation_email.rendered
      sms_message   = "Your username is {username} and temporary password is {####}."
    }
  }


  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  // Standard attributes
  // https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-attributes.html#cognito-user-pools-standard-attributes
  schema {
    name                     = "family_name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 1
      max_length = 30
    }
  }

  schema {
    name                     = "name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 4
      max_length = 20
    }
  }


  tags = {
    Name        = "proguider"
  }

}

resource "aws_cognito_user_group" "this" {
  name         = "basic"
  description  = "Basic users"
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "reza"
  generate_secret                      = false
  user_pool_id                         = aws_cognito_user_pool.this.id
  explicit_auth_flows                  = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["code"]
  callback_urls                        = ["https://test.proguider.com/"]
  allowed_oauth_scopes                 = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows_user_pool_client = true
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = "test-proguider"
  user_pool_id = aws_cognito_user_pool.this.id
}