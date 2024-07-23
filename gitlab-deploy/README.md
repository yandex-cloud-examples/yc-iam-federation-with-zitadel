
# Terraform модуль `gitlab-deploy` 

## Оглавление
* [Развёртывание экземпляра Gitlab](#gl-deploy)
* [Описание модуля](#gl-overview)
* [Входные параметры модуля](#gl-inputs)
* [Выходные параметры модуля](#gl-outputs)
* [Настройка Gitlab OmniAuth](#gl-omni)

## Развёртывание экземпляра Gitlab <a id="gl-deploy"/></a>

Перед запуском модуля необходимо выполнить развёртывание экземпляра Gitlab в сервисе [Yandex Managed Service for GitLab](https://yandex.cloud/ru/docs/managed-gitlab/).

Для выполнения развёртывания необходимо следовать [инструкции в документации](https://yandex.cloud/ru/docs/managed-gitlab/operations/instance/instance-create).


## Описание модуля <a id="gl-overview"/></a>

Модуль `gitlab-deploy` выполняет настройку предварительно развёрнутого экземпляра (Instance) в сервисе [Yandex Managed Service for GitLab](https://yandex.cloud/ru/docs/managed-gitlab/).


## Входные параметры модуля <a id="gl-inputs"/></a>

| Параметр (переменная) | Описание |
| - | -
| `gitlab.domain` | Имя Gitlab instance в домене `.gitlab.yandexcloud.net` |
| `gitlab.group_name` | Имя группы, которое будет создано в Gitlab. |
| `gitlab.token_file` | Путь к файлу с [Personal Access Token (PAT)](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) для работы с Gitlab. |


## Выходные параметры модуля <a id="gl-outputs"/></a>

Модуль не возвращает выходных параметров.

## Настройка Gitlab OmniAuth <a id="gl-omni"/></a>

После запуска модуля `gitlab-deploy` необходимо настроить компонент Gitlab `OmniAuth` для работы с IdP Zitadel. Для этого нужно следовать [инструкции в документации](https://yandex.cloud/ru/docs/managed-gitlab/operations/omniauth#keycloak). 

При настройке следует обратить внимание на следующие особенности:
* Использовать тип провайдера аутентификации `Keycloak`.
* Значения параметров `Issuer`, `Client ID` и `Client Secret` необходимо получить из [параметров приложения](https://zitadel.com/docs/guides/manage/console/applications) "gitlab-omniauth-oidc" в Zitadel.
