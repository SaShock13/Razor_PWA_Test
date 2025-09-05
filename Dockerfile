# Базовый образ для сборки
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Копируем файл проекта и восстанавливаем зависимости
COPY Test_Frontend_Blazor/Test_Frontend_Blazor.csproj Test_Frontend_Blazor/
RUN dotnet restore Test_Frontend_Blazor/Test_Frontend_Blazor.csproj

# Копируем всё и публикуем
COPY . .
RUN dotnet publish Test_Frontend_Blazor/Test_Frontend_Blazor.csproj \
    -c Release \
    -o /app \
    --nologo

# Финальный образ с nginx
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Копируем опубликованное приложение
COPY --from=build /app/wwwroot .

# Копируем nginx config
COPY Test_Frontend_Blazor/nginx.conf /etc/nginx/nginx.conf

# Открываем порт
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1