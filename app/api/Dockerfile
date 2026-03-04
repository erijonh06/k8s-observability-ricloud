# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies (Optimization: layer caching)
COPY ["api.csproj", "./"]
RUN dotnet restore "api.csproj"

# Copy everything else and build
COPY . .
RUN dotnet publish "api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Create a non-root user and set ownership (no-op if already exists)
RUN if ! getent group app >/dev/null 2>&1; then addgroup --system app; fi \
 && if ! id -u app >/dev/null 2>&1; then adduser --system --ingroup app --uid 1000 app || true; fi

# Copy only the compiled output from the build stage
COPY --from=build /app/publish .
RUN chown -R app:app /app

USER app

ENTRYPOINT ["dotnet", "api.dll"]