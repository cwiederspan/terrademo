FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.2-sdk AS build
WORKDIR /src
COPY ["/Terrademo.Backend/Terrademo.Backend.csproj", "Terrademo.Backend/"]
RUN dotnet restore "Terrademo.Backend/Terrademo.Backend.csproj"
COPY . .
WORKDIR "/src/Terrademo.Backend"
RUN dotnet build "Terrademo.Backend.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "Terrademo.Backend.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "Terrademo.Backend.dll"]