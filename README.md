
# Trufflehog Actions Scan :pig_nose::key:

* Forkado de https://github.com/dxa4481/truffleHog
* Nao exibe os segredos encontrados
* Verifica apenas os commits da branch atual

## Exemplo de workflow

```yaml

name: Check secrets
on: workflow_dispatch
jobs:
  check_secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: trufflehog-actions-scan
        uses: contratadome/trufflehog-actions-scan@master

```
