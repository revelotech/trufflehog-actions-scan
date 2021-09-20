
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
        uses: contratadome/trufflehog-actions-scan
        with:
          DEFAULT_BRANCH: main

```

## Como remover um segredo
Mesmo que você remova o segredo em um commit seguinte, ele ficará no histórico do Git. Portanto, é necessário reescrever o commit.

Neste caso, a action informará em qual commit e arquivo foi encontrado o segredo. Por exemplo:
```
{
   "branch": "FETCH_HEAD",
   "commit": "Merge branch 'develop' into tech/update-flutter",
   "commitHash": "<COMMIT-HASH>",
   "date": "2021-08-26 14:03:33",
   "path": "lib/login/presentation/login_social_page.dart",
   "reason": "LinkedIn API Key"
 }
```

Recomendamos editar o commit usando o [`git rebase -i`](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History#_changing_multiple):

1. No terminal, faça um git rebase com o hash do commit apontado pelo trufflehog. Por exemplo:
```
git rebase -i '<COMMIT-HASH>'
```
2. Isso iniciará o processo de rebase e mostrará a sequência de commits em uma lista.
```
pick <COMMIT-HASH> add secret
pick <COMMIT-HASH-1> fix unit tests
pick <COMMIT-HASH-2> remove secret
```
3. Se no commit você somente adicionou o secret, você pode removê-lo inteiramente apagando a linha. Caso queira preservar o commit e só remover o segredo, renomeie `pick` para `edit`:
```
edit <COMMIT-HASH> add secret
pick <COMMIT-HASH-1> fix unit tests
pick <COMMIT-HASH-2> remove secret
```
4. Salve o arquivo e saia. Isso fará o git iniciar o processo de rebase e parará no commit que queremos editar. Então basta remover o secret do código.
5. Assim que tiver terminado a modificação adicione o arquivo ao stage com `git add`, execute `git commit --amend` e `git rebase --continue`.
6. Caso existam conflitos, é necessário resolvê-los e executar os mesmos comandos do passo 5.
7. Ao terminar, execute `git push -f` para que os novos commits sejam atualizados no github.

## O Trufflehog acredita que um segredo tenha sido adicionado, mas não foi

Neste caso, você pode:
- alterar/corrigir uma regex que acusou erroneamente um segredo, que estão definidas em `regexes.json` neste projeto;
- configurar essa action para ignorar um arquivo (alterando `.ignorelist`).

Lembre de testar muito bem essas alterações para não comprometer a segurança das aplicações ;)
