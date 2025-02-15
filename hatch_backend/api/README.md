# HATCH! REST API

__API REST__ développée en Python avec le framework __FastAPI__ (<https://fastapi.tiangolo.com/>).

## Installation

- Créer le fichier ./api/.env  basé sur le fichier modèle __./api/.env.example__ (à adapter).
- Créer le fichier ./db/.env  basé sur le fichier modèle __./db/.env.example__ (à adapter).

## Commandes Docker utiles

- Création d'une image Docker à partir du fichier Dockerfile et des sources :
`docker build -t fastapiimage .`

- Création d'un container à partir de l'image "fastapiimage" précédemment créée :
`docker run -d --name fastapi -p 8080:80 fastapiimage`

- Initialisation des services Docker :
`docker compose up`

- Rénitialisation des services Docker (suppression des données) :
`docker compose down`

- Initialisation des services Docker en mode détaché (reprise de la main dans le terminal) :
`docker compose up -d`

- Initialisation des services Docker avec reconstruction de l'image :
`docker compose up --build`

- Initialisation des services Docker avec activation du mode watch (= hot reloading) :
`docker compose up --watch`

- Démarrage des services Docker :
`docker compose start`

- Consultation des services Docker actifs :
`docker compose ps`

- Clôture des services Docker :
`docker compose stop`

## Documentation Swagger

- Documentation Swagger générée automatiquement par FastAPI
<http://localhost:8080/docs>

## Adminer (interface d'administration de base de données)

<http://localhost:8181>

--

La structure et l’arborescence de ce projet sont inspirées par:
https://github.com/shrp777/todolist-rest-api
https://github.com/shrp777/todolist-flutter

Crée par M.
__Alexandre Leroux__  
