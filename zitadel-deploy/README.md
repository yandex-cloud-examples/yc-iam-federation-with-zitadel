
# Terraform модуль `zitadel-deploy` 

## Оглавление
* [Описание модуля](#zd-overview)
* [Входные параметры модуля](#zd-inputs)
  * [Группа параметров инфраструктуры Yandex Cloud](#zd-input-infra)
  * [Группа параметров для развёртывания кластера PostgreSQL](#zd-input-pg)
  * [Группа параметров для сборки Docker-контейнера Zitadel](#zd-input-zitacntr)
  * [Группа параметров для развёртывания Zitadel ВМ](#zd-input-zitavm)
* [Выходные параметры модуля](#zd-outputs)


## Описание модуля <a id="zd-overview"/></a>

Terraform модуль `zitadel-deploy` выполняет следующие действия:
* Создаёт запрос на LE-сертификат для FQDN виртуальной машины (контейнера).
* Создаёт кластер БД PostgreSQL, БД в кластере и пользователя для доступа к БД.
* Резервирует статический [публичный IP-адрес](https://yandex.cloud/ru/docs/vpc/concepts/address#public-addresses) для Zitadel ВМ.
* Создаёт [группу безопасности](https://yandex.cloud/ru/docs/vpc/concepts/security-groups) для Zitadel ВМ.
* Создаёт `Zitadel ВМ`. В процессе создания ВМ на неё устанавливаются инструменты `Docker` и происходит сборка `контейнера Zitadel`.
* Внутри Zitadel создаётся [сервисная учётная запись](https://zitadel.com/docs/concepts/structure/users#service-users) администратора, ключ от которой (jwt-key) копируется на компьютер на котором запускалось развёртывание решения. Этот ключ далее будет использоваться при запуске других модулей.


## Входные параметры модуля <a id="zd-inputs"/></a>

### Группа параметров инфраструктуры Yandex Cloud <a id="zd-input-infra"/></a>

| Параметр (переменная) | Описание |
| - | -
| `yc_infra.cloud_id` | Идентификатор облака. |
| `yc_infra.folder_name` | Имя каталога в облаке `yc_infra.cloud_id`. |
| `yc_infra.zone_id` | Идентификатор [зоны доступности](https://yandex.cloud/ru/docs/overview/concepts/geo-scope), где будут развёрнуты Zitadel ВМ и [кластер PostgreSQL](https://yandex.cloud/ru/docs/managed-postgresql/). |
| `yc_infra.dns_zone_name` | Имя зоны DNS в сервисе [Yandex Cloud DNS](https://yandex.cloud/ru/docs/dns/). |
| `yc_infra.network` | Имя [сети](https://yandex.cloud/ru/docs/vpc/concepts/network#network) в каталоге `yc_infra.folder_name` к подсетям которой будут подключены развёртываемые ресурсы.  |
| `yc_infra.subnet1` | Имя [подсети](https://yandex.cloud/ru/docs/vpc/concepts/network#subnet) в сети `yc_infra.network` к которой будут подключены развёртываемые ресурсы. |


### Группа параметров для развёртывания кластера PostgreSQL <a id="zd-input-pg"/></a>

| Параметр (переменная) | Описание |
| - | -
| `pg_cluster.name` | [Имя кластера](https://yandex.cloud/ru/docs/glossary/cluster) в сервисе [Yandex Managed Service for PostgreSQL](https://yandex.cloud/ru/docs/managed-postgresql/concepts/). |
| `pg_cluster.version` | Версия PostgreSQL которая будет развёрнута в кластере. | 
| `pg_cluster.flavor` | [Класс хостов](https://yandex.cloud/ru/docs/managed-postgresql/concepts/instance-types) в кластере PostgreSQL. |
| `pg_cluster.disk_size`| Размер дискового пространства в кластере (в гигабайтах). |
| `pg_cluster.db_port` | Номер порта на котором будет отвечать развёрнутый кластер БД. Например, `6432`. |
| `pg_cluster.db_name` | Имя базы данных (БД) для работы Zitadel ВМ. |
| `pg_cluster.db_user` | Имя учётной записи администратора для подключения к БД. |
| `pg_cluster.db_pass` | Пароль для учётной записи администратора БД. |


### Группа параметров для сборки Docker контейнера Zitadel  <a id="zd-input-zitacntr"/></a>
| Параметр (переменная) | Описание |
| - | -
| `zitadel_cntr.name` | Имя образа который будет собираться, например, `zitadel`. |
| `zitadel_cntr.cr_name` | Имя `Container Registry` из которого будет загружаться базовый образ при сборке контейнера Zitadel, например, `mirror.gcr.io`. |
| `zitadel_cntr.cr_base_image` | Имя базового образа в Container Registry, который будет использоваться при сборке контейнера Zitadel,например, `ubuntu:22.04`. |
| `zitadel_cntr.zitadel_source` | [URL](https://github.com/zitadel/zitadel/releases) к дистрибутиву Zitadel, по-умолчанию ссылка на `github.com`. |
| `zitadel_cntr.zitadel_version` | Версия Zitadel, которую нужно развернуть, например, `2.53.2`. |
| `zitadel_cntr.zitadel_file` | Имя архива по пути, указанном в `zitadel_source`, который будет использоваться при сборке контейнера. |
| `zitadel_cntr.yq_source` | [URL](https://github.com/mikefarah/yq/releases/) к дистрибутиу YQ, по-умолчанию ссылка на `github.com`. |
| `zitadel_cntr.yq_version` | Версия YQ, которую нужно установить при сборке контейнера, например, `2.44.2`. |
| `zitadel_cntr.yq_file` | Имя файла по пути, указанном в `yq_source`, который будет использоваться при сборке контейнера. |


### Группа параметров для развёртывания Zitadel ВМ <a id="zd-input-zitavm"/></a>

| Параметр (переменная) | Описание |
| - | -
| `zitadel_vm.name` | Имя виртуальной машины Zitadel ВМ. |
| `zitadel_vm.vcpu` | Количество ядер для Zitadel ВМ. |
| `zitadel_vm.ram` | Количество оперативной памяти (RAM) для Zitadel ВМ (в гигабайтах). |
| `zitadel_vm.disk_size` | Размер диска для Zitadel ВМ. Предполагается использование [network-ssd](https://yandex.cloud/ru/docs/compute/concepts/disk#disks-types) диска для развёртывания ВМ (в гигабайтах).|
| `zitadel_vm.image_family` | Имя [базового образа](https://yandex.cloud/ru/docs/compute/concepts/image) для развёртывания Zitadel ВМ. Например, `ubuntu-2204-lts`. |
| `zitadel_vm.port` | Номер порта на котором будет отвечать Zitadel после развёртывания. Например, `8443`. |
| `zitadel_vm.jwt_path` | Путь в системе где запускается Terraform развёртывание по которому Zitadel в процессе своей инициализации создаст ключ [сервисной учётной записи](https://zitadel.com/docs/concepts/structure/users#service-users) в виде файла в формате json. Имя файла с ключём будет иметь вид: `<zitadel_vm.name>-sa.json`, например, `zitadel-vm-sa.json`. Этот файл будет использоваться в дальнейшем для создания всех необходимых объектов в Zitadel. |
| `zitadel_vm.admin_user` | Имя администратора Zitadel ВМ. Используется только при подключении к ВМ по протоколу SSH.|
| `zitadel_vm.admin_key_file` | Путь к файлу с приватным SSH-ключём администратора Zitadel ВМ. Используется только при подключении к ВМ по протоколу SSH, например, `~/.ssh/id_ed25519`. |


## Выходные параметры модуля <a id="zd-outputs"/></a>

После завершения своей работы модуль `zitadel-deploy` возвращает следующие переменные:

| Параметр (переменная) | Описание |
| - | -
| `zitadel_base_url` | URL с указанием FQDN развёрнутого IdP Zitadel, например, `https://zitadel-vm.my-domain.net:8443`.
| `jwt_key_full_path` | Полный путь к файлу с ключём сервисной учётной записи, например, `~/.ssh/zitadel-vm-sa.json`.
