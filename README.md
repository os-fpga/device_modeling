# Contents


  - BB_Library -- Black Box library
  - bin -- scripts for generating simulation models
  - Clocking   -- design examples for clocking
  - IO  -- design examples for IO uses
  - models_internal -- simulation models for primitives, for internal use
  - models_customer -- simulation models for primitives, for customer (stripped internal code)
  - sprints -- testcases used for sprints 2023Q2
  - specs -- specifications for primitives, in P4DEF format.

See https://rapidsilicon.atlassian.net/wiki/spaces/RS/pages/224002049/Generating+Simulation+Models for instructions on using this repository.

# Download Instructions

For each release <version>, there should be an asset named models_internal-$version.tar.gz which can be downloaded from the github server.

Assuming the release is 0.9.11, the link to download from the github server would be:

```
   https://github.com/RapidSilicon/device_modeling/releases/download/0.9.11/models_internal-0.9.11.tar.gz
```

Command line for download would be:

```
   module load opensource/ghcli/2.31.0
   gh release download 0.9.11 -R RapidSilicon/device_modeling
```


