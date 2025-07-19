#!/usr/bin/env bash

# Скрипт для генерации листинга по .vue и .ts файлам.
#
# Использование:
# ./get_listing.sh <путь_к_директории_src> [фильтр1] [фильтр2] ...
#
# Пример:
# ./get_listing.sh ../01-create-vue/vue-project/src
# ./get_listing.sh ../01-create-vue/vue-project/src Welcome
#
# Файл генерируется на одну директорию выше указанного пути в аргументе

# Проверяем, передан ли хотя бы один аргумент
if [ "$#" -lt 1 ]; then
  echo "Ошибка: Не указан путь к директории 'src'."
  echo "Использование: $0 <путь_к_директории_src> [фильтр1] [фильтр2] ..."
  exit 1
fi

SRC_DIR="$1"
shift

# Проверяем, является ли указанный путь директорией
if [ ! -d "$SRC_DIR" ]; then
  echo "Ошибка: Директория '$SRC_DIR' не найдена."
  exit 1
fi

# Определяем путь для файла листинга
PARENT_DIR=$(dirname "$SRC_DIR")
LISTING_FILE="$PARENT_DIR/listing.md"
LISTING_TITLE="Листинг файлов для $PARENT_DIR"

# Создаем или очищаем файл листинга и добавляем заголовок
echo "## $LISTING_TITLE" > "$LISTING_FILE"
echo "" >> "$LISTING_FILE"

# Ищем все .vue и .ts файлы в указанной директории
find "$SRC_DIR" -type f \( -name "*.vue" -o -name "*.ts" -o -name "*.html" \) | while read -r filepath; do
  filename=$(basename "$filepath")
  # Получаем относительный путь от SRC_DIR
  relative_path=$(realpath --relative-to="$SRC_DIR" "$filepath")
  
  # Если есть фильтры, проверяем имя файла
  if [ "$#" -gt 0 ]; then
    match_all=true
    for filter in "$@"; do
      if [[ "$filename" != *"$filter"* ]]; then
        match_all=false
        break
      fi
    done
    # Если имя файла не соответствует всем фильтрам, пропускаем его
    if ! $match_all; then
      continue
    fi
  fi

  # Определяем язык для блока кода
  if [[ "$filename" == *.vue ]]; then
    language="vue"
  elif [[ "$filename" == *.ts ]]; then
    language="typescript"
  elif [[ "$filename" == *.html ]]; then
    language="html"
  else
    language="text"
  fi

  # Добавляем имя файла с относительным путем и его содержимое в листинг
  echo "### $filename" >> "$LISTING_FILE"
  echo "" >> "$LISTING_FILE"
  echo "**Путь:** \`$relative_path\`" >> "$LISTING_FILE"
  echo "" >> "$LISTING_FILE"
  echo "\`\`\`$language" >> "$LISTING_FILE"
  cat "$filepath" >> "$LISTING_FILE"
  echo "\`\`\`" >> "$LISTING_FILE"
  echo "" >> "$LISTING_FILE"
done

echo "Листинг успешно сгенерирован: $LISTING_FILE"
