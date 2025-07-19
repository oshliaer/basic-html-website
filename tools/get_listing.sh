#!/usr/bin/env bash

# Скрипт для генерации Markdown-листинга файлов .vue, .ts и .html в указанной директории.
#
# Использование:
#   ./get_listing.sh <путь_к_директории_src> [фильтр1] [фильтр2] ...
#
# Пример:
#   ./get_listing.sh ../01-create-vue/vue-project/src
#   ./get_listing.sh ../01-create-vue/vue-project/src Welcome
#
# Файл листинга (listing.md) будет создан на один уровень выше указанной директории src.
#
# Если заданы фильтры, в листинг попадут только те файлы, имена которых содержат все фильтры.

# Проверяем, что передан хотя бы один аргумент (директория src)
if [ "$#" -lt 1 ]; then
#   echo "Ошибка: Не указан путь к директории src."
  echo "Ошибка: Не указан путь к директории 'src'."
  echo "Использование: $0 <путь_к_директории_src> [фильтр1] [фильтр2] ..."
  exit 1
fi

SRC_DIR="$1"
shift

# Проверяем, что указанный путь — это директория
if [ ! -d "$SRC_DIR" ]; then
  echo "Ошибка: Директория '$SRC_DIR' не найдена."
  exit 1
fi

# Определяем путь к файлу листинга (на уровень выше SRC_DIR)
PARENT_DIR=$(dirname "$SRC_DIR")
LISTING_FILE="$PARENT_DIR/listing.md"
LISTING_TITLE="Листинг файлов для $PARENT_DIR"

# Создаём или очищаем файл листинга и добавляем заголовок
echo "## $LISTING_TITLE" > "$LISTING_FILE"
echo "" >> "$LISTING_FILE"

# Ищем все .vue, .ts и .html файлы в SRC_DIR (рекурсивно)
find "$SRC_DIR" -type f \( -name "*.vue" -o -name "*.ts" -o -name "*.html" \) | while read -r filepath; do
  filename=$(basename "$filepath")
  # Получаем путь относительно SRC_DIR
  relative_path=$(realpath --relative-to="$SRC_DIR" "$filepath")
  
  # Если заданы фильтры, проверяем, что имя файла содержит все фильтры
  if [ "$#" -gt 0 ]; then
    match_all=true
    for filter in "$@"; do
      if [[ "$filename" != *"$filter"* ]]; then
        match_all=false
        break
      fi
    done
    # Пропускаем файл, если не все фильтры найдены в имени
    if ! $match_all; then
      continue
    fi
  fi

  # Определяем язык блока кода для Markdown
  if [[ "$filename" == *.vue ]]; then
    language="vue"
  elif [[ "$filename" == *.ts ]]; then
    language="typescript"
  elif [[ "$filename" == *.html ]]; then
    language="html"
  else
    language="text"
  fi

  # Добавляем секцию файла в листинг: имя, относительный путь и содержимое как блок кода
  echo "### $filename" >> "$LISTING_FILE"
  echo "" >> "$LISTING_FILE"
  echo "**Путь:** \`$relative_path\`" >> "$LISTING_FILE"
  echo "" >> "$LISTING_FILE"
  echo "\"\"\"$language" >> "$LISTING_FILE"
  cat "$filepath" >> "$LISTING_FILE"
  echo "\"\"\"" >> "$LISTING_FILE"
  echo "" >> "$LISTING_FILE"
done

# Выводим сообщение об успешном завершении с указанием пути к файлу листинга
echo "Листинг успешно сгенерирован: $LISTING_FILE"
