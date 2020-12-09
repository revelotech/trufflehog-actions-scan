
# Trufflehog Actions Scan :pig_nose::key:

* Forkado de https://github.com/dxa4481/truffleHog
* Nao exibe os segredos encontrados
* Verifica apenas os commits da branch atual

## Exemplo de workflow

Executa o workflow a cada push, olhando apenas para o branch atual.

```yaml
# .github/workflows/check_secrets.yml

name: Check secrets
on: push
jobs:
  check_secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: trufflehog-actions-scan
        uses: contratadome/trufflehog-actions-scan@master
        with:
          DEFAULT_BRANCH: main

```
