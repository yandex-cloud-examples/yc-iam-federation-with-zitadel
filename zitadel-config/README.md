
# Terraform модуль `zitadel-config` 

## Оглавление
* [Описание модуля](#zc-overview)
* [Входные параметры модуля](#zc-inputs)
  * [Группа системных параметров](#zc-input-sys)
  * [Группа параметров организации Zitadel](#zc-input-org)
* [Выходные параметры модуля](#zc-outputs)


## Описание модуля <a id="zc-overview"/></a>

Модуль `zitadel-config` выполняет следующие действия:
* Создаёт [федерацию удостоверений](https://yandex.cloud/ru/docs/organization/concepts/add-federation) в Yandex Cloud.
* Создаёт организацию, проект, SAML-приложение и другие сопутствующие объекты в `Zitadel`. [Описание логической модели Zitadel](../README.md#zita-logic).
* Обеспечивает обмен сертификатами между федерацией Yandex Cloud и `Zitadel SAML Application`.
* С помощью вспомогательного модуля `usersgen` обеспечивает управление учетными записями пользователей в структуре `Zitadel`, а также их синхронизацию в организацию Yandex Cloud.


## Входные параметры модуля <a id="zc-inputs"/></a>

### Группа системных параметров <a id="zc-input-sys"/></a>

Значения в данной группе параметров передаются через переменные окружения с помощью [скрипта инциализации](../examples/zitadel-config/env-setup.sh) до запуска данного модуля.

| Параметр (переменная) | Описание |
| - | -
| `system.base_url` | Zitadel API Endpoint URL. Значение передаётся из `module.zitadel-deploy.zita_base_url`. |
| `system.jwt_key` |  Путь к ключу [сервисной учётной записи Zitadel](https://zitadel.com/docs/concepts/structure/users#service-users). Значение передаётся из `module.zitadel-deploy.jwt_key_full_path`. |
| `system.zt_token` | Сессионный ключ (token) для аутентификации в Zitadel API. Генерируется с помощью скрипта [ztgen.py](./ztgen.py) и передаётся через [скрипт инициализации](../examples/zitadel-config/env-setup.sh) перед запуском модуля. |
| `system.yc_token` | Сессионый ключ (token) для аутентификации в Yandex Cloud API. Передаётся через [скрипт инициализации](../examples/zitadel-config/env-setup.sh) перед запуском модуля.|


### Группа параметров организации Zitadel <a id="zc-input-org"/></a>

| Параметр (переменная) | Описание |
| - | -
| `zitadel_org.org_name` | Имя организации в Zitadel, например `MyOrg`. |
| `zitadel_org.manager_uname` | Имя учётной записи (УЗ) пользователя - менеджера. Основная задача менеджера - управлять учетными записями обычных пользователей. При необходимости менеджеру можно предоставить более широкие полномочия как на уровне отдельной [организации](https://zitadel.com/docs/concepts/structure/organizations), так и на уровне всего [Zitadel Instance](https://zitadel.com/docs/concepts/structure/instance). |
| `zitadel_org.manager_pass` | Пароль для УЗ менеджера. |
| `zitadel_org.manager_fname` | Имя пользователям для УЗ менеджера. |
| `zitadel_org.manager_lname` | Фамилия пользователям для УЗ менеджера. |
| `zitadel_org.manager_lang` | Язык локали по умолчанию для УЗ менеджера. |
| `zitadel_org.manager_email` | e-mail для УЗ менеджера. |
| `zitadel_org.manager_role` | Системная роль, определяющая полномочия менеджера в Zitadel, например, `ORG_USER_MANAGER`. [Системные роли в Zitadel](https://zitadel.com/docs/guides/manage/console/managers#roles). |
| `zitadel_org.project_name` | Имя проекта для работы с Yandex Cloud. [Проект](https://zitadel.com/docs/concepts/structure/projects) это контейнер для `пользователей` и `приложений`. |
| `zitadel_org.saml_app_name` | Имя для приложения (тип `SAMLv2`), которое будет обеспечивать взаимодействие с [федерацией удостоверений](https://yandex.cloud/ru/docs/organization/concepts/add-federation) в Yandex Cloud для аутентификации проектных пользователей, например `yc-federation-saml`. |
| `zitadel_org.yc_org_id` | Идентификатор организации в Yandex Cloud в которой будет создаваться федерация удостоверений. |
| `zitadel_org.yc_fed_name` | Имя [федерации удостоверений](https://yandex.cloud/ru/docs/organization/concepts/add-federation) в Yandex Cloud, например `zitadel-federation`. |
| `zitadel_org.yc_fed_descr` | Подробное описание федерации удостовереений в Yandex Cloud, например, `YC and Zitadel integration`. |


## Выходные параметры модуля <a id="zc-outputs"/></a>

После завершения своей работы модуль `zitadel-config` возвращает следующие переменные:

| Параметр (переменная) | Описание |
| - | -
| `yc_federation_url` | URL федерации удостоверений в Yandex Cloud по которому нужно перейти для входа в облако, например, `https://console.yandex.cloud/federations/bpfc8qtg7hd28q7oz72i`. После обращения по данному URL облаком будет выполнено перенаправление на IdP Zitadel для аутентификации.
