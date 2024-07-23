# Хранение Terraform state в Yandex Object Storage

## Создание S3-bucket в Yandex Object Storage и организация доступа к нему

Подробно узнать о том как настроить хранение Terraform state в [Yandex Object Storage](https://yandex.cloud/ru/docs/storage/) можно [в документации](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-storage).

Для хранения Terraform state в [Yandex Object Storage](https://yandex.cloud/ru/docs/storage/) необходимо:
1. Создать [Bucket](https://yandex.cloud/ru/docs/storage/concepts/bucket) в [Yandex Object Storage](https://yandex.cloud/ru/docs/storage/).
2. Создать [Service Account (SA)](https://yandex.cloud/ru/docs/iam/concepts/users/service-accounts) с ролью [storage.uploader](https://yandex.cloud/ru/docs/iam/roles-reference#storage-uploader).
3. Создать [статический ключ доступа](https://yandex.cloud/ru/docs/iam/concepts/authorization/access-key) для SA.
4. Сохранить созданный статический ключ доступа как [Lockbox Secret](https://yandex.cloud/ru/docs/lockbox/concepts/secret).

## Настройка Terraform для работы c Yandex Object Storage

1. Запустить процесс создания S3-bucket и необходимых доступов для хранения Terraform state в [Yandex Object Storage](https://yandex.cloud/ru/docs/storage/):
   ```bash
   cd s3-init
   ./s3-init.sh b1g22jx2133dpa3yvxc3 my-tf-state-storage
   ```

2. Получить результаты работы `init.sh` вида:
    ```bash
    === 1. Add lines below to your env-setup.sh ===
    SEC_LIST=($(yc lockbox payload get --name=my-tf-state-storage --format=json | jq -r '.entries[0] | .key, .text_value'))
    export AWS_ACCESS_KEY_ID=${SEC_LIST[0]}
    export AWS_SECRET_ACCESS_KEY=${SEC_LIST[1]}
    ====

    === 2. Initialize Terraform S3 backend as following: ===
    terraform init -backend-config="bucket=my-tf-state-storage" -backend-config="key=zitadel-deploy.tfstate"
    ===
    ```

3. Добавить строки из вывода `init.sh` выше в скрипт настройки окружения `env-setup.sh` нужного модуля для получения значений секретов S3 в переменные окружения.

4. Удалить символы комментариев `/*, */` в файлах `providers.tf` в блоке кода, обозначенного как `S3 remote TF state config`.

5. Инициализировать [Terraform Backend](https://developer.hashicorp.com/terraform/language/settings/backends/configuration), используя  вывод `init.sh` выше, указав в параметре `key` желаемое имя файла где будет храниться Terraform state :
   ```bash
    terraform init -backend-config="bucket=my-tf-state-storage" -backend-config="key=zitadel-deploy.tfstate"   
   ```
