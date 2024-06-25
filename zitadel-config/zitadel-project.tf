# ===============
# Zitadel Project
# ===============

// Project
resource "zitadel_project" "project" {
  name                     = var.zitadel_org.project_name
  org_id                   = zitadel_org.org.id
  project_role_assertion   = false
  project_role_check       = false
  has_project_check        = true
  private_labeling_setting = "PRIVATE_LABELING_SETTING_ALLOW_LOGIN_USER_RESOURCE_OWNER_POLICY"
}

// Yandex Cloud Federation
resource "yandex_organizationmanager_saml_federation" "yc_federation" {
  name                         = var.zitadel_org.yc_fed_name
  description                  = var.zitadel_org.yc_fed_descr
  organization_id              = var.zitadel_org.yc_org_id
  issuer                       = "${var.system.base_url}/saml/v2/metadata"
  sso_url                      = "${var.system.base_url}/saml/v2/SSO"
  sso_binding                  = "POST"
  auto_create_account_on_login = false
  case_insensitive_name_ids    = false
  security_settings {
    encrypted_assertions = false
  }
}

// Download SSL Certificate from Zitadel
resource "terracurl_request" "download_zitadel_ssl_cert" {
  name           = "zitadel-ssl-cert"
  url            = "${var.system.base_url}/saml/v2/certificate"
  method         = "GET"
  response_codes = [200]
}

// Upload Zitadel SSL Certificate to YC Federation
resource "terracurl_request" "upload_cert_to_yc_federation" {
  name         = "upload-cert-to-yc-federation"
  url          = "https://organization-manager.api.cloud.yandex.net/organization-manager/v1/saml/certificates"
  method       = "POST"
  request_body = <<EOF
    {
      "federationId": "${yandex_organizationmanager_saml_federation.yc_federation.id}",
      "name": "${yandex_organizationmanager_saml_federation.yc_federation.name}",
      "description": "IDP SSL Certificate.",
      "data": "${terracurl_request.download_zitadel_ssl_cert.response}" 
    }
  EOF
  headers = {
    Authorization = "Bearer ${var.system.yc_token}"
  }
  response_codes = [200]

  lifecycle {
    ignore_changes = [headers]
  }

  depends_on = [yandex_organizationmanager_saml_federation.yc_federation]
}

locals {
  yc_fed_url = "https://console.cloud.yandex.ru/federations/${yandex_organizationmanager_saml_federation.yc_federation.id}"
}

// Zitadel SAML Application for YC Integration
resource "zitadel_application_saml" "yc_saml" {
  org_id       = zitadel_org.org.id
  project_id   = zitadel_project.project.id
  name         = var.zitadel_org.saml_app_name
  metadata_xml = "<?xml version=\"1.0\"?> <md:EntityDescriptor xmlns:md=\"urn:oasis:names:tc:SAML:2.0:metadata\" entityID=\"${local.yc_fed_url}\"> <md:SPSSODescriptor AuthnRequestsSigned=\"false\" WantAssertionsSigned=\"false\" protocolSupportEnumeration=\"urn:oasis:names:tc:SAML:2.0:protocol\"> <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified</md:NameIDFormat> <md:AssertionConsumerService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST\" Location=\"${local.yc_fed_url}\" index=\"1\"/> </md:SPSSODescriptor>\n</md:EntityDescriptor>"
  # validUntil=\"2025-01-26T17:48:38Z\" cacheDuration=\"PT604800S\"

  depends_on = [yandex_organizationmanager_saml_federation.yc_federation]
}
