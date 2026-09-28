# github-actions-cicd

Скиллы для Codex, которые помогают настроить CI/CD на GitHub Actions для реального проекта: сначала изучить репозиторий, потом добавить минимальную проверку кода и только по явной просьбе — доставку.

| Скилл | Для чего |
|---|---|
| `github-actions-ci` | Добавить, объяснить или починить CI: тесты, lint и build на push или pull request, разбор упавшего запуска |
| `github-actions-cd` | Deploy, публикация релиза и rollback поверх уже работающего CI |

## Что умеют

- Смотрят на проект, прежде чем что-то писать: runtime и его версию, lockfile, реальные команды тестов и сборки, default branch, существующие workflow.
- Отделяют факты от предположений и задают вопрос, если чего-то не хватает, вместо того чтобы придумывать.
- Создают один понятный workflow с минимальными правами (`contents: read`), таймаутом и версией runtime из файла проекта.
- Честно называют пробелы: нет тестов, нет lockfile, тестам нужна база или переменные окружения.
- Объясняют каждый шаг на языке пользователя и говорят, что проверено, а что нет.

## Чего не делают без вашей просьбы

- Не добавляют deploy, релизы и secrets в обычный CI.
- Не выкладывают в production и не откатывают релиз без явной команды.
- Не «чинят» красный CI удалением тестов или ослаблением проверок.
- Не создают пустой workflow с `echo` ради зелёной галочки.

CD здесь означает continuous delivery: проверенная сборка готова к выкладке, а в production её выпускает человек. Полностью автоматический выпуск включается только после вашего подтверждения.

## Установка

### Через Codex (рекомендуется)

Напишите в Codex:

```text
$skill-installer install skills/github-actions-ci and skills/github-actions-cd from Prontsevich/github-actions-cicd
```

Установщику нужна сеть, поэтому Codex может попросить подтверждение. Скиллы появятся со следующего сообщения; если нет — перезапустите Codex.

### Вручную

Скопируйте **папки скиллов**, а не весь репозиторий:

```bash
git clone https://github.com/Prontsevich/github-actions-cicd.git
mkdir -p ~/.agents/skills
cp -R github-actions-cicd/skills/github-actions-ci github-actions-cicd/skills/github-actions-cd ~/.agents/skills/
```

Чтобы скиллы работали только в одном проекте, скопируйте их в `.agents/skills/` внутри этого проекта.

### Проверка

Спросите Codex: «Какие у тебя есть скиллы для GitHub Actions?» — в ответе должны быть `github-actions-ci` и `github-actions-cd`.

## Как пользоваться

Скилл подключается сам, когда запрос подходит под его описание. Можно вызвать и явно через `$`:

```text
Настрой CI для этого проекта
Почему упал workflow в последнем pull request?
Настрой CI/CD: тесты на каждый PR и выкладка на staging
$github-actions-cd Как безопасно откатить последний релиз?
```

На запрос «CI/CD» сначала настраивается проверка кода, потом доставка поверх неё.

## Что пригодится

- Проект в git-репозитории на GitHub.
- [GitHub CLI](https://cli.github.com/) (`gh`) — не обязателен, но помогает смотреть логи упавших запусков.
- [actionlint](https://github.com/rhysd/actionlint) — не обязателен; если установлен, скилл проверит им workflow.

## Структура репозитория

```text
skills/
├── github-actions-ci/     # SKILL.md, agents/openai.yaml, references/examples.md
└── github-actions-cd/     # SKILL.md, agents/openai.yaml
evals/fixtures/            # тестовые проекты для проверки поведения скиллов
```

## Лицензия

[MIT](LICENSE)
