
# Примеры развёртывания Zitadel в базовом и расширенных вариантах

## Базовый вариант развёртывания
* [zitadel-deploy](../zitadel-deploy/README.md)

## Расширенные варианты развёртывания
* [zitadel-gitlab-deploy](./zitadel-gitlab-deploy)
* [zitadel-bbb-deploy](./zitadel-bbb-deploy/)
* [zitadel-bbb-gitlab-deploy](./zitadel-bbb-gitlab-deploy/)

Описание Terraform модулей, которые используются в расширенных вариантах развёртывания:
* [gitlab-deploy](../gitlab-deploy/README.md)
* [bbb-deploy](../bbb-deploy/README.md)

## Конфигурирование

После выполнения базового или расширенного варианта развёртывания необходимо добавить туда пользователей и облачные ресурсы (зависит от типа развёртывания и [используемого шаблона](../usersgen/templates)).
* [zitadel-config](../zitadel-config/README.md)
* [usersgen](../usersgen/README.md)
