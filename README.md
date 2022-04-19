# unifi-network-application

A clean, reproducible and Kubernetes-friendly Docker image for UniFi Network Application.
Built-in MongoDB is disabled intentionally.

This is still work in progress.


## Variables

- `UNIFI_MONGO_USERNAME_FILE` - path to a file containing the MongoDB username with access to the `<UNIFI_MONGO_DB_NAME>` and `<UNIFI_MONGO_DB_NAME>_stat` databases,
- `UNIFI_MONGO_PASSWORD_FILE` - path to a file containing the password for `<UNIFI_MONGO_USERNAME_FILE>`
- `UNIFI_MONGO_HOSTS` - addresses of MongoDB server(s) in the `host1[:port1][,...hostN[:portN]` format,
- `UNIFI_MONGO_AUTH_DB`: MongoDB auth database name (`admin` for example),
- `UNIFI_MONGO_DB_NAME`: MongoDB database name to use; `<UNIFI_MONGO_DB_NAME>_stat` database will be used for statistics.


## Developing

Most of the build targets use Podman, not Docker.

- `make build` - build the image,
- `make update-versionlock` - update the Ubuntu package version lockfile,
- `make compose` - bring up a test stack (including a MongoDB container),
- `make compose-down` - bring down the test stack, but keep the volumes,
- `make compose-down-mrproper` - destroy the test stack completely,
- `make trivy-scan` - security-scan the container,

