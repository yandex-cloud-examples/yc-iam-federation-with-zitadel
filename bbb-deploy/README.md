
# Terraform модуль `bbb-deploy` 

## Оглавление
* [Описание модуля](#bbb-overview)
* [Входные параметры модуля](#bbb-inputs)
  * [Группа параметров BBB ВМ](#bbb-input-vm)
* [Выходные параметры модуля](#bbb-outputs)


## Описание модуля <a id="bbb-overview"/></a>

Модуль `bbb-deploy` выполняет развёртывание ВМ с ПО [Big Blue Button (BBB)](https://docs.bigbluebutton.org):
* Создаёт запрос на LE-сертификат для FQDN виртуальной машины с `BBB ВМ`.
* Резервирует статический [публичный IP-адрес](https://yandex.cloud/ru/docs/vpc/concepts/address#public-addresses) для `BBB ВМ`.
* Создаёт [группу безопасности](https://yandex.cloud/ru/docs/vpc/concepts/security-groups) для `BBB ВМ`.
* Создаёт `BBB ВМ`. В процессе создания ВМ на неё устанавливается ПО [Big Blue Button (BBB)](https://docs.bigbluebutton.org).


## Входные параметры модуля <a id="bbb-inputs"/></a>

### Группа параметров BBB ВМ<a id="bbb-input-vm"/></a>

| Параметр (переменная) | Описание |
| - | -
| `bbb_vm.name` | Имя виртуальной машины BBB ВМ. |
| `bbb_vm.pub_name` | Имя ВМ в публичном FQDN (может отличаться от `bbb_vm.name`). |
| `bbb_vm.version` | Версия ПО [Big Blue Button](https://docs.bigbluebutton.org). |
| `bbb_vm.vcpu` | Количество ядер для BBB ВМ. |
| `bbb_vm.ram` | Количество оперативной памяти (RAM) для BBB ВМ (в гигабайтах). |
| `bbb_vm.disk_size` | Размер диска для BBB ВМ. Предполагается использование [network-ssd](https://yandex.cloud/ru/docs/compute/concepts/disk#disks-types) диска для развёртывания ВМ (в гигабайтах).|
| `bbb_vm.image_family` | Имя семейства [базового образа](https://yandex.cloud/ru/docs/compute/concepts/image) для развёртывания BBB ВМ. |
| `bbb_vm.port` | Номер порта на котором будет отвечать ВВВ ВМ после развёртывания.|
| `bbb_vm.cert_priv` | Имя файла для приватного ключа LE-сертификата. |
| `bbb_vm.cert_pub` | Имя файла для публичного ключа LE-сертификата. |
| ------------------------ | *--- Значения переменных перечисленных ниже импортируются из модуля [zitadel-deploy](../zitadel-deploy/README.md). ---* |
| `bbb_vm.infra_zone_id` | Значение импортируется из переменной `yc_infra.zone_id` |
| `bbb_vm.infra_folder_id` | Значение импортируется из переменной `yc_infra.folder_id` |
| `bbb_vm.infra_dns_zone_name` | Значение импортируется из переменной `yc_infra.dbs_zone_name` |
| `bbb_vm.infra_net_id` | Значение импортируется из переменной `yc_infra.net_id` |
| `bbb_vm.infra_subnet1_id` | Значение импортируется из переменной `yc_infra.subnet1_id` |
| `bbb_vm.admin_user` | Значение импортируется из переменной `zitadel_vm.admin_user` |
| `bbb_vm.admin_key_file` | Значение импортируется из переменной `zitadel_vm.admin_key_file` |


## Выходные параметры модуля <a id="bbb-outputs"/></a>

Модуль не возвращает выходных параметров.
