#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["BlazorServer.csproj", "BlazorServer/"]
RUN dotnet restore "BlazorServer/BlazorServer.csproj"

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt install -y nodejs

COPY . /src/BlazorServer
WORKDIR "/src/BlazorServer"
RUN npm install
RUN dotnet build "BlazorServer.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BlazorServer.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BlazorServer.dll"]