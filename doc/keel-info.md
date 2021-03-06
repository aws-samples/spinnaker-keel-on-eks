# Spinnaker Keel Setup Guide

This repo is intended to be used by the Spinnaker keel setup blog post. Notes below are for informational purposes only. 

## Configuration required by Keel in addition to core Spinnaker microservices:
  1. MySQL installation reachable by Keel.
  2. Keel service endpoint available to Orca, Echo, and Front50.
  3. Enable feature flags in Deck
  4. Enable Igor integration with SCM services
  
## If you do not want to create new Spinnaker installation entirely 
### MySQL instance
  Can be a cloud managed MySQL instance, an instance running in Kubernetes, or on a VM. It just needs to be rechable by Keel.

  This is only needed if you would like to create the database manually:
  ```
  CREATE DATABASE `keel` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

  GRANT
  SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, LOCK TABLES, EXECUTE, SHOW VIEW, CREATE VIEW
  ON `keel`.*
  TO 'keel_service'@'%'; -- IDENTIFIED BY "password" if using password based auth
  ```
### Keel service endpoint
  Keel service endpoint must be known by other serivces. Usually service endpoint information is configured in `/opt/spinnaker/config/spinnaker.yml` for each service, but this can be added to `<SERVICE>-local.yml` as well. Add the following to one of yml files.
  ```
  keel:
    baseUrl: http://keel:7010
    enabled: true
  ```
  Note that the keel service must be reachable at `keel` on port 7010 for the above configuraiton to work. If this is not correct for your environment, be sure to update it. 

### Configure Deck
  To display Managed Delivery features in UI, the following must be specified in `settings-local.js` file in Deck.
  ```
  window.spinnakerSettings.feature.managedDelivery = true;
  window.spinnakerSettings.feature.managedResources = true;
  ```
  
### Configure Igor 
  Keel needs to be able to pull delivery configuration from a configured source. Consult [this page](https://github.com/spinnaker/igor#integration-with-scm-services) for syntaxes. For example, if your delivery configuration will be hosted on Github, add the following to `igor-local.yml` or `igor.yml`.
  ```
  github:
    baseUrl: "https://api.github.com"
    accessToken: <TOKEN>
    commitDisplayLength: 8
  ```
  Consult [this page](https://spinnaker.io/setup/artifacts/github/#prerequisites) for steps on generating Github tokens.

### Configure Front50
  Add the following to `front50.yml` or `front50-local.yml`.
  ```
  spinnaker:
    delivery:
      enabled: true
  ```

### Configure and run Keel
  1. [Build docker image](#build-binary-and-docker-image)
  2. Create a configuration file for keel (keel.yml or keel-loca.yml):
  ```
  keel:
    plugins:
      deliveryConfig:
        enabled: true
      ec2:
        enabled: true
      k8s:
        enabled: true # Only if you have the K8s plugin installed.
  sql:
    connectionPools:
      default:
        jdbcUrl: jdbc:mysql://mysql/keel?useSSL=false
        password: mysecretpassword 
        user: keel
    enabled: true
    migration:
      jdbcUrl: jdbc:mysql://mysql/keel?useSSL=false
      password: mysecretpassword
      user: keel
  ```
  3. Mount configuration files (`/opt/spinnaker/config/{spinnaker.yml,keel.yml,keel-local.yml`) and run `/opt/keel/bin/keel`
  4. See `Dockerfile.ubuntu` and [keel deployment file](kustomization-base/keel/base/deployment.yml) for an example.


### Keel usage
Follow [this guide](https://spinnaker.io/guides/user/managed-delivery/getting-started/) for quick start. 

#### Notes
1. The delivery config must reference a service account in the top level field `serviceAccount` e.g. Example of this is available in .spinnaker.yml
  ```
  name: test1
  application: keeltest
  serviceAccount: keeltest-service-account
  artifacts: []
  environments:[]
  ...
  ```
2. Create service account by following [this page](https://spinnaker.io/setup/security/authorization/service-accounts/)
3. If you'd like to use the kubernetes plugin for keel, example configuration is available [here](spinnaker-config/overlays/keel/local/keel-local.yml). It's commented out by default. Source is available [here](https://github.com/nimakaviani/managed-delivery-k8s-plugin)




