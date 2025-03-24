# Hatch! 🐣

## Description
**Hatch!** est une application de coaching personnel visant à aider les utilisateurs à développer de bonnes habitudes, suivre leurs objectifs et recevoir des conseils personnalisés d’un coach virtuel.
Ce projet a été réalisé par Inès ALLAG, Marco BUISSON, Wassim DELALA et Nadim SALEEM.

---

## 🧑‍💻 Client

- **Technologie** : [Flutter](https://flutter.dev/) (Mobile & Web)
- **Langage** : Dart
- **Structure** :
  - Le point d'entrée est `main.dart`
  - Pages dans `Pages/` et services dans `Services/`
  - Localisation supportée : `fr-FR`, `en-US`
  - Système de routing personnalisé avec guard d'authentification

---

## 🧠 API Backend

- **Framework** : [FastAPI](https://fastapi.tiangolo.com/)
- **Langage** : Python 3.10+
- **Structure** :
  - Dossier principal : `hatch_backend/api/app`
  - ORM : SQLAlchemy
  - Authentification : OAuth2 + JWT
  - Conteneurisation : Docker (`docker-compose.yml`)

---

## 🚧 Infrastructure Docker

Le projet repose sur une architecture multi-conteneurs via Docker Compose :

- **api** : Conteneur principal FastAPI servant l'API REST.
- **db** : Conteneur PostgreSQL pour le stockage des données utilisateurs, habitudes, objectifs...
- **adminer** : Interface web de gestion de base de données pour visualiser et interagir avec PostgreSQL.

> Aucun volume persistant n'est configuré actuellement. Les données sont donc éphémères.

---

## 🌐 Routes API FastAPI

### 🔐 Authentification (`/auth`)
| Méthode | Route            | Description |
|--------|------------------|-------------|
| POST   | `/auth/token`    | Connexion utilisateur, retourne les tokens |
| POST   | `/auth/refresh`  | Rafraîchit le token d'accès via le refresh token |
| POST   | `/auth/register` | Inscription d’un nouvel utilisateur |
| POST   | `/auth/logout`   | Déconnexion (suppression du refresh token) |
| GET    | `/auth/me`       | Récupère le profil utilisateur à partir du token |

### 👤 Utilisateur (`/users`)
| Méthode | Route                  | Description |
|--------|------------------------|-------------|
| GET    | `/users/me`            | Récupérer le profil de l’utilisateur connecté |
| PUT    | `/users/me/update`     | Mettre à jour les infos du profil |
| PUT    | `/users/me/change_pw`  | Mettre à jour le mot de passe |
| DELETE | `/users/me/supprimer`  | Supprimer son compte utilisateur |

### 🧠 Coach (`/coach`)
| Méthode | Route         | Description |
|--------|---------------|-------------|
| GET    | `/coach/`     | Liste complète des coachs |
| GET    | `/coach/{id}` | Détails d’un coach |
| POST   | `/coach/create` | Créer un nouveau coach |
| PUT    | `/coach/edit` | Modifier un coach existant |
| DELETE | `/coach/delete` | Supprimer un coach |

### 🪴 Habitudes (`/habits`)
| Méthode | Route                         | Description |
|--------|-------------------------------|-------------|
| GET    | `/habits/`                    | Liste des habitudes |
| GET    | `/habits/{id}`                | Détails d’une habitude |
| POST   | `/habits/create`              | Créer une nouvelle habitude |
| PUT    | `/habits/{id}/edit`           | Modifier une habitude |
| DELETE | `/habits/{id}/delete`         | Supprimer une habitude |
| GET    | `/habits/{id}/stats`          | Statistiques de progression |

### 🌟 Objectifs (`/habits/{habitude_id}/objectifs`)
| Méthode | Route                                                                 | Description |
|--------|------------------------------------------------------------------------|-------------|
| GET    | `/habits/{hid}/objectifs/`                                            | Liste des objectifs d’une habitude |
| GET    | `/habits/{hid}/objectifs/{oid}`                                       | Détails d’un objectif |
| POST   | `/habits/{hid}/objectifs/create`                                      | Créer un objectif |
| PUT    | `/habits/{hid}/objectifs/{oid}/edit`                                  | Modifier un objectif |
| DELETE | `/habits/{hid}/objectifs/{oid}/delete`                                | Supprimer un objectif |
| POST   | `/habits/{hid}/objectifs/{oid}/addprogress`                           | Ajouter une progression (calcul du score) |

---

> ✨ Application multilingue, orientée utilisateur, évolutive et facilement extensible.

