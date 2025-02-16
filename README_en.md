
# Deploying an identity federation in Yandex Cloud using Zitadel

## Contents

* [About the solution](#overview)
* [Authenticating a user via a federation](#flow)
* [Solution architecture](#arch)
    * [Zitadel container structure](#container)
    * [Zitadel logical model](#zita-logic)
* [Basic deployment](#deploy-base)
    * [zitadel-deploy](./zitadel-deploy/README.md) module
    * [zitadel-config](./zitadel-config/README.md) module 
    * [usersgen](./usersgen/README.md) module
* [External dependencies](#ext-dep)
* [Deployment steps](#deploy)
* [Deployment results](#results)
* [Extended deployment options](#deploy-ext)
    * [Integrating Zitadel with Yandex Managed Service for GitLab](#deploy-gl)
    * [Integrating Zitadel with BigBlueButton](#deploy-bbb)
    * [Integrating Zitadel with Yandex Managed Service for GitLab and BigBlueButton](#deploy-gl-bbb)
* [Deleting the deployment and freeing up the resources](#uninstall)
* [*Storing Terraform State in Yandex Object Storage (optional step)*](./s3-init/README.md)

## About the solution <a id="overview"/></a>

To provide corporate users with access to cloud resources, [Yandex Cloud](https://yandex.cloud) employs:
* [Organization service](https://yandex.cloud/docs/organization/)
* [Identity federation](https://yandex.cloud/docs/organization/add-federation)
* [Identity Provider](https://en.wikipedia.org/wiki/Identity_provider) (`IdP`)

Organization is a container for users. Users can be added to and deleted from an organization.

IdP is used for authentication. Usually, it is integrated with a user credentials repository such as MS Active Directory, a database, etc.

Identity federation acts as a connector between the organization service and IdP. A federation synchronizes user accounts from the IdP to the Yandex Cloud organization.

After successfully synchronizing user accounts to a Yandex Cloud organization, you can [assign roles](https://yandex.cloud/docs/iam/roles-reference) (grant permissions) for cloud resources. Yandex Cloud supports [SAML v2.0](https://wiki.oasis-open.org/security#SAML_V2.0_Standard)-based identity federations. 

For [the list of IdPs](https://yandex.cloud/docs/organization/concepts/add-federation#federation-usage) that were tested to work with identity federations in Yandex Cloud, see the respective section. 

### Authenticating a user via a federation <a id="flow"/></a>

This solution implements user authentication as follows:
1. The user enters the Yandex Cloud console URL in the browser, specifying their federation ID, e.g., `https://console.yandex.cloud/federations/bpf3375ucdgp5dxq823tt`.
1. The cloud console redirects the user request to the FQDN of the IdP, which is deployed as a VM running [Zitadel](https://zitadel.com).
1. On the `IdP` page, the user sees an authentication form where they need to enter their login and password.
1. The user enters their credentials into the form.
1. The `IdP` checks the user credentials and, if successful, returns the user, now authenticated, to the Yandex Cloud console.
1. Yandex Cloud performs the user authorization to cloud resources.
1. Once their authority is successfully verified in the cloud console, the user should see the folders of cloud resources they are authorized to access.

## Solution architecture <a id="arch"/></a>

The figure below shows the generalized architecture of the base solution.

<p align="left">
    <img src="./zitadel-deploy/diagrams/zitadel-solution.svg" alt="Zitadel Solution Architecture" width="800"/>
</p>

The core elements are as follows:

* `IdP Zitadel`: Essential element of the solution deployed as a Docker container with a certain [Zitadel](https://zitadel.com/docs) solution inside the `zitadel-vm` virtual machine. The container is built during the solution deployment. The [figure below](#container) shows the `Zitadel` container structure. Check out the details of the container build in its [Dockerfile](./zitadel-deploy/docker/Dockerfile).

* DB cluster built on [Yandex Managed Service for PostgreSQL](https://yandex.cloud/docs/managed-postgresql/). An auxiliary element that is required to create a database for the `Zitadel` solution. This solution deploys a single-node PostgreSQL cluster. This configuration is not fault-tolerant, so we recommend that you only use it for testing purposes. In a production environment, create a cluster of at least two nodes. You can [increase](https://yandex.cloud/docs/managed-postgresql/operations/hosts#add) the number of nodes in your PostgreSQL cluster as you need.

* [Сloud](https://yandex.cloud/docs/resource-manager/concepts/resources-hierarchy#cloud) and [Folder](https://yandex.cloud/docs/resource-manager/concepts/resources-hierarchy#folder). The solution will be deployed in the cloud and cloud resource folder that you specify before the deployment.

* DNS zone and [Cloud DNS](https://yandex.cloud/docs/dns/). Before proceeding to the deployment, make sure you have a DNS zone created in the cloud resource folder. Make sure to specify the name of that DNS zone in the deployment parameters. The domain zone will be used to: 
    * Create an A-record when [reserving a public IP address](https://yandex.cloud/docs/vpc/operations/get-static-ip) for the `zitadel-vm` VM.
    * Create a verification record during the [domain rights check](https://yandex.cloud/docs/certificate-manager/concepts/challenges) when creating a [Certificate Manager](https://yandex.cloud/docs/certificate-manager/concepts/) request for a certificate from `Let's Encrypt (LE)`.

* The [Certificate Manager](https://yandex.cloud/docs/certificate-manager/) (CM) service will help you obtain a `Let's Encrypt` certificate and work with the Cloud DNS service while obtaining that certificate. When starting, the `IdP Zitadel` container will contact CM to obtain the current version of the LE certificate.

### Zitadel container structure <a id="container"/></a>

A Docker container with `Zitadel` is built during the VM deployment. 

The figure below shows the container structure and its components.

<p align="left">
    <img src="./zitadel-deploy/diagrams/zitadel-container.svg" alt="Zitadel container structure" width="500"/>
</p>

### Zitadel logical model <a id="zita-logic"/></a>

The figure below shows the logical structure of objects in this specific deployment and how they relate to each other.

<p align="left">
    <img src="./zitadel-config/diagrams/zitadel-logic.svg" alt="Zitadel Logic structure" width="800"/>
</p>

The main Zitadel objects shown below are:

* [Instance](https://zitadel.com/docs/concepts/structure/instance): Highest level of hierarchy in the Zitadel architecture. This level contains the default configuration settings and various policies. In a single instance, you can create one or more organizations.

    This deployment includes the `ZITADEL` instance to process connection requests for this URL: `https://zitadel-vm.my-domain.net:8443`.

* [Organization](https://zitadel.com/docs/concepts/structure/organizations): Container for users and projects, and the links between them. At the organization level, you can override certain instance-level configuration and policy settings.

    In this deployment, two organizations are created within `Zitadel Instance`:
    * `SysOrg`: System organization (missing in the chart) which is created at the `(zitadel-deploy)` stage. In that organization, a [service account](https://zitadel.com/docs/concepts/structure/users#service-users) is created with a JWT key to authenticate to the Zitadel API, with the broadest permissions possible. The service account key will be further used to create all other objects within Zitadel, including doing so through the Terraform provider. The name of the file with the service account key is formatted as `<VM-name>-sa.json` (in this case, `~/.ssh/zitadel-vm-sa.json`).
    
    * `MyOrg`: User organization which is created at the `zitadel-config` stage. That organization will be housing all the child objects that are shown in the chart above. When creating that organization, it gets the `Default` status to simplify further operations with it. Only one organization per instance can have that status.

* [Manager](https://zitadel.com/docs/concepts/structure/users): Specific user in an organization that is granted [special permissions](https://zitadel.com/docs/guides/manage/console/managers#roles) (roles) to manage other users in the organization. This user will not have access permissions to Yandex Cloud resources. You can set the permission type (list of roles) in the deployment parameters.

    This deployment will create a user named `userman` with the `ORG_USER_MANAGER` permissions. That user will be able to create accounts for regular users, as well as permit them to authenticate to Yandex Cloud. For more information about roles, see [this Zitadel guide]((https://zitadel.com/docs/guides/manage/console/managers#roles)).

* [Users](https://zitadel.com/docs/concepts/structure/users#human-users): Regular users who are granted access to Yandex Cloud.

    This deployment will create regular users named `zuser1` and `zuser2`, with accounts that can be authenticated in the Yandex Cloud identity federation.

* [Project](https://zitadel.com/docs/concepts/structure/projects): Container for user roles and applications. One organization may house multiple projects.

    This deployment creates a project named `yc-users`.

* [Application](https://zitadel.com/docs/concepts/structure/applications): User entry point into a project. Applications implement interfaces for working with external systems within the processes associated with authentication, authorization, etc.

    This deployment creates an application named `yc-federation-saml` (**SAML** type) to integrate Zitadel with the Yandex Cloud identity federation over the `SAMLv2` protocol.

* [Authorizations](https://zitadel.com/docs/guides/manage/console/roles#authorizations): Tool for adding users to a project (Zitadel does not have regular user groups). In Terraform provider, the `Authorization` entity is called `User Grant`.

Managing users in Zitadel to grant them access to Yandex Cloud comes down to two simple steps:
1. Create a `Human User` user.
1. Authorize that user (create a `User Grant` for them) in the project.

After that, the user will be able to authenticate in Yandex Cloud. The exact cloud resources and respective access permissions for the user would depend on the specific [roles](https://yandex.cloud/docs/iam/roles-reference) the administrator [grants](https://yandex.cloud/docs/iam/operations/roles/grant) that user's account in the cloud organization.

## Basic deployment <a id="deploy-base"/></a>

With a view to simplify deploying and further work, this solution consists of various `Terraform` modules:

* [zitadel-deploy](./zitadel-deploy/README.md)
* [zitadel-config](./zitadel-config/README.md) 
* [usersgen](./usersgen/README.md)

### External dependencies <a id="ext-dep"/></a>

Before deploying the solution, make sure you properly prepared your Yandex Cloud infrastructure. To feed the values of the infrastructure parameters to the above TF modules, provide those values as input variables. 

Before deploying the solution in Yandex Cloud, make sure the following objects are available:
* Cloud in which the deployment will run (`yc_infra.cloud_id`).
* Cloud resource folder in which the deployment will run (`yc_infra.folder_name`).
* `Cloud DNS` [public zone](https://yandex.cloud/docs/dns/concepts/dns-zone#public-zones). Make sure to first `delegate` the `yc_infra.dns_zone_name` domain, i.e., the one you will create in Cloud DNS, from the domain registrar.
* Network to run the deployment in (`yc_infra.network`).
* Subnet to run the deployment in (`yc_infra.subnet1`).

The names provided above in parentheses are the names of input variables for deployment from [zitadel-deploy](./zitadel-deploy/README.md#zd-inputs).

## Deployment steps <a id="deploy"/></a>

This solution is compatible with `Linux` and `MacOS`.

We did not test it in the `Windows` or [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl) environment.

1. Before starting your deployment, make sure all required tools are installed and properly configured:
* `yc CLI` is [installed](https://yandex.cloud/docs/cli/operations/install-cli) and [configured](https://yandex.cloud/docs/cli/operations/profile/profile-create#create).
* `Terraform` is [installed](https://yandex.cloud/docs/tutorials/infrastructure-management/terraform-quickstart#install-terraform) and [configured](https://yandex.cloud/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider).
* `Python3` and the [requests](https://pypi.org/project/requests) and [jwt](https://pypi.org/project/jwt) modules are installed.

1. Download the solution from [this GitHub repository](https://github.com/yandex-cloud-examples/yc-iam-federation-with-zitadel):

    ```bash
    git clone https://github.com/yandex-cloud-examples/yc-iam-federation-with-zitadel.git
    ```

1. Select the deployment option:
* [zitadel-deploy](./examples/zitadel-deploy/): Basic Zitadel deployment.
* [zitadel-gitlab-deploy](./examples/zitadel-gitlab-deploy/): Extended Zitadel deployment option, integrating with [Yandex Managed Service for GitLab](https://yandex.cloud/docs/managed-gitlab/).
* [zitadel-bbb-deploy](./examples/zitadel-bbb-deploy/): Extended Zitadel deployment option, integrating with [BigBlueButton](https://docs.bigbluebutton.org/) (BBB).
* [zitadel-bbb-gitlab-deploy](./examples/zitadel-bbb-gitlab-deploy/): Extended Zitadel deployment option, implementing combined integration with `Gitlab` and `BBB`. 

    For more information about the extended deployment options, see [this section](#deploy-ext).

1.  Go to the folder with an example of the selected deployment option, e.g., [zitadel-deploy](./examples/zitadel-deploy/):

    ```bash
    cd yc-iam-federation-with-zitadel/examples/zitadel-deploy
    ```

1. **Important:**First make sure all [external dependencies](#ext-dep) exist.

1. In the [main.tf](./examples/zitadel-deploy/main.tf) file, check the values of the variables and make corrections as appropriate. 

1. Prepare the environment for your deployment:

    ```bash
    terraform init
    source env-setup.sh
    ```

1. Run the `zitadel-deploy` deployment:

    ```bash
    terraform apply
    ```

    It may take up to 30 minutes to process a request for a [Let's Encrypt](https://letsencrypt.org/) certificate.

1. Check the status of the obtained Let's Encrypt certificate:

    ```bash
    yc cm certificate list
    ```

1. Go to the folder with the example of deploying the [zitadel-config](./examples/zitadel-config/) module:

    ```bash
    cd ../zitadel-config
    ```

1. In the [main.tf](./examples/zitadel-config/main.tf) file, check the values of the variables and make corrections as appropriate.
   
   **Important:**Make sure the `template_file` variable refers to the [template](./usersgen/README.md#user-template) matching the selected deployment option.

1. Adjust user information in the [users.yml](./examples/zitadel-config/users.yml) file.

1. Prepare the environment for your deployment:

    ```bash
    terraform init
    source env-setup.sh
    ```

1. Deploy `zitadel-config` and generate a user resource file named `users.tf`:

    ```bash
    terraform apply
    ```

1. Deploy the user resources from `users.tf`:

    ```bash
    terraform apply
    ```

## Deployment results <a id="results"/></a>

During the basic deployment of this solution, you will be creating the following objects in Yandex Cloud:
* [Identity federation](https://yandex.cloud/docs/organization/concepts/add-federation) in the selected organization.
* [Let’s Encrypt](https://letsencrypt.org/) certificate for `IdP Zitadel` in [Certificate Manager](https://yandex.cloud/docs/certificate-manager).
* `IdP Zitadel` successfully works with the identity federation from the Yandex Cloud side.
* Yandex Cloud DNS record with the public IP address of the `zitadel-vm` VM.
* User accounts in the Zitadel IdP are synchronized to the Yandex Cloud organization through the respective federation.

Once the basic deployment is complete, grant the user accounts created in the organization the required [roles](https://yandex.cloud/docs/iam/roles-reference) to the respective cloud resources.

Extended deployment options will be creating additional objects according to the selected option.

## Extended deployment options <a id="deploy-ext"/></a>

Apart from the basic deployment option, this solution also offers certain extended options that integrate additional components, such as:
* [Yandex Managed Service for GitLab](https://yandex.cloud/docs/managed-gitlab/) (GitLab), a development management system.
* [BigBlueButton](https://docs.bigbluebutton.org/) (BBB), a videoconference system.
* Combined integration with GitLab and BBB.

The extended deployment options differ from the basic one only in the way `zitadel-deploy` works; other modules, `zitadel-config` and `usersgen`, work in the same way for all deployment options.

### Integrating Zitadel with Yandex Managed Service for GitLab <a id="deploy-gl"/></a>
<p align="left">
    <img src="./gitlab-deploy/diagrams/zitadel-gitlab.svg" alt="Gitlab integration diagram" width="800"/>
</p>

See the [zitadel-gitlab-deploy](./examples/zitadel-gitlab-deploy/) folder for the sample deployment.

### Integrating Zitadel with BigBlueButton <a id="deploy-bbb"/></a>
<p align="left">
    <img src="./bbb-deploy/diagrams/zitadel-bbb.svg" alt="BBB integration diagram" width="800"/>
</p>

See the [zitadel-bbb-deploy](./examples/zitadel-bbb-deploy/) folder for the sample deployment.

### Integrating Zitadel with Yandex Managed Service for GitLab and BigBlueButton<a id="deploy-gl-bbb"/></a>
<p align="left">
    <img src="./zitadel-deploy/diagrams/zitadel-bbb-gitlab.svg" alt="Gitlab integration diagram" width="800"/>
</p>

See the [zitadel-bbb-gitlab-deploy](./examples/zitadel-bbb-gitlab-deploy/) folder for the sample deployment.

## Deleting the deployment and freeing up the resources <a id="uninstall"/></a>

You should free up the resources in the reverse order of how they were created.

1. Go to the folder with the example of deploying the [zitadel-config](./examples/zitadel-config/) module:

    ```bash
    cd yc-iam-federation-with-zitadel/examples/zitadel-config
    ```

1. Prepare the environment:

    ```bash
    source env-setup.sh
    ```

1. Delete the resources:

    ```bash
    terraform destroy
    ```

    Ignore the `Default Organisation must not be deleted` error.

1. Go to the folder housing the [zitadel-deploy](./examples/zitadel-deploy/) sample deployment:

    ```bash
    cd ../zitadel-deploy
    ```

1. Prepare the environment:

    ```bash
    source env-setup.sh
    ```

1. Delete the resources:

    ```bash
    terraform destroy
    ```

1. Delete the project folder (where needed).

    Go to the project folder's parent folder and run this command:
   ```bash
   rm -rf yc-iam-federation-with-zitadel
   ```
